// Copyright 2026 EPFL.
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
//
// File: LC_ctrl.sv
// Author: Juan Sapriza

module LC_ctrl #(
) (

    input logic clk_i,
    input logic rst_ni,

    output logic [3:0] lvl_width_sel_o,
    output logic [3:0] dir_width_sel_o,
    output logic [1:0] cap_sel_o,

    input  reg_pkg::reg_req_t req_i,
    output reg_pkg::reg_rsp_t rsp_o
);

  /* verilator lint_off UNUSED */
  lc_ctrl_reg_pkg::lc_ctrl_reg2hw_t reg2hw;
  /* verilator lint_on UNUSED */

  // LC_ctrl registers
  lc_ctrl_reg_top #(
      .reg_req_t(reg_pkg::reg_req_t),
      .reg_rsp_t(reg_pkg::reg_rsp_t)
  ) u_lc_ctrl_reg_top (
      .clk_i    (clk_i),
      .rst_ni   (rst_ni),
      .reg_req_i(req_i),
      .reg_rsp_o(rsp_o),
      .reg2hw   (reg2hw),
      .devmode_i(1'b0)
  );

  assign lvl_width_sel_o = reg2hw.lvl_width_sel.q;
  assign dir_width_sel_o = reg2hw.dir_width_sel.q;
  assign cap_sel_o = reg2hw.cap_sel.q;


endmodule
