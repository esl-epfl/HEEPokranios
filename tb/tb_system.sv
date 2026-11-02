// Copyright 2022 EPFL and Politecnico di Torino.
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
//
// File: tb_system.sv
// Author: Michele Caon
// Date: 15/06/2023
// Description: cheep testbench system

`include "analog_defs.svh"
import analog_defs::analog_type;

`ifndef VERILATOR
typedef logic signed [31:0] analog_tb_type;
`define analog_tb_t analog_tb_type
`endif

module tb_system #(
    parameter int unsigned CLK_FREQ = 32'd100_000  // kHz
) (
    inout wire ref_clk_i,
    inout wire rst_ni,

    // Static configuration
    inout wire boot_select_i,
    inout wire execute_from_flash_i,

    inout wire jtag_tck_i,
    inout wire jtag_tms_i,
    inout wire jtag_trst_ni,
    inout wire jtag_tdi_i,
    inout wire jtag_tdo_o,

    // Exit signals
    inout wire        exit_valid_o,
    inout wire [31:0] exit_value_o
);
  // Include testbench utils
  `include "tb_util.svh"

  // INTERNAL SIGNALS
  // ----------------

  // UART
  wire cheep_uart_tx;
  wire cheep_uart_rx;

  // GPIO
  wire gpio;

`ifndef VERILATOR
  // Pull-up/down are needed in Questasim
  // This feature will be supported in Verilator 5.
  // For Verilator 4 and below, this is actually not needed.
  // SPI flash
  tri0 spi_slave_sck;
  tri0 spi_slave_mosi;
  tri0 spi_slave_miso;

`else
  wire spi_slave_sck;
  wire spi_slave_mosi;
  wire spi_slave_miso;

`endif


  // UART DPI emulator
  uartdpi #(
      .BAUD(CLK_FREQ * 1000 / 20),
      .FREQ(CLK_FREQ * 1000),  // Hz
      .NAME("uart")
  ) u_uartdpi (
      .clk_i (u_cheep_top.u_cheep_peripherals.system_clk_o),
      .rst_ni(rst_ni),
      .tx_o  (cheep_uart_rx),
      .rx_i  (cheep_uart_tx)
  );


`ifdef USE_PG_PIN
  supply1 VDD;
  supply0 VSS;
`endif

`ifdef RTL_SIMULATION

  localparam int unsigned SwitchAckLatency = 45;

  //pretending to be SWITCH CELLs that delay by SwitchAckLatency cycles the ACK signal
  // This is done only for HEEP memories as CPU and Peripherals ACKs are hardwired in CHEEP top level
  // and Carus and CGRAs memories simulation models delay the ACK signal by 1 cycles

  logic [core_v_mini_mcu_pkg::NUM_BANKS-1:0] tb_memory_subsystem_banks_powergate_switch_ack_n[SwitchAckLatency+1];
  logic [core_v_mini_mcu_pkg::NUM_BANKS-1:0] delayed_tb_memory_subsystem_banks_powergate_switch_ack_n;

  always_ff @(negedge u_cheep_top.u_cheep_peripherals.system_clk_o) begin
    tb_memory_subsystem_banks_powergate_switch_ack_n[0] <= u_cheep_top.u_core_v_mini_mcu.memory_subsystem_banks_powergate_switch_n;
    for (int i = 0; i < SwitchAckLatency; i++) begin
      tb_memory_subsystem_banks_powergate_switch_ack_n[i+1] <= tb_memory_subsystem_banks_powergate_switch_ack_n[i];
    end
  end

  assign delayed_tb_memory_subsystem_banks_powergate_switch_ack_n = tb_memory_subsystem_banks_powergate_switch_ack_n[SwitchAckLatency];

  always_comb begin
`ifndef VERILATOR
    force u_cheep_top.u_core_v_mini_mcu.memory_subsystem_banks_powergate_switch_ack_n = delayed_tb_memory_subsystem_banks_powergate_switch_ack_n;
`else
    u_cheep_top.u_core_v_mini_mcu.memory_subsystem_banks_powergate_switch_ack_n = delayed_tb_memory_subsystem_banks_powergate_switch_ack_n;
`endif
  end

