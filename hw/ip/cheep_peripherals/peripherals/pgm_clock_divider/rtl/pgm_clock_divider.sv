// Copyright 2024 EPFL.
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
//
// File: pgm_clock_divider.sv
// Author: Juan Sapriza
// Date: 15/01/26

module pgm_clock_divider #(
    parameter integer DIV_VALUE_WIDTH   = 10,
    parameter integer DEFAULT_DIV_VALUE = 1
) (

    input logic clk_i,
    input logic rst_ni,

    input logic freq_div_valid_i,

    input  reg_pkg::reg_req_t req_i,
    output reg_pkg::reg_rsp_t rsp_o,

    output logic clk_o
);

  logic                                                 [DIV_VALUE_WIDTH-1:0] freq_div;
  logic                                                                       enable;
  logic                                                                       bypass;

  reg_pkg::reg_req_t                                                          slow_req;
  reg_pkg::reg_req_t                                                          fast_req;
  reg_pkg::reg_rsp_t                                                          slow_rsp;
  reg_pkg::reg_rsp_t                                                          fast_rsp;


  /* verilator lint_off UNUSED */
  pgm_clock_divider_reg_pkg::pgm_clock_divider_reg2hw_t                       reg2hw;
  /* verilator lint_on UNUSED */


  assign bypass = '0;
  assign enable = reg2hw.enable.q;
  assign freq_div = reg2hw.divider.q;

  assign slow_req = req_i;
  assign rsp_o = slow_rsp;

  // DSM registers registers
  pgm_clock_divider_reg_top #(
      .reg_req_t(reg_pkg::reg_req_t),
      .reg_rsp_t(reg_pkg::reg_rsp_t)
  ) u_pgm_clock_divider_reg_top (
      .clk_i    (clk_i),
      .rst_ni   (rst_ni),
      .reg_req_i(fast_req),
      .reg_rsp_o(fast_rsp),
      .reg2hw   (reg2hw),
      .devmode_i(1'b0)
  );



  reg_cdc #(
      .req_t(reg_pkg::reg_req_t),
      .rsp_t(reg_pkg::reg_rsp_t)
  ) u_cdc_reg (
      .src_clk_i(clk_o),  // The MCU, at the slow clock
      .src_rst_ni(rst_ni),
      .src_req_i(slow_req),
      .src_rsp_o(slow_rsp),

      .dst_clk_i (clk_i),
      .dst_rst_ni(rst_ni),
      .dst_req_o (fast_req),
      .dst_rsp_i (fast_rsp)
  );

  clk_int_div #(
      .DIV_VALUE_WIDTH  (DIV_VALUE_WIDTH),
      .DEFAULT_DIV_VALUE(DEFAULT_DIV_VALUE)
  ) u_clk_int_div (
      .clk_i,
      .rst_ni,
      .en_i(enable),
      .test_mode_en_i(bypass),
      .div_i(freq_div),
      .div_valid_i(freq_div_valid_i),
      .div_ready_o(),
      .clk_o(clk_o),
      .cycl_count_o()
  );

endmodule
