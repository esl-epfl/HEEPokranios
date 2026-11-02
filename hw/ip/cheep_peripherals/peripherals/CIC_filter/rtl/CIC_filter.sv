// Copyright 2025 EPFL
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
//
// Authors: Pierre Guillod <pierre.guillod@epfl.ch> ,EPFL, STI-SEL
//          Jérémie Moullet<jeremie.moullet@epfl.ch>,EPFL, STI-SEL
//          Juan Sapriza <juan.sapriza@epfl.ch>
//
// Date: 05.2026
//
//┌───────────────────────┐
//│       CIC Filter      │
//│┌─────┐ ┌─────┐ ┌─────┐│
//││Intgs├─►Decim├─►Combs├│
//│└─────┘ └─────┘ └─────┘│
//└───────────────────────┘
// (made with asciiflow.com)
//
//
// Compile-Time Parameters (RTL):
//   - FIFO_DEPTH : Number of entries in the clock domain crossing FIFO.
//   - MAXIMUM_WIDTH : Bit-width of the data path.
//
// Runtime Configuration (via register interface):
//   - CLKDIVIDX            : Clock divider from system clock to sampling frequency (must be even).
//   - DECIMCIC             : Decimation factor from sampling frequency to CIC output frequency.
//   - cic_delay_comb       : Delay parameter (D) in the CIC comb stage.
//   - cic_activated_stages : Thermometric, right-aligned encoding of the number of active CIC stages.
//                            (e.g., 4'b1111 means 4 stages are active).
//
// NOTE: This list includes runtime configuration for the CIC block only.
//       The full cic_filter register map is defined in `cic_filter.hjson`.
//
// NOTE: The maximum value for each configuration parameter is determined
//       by the bit-width defined in `cic_filter.hjson`.
//
// Ports:
//   - clk_sys_i     : Main system clock.
//   - rst_ni    : Active-low reset.
//   - reg_req_i : Register interface request input.
//   - reg_rsp_o : Register interface response output.
//   - dsm_i     : 1-bit digital input from the PDM source.
//   - clk_fs_o : Output clock signal that samples `dsm_i`.
//                 (One sample per rising edge of `clk_fs_o`.)
//
// Control and status registers:
//   - control :
//      - bit 0 : Starts PDM data processing. The FIFO starts to fill with PCM data.
//      - bit 1 : Clears the FIFO buffer.
//   - status  :
//      - bit 0 : The FIFO buffer is empty.
//      - bit 1 : The FIFO buffer is full.
//
// Output:
//   - rxdata (via FIFO window)
//
// Features:
//   - Configurable CIC filter: number of stages, decimation, and comb delay.
//   - Optional post-processing: Half-band and FIR filters (when `cic_mode == 0`).
//   - Integer-based dynamic clock division for sampling control.
//   - CDC FIFO for safe data transfer between clock domains.
//   - Standardized register and window interface integration for memory-mapped access.

