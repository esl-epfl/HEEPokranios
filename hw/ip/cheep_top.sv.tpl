// Copyright 2022 EPFL and Politecnico di Torino.
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
//
// File: cheep-top.sv
// Author: Juan Sapriza
// Date: 02/2026
// Description: cheep top-level module

`include "analog_defs.svh"
import analog_defs::analog_type;

<%!
    from cheep_pad_defs import Antenna
    from x_heep_gen.pads.pin import Input, Output, Inout, PinDigital, Asignal
%>
<%
    cheep = xheep.get_extension('cheep')
    ext_peripherals = cheep['ext_peripherals']
    attribute_bits = xheep.get_padring().attributes.get("bits")
    any_muxed_pads = xheep.get_padring().num_muxed_pads() > 0
    analog_signal_pads = [ pad for pad in xheep.get_padring().pad_list if any( (isinstance(pin, Asignal) or isinstance(pin, Antenna)) for pin in pad.pins) ]
%>


module cheep_top (

    output logic debug_manual_start_o,

    // These are bonded directly into the macro
    input  `analog_t wpdt_ant_p_io,
    input  `analog_t wpdt_ant_n_io,

<%
    padlist = [ pad for pad in xheep.get_padring().pad_list if len(pad.pins) > 0 ]
    unique_padlist = [padlist[0]]
    for pad in padlist:
        if pad not in unique_padlist: unique_padlist.append(pad)
%>
    % for pad in unique_padlist:
<%
has_input_pin = any(isinstance(pin, Input) for pin in pad.pins)
has_output_pin = any(isinstance(pin, Output) for pin in pad.pins)
has_inout_pin = any(isinstance(pin, Inout) for pin in pad.pins)

#if not (has_input_pin or has_output_pin or has_inout_pin): continue
pin0_name = pad.attributes.get("custom_name") if pad.attributes.get("custom_name") else pad.pins[0].rtl_name()
muxed_string = "_muxed" if pad.is_muxed() else ""
%>\
    % if has_inout_pin or (has_input_pin and has_output_pin):
    inout wire ${pin0_name}io,
    % elif has_input_pin:
    inout wire ${pin0_name}i,
    % elif has_output_pin:
    inout wire ${pin0_name}o,
    % endif
    % endfor

% if len(analog_signal_pads)>0:
  // USE THESE NETS TO CONNECT TO YOUR ANALOG BLOCKS
    % for pad in analog_signal_pads:
    ${"output" if pad.pins[0].attributes.get("output") == True else "input"} `analog_t ${pad.name.lower()}_io${"" if loop.last else ","}
    % endfor
