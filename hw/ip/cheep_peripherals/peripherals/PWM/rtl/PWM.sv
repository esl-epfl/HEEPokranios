// Copyright 2026 EPFL.
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
//
// File: PWM.sv
// Author: Juan Sapriza

module PWM #(
    parameter int WIDTH = 16  // Counter width, coordinate with registers/PWM.hjson
) (
    input  logic ref_clk_i,
    input  logic clk_i,
    input  logic rst_ni,
    input  logic enable_i,
    output logic out_o,

    input  reg_pkg::reg_req_t req_i,
    output reg_pkg::reg_rsp_t rsp_o
);

  /* verilator lint_off UNUSED */
  /* verilator lint_off UNDRIVEN */
  pwm_reg_pkg::pwm_hw2reg_t hw2reg;
  pwm_reg_pkg::pwm_reg2hw_t reg2hw;
  /* verilator lint_on UNDRIVEN */
  /* verilator lint_on UNUSED */

  // PWM registers
  pwm_reg_top #(
      .reg_req_t(reg_pkg::reg_req_t),
      .reg_rsp_t(reg_pkg::reg_rsp_t)
  ) u_PWM_reg_top (
      .clk_i    (clk_i),
      .rst_ni   (rst_ni),
      .reg_req_i(req_i),
      .reg_rsp_o(rsp_o),
      .reg2hw   (reg2hw),
      .hw2reg   (hw2reg),
      .devmode_i(1'b0)
  );

  logic [WIDTH-1:0] L;
  logic [WIDTH-1:0] H;

  assign L = reg2hw.l_cc.q;
  assign H = reg2hw.h_cc.q;

  logic [WIDTH-1:0] cnt_q;

  // @ToDo_heepokranios: this rst_ni should be syncronized to the ref_clk
  always_ff @(posedge ref_clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      // Initialize to the Low phase
      cnt_q <= '0;
      out_o <= 1'b0;
    end else begin
      if (!enable_i) begin
        cnt_q <= L;
        out_o <= 1'b0;
      end else begin
        if (cnt_q <= 1) begin
          // Toggle output and load the duration for the NEXT phase
          // When out_o is 0, we just finished L, so load H and go High.
          // When out_o is 1, we just finished H, so load L and go Low.
          out_o <= ~out_o;
          cnt_q <= (out_o == 1'b0) ? H : L;
        end else begin
          cnt_q <= cnt_q - 1'b1;
        end
      end
    end
  end

endmodule