`endif

`ifdef POSTLAYOUT
`ifdef LOAD_SDF
  initial begin
    $sdf_annotate("../../../implementation/pnr/symlinks/common_pnr_build/cheep.sdf.gz", tb_top.u_tb_system.u_cheep_top,, "sdf.log", "TYPICAL",,);
  end
`endif
`endif

  /* verilator lint_off UNUSED */
  /* verilator lint_off UNDRIVEN */
  `analog_t ch_0_lna_vin_p;
  `analog_t ch_0_lna_vin_n;
  `analog_t ch_0_lna_vout_p;
  `analog_t ch_0_lna_vout_n;
  `analog_t ch_0_bpe_vout_p;
  `analog_t ch_0_bpe_vout_n;

  `analog_t ch_1_lna_vin_p;
  `analog_t ch_1_buff_vout_p;
  `analog_t ch_1_buff_vout_n;

  `analog_t ch_2_vco_vin;
  `analog_t ch_3_lna_vin;
  `analog_t ch_3_vin;
  `analog_t ch_4_vin;

  `analog_t iref_i;

  logic dmux_rst_ni;
  logic wpdt_modulated_data;

  `analog_t wpdt_generated_vdd;
  assign wpdt_generated_vdd = 1_000_000;

  /* verilator lint_on UNUSED */
  /* verilator lint_on UNDRIVEN */

  sinc_gen #(
      .LENGTH_N(5000)
  ) u_sinc_gen_p (
      .rst_ni(rst_ni),
      .refresh_i(ref_clk_i),
      .out_o(ch_0_lna_vin_p)
  );

  sinc_gen #(
      .LENGTH_N(7000)
  ) u_sinc_gen_n (
      .rst_ni(rst_ni),
      .refresh_i(ref_clk_i),
      .out_o(ch_0_lna_vin_n)
  );

  sinc_gen #(
      .LENGTH_N(3000)
  ) u_sinc_gen_1_p (
      .rst_ni(rst_ni),
      .refresh_i(ref_clk_i),
      .out_o(ch_1_lna_vin_p)
  );

  sinc_gen #(
      .LENGTH_N(2000)
  ) u_sinc_gen_2 (
      .rst_ni(rst_ni),
      .refresh_i(ref_clk_i),
      .out_o(ch_2_vco_vin)
  );

  sinc_gen #(
      .LENGTH_N(1000)
  ) u_sinc_gen_3 (
      .rst_ni(rst_ni),
      .refresh_i(ref_clk_i),
      .out_o(ch_3_lna_vin)
  );

  sinc_gen #(
      .LENGTH_N(5000)
  ) u_sinc_gen_4 (
      .rst_ni(rst_ni),
      .refresh_i(ref_clk_i),
      .out_o(ch_4_vin)
  );

  /* verilator lint_off UNOPTFLAT */
  /* verilator lint_off UNUSED */
  wire [7:0] dmux;
  wire [1:0] dmux_sel;
  /* verilator lint_on UNUSED */
  /* verilator lint_on UNOPTFLAT */

  WPDT_tx u_wpdt_tx (
      .ref_clk_i(ref_clk_i),
      .modulated_data_o(wpdt_modulated_data)
  );

`ifdef POSTSYNTHESIS_SIM
  `define POSTSYNTHESIS_OR_POSTLAYOUT_SIM
`endif

`ifdef POSTLAYOUT
  `define POSTSYNTHESIS_OR_POSTLAYOUT_SIM
`endif