%endif


);
  import obi_pkg::*;
  import reg_pkg::*;
  import cheep_pkg::*;
  import core_v_mini_mcu_pkg::*;
  import analog_defs::*;

  // PARAMETERS
  localparam int unsigned ExtXbarNmasterRnd = (cheep_pkg::ExtXbarNMaster > 0) ?
    cheep_pkg::ExtXbarNMaster : 32'd1;
  localparam int unsigned ExtDomainsRnd = core_v_mini_mcu_pkg::EXTERNAL_DOMAINS == 0 ?
    32'd1 : core_v_mini_mcu_pkg::EXTERNAL_DOMAINS;

  // INTERNAL SIGNALS
  // ----------------
  // Synchronized reset
  logic rst_nin_sync;

  // System clock
  logic system_clk;


  // X-HEEP external master ports
  obi_req_t  heep_core_instr_req;
  obi_resp_t heep_core_instr_rsp;
  obi_req_t  heep_core_data_req;
  obi_resp_t heep_core_data_rsp;
  obi_req_t  heep_debug_master_req;
  obi_resp_t heep_debug_master_rsp;
  obi_req_t  [DMA_NUM_MASTER_PORTS-1:0] heep_dma_read_req;
  obi_resp_t [DMA_NUM_MASTER_PORTS-1:0] heep_dma_read_rsp;
  obi_req_t  [DMA_NUM_MASTER_PORTS-1:0] heep_dma_write_req;
  obi_resp_t [DMA_NUM_MASTER_PORTS-1:0] heep_dma_write_rsp;
  obi_req_t  [DMA_NUM_MASTER_PORTS-1:0] heep_dma_addr_req;
  obi_resp_t [DMA_NUM_MASTER_PORTS-1:0] heep_dma_addr_rsp;

  // X-HEEP slave ports
  obi_req_t  [ExtXbarNmasterRnd-1:0] heep_slave_req;
  obi_resp_t [ExtXbarNmasterRnd-1:0] heep_slave_rsp;

  // External master ports
  obi_req_t  [ExtXbarNmasterRnd-1:0] cheep_master_req;
  obi_resp_t [ExtXbarNmasterRnd-1:0] cheep_master_resp;

  // X-HEEP external peripheral master ports
  reg_req_t heep_peripheral_req;
  reg_rsp_t heep_peripheral_rsp;

  // PLIC interrupt vector
  logic [core_v_mini_mcu_pkg::NEXT_INT-1:0] ext_int_vector;

    // FIC interrupt
  logic intr_ext_peripheral;

  // Power Manager signals
  logic cpu_subsystem_powergate_switch_n;
  logic cpu_subsystem_powergate_switch_ack_n;
  logic peripheral_subsystem_powergate_switch_n;
  logic peripheral_subsystem_powergate_switch_ack_n;

  // External SPC interface signals
  logic [DMACHNum-1:0] dma_busy;

  // Pad controller
  reg_req_t pad_req;
  reg_rsp_t pad_rsp;

  // SPI slave CS
  logic spi_slave_cs_int;
  logic spi_slave_cs;
  logic spi_slave_enable;


  // Signal to let the system know that the CPU will take over the muxing of the pads
  logic dmux_cpu_sel;
  // Just for debug (to notify the tb that the CPU is under control of the tests from now on)
  assign debug_manual_start_o = dmux_cpu_sel;

  % if attribute_bits != None:
  logic [core_v_mini_mcu_pkg::NUM_PAD-1:0][${attribute_bits}] pad_attributes;
  % endif
  % if any_muxed_pads:
  logic [core_v_mini_mcu_pkg::NUM_PAD-1:0][${xheep.get_padring().get_muxed_pad_select_width()-1}:0] pad_muxes;
  % endif

  // External power domains
  logic [ExtDomainsRnd-1:0] external_subsystem_powergate_switch_n;
  logic [ExtDomainsRnd-1:0] external_subsystem_powergate_switch_ack_n;
  logic [ExtDomainsRnd-1:0] external_subsystem_powergate_iso_n;

  // External RAM banks retentive mode control
  logic [ExtDomainsRnd-1:0] external_ram_banks_set_retentive_n;

  // External domains reset
  logic [ExtDomainsRnd-1:0] external_subsystem_rst_n;

  // External domains clock-gating
  logic [ExtDomainsRnd-1:0] external_subsystem_clkgate_en_n;

  // External peripherals register interfaces
% for name, conf in ext_peripherals.items():
  <%
    p_name = name.lower()
    # Check direction. Default to 'hrw' (generate both) if missing.
    direction = conf.get('register_direction', 'hrw')
  %>
  % if direction in ['hrw', 'hro']:
  reg_req_t ${p_name}_req;
  % endif
  % if direction in ['hrw', 'hwo']:
  reg_rsp_t ${p_name}_rsp;
  % endif
% endfor

  // DMA control signals
  logic [core_v_mini_mcu_pkg::DMA_CH_NUM-1:0] ext_dma_slot_tx;
  logic [core_v_mini_mcu_pkg::DMA_CH_NUM-1:0] ext_dma_slot_rx;

  logic ext_debug_req;
  logic ext_debug_reset_n;

