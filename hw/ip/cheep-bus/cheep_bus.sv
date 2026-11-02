// Copyright 2022 EPFL and Politecnico di Torino.
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
//
// File: cheep_bus.sv
// Author: Michele Caon, Luigi Giuffrida
// Date: 29/04/2024
// Description: External bus for cheep



module cheep_bus #(
    // Dependent parameters: do not override!
    localparam int unsigned ExtXbarNmasterRnd = (cheep_pkg::ExtXbarNMaster > 0) ? cheep_pkg::ExtXbarNMaster : 32'd1
) (
    input logic clk_i,
    input logic rst_ni,

    // X-HEEP master ports
    input  obi_pkg::obi_req_t  heep_core_instr_req_i,
    output obi_pkg::obi_resp_t heep_core_instr_resp_o,

    input  obi_pkg::obi_req_t  heep_core_data_req_i,
    output obi_pkg::obi_resp_t heep_core_data_resp_o,

    input  obi_pkg::obi_req_t  heep_debug_master_req_i,
    output obi_pkg::obi_resp_t heep_debug_master_resp_o,

    input  obi_pkg::obi_req_t  [cheep_pkg::DMAMasterPortsNum-1:0] heep_dma_read_req_i,
    output obi_pkg::obi_resp_t [cheep_pkg::DMAMasterPortsNum-1:0] heep_dma_read_resp_o,

    input  obi_pkg::obi_req_t  [cheep_pkg::DMAMasterPortsNum-1:0] heep_dma_write_req_i,
    output obi_pkg::obi_resp_t [cheep_pkg::DMAMasterPortsNum-1:0] heep_dma_write_resp_o,

    input  obi_pkg::obi_req_t  [cheep_pkg::DMAMasterPortsNum-1:0] heep_dma_addr_req_i,
    output obi_pkg::obi_resp_t [cheep_pkg::DMAMasterPortsNum-1:0] heep_dma_addr_resp_o,

    // External master ports
    input  obi_pkg::obi_req_t  [ExtXbarNmasterRnd-1:0] cheep_master_req_i,
    output obi_pkg::obi_resp_t [ExtXbarNmasterRnd-1:0] cheep_master_resp_o,

    // X-HEEP slave ports (one per external master)
    output obi_pkg::obi_req_t  [ExtXbarNmasterRnd-1:0] heep_slave_req_o,
    input  obi_pkg::obi_resp_t [ExtXbarNmasterRnd-1:0] heep_slave_resp_i,

    // External peripherals slave ports

    output reg_pkg::reg_req_t cheep_peripherals_req_o,
    input  reg_pkg::reg_rsp_t cheep_peripherals_rsp_i,

    output reg_pkg::reg_req_t system_clock_divider_req_o,
    input  reg_pkg::reg_rsp_t system_clock_divider_rsp_i,

    output reg_pkg::reg_req_t dlc_req_o,
    input  reg_pkg::reg_rsp_t dlc_rsp_i,

    output reg_pkg::reg_req_t ch_0_req_o,
    input  reg_pkg::reg_rsp_t ch_0_rsp_i,

    output reg_pkg::reg_req_t ch_1_req_o,
    input  reg_pkg::reg_rsp_t ch_1_rsp_i,

    output reg_pkg::reg_req_t ch_2_req_o,
    input  reg_pkg::reg_rsp_t ch_2_rsp_i,

    output reg_pkg::reg_req_t ch_3_req_o,
    input  reg_pkg::reg_rsp_t ch_3_rsp_i,

    output reg_pkg::reg_req_t ch_4_req_o,
    input  reg_pkg::reg_rsp_t ch_4_rsp_i,

    output reg_pkg::reg_req_t ch_0_lna_ctrl_req_o,
    input  reg_pkg::reg_rsp_t ch_0_lna_ctrl_rsp_i,

    output reg_pkg::reg_req_t ch_0_bpe_ctrl_req_o,
    input  reg_pkg::reg_rsp_t ch_0_bpe_ctrl_rsp_i,

    output reg_pkg::reg_req_t ch_0_bpe_clock_divider_req_o,
    input  reg_pkg::reg_rsp_t ch_0_bpe_clock_divider_rsp_i,

    output reg_pkg::reg_req_t ch_0_bpe_pwm_0_req_o,
    input  reg_pkg::reg_rsp_t ch_0_bpe_pwm_0_rsp_i,

    output reg_pkg::reg_req_t ch_0_bpe_pwm_1_req_o,
    input  reg_pkg::reg_rsp_t ch_0_bpe_pwm_1_rsp_i,

    output reg_pkg::reg_req_t ch_0_bpe_pwm_2_req_o,
    input  reg_pkg::reg_rsp_t ch_0_bpe_pwm_2_rsp_i,

    output reg_pkg::reg_req_t ch_0_bpe_pwm_3_req_o,
    input  reg_pkg::reg_rsp_t ch_0_bpe_pwm_3_rsp_i,

    output reg_pkg::reg_req_t ch_0_dsm_ctrl_req_o,
    input  reg_pkg::reg_rsp_t ch_0_dsm_ctrl_rsp_i,

    output reg_pkg::reg_req_t ch_0_dsm_cic_req_o,
    input  reg_pkg::reg_rsp_t ch_0_dsm_cic_rsp_i,

    output reg_pkg::reg_req_t ch_0_dsm_ses_req_o,
    input  reg_pkg::reg_rsp_t ch_0_dsm_ses_rsp_i,

    output reg_pkg::reg_req_t ch_0_vco_p_counter_req_o,
    input  reg_pkg::reg_rsp_t ch_0_vco_p_counter_rsp_i,

    output reg_pkg::reg_req_t ch_0_vco_n_counter_req_o,
    input  reg_pkg::reg_rsp_t ch_0_vco_n_counter_rsp_i,

    output reg_pkg::reg_req_t ch_0_dlc_req_o,
    input  reg_pkg::reg_rsp_t ch_0_dlc_rsp_i,

    output reg_pkg::reg_req_t ch_1_lna_ctrl_req_o,
    input  reg_pkg::reg_rsp_t ch_1_lna_ctrl_rsp_i,

    output reg_pkg::reg_req_t ch_1_dsm_ctrl_req_o,
    input  reg_pkg::reg_rsp_t ch_1_dsm_ctrl_rsp_i,

    output reg_pkg::reg_req_t ch_1_dsm_cic_req_o,
    input  reg_pkg::reg_rsp_t ch_1_dsm_cic_rsp_i,

    output reg_pkg::reg_req_t ch_1_dsm_ses_req_o,
    input  reg_pkg::reg_rsp_t ch_1_dsm_ses_rsp_i,

    output reg_pkg::reg_req_t ch_2_vco_counter_req_o,
    input  reg_pkg::reg_rsp_t ch_2_vco_counter_rsp_i,

    output reg_pkg::reg_req_t ch_2_lc_ctrl_req_o,
    input  reg_pkg::reg_rsp_t ch_2_lc_ctrl_rsp_i,

    output reg_pkg::reg_req_t ch_3_vco_counter_req_o,
    input  reg_pkg::reg_rsp_t ch_3_vco_counter_rsp_i,

    output reg_pkg::reg_req_t ch_3_lna_ctrl_req_o,
    input  reg_pkg::reg_rsp_t ch_3_lna_ctrl_rsp_i,

    output reg_pkg::reg_req_t ch_3_lc_ctrl_req_o,
    input  reg_pkg::reg_rsp_t ch_3_lc_ctrl_rsp_i,

    output reg_pkg::reg_req_t ch_3_dlc_req_o,
    input  reg_pkg::reg_rsp_t ch_3_dlc_rsp_i,

    output reg_pkg::reg_req_t ch_4_vco_counter_req_o,
    input  reg_pkg::reg_rsp_t ch_4_vco_counter_rsp_i,

    output reg_pkg::reg_req_t ch_4_lc_ctrl_req_o,
    input  reg_pkg::reg_rsp_t ch_4_lc_ctrl_rsp_i,

    output reg_pkg::reg_req_t idac_ctrl_req_o,
    input  reg_pkg::reg_rsp_t idac_ctrl_rsp_i,

    output reg_pkg::reg_req_t refs_ctrl_req_o,
    input  reg_pkg::reg_rsp_t refs_ctrl_rsp_i,

    // X-HEEP peripheral master port
    input  reg_pkg::reg_req_t heep_periph_req_i,
    output reg_pkg::reg_rsp_t heep_periph_resp_o

);
  import cheep_pkg::*;
  import obi_pkg::*;
  import reg_pkg::*;

  // PARAMETERS
  localparam int unsigned IdxWidth = cf_math_pkg::idx_width(ExtXbarNSlave);

  // INTERNAL SIGNALS
  // ----------------
  // External slaves request
  obi_req_t  [  ExtXbarNSlave-1:0] ext_slave_req;
  obi_resp_t [  ExtXbarNSlave-1:0] ext_slave_rsp;

  // External peripherals request
  reg_req_t  [ExtPeriphNSlave-1:0] ext_periph_req;
  reg_rsp_t  [ExtPeriphNSlave-1:0] ext_periph_rsp;


  // External slave bus
  // ------------------
  // External slave mapping

  if (ExtXbarNMaster != 32'd0 || ExtXbarNSlave != 32'd0) begin : gen_ext_bus

    assign ext_slave_rsp = '0;

    // External bus
    ext_bus #(
        .EXT_XBAR_NMASTER(ExtXbarNMaster),
        .EXT_XBAR_NSLAVE(ExtXbarNSlave),
        .DMA_MASTER_PORTS_NUM(DMAMasterPortsNum)
    ) u_ext_bus (
        .clk_i                   (clk_i),
        .rst_ni                  (rst_ni),
        .addr_map_i              (ExtSlaveAddrRules),
        .default_idx_i           (ExtSlaveDefaultIdx[IdxWidth-1:0]),
        .heep_core_instr_req_i   (heep_core_instr_req_i),
        .heep_core_instr_resp_o  (heep_core_instr_resp_o),
        .heep_core_data_req_i    (heep_core_data_req_i),
        .heep_core_data_resp_o   (heep_core_data_resp_o),
        .heep_debug_master_req_i (heep_debug_master_req_i),
        .heep_debug_master_resp_o(heep_debug_master_resp_o),
        .heep_dma_read_req_i     (heep_dma_read_req_i),
        .heep_dma_read_resp_o    (heep_dma_read_resp_o),
        .heep_dma_write_req_i    (heep_dma_write_req_i),
        .heep_dma_write_resp_o   (heep_dma_write_resp_o),
        .heep_dma_addr_req_i     (heep_dma_addr_req_i),
        .heep_dma_addr_resp_o    (heep_dma_addr_resp_o),
        .ext_master_req_i        (cheep_master_req_i),
        .ext_master_resp_o       (cheep_master_resp_o),
        .heep_slave_req_o        (heep_slave_req_o),
        .heep_slave_resp_i       (heep_slave_resp_i),
        .ext_slave_req_o         (ext_slave_req),
        .ext_slave_resp_i        (ext_slave_rsp)
    );

  end else begin : gen_no_ext_bus
    assign heep_core_instr_resp_o = '0;
    assign heep_core_data_resp_o = '0;
    assign heep_debug_master_resp_o = '0;
    assign heep_dma_read_resp_o = '0;
    assign heep_dma_write_resp_o = '0;
    assign heep_dma_addr_resp_o = '0;
    assign cheep_master_resp_o = '0;
    assign heep_slave_req_o = '0;
    assign heep_periph_resp_o = '0;
    assign ext_slave_req = '0;
  end

  // External peripherals bus
  // ------------------------
  // External peripherals mapping


  assign cheep_peripherals_req_o = ext_periph_req[CheepCheepPeripheralsIdx];
  assign ext_periph_rsp[CheepCheepPeripheralsIdx] = cheep_peripherals_rsp_i;

  assign system_clock_divider_req_o = ext_periph_req[CheepSystemClockDividerIdx];
  assign ext_periph_rsp[CheepSystemClockDividerIdx] = system_clock_divider_rsp_i;

  assign dlc_req_o = ext_periph_req[CheepdLCIdx];
  assign ext_periph_rsp[CheepdLCIdx] = dlc_rsp_i;

  assign ch_0_req_o = ext_periph_req[CheepCh0Idx];
  assign ext_periph_rsp[CheepCh0Idx] = ch_0_rsp_i;

  assign ch_1_req_o = ext_periph_req[CheepCh1Idx];
  assign ext_periph_rsp[CheepCh1Idx] = ch_1_rsp_i;

  assign ch_2_req_o = ext_periph_req[CheepCh2Idx];
  assign ext_periph_rsp[CheepCh2Idx] = ch_2_rsp_i;

  assign ch_3_req_o = ext_periph_req[CheepCh3Idx];
  assign ext_periph_rsp[CheepCh3Idx] = ch_3_rsp_i;

  assign ch_4_req_o = ext_periph_req[CheepCh4Idx];
  assign ext_periph_rsp[CheepCh4Idx] = ch_4_rsp_i;

  assign ch_0_lna_ctrl_req_o = ext_periph_req[CheepCh0LnaCtrlIdx];
  assign ext_periph_rsp[CheepCh0LnaCtrlIdx] = ch_0_lna_ctrl_rsp_i;

  assign ch_0_bpe_ctrl_req_o = ext_periph_req[CheepCh0BpeCtrlIdx];
  assign ext_periph_rsp[CheepCh0BpeCtrlIdx] = ch_0_bpe_ctrl_rsp_i;

  assign ch_0_bpe_clock_divider_req_o = ext_periph_req[CheepCh0BpeClockDividerIdx];
  assign ext_periph_rsp[CheepCh0BpeClockDividerIdx] = ch_0_bpe_clock_divider_rsp_i;

  assign ch_0_bpe_pwm_0_req_o = ext_periph_req[CheepCh0BpePwm0Idx];
  assign ext_periph_rsp[CheepCh0BpePwm0Idx] = ch_0_bpe_pwm_0_rsp_i;

  assign ch_0_bpe_pwm_1_req_o = ext_periph_req[CheepCh0BpePwm1Idx];
  assign ext_periph_rsp[CheepCh0BpePwm1Idx] = ch_0_bpe_pwm_1_rsp_i;

  assign ch_0_bpe_pwm_2_req_o = ext_periph_req[CheepCh0BpePwm2Idx];
  assign ext_periph_rsp[CheepCh0BpePwm2Idx] = ch_0_bpe_pwm_2_rsp_i;

  assign ch_0_bpe_pwm_3_req_o = ext_periph_req[CheepCh0BpePwm3Idx];
  assign ext_periph_rsp[CheepCh0BpePwm3Idx] = ch_0_bpe_pwm_3_rsp_i;

  assign ch_0_dsm_ctrl_req_o = ext_periph_req[CheepCh0DsmCtrlIdx];
  assign ext_periph_rsp[CheepCh0DsmCtrlIdx] = ch_0_dsm_ctrl_rsp_i;

  assign ch_0_dsm_cic_req_o = ext_periph_req[CheepCh0DsmCicIdx];
  assign ext_periph_rsp[CheepCh0DsmCicIdx] = ch_0_dsm_cic_rsp_i;

  assign ch_0_dsm_ses_req_o = ext_periph_req[CheepCh0DsmSesIdx];
  assign ext_periph_rsp[CheepCh0DsmSesIdx] = ch_0_dsm_ses_rsp_i;

  assign ch_0_vco_p_counter_req_o = ext_periph_req[CheepCh0VcoPCounterIdx];
  assign ext_periph_rsp[CheepCh0VcoPCounterIdx] = ch_0_vco_p_counter_rsp_i;

  assign ch_0_vco_n_counter_req_o = ext_periph_req[CheepCh0VcoNCounterIdx];
  assign ext_periph_rsp[CheepCh0VcoNCounterIdx] = ch_0_vco_n_counter_rsp_i;

  assign ch_0_dlc_req_o = ext_periph_req[CheepCh0DlcIdx];
  assign ext_periph_rsp[CheepCh0DlcIdx] = ch_0_dlc_rsp_i;

  assign ch_1_lna_ctrl_req_o = ext_periph_req[CheepCh1LnaCtrlIdx];
  assign ext_periph_rsp[CheepCh1LnaCtrlIdx] = ch_1_lna_ctrl_rsp_i;

  assign ch_1_dsm_ctrl_req_o = ext_periph_req[CheepCh1DsmCtrlIdx];
  assign ext_periph_rsp[CheepCh1DsmCtrlIdx] = ch_1_dsm_ctrl_rsp_i;

  assign ch_1_dsm_cic_req_o = ext_periph_req[CheepCh1DsmCicIdx];
  assign ext_periph_rsp[CheepCh1DsmCicIdx] = ch_1_dsm_cic_rsp_i;

  assign ch_1_dsm_ses_req_o = ext_periph_req[CheepCh1DsmSesIdx];
  assign ext_periph_rsp[CheepCh1DsmSesIdx] = ch_1_dsm_ses_rsp_i;

  assign ch_2_vco_counter_req_o = ext_periph_req[CheepCh2VcoCounterIdx];
  assign ext_periph_rsp[CheepCh2VcoCounterIdx] = ch_2_vco_counter_rsp_i;

  assign ch_2_lc_ctrl_req_o = ext_periph_req[CheepCh2LcCtrlIdx];
  assign ext_periph_rsp[CheepCh2LcCtrlIdx] = ch_2_lc_ctrl_rsp_i;

  assign ch_3_vco_counter_req_o = ext_periph_req[CheepCh3VcoCounterIdx];
  assign ext_periph_rsp[CheepCh3VcoCounterIdx] = ch_3_vco_counter_rsp_i;

  assign ch_3_lna_ctrl_req_o = ext_periph_req[CheepCh3LnaCtrlIdx];
  assign ext_periph_rsp[CheepCh3LnaCtrlIdx] = ch_3_lna_ctrl_rsp_i;

  assign ch_3_lc_ctrl_req_o = ext_periph_req[CheepCh3LcCtrlIdx];
  assign ext_periph_rsp[CheepCh3LcCtrlIdx] = ch_3_lc_ctrl_rsp_i;

  assign ch_3_dlc_req_o = ext_periph_req[CheepCh3DlcIdx];
  assign ext_periph_rsp[CheepCh3DlcIdx] = ch_3_dlc_rsp_i;

  assign ch_4_vco_counter_req_o = ext_periph_req[CheepCh4VcoCounterIdx];
  assign ext_periph_rsp[CheepCh4VcoCounterIdx] = ch_4_vco_counter_rsp_i;

  assign ch_4_lc_ctrl_req_o = ext_periph_req[CheepCh4LcCtrlIdx];
  assign ext_periph_rsp[CheepCh4LcCtrlIdx] = ch_4_lc_ctrl_rsp_i;

  assign idac_ctrl_req_o = ext_periph_req[CheepIdacCtrlIdx];
  assign ext_periph_rsp[CheepIdacCtrlIdx] = idac_ctrl_rsp_i;

  assign refs_ctrl_req_o = ext_periph_req[CheepREFsCtrlIdx];
  assign ext_periph_rsp[CheepREFsCtrlIdx] = refs_ctrl_rsp_i;

  // External peripherals bus
  periph_bus #(
      .NSLAVE(ExtPeriphNSlave)
  ) u_periph_bus (
      .clk_i       (clk_i),
      .rst_ni      (rst_ni),
      .addr_map_i  (ExtPeriphAddrRules),
      .master_req_i(heep_periph_req_i),
      .master_rsp_o(heep_periph_resp_o),
      .slave_req_o (ext_periph_req),
      .slave_rsp_i (ext_periph_rsp)
  );

endmodule
