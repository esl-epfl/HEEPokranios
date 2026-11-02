// Copyright 2025 EPFL contributors
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
//
// File: DSM_ctrl.sv
// Author:Juan Sapriza
// Description: Controller for the DSM

module DSM_ctrl #(
) (

    output logic       fsm_en_no,
    output logic       resonator_en_no,
    output logic [4:0] cap_sel_o,
    output logic [1:0] lowpower_sel_o,
    output logic       lfp_en_o,

    // Bus interface
    input  reg_pkg::reg_req_t req_i,
    output reg_pkg::reg_rsp_t rsp_o,

    input logic clk_i,
    input logic rst_ni
);
  /* verilator lint_off UNUSED */
  /* verilator lint_off UNDRIVEN */
  dsm_ctrl_reg_pkg::dsm_ctrl_hw2reg_t hw2reg;
  dsm_ctrl_reg_pkg::dsm_ctrl_reg2hw_t reg2hw;
  /* verilator lint_on UNUSED */
  /* verilator lint_on UNDRIVEN */

  // DSM registers registers
  dsm_ctrl_reg_top #(
      .reg_req_t(reg_pkg::reg_req_t),
      .reg_rsp_t(reg_pkg::reg_rsp_t)
  ) u_dsm_ctrl_reg_top (
      .clk_i    (clk_i),
      .rst_ni   (rst_ni),
      .reg_req_i(req_i),
      .reg_rsp_o(rsp_o),
      .reg2hw   (reg2hw),
      .hw2reg   (hw2reg),
      .devmode_i(1'b0)
  );

  assign fsm_en_no       = reg2hw.fsm_en_n.q;
  assign resonator_en_no = reg2hw.resonator_en_n.q;
  assign cap_sel_o       = reg2hw.cap_sel.q;
  assign lowpower_sel_o  = reg2hw.lowpower_sel.q;
  assign lfp_en_o        = reg2hw.lfp_en.q;

endmodule  // dsm_ctrl