/* verilator lint_off UNUSED */
/* verilator lint_off UNDRIVEN */

  fifo_pkg::fifo_req_t  [core_v_mini_mcu_pkg::DMA_CH_NUM-1:0] ext_read_fifo_req;
  fifo_pkg::fifo_resp_t [core_v_mini_mcu_pkg::DMA_CH_NUM-1:0] ext_read_fifo_resp;
  logic [core_v_mini_mcu_pkg::DMA_CH_NUM-1:0][core_v_mini_mcu_pkg::DMA_EXT_READ_FIFO_ID_BITS-1:0] ext_read_fifo_req_id;

  logic [core_v_mini_mcu_pkg::DMA_CH_NUM-1:0] hw_fifo_done;
  fifo_pkg::fifo_req_t  [core_v_mini_mcu_pkg::DMA_CH_NUM-1:0] hw_fifo_req;
  fifo_pkg::fifo_resp_t [core_v_mini_mcu_pkg::DMA_CH_NUM-1:0] hw_fifo_resp;

  assign hw_fifo_resp [core_v_mini_mcu_pkg::DMA_CH_NUM-1:1] = '0;

    logic ch_0_dlc_done;
    logic ch_3_dlc_done;

  assign hw_fifo_done[0] = ch_0_dlc_done | ch_3_dlc_done;

/* verilator lint_on UNUSED */
/* verilator lint_on UNDRIVEN */

  // Tie the CV-X-IF coprocessor signals to a default value that will
  // receive petitions but reject all offloaded instructions
  // CV-X-IF is unused in core-v-mini-mcu as it has the cv32e40p CPU
  if_xif #() ext_if ();

  assign ext_if.compressed_ready = 1'b1;
  assign ext_if.compressed_resp  = '0;

  assign ext_if.issue_ready      = 1'b1;
  assign ext_if.issue_resp       = '0;

  assign ext_if.mem_valid        = 1'b0;
  assign ext_if.mem_req          = '0;

  assign ext_if.result_valid     = 1'b0;
  assign ext_if.result           = '0;

  // --------------
  // SYSTEM MODULES
  // --------------

<%
  unique_pins = []
%>

  % for pad in xheep.get_padring().pad_list:
    % for pin in pad.pins:
    <%
      if pin.name not in unique_pins: unique_pins.append(pin.name)
      else: continue
    %>\
      % if isinstance(pin, PinDigital):
  logic ${pin.rtl_name()}in_x, ${pin.rtl_name()}out_x, ${pin.rtl_name()}oe_x;
      % endif
    % endfor
      % if len(pad.pins) > 1 and any( isinstance(pin, PinDigital) for pin in pad.pins ):
      <%
      pin0_name = pad.attributes.get("custom_name") if pad.attributes.get("custom_name") else pad.pins[0].rtl_name()
      %>
  logic ${pin0_name}in_x_muxed, ${pin0_name}out_x_muxed, ${pin0_name}oe_x_muxed;
      %endif
  % endfor

// Select the CS of the SPI from either inside (the wpdt2ser) or outside (an actual SPI device)
 assign spi_slave_cs = (~spi_slave_enable) | spi_slave_cs_ext_in_x | spi_slave_cs_int;

// This is just to have a pin that can serve as a placeholder while you dont add a pin into the padring
assign dummy_7_out_x  = 1'b0;
assign dummy_9_out_x  = 1'b0;