`ifdef POSTSYNTHESIS_OR_POSTLAYOUT_SIM

  `analog_tb_t dsm_vin_p;
  `analog_tb_t dsm_vin_n;

  // sinc_gen #(
  //     .LENGTH_N(5000)
  // ) u_sinc_postsynth_gen_p (
  //     .rst_ni(rst_ni),
  //     .refresh_i(ref_clk_i),
  //     .out_o(dsm_vin_p)
  // );

  // sinc_gen #(
  //     .LENGTH_N(3000)
  // ) u_sinc_postsynth_gen_n (
  //     .rst_ni(rst_ni),
  //     .refresh_i(ref_clk_i),
  //     .out_o(dsm_vin_n)
  // );


  sin_gen #(
      .AMP(400_000),  // Single-ended peak amplitude: 0.2 V
      .VCM(500_000),  // Common-mode voltage: 0.5 V
      .FREQ_HZ(1000),
      .FS_HZ(1_000_000)
  ) sin (
      .rst_ni,
      .refresh_i(ref_clk_i),
      .out_p_o  (dsm_vin_p),
      .out_n_o  (dsm_vin_n)
  );


  DSM_tb u_DSM_tb (
      .bvdd           (`analog_tb_t'(1_000_000)),
      .avss           (`analog_tb_t'(0)),
      .vcm            (`analog_tb_t'(500_000)),
      .ibias          (`analog_tb_t'(1_000)),
      .vin_p          (dsm_vin_p),
      .vin_n          (dsm_vin_n),
      .fsm_en_ni      (1'b0),                      // ACTIVE LOW
      .resonator_en_ni(1'b0),                      // ACTIVE LOW
      .cap_sel_i      ('0),
      .lowpower_sel_i ('0),
      .lfp_en_i       (1'b0),                      // Mode 0 or 1
      .out_o          (dmux[1]),
      .dsm_en_ni      (1'b0),                      // ENABLE IS ACTIVE LOW
      .clk_i          (dmux[6]),
      .rst_i          (~rst_ni)                    // RESET IS ACTIVE HIGH!
  );

  assign dmux_sel_0  = 1'b1;
  assign dmux_sel[0] = 1'b1;
  assign dmux_sel[1] = 1'b0;

`else

  //   dmux_ctrl u_dmux_ctrl (
  //       .clk_i(ref_clk_i),
  //       .dmux(dmux),
  //       .dmux_sel(dmux_sel)
  //   );
  `analog_t dsm_vin_p;
  `analog_t dsm_vin_n;
  sin_gen #(
      .AMP(400_000),  // Single-ended peak amplitude: 0.2 V
      .VCM(500_000),  // Common-mode voltage: 0.5 V
      .FREQ_HZ(1000),
      .FS_HZ(1_000_000)
  ) sin (
      .rst_ni,
      .refresh_i(ref_clk_i),
      .out_p_o  (dsm_vin_p),
      .out_n_o  (dsm_vin_n)
  );


  DSM_tb u_DSM_tb (
      .bvdd           (`analog_t'(1_000_000)),
      .avss           (`analog_t'(0)),
      .vcm            (`analog_t'(500_000)),
      .ibias          (`analog_t'(1_000)),
      .vin_p          (dsm_vin_p),
      .vin_n          (dsm_vin_n),
      .fsm_en_ni      (1'b0),                   // ACTIVE LOW
      .resonator_en_ni(1'b0),                   // ACTIVE LOW
      .cap_sel_i      ('0),
      .lowpower_sel_i ('0),
      .lfp_en_i       (1'b0),                   // Mode 0 or 1
      .out_o          (dmux[1]),
      .dsm_en_ni      (1'b0),                   // ENABLE IS ACTIVE LOW
      .clk_i          (dmux[6]),
      .rst_i          (~rst_ni)                 // RESET IS ACTIVE HIGH!
  );


  assign dmux_sel[0] = 1'b1;
  assign dmux_sel[1] = 1'b0;

`endif

  // reg2ser_scki is selected from DMUX_IO_5 (dMUX selector 2). The
  // serializer expects an external source clock on that pad; its scko output
  // is only a gated copy of scki. Keep this testbench source in VCO mode so
  // DMUX_IO_5 receives ref_clk_i in both RTL and post-layout simulations.
  // The other dMUX pads remain high impedance in VCO mode.
  dmux_ctrl u_reg2ser_clock_driver (
      .clk_i(ref_clk_i),
      .dmux(dmux),
      .dmux_sel(2'b10)
  );

  // DUT
  // ---
  cheep_top u_cheep_top (
`ifdef USE_PG_PIN
      .VSS,
      .VDD,
`endif
      .clk_i               (ref_clk_i),
      .rst_ni              (rst_ni),
      .heartbeat_o         (),
      //   .exit_valid_o        (exit_valid_o),
      //   .exit_value_o        (exit_value_o[0]),
      .debug_manual_start_o(dmux_rst_ni),

      .wpdt_ant_p_io(32'(wpdt_modulated_data)),  // This is only for the sake
      .wpdt_ant_n_io(32'(ref_clk_i)),            // of the simulation (with behavioral models)

      .wpdt_ldo_vout_io(),

      .vref_0v5_unbuff_io(),
      .vref_0v5_buff_io(),
      .wpdt_ldo_vin_io(`analog_t'(500_000)),

      .vref_0v4_buff_io(),
      .vref_0v6_buff_io(),
      .vref_vin_io(`analog_t'(500_000)),  // 400mV Vcm for all analog blocks
      .vref_hvdd_io(`analog_t'(1_200_000)),
      .vref_en_io(`analog_t'(1_200_000)),

      .imirror_iin_io(iref_i),  // 1 uA in nA
      .imirror_iout_io(),
      .iref_iout_io(iref_i),
      .refs_vdd_io(1_000_000),

      .wpdt_rect_vout_io(),
      .wpdt_data_clk_vin_io(`analog_t'(600_000)),
      .wpdt_blocks_vin_io(`analog_t'(600_000)),

      .wpdt_ref_clk_o(),
      .wpdt_scko_o(),  // Clock recovered from data transmission (can be used as system clock???)
      .wpdt2ser_sdo_o(spi_slave_mosi),
      .wpdt2ser_scko_o(spi_slave_sck),

      .wpdt_sdi_i (dmux[2]),  // The input to these would be multiplexed
      .wpdt_scki_i(dmux[3]),

      .spi_slave_cs_ext_i(),
      .spi_slave_sck_i(spi_slave_sck),
      .spi_slave_mosi_i(spi_slave_mosi),
      .spi_slave_miso_o(spi_slave_miso),

      .ch_0_lna_vout_p_io (ch_0_lna_vout_p),
      .ch_0_lna_vout_n_io (ch_0_lna_vout_n),
      .ch_0_lna_vin_p_io  (ch_0_lna_vin_p),
      .ch_01_lna_vin_n_io (ch_0_lna_vin_n),
      .ch_0_lna_vdd_io    (wpdt_generated_vdd),
      .lna_vcm_vin_io     (`analog_t'(400_000)),                    // 400mV Vcm for the LNA
      .ch_0_bpe_vdd_io    (wpdt_generated_vdd),
      .ch_0_bpe_vin_p_io  (ch_0_lna_vout_p),
      .ch_0_bpe_vin_n_io  (ch_0_lna_vout_n),
      .ch_0_bpe_vout_p_io (ch_0_bpe_vout_p),
      .ch_0_bpe_vout_n_io (ch_0_bpe_vout_n),
      .ch_0_dsm_vin_p_io  (ch_0_bpe_vout_p),
      .ch_0_dsm_vin_n_io  (ch_0_bpe_vout_n),
      .ch_0_dsm_vdd_io    (wpdt_generated_vdd),
      .ch_0_pdvco_vdd_io  (wpdt_generated_vdd),
      .ch_0_pdvco_vin_p_io(`analog_t'(100_000) + ch_0_lna_vout_p),
      .ch_0_pdvco_vin_n_io(`analog_t'(100_000) + ch_0_lna_vout_n),

      .ch_1_vdd_io        (wpdt_generated_vdd),
      .ch_1_lna_vin_p_io  (ch_1_lna_vin_p),
      //   .ch_01_lna_vin_n_io  (ch_0_lna_vin_n),   // shared with CH 0
      .ch_1_buff_vout_p_io(ch_1_buff_vout_p),
      .ch_1_buff_vout_n_io(ch_1_buff_vout_n),
      .ch_1_dsm_vdd_io    (wpdt_generated_vdd),
      .ch_1_dsm_vin_p_io  (ch_1_buff_vout_p),
      .ch_1_dsm_vin_n_io  (ch_1_buff_vout_n),

      .ch_2_vco_vin_io  (ch_1_buff_vout_p),                    // Taken from Ch1
      .ch_3_lna_vin_io  (`analog_t'(500_000) + ch_3_lna_vin),
      .ch_3_buff_vout_io(ch_3_vin),
      .ch_3_vin_io      (`analog_t'(500_000) + ch_3_vin),
      .ch_4_vin_io      (),                                    //let this be an output because the iDAC is connected here
      .ch_234_vdd_io    (wpdt_generated_vdd),

      .ch_2_lc_vdd_io(),
      .ch_2_lc_vin_io(),

      .dmux_sel_0_io(dmux_sel[0]),
      .dmux_sel_1_io(dmux_sel[1]),
      .dmux_io_0_io (dmux[0]),        // <-.
      .dmux_io_1_io (dmux[1]),        // <-|-.
      .dmux_io_2_io (dmux[2]),        // <-|-|-.
      .dmux_io_3_io (dmux[3]),        // <-|-|-|-.
      .dmux_io_4_io (dmux[4]),        // --* | | |
      .dmux_io_5_io (dmux[5]),        // ----* | |
      .dmux_io_6_io (dmux[6]),        // ------* |
      .dmux_io_7_io (dmux[7]),        // --------*
      .jtag_tck_i   (jtag_tck_i),
      .jtag_tms_i   (jtag_tms_i),
      .jtag_trst_ni (jtag_trst_ni),
      .jtag_tdi_i   (jtag_tdi_i),
      .jtag_tdo_o   (jtag_tdo_o),
      .uart_rx_i    (cheep_uart_rx),
      .uart_tx_o    (cheep_uart_tx)

  );

  // Exit value
  assign exit_valid_o = u_cheep_top.u_core_v_mini_mcu.ao_peripheral_subsystem_i.exit_valid_o;
  assign exit_value_o = u_cheep_top.u_core_v_mini_mcu.exit_value_o;
endmodule
