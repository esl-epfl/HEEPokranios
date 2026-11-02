// Copyright 2026 EPFL.
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
//
// File: BPE_ctrl.sv
// Author: Juan Sapriza

module BPE_ctrl #(
) (

    input logic clk_i,
    input logic rst_ni,

    output logic [5:0] ibias_sel,
    output logic [5:0] ch_en,

    input  reg_pkg::reg_req_t req_i,
    output reg_pkg::reg_rsp_t rsp_o
);

  /* verilator lint_off UNUSED */
  /* verilator lint_off UNDRIVEN */
  bpe_ctrl_reg_pkg::bpe_ctrl_reg2hw_t reg2hw;
  /* verilator lint_on UNDRIVEN */
  /* verilator lint_on UNUSED */

  // BPE_ctrl registers
  bpe_ctrl_reg_top #(
      .reg_req_t(reg_pkg::reg_req_t),
      .reg_rsp_t(reg_pkg::reg_rsp_t)
  ) u_bpe_ctrl_reg_top (
      .clk_i    (clk_i),
      .rst_ni   (rst_ni),
      .reg_req_i(req_i),
      .reg_rsp_o(rsp_o),
      .reg2hw   (reg2hw),
      .devmode_i(1'b0)
  );

  assign ibias_sel = reg2hw.ibias_sel.q;
  assign ch_en = reg2hw.ch_en.q;

endmodule