heartbeat u_heartbeat (
    .clk_i(clk_in_x),
    .rst_ni(rst_nin_sync),
    .alive_i(dmux_cpu_sel),
    .heartbeat_o(heartbeat_out_x)
);


  // CORE-V-MINI-MCU (microcontroller)
  // ---------------------------------
  core_v_mini_mcu #(
    .EXT_XBAR_NMASTER(ExtXbarNMaster),
    .EXT_HARTS       (1)
  ) u_core_v_mini_mcu (

    .rst_ni (rst_nin_sync),
    .clk_i  (system_clk),

    .hart_id_i('0),
    .xheep_instance_id_i('0),

    // MCU pads
    % for pin in xheep.get_padring().get_connected_pins():
      % if pin.module == "core_v_mini_mcu":
        % if isinstance(pin, (Input, Inout)):
    .${pin.rtl_name()}i(${pin.rtl_name()}in_x),
        % endif
        % if isinstance(pin, (Output, Inout)):
    .${pin.rtl_name()}o(${pin.rtl_name()}out_x),
        % endif
        % if isinstance(pin, Inout):
    .${pin.rtl_name()}oe_o(${pin.rtl_name()}oe_x),
        % endif
      % endif
    % endfor

    .spi_slave_cs_i(spi_slave_cs),

    // CORE-V eXtension Interface
    .xif_compressed_if (ext_if.cpu_compressed),
    .xif_issue_if      (ext_if.cpu_issue),
    .xif_commit_if     (ext_if.cpu_commit),
    .xif_mem_if        (ext_if.cpu_mem),
    .xif_mem_result_if (ext_if.cpu_mem_result),
    .xif_result_if     (ext_if.cpu_result),

    // Pad controller interface
    .pad_req_o  (pad_req),
    .pad_resp_i (pad_rsp),

    // External slave ports
    .ext_xbar_master_req_i (heep_slave_req),
    .ext_xbar_master_resp_o (heep_slave_rsp),

    // External master ports
    .ext_core_instr_req_o (heep_core_instr_req),
    .ext_core_instr_resp_i (heep_core_instr_rsp),
    .ext_core_data_req_o (heep_core_data_req),
    .ext_core_data_resp_i (heep_core_data_rsp),
    .ext_debug_master_req_o (heep_debug_master_req),
    .ext_debug_master_resp_i (heep_debug_master_rsp),
    .ext_dma_read_req_o (heep_dma_read_req),
    .ext_dma_read_resp_i (heep_dma_read_rsp),
    .ext_dma_write_req_o (heep_dma_write_req),
    .ext_dma_write_resp_i (heep_dma_write_rsp),
    .ext_dma_addr_req_o (heep_dma_addr_req),
    .ext_dma_addr_resp_i (heep_dma_addr_rsp),

    // External peripherals slave ports
    .ext_peripheral_slave_req_o  (heep_peripheral_req),
    .ext_peripheral_slave_resp_i (heep_peripheral_rsp),

    // SPC signals
    .ext_ao_peripheral_slave_req_i('0),
    .ext_ao_peripheral_slave_resp_o(),

    // Power switches connected by the backend
    .cpu_subsystem_powergate_switch_no            (cpu_subsystem_powergate_switch_n),
    .cpu_subsystem_powergate_switch_ack_ni        (cpu_subsystem_powergate_switch_ack_n),
    .peripheral_subsystem_powergate_switch_no     (peripheral_subsystem_powergate_switch_n),
    .peripheral_subsystem_powergate_switch_ack_ni (peripheral_subsystem_powergate_switch_ack_n),

    .external_subsystem_powergate_switch_no(external_subsystem_powergate_switch_n),
    .external_subsystem_powergate_switch_ack_ni(external_subsystem_powergate_switch_ack_n),
    .external_subsystem_powergate_iso_no(external_subsystem_powergate_iso_n),

    // Control signals for external peripherals
    .external_subsystem_rst_no (external_subsystem_rst_n),
    .external_ram_banks_set_retentive_no (external_ram_banks_set_retentive_n),
    .external_subsystem_clkgate_en_no (external_subsystem_clkgate_en_n),

    // External interrupts
    .intr_vector_ext_i (ext_int_vector),
    .intr_ext_peripheral_i(intr_ext_peripheral), // TODO_heepokranios: maybe add some other alternatives here

    .ext_dma_slot_tx_i(ext_dma_slot_tx),
    .ext_dma_slot_rx_i(ext_dma_slot_rx),

    .ext_debug_req_o(ext_debug_req),
    .ext_debug_reset_no(ext_debug_reset_n),
    .ext_cpu_subsystem_rst_no(),

    .ext_dma_stop_i('0),
    .dma_done_o(dma_busy),

    .ext_read_fifo_req_i(ext_read_fifo_req),
    .ext_read_fifo_resp_o(ext_read_fifo_resp),
    .ext_read_fifo_req_id_i(ext_read_fifo_req_id),

    .hw_fifo_done_i(hw_fifo_done),
    .hw_fifo_req_o(hw_fifo_req),
    .hw_fifo_resp_i(hw_fifo_resp),

    .exit_value_o ()
  );

  assign cpu_subsystem_powergate_switch_ack_n = cpu_subsystem_powergate_switch_n;
  assign peripheral_subsystem_powergate_switch_ack_n = peripheral_subsystem_powergate_switch_n;

  // DMA DAC ext slots
  assign ext_dma_slot_rx[1] = '0;
  assign ext_dma_slot_tx[0] = '0;

  // External peripherals bus
  // ------------------------
  cheep_bus u_cheep_bus (
    .clk_i                        (system_clk),
    .rst_ni                       (rst_nin_sync),

    // Automatically added register interface
% for name, conf in ext_peripherals.items():
  <%
    p_name = name.lower()
    direction = conf.get('register_direction', 'hrw')
  %>\
    % if direction in ['hrw', 'hro']:
  .${p_name}_req_o(${p_name}_req),
    % endif
    % if direction in ['hrw', 'hwo']:
    .${p_name}_rsp_i(${p_name}_rsp),
    % endif
% endfor

    .heep_core_instr_req_i        (heep_core_instr_req),
    .heep_core_instr_resp_o       (heep_core_instr_rsp),

    .heep_core_data_req_i         (heep_core_data_req),
    .heep_core_data_resp_o        (heep_core_data_rsp),

    .heep_debug_master_req_i      (heep_debug_master_req),
    .heep_debug_master_resp_o     (heep_debug_master_rsp),

    .heep_dma_read_req_i          (heep_dma_read_req),
    .heep_dma_read_resp_o         (heep_dma_read_rsp),
    .heep_dma_write_req_i         (heep_dma_write_req),
    .heep_dma_write_resp_o        (heep_dma_write_rsp),
    .heep_dma_addr_req_i          (heep_dma_addr_req),
    .heep_dma_addr_resp_o         (heep_dma_addr_rsp),

    .cheep_master_req_i           (cheep_master_req),
    .cheep_master_resp_o          (cheep_master_resp),

    .heep_slave_req_o             (heep_slave_req),
    .heep_slave_resp_i            (heep_slave_rsp),

    .heep_periph_req_i            (heep_peripheral_req),
    .heep_periph_resp_o           (heep_peripheral_rsp)

  );


//   assign exit_value_out_x = exit_value[0];

 // Pad ring
  // --------
  pad_ring pad_ring_i (
    % for pad in xheep.get_padring().pad_list:
<%
has_input_pin = any(isinstance(pin, Input) for pin in pad.pins)
has_output_pin = any(isinstance(pin, Output) for pin in pad.pins)
has_inout_pin = any(isinstance(pin, Inout) for pin in pad.pins)

if not (has_input_pin or has_output_pin or has_inout_pin): continue
pin0_name = pad.attributes.get("custom_name") if pad.attributes.get("custom_name") else pad.pins[0].rtl_name()
muxed_string = "_muxed" if pad.is_muxed() else ""
%>\
    % if has_inout_pin or (has_input_pin and has_output_pin):
    .${pin0_name}i(${pin0_name}out_x${muxed_string}),
    .${pin0_name}oe_i(${pin0_name}oe_x${muxed_string}),
    .${pin0_name}o(${pin0_name}in_x${muxed_string}),
    .${pin0_name}io(${pin0_name}io),
    % elif has_input_pin:
    .${pin0_name}o(${pin0_name}in_x${muxed_string}),
    .${pin0_name}io(${pin0_name}i),
    % elif has_output_pin:
    .${pin0_name}i(${pin0_name}out_x${muxed_string}),
    .${pin0_name}io(${pin0_name}o),
    % endif
    % endfor

    % if len(analog_signal_pads)>0:
        % for pad in analog_signal_pads:
        % if not any( isinstance(pin, Antenna) for pin in pad.pins):
            .${pad.name.lower()}_io,
        % endif
        % endfor
    %endif

    % if attribute_bits != None:
        .pad_attributes_i(pad_attributes)
    % else:
        .pad_attributes_i('0)
    % endif
  );

// Hardcode pad cell directions if they are not inout
% for pin in {pin for pad in xheep.get_padring().pad_list for pin in pad.pins}:
  % if isinstance(pin, Input):
    assign ${pin.rtl_name()}out_x = 1'b0;
    assign ${pin.rtl_name()}oe_x = 1'b0;
  % endif
  % if isinstance(pin, Output):
    assign ${pin.rtl_name()}oe_x = 1'b1;
  % endif
% endfor

  // PAD MULTIPLEXERS
  logic dmux_sel_0_sync, dmux_sel_1_sync;
  always_ff @(posedge clk_in_x or negedge rst_nin_sync) begin
    if (!rst_nin_sync) begin
      dmux_sel_0_sync <= 1'b0;
      dmux_sel_1_sync <= 1'b0;
    end else begin
      dmux_sel_0_sync <= dmux_sel_0_in_x;
      dmux_sel_1_sync <= dmux_sel_1_in_x;
    end
  end


% for pad in [pad for pad in xheep.get_padring().pad_list if pad.is_muxed() and any(isinstance(pin, PinDigital) for pin in pad.pins)]:
<% pin0_name = pad.attributes.get("custom_name") if pad.attributes.get("custom_name") else pad.pins[0].rtl_name() %>\
  logic [2:0] mux_sel_${pad.name.lower()};
  assign mux_sel_${pad.name.lower()} = dmux_cpu_sel ? pad_muxes[core_v_mini_mcu_pkg::PAD_${pad.name.upper()}] : {1'b0, dmux_sel_1_sync, dmux_sel_0_sync};

  always_comb
  begin
    % for pin in pad.pins:
        ${pin.rtl_name()}in_x = 1'b0;
    % endfor
    ${pin0_name}out_x_muxed = 1'b0;
    ${pin0_name}oe_x_muxed  = 1'b0;

    unique case(mux_sel_${pad.name.lower()})
      % for idx, pin in enumerate(pad.pins):
        ${idx}: begin
          <% pinidx_name = pin.rtl_name() %>
          ${pin0_name}out_x_muxed = ${pinidx_name}out_x;
          ${pin0_name}oe_x_muxed  = ${pinidx_name}oe_x;
          ${pinidx_name}in_x        = ${pin0_name}in_x_muxed;
        end
      % endfor
      default: begin
        ${pin0_name}out_x_muxed = ${pad.pins[0].rtl_name()}out_x;
        ${pin0_name}oe_x_muxed  = ${pad.pins[0].rtl_name()}oe_x;
        ${pad.pins[0].rtl_name()}in_x        = ${pin0_name}in_x_muxed;
      end
    endcase
  end

% endfor



  // Pad control
  // -----------
  pad_control #(
      .reg_req_t(reg_pkg::reg_req_t),
      .reg_rsp_t(reg_pkg::reg_rsp_t),
      .NUM_PAD  (core_v_mini_mcu_pkg::NUM_PAD)
  ) pad_control_i (
      .clk_i(clk_in_x),
      .rst_ni(rst_nin_sync),
      .reg_req_i(pad_req),
      .reg_rsp_o(pad_rsp)${"," if any_muxed_pads or attribute_bits != None else ""}
      % if attribute_bits != None:
      .pad_attributes_o(pad_attributes)${"," if any_muxed_pads else ""}
      % endif
      % if any_muxed_pads:
      .pad_muxes_o(pad_muxes)
      % endif
  );


  // Reset generator
  // ---------------
  rstgen u_rstgen (
    .clk_i      (clk_in_x),
    .rst_ni     (rst_nin_x),
    .test_mode_i(1'b0 ), // not implemented
    .rst_no     (rst_nin_sync),
    .init_no    () // unused
  );

// ----------------------------------------
// vvvvv Custom stuff goes down here vvvvv

    logic [7:0] output_byte;
    assign output_byte_0_out_x = output_byte[0];
    assign output_byte_1_out_x = output_byte[1];
    assign output_byte_2_out_x = output_byte[2];
    assign output_byte_3_out_x = output_byte[3];
    assign output_byte_4_out_x = output_byte[4];
    assign output_byte_5_out_x = output_byte[5];
    assign output_byte_6_out_x = output_byte[6];
    assign output_byte_7_out_x = output_byte[7];

    assign dmux_report_0_out_x = mux_sel_dmux_io_0[0];
    assign dmux_report_1_out_x = mux_sel_dmux_io_0[1];

// -----------------------------------------
//   DMA control


    logic dma_ext_trigger_meta;
    logic dma_ext_trigger_sync;
    logic dma_ext_trigger_sync_d;

    logic dma_ext_trigger_pulse;

    always_ff @(posedge system_clk or negedge rst_nin_sync) begin
        if (!rst_nin_sync) begin
            dma_ext_trigger_meta   <= 1'b0;
            dma_ext_trigger_sync   <= 1'b0;
            dma_ext_trigger_sync_d <= 1'b0;
        end else begin
            // 2-flop synchronizer, useful if dma_ext_trigger_in_x is asynchronous
            dma_ext_trigger_meta   <= dma_ext_trigger_in_x;
            dma_ext_trigger_sync   <= dma_ext_trigger_meta;

            // previous-cycle value
            dma_ext_trigger_sync_d <= dma_ext_trigger_sync;
        end
    end

    assign dma_ext_trigger_pulse = dma_ext_trigger_sync & ~dma_ext_trigger_sync_d;


    logic channels_data_available;
     // Let the DMA 0 read from the channels only when new data is available
  assign ext_dma_slot_rx[0] = channels_data_available;

    // Let the DMA 1 write data only when triggered by a timer or external trigger
  assign ext_dma_slot_tx[1] =  dma_ext_trigger_pulse;

  // External peripherals
  // --------------------
  cheep_peripherals u_cheep_peripherals(
    .ref_clk_i              (clk_in_x),
    .rst_ni                 (rst_nin_sync),
    .system_clk_o           (system_clk),

    // Automatically added register interfaces
% for name, conf in ext_peripherals.items():
  <%
    p_name = name.lower()
    direction = conf.get('register_direction', 'hrw')
  %>\
    % if direction in ['hrw', 'hro']:
  .${p_name}_req_i(${p_name}_req),
    % endif
    % if direction in ['hrw', 'hwo']:
    .${p_name}_rsp_o(${p_name}_rsp),
    % endif
% endfor

    % if len(analog_signal_pads)>0:
  // USE THESE NETS TO CONNECT TO YOUR ANALOG BLOCKS
    % for pad in analog_signal_pads:
        %if pad.pins[0].module == "cheep_peripherals":
            .${pad.name.lower()}_io,
        %endif
    % endfor
    %endif

    .output_byte_o(output_byte),

    .dmux_cpu_sel_o(dmux_cpu_sel),

    // Manually copied and assigned digital pins

    // WPDT
    .wpdt_ref_clk_o(wpdt_ref_clk_out_x),
    .wpdt_scko_o(wpdt_scko_out_x),
    .wpdt_sdi_i(wpdt_sdi_in_x),
    .wpdt_scki_i(wpdt_scki_in_x),

    .wpdt_ant_p_io,
    .wpdt_ant_n_io,

    // WPDT 2 serial
    .wpdt2ser_sdo_o(wpdt2ser_sdo_out_x),
    .wpdt2ser_scko_o(wpdt2ser_scko_out_x),
    .wpdt2ser_cs_o(spi_slave_cs_int),

    .spi_slave_enable_o(spi_slave_enable),

    // reg2ser
    .reg2ser_sdo_o(reg2ser_sdo_out_x),
    .reg2ser_scko_o(reg2ser_scko_out_x),
    .reg2ser_scki_i(reg2ser_scki_in_x),

    // Channel 0
    .ch_0_bpe_pwm_0_i(ch_0_bpe_pwm_0_in_x),
    .ch_0_bpe_pwm_1_i(ch_0_bpe_pwm_1_in_x),
    .ch_0_bpe_pwm_2_i(ch_0_bpe_pwm_2_in_x),
    .ch_0_bpe_pwm_3_i(ch_0_bpe_pwm_3_in_x),
    .ch_0_bpe_comp_p_o(ch_0_bpe_comp_p_out_x),
    .ch_0_bpe_comp_n_o(ch_0_bpe_comp_n_out_x),
    .ch_0_dsm_clk_in_i(ch_0_dsm_clk_in_in_x),
    .ch_0_dsm_clk_out_o(ch_0_dsm_clk_out_out_x),
    .ch_0_dsm_out_o(ch_0_dsm_out_out_x),
    .ch_0_dec_in_i(ch_0_dec_in_in_x),

    // PWM
    .ch_0_bpe_pwm_0_out_o(ch_0_bpe_pwm_0_out_out_x),
    .ch_0_bpe_pwm_1_out_o(ch_0_bpe_pwm_1_out_out_x),
    .ch_0_bpe_pwm_2_out_o(ch_0_bpe_pwm_2_out_out_x),
    .ch_0_bpe_pwm_3_out_o(ch_0_bpe_pwm_3_out_out_x),

    // PDVCO
    .ch_0_vco_n_out_o(ch_0_vco_n_out_out_x),
    .ch_0_vco_p_out_o(ch_0_vco_p_out_out_x),

    // dLC
    .ch_0_dlc_xing_o    (ch_0_dlc_xing_out_x),
    .ch_0_dlc_dir_o     (ch_0_dlc_dir_out_x),
    .ch_0_dlc_done_o    (ch_0_dlc_done),

    // Channel 1
    .ch_1_dsm_clk_in_i(ch_1_dsm_clk_in_in_x),
    .ch_1_dsm_clk_out_o(ch_1_dsm_clk_out_out_x),
    .ch_1_dsm_out_o(ch_1_dsm_out_out_x),
    .ch_1_dec_in_i(ch_1_dec_in_in_x),

    // Channels 2, 3, 4
    .ch_2_vco_out_o(ch_2_vco_out_out_x),
    .ch_3_vco_out_o(ch_3_vco_out_out_x),
    .ch_4_vco_out_o(ch_4_vco_out_out_x),

    .ch_3_lc_dir_o(ch_3_lc_dir_out_x),
    .ch_3_lc_xing_o(ch_3_lc_xing_out_x),
    .ch_3_lc_discharge_o(ch_3_lc_discharge_out_x),
    .ch_3_dlc_done_o    (ch_3_dlc_done),

    .ch_2_lc_dir_o(ch_2_lc_dir_out_x),
    .ch_2_lc_xing_o(ch_2_lc_xing_out_x),
    .ch_2_lc_discharge_o(ch_2_lc_discharge_out_x),
    .ch_4_lc_dir_o(ch_4_lc_dir_out_x),
    .ch_4_lc_xing_o(ch_4_lc_xing_out_x),
    .ch_4_lc_discharge_o(ch_4_lc_discharge_out_x),

    .data_available_o(channels_data_available),
    .intr_ext_peripheral_o(intr_ext_peripheral),
    .ext_int_vector_o     (ext_int_vector),

    // DMA EXT FIFO int
    .ext_read_fifo_req_o(ext_read_fifo_req),
    .ext_read_fifo_resp_i(ext_read_fifo_resp),
    .ext_read_fifo_req_id_o(ext_read_fifo_req_id)

  );

endmodule // cheep_top
