// Copyright 2026 EPFL.
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
//
// File: LNA_ctrl.sv
// Author: Juan Sapriza

module LNA_ctrl #(
) (

    output [2:0] pr_o,
    output [1:0] gain_o,
    output [1:0] cutoff_o,

    input logic clk_i,
    input logic rst_ni,

    input  reg_pkg::reg_req_t req_i,
    output reg_pkg::reg_rsp_t rsp_o
);

  /* verilator lint_off UNUSED */
  /* verilator lint_off UNDRIVEN */
  lna_ctrl_reg_pkg::lna_ctrl_reg2hw_t reg2hw;
  /* verilator lint_on UNDRIVEN */
  /* verilator lint_on UNUSED */

  // LNA_ctrl registers
  lna_ctrl_reg_top #(
      .reg_req_t(reg_pkg::reg_req_t),
      .reg_rsp_t(reg_pkg::reg_rsp_t)
  ) u_lna_ctrl_reg_top (
      .clk_i    (clk_i),
      .rst_ni   (rst_ni),
      .reg_req_i(req_i),
      .reg_rsp_o(rsp_o),
      .reg2hw   (reg2hw),
      .devmode_i(1'b0)
  );


  assign pr_o = reg2hw.pr.q;
  assign gain_o = reg2hw.gain.q;
  assign cutoff_o = reg2hw.cutoff.q;


endmodule