module CIC_filter #(
    parameter type reg_req_t = logic,
    parameter type reg_rsp_t = logic,
    parameter int unsigned MAXIMUM_WIDTH = 18
) (
    input logic ref_clk_i,
    input logic clk_sys_i,
    input logic rst_ni,

    // Register interface
    input  reg_req_t reg_req_i,
    output reg_rsp_t reg_rsp_o,

    // PDM interface
    input logic dsm_i,
    output logic clk_fs_o,
    output logic [MAXIMUM_WIDTH-1:0] data_o,

    // DSM interface
    output logic data_valid_o,
    output logic activated_o
);

  import cic_filter_reg_pkg::*;

  // Interface signals
  /* verilator lint_off UNUSED */
  /* verilator lint_off UNDRIVEN */
  cic_filter_reg2hw_t reg2hw;
  cic_filter_hw2reg_t hw2reg;
  /* verilator lint_on UNDRIVEN */
  /* verilator lint_on UNUSED */

  //Compile time operation
  localparam integer CicMaxStageNumber = $bits(reg2hw.cic_activated_stages.q);
  localparam integer DecimCicWidth = $bits(reg2hw.decimcic.q);
  localparam integer ClkDivIdxWidth = $bits(reg2hw.clkdividx.q);
  localparam integer DelayCombWidth = $bits(reg2hw.cic_delay_comb.q);


  logic [   ClkDivIdxWidth-1:0] sysclk_div;
  logic [    DecimCicWidth-1:0] par_decim_idx_combs;
  logic [CicMaxStageNumber-1:0] par_cic_activated_stages;
  logic [   DelayCombWidth-1:0] par_delay_combs;
  logic                         pcm_data_valid;

  assign hw2reg.status.fulll.de = 1;
  assign hw2reg.status.empty.de = 1;
  assign sysclk_div = reg2hw.clkdividx.q;
  assign par_decim_idx_combs = reg2hw.decimcic.q;
  assign par_cic_activated_stages = reg2hw.cic_activated_stages.q;
  assign par_delay_combs = reg2hw.cic_delay_comb.q;

  //----------------- Registers containing parameters ------------------------------

  cic_filter_reg_top #(
      .reg_req_t(reg_req_t),
      .reg_rsp_t(reg_rsp_t)
  ) cic_filter_reg_top_i (
      .clk_i(clk_sys_i),
      .rst_ni,
      .reg_req_i,
      .reg_rsp_o,
      .reg2hw,
      .hw2reg,
      .devmode_i(1'b1)
  );


  //-----------------Division of the reference clk------------------------------

  clk_int_div #(
      .DIV_VALUE_WIDTH  (ClkDivIdxWidth),
      .DEFAULT_DIV_VALUE(1)
  ) u_clk_int_div (
      .clk_i(ref_clk_i),
      .rst_ni,
      .en_i(reg2hw.control.enabl.q),
      .test_mode_en_i('0),
      .div_i(sysclk_div),
      .div_valid_i('1),
      .div_ready_o(),
      .clk_o(clk_fs_o),
      .cycl_count_o()
  );

  //-----------------CIC filter core ------------------------------

  cic_core #(
      .MAX_STAGE_CIC(CicMaxStageNumber),
      .WIDTH(MAXIMUM_WIDTH),
      .DECIM_COMBS_CNT_W(DecimCicWidth),
      .DELAYCOMBWIDTH(DelayCombWidth)
  ) cic_core_i (
      .clk_fs_i(clk_fs_o),
      .rstn_i(rst_ni),
      .en_i(reg2hw.control.enabl.q),
      .par_cic_activated_stages,
      .par_decim_idx_combs,
      .par_delay_combs,
      .dsm_i,
      .data_o(data_o),
      .pcm_data_valid_o(pcm_data_valid)
  );


  //----------------- Data valid CDC -------------------------------
  //
  // pcm_data_valid is generated in the clk_fs_o domain
  // data_valid_o must be a one-cycle pulse in the clk_sys_i domain

  logic pcm_valid_toggle_fs;

  logic pcm_valid_toggle_sys_q;
  logic pcm_valid_toggle_sys_qq;

  // clk_fs_o domain: convert pcm_data_valid pulse into a toggle event
  always_ff @(posedge clk_fs_o or negedge rst_ni) begin
    if (!rst_ni) begin
      pcm_valid_toggle_fs <= 1'b0;
    end else if (!reg2hw.control.enabl.q) begin
      pcm_valid_toggle_fs <= 1'b0;
    end else if (pcm_data_valid) begin
      pcm_valid_toggle_fs <= ~pcm_valid_toggle_fs;
    end
  end

  // clk_sys_i domain: sample the toggle and generate a one-cycle pulse
  always_ff @(posedge clk_sys_i or negedge rst_ni) begin
    if (!rst_ni) begin
      pcm_valid_toggle_sys_q  <= 1'b0;
      pcm_valid_toggle_sys_qq <= 1'b0;
      data_valid_o            <= 1'b0;
    end else begin
      if (!reg2hw.control.enabl.q) begin
        pcm_valid_toggle_sys_q  <= 1'b0;
        pcm_valid_toggle_sys_qq <= 1'b0;
        data_valid_o            <= 1'b0;
      end else begin
        pcm_valid_toggle_sys_q <= pcm_valid_toggle_fs;
        pcm_valid_toggle_sys_qq <= pcm_valid_toggle_sys_q;

        // One clk_sys_i-cycle pulse whenever there's been a toggle
        data_valid_o <= pcm_valid_toggle_sys_q ^ pcm_valid_toggle_sys_qq;
      end
    end
  end

  assign hw2reg.data_out.d = data_o;
  assign hw2reg.data_out.de = data_valid_o;

  assign activated_o = reg2hw.control.enabl.q;

endmodule
