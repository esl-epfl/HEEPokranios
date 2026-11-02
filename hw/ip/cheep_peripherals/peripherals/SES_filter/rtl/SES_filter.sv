// Copyright 2025 EPFL
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
//
// Authors: Jérémie Moullet <jeremie.moullet@epfl.ch>, EPFL, STI-SEL
//          Juan Sapriza <juan.sapriza@epfl.ch>, EPFL, STI-SEL
//
// Date: 05.2026
//
// Description: Top-level Simple Exponential Smoothing (SES) filter.
//              Converts 1-bit DSM input into decimated, smoothed PCM output
//              using a configurable number of SES stages.
//
// Compile-Time Parameters:
//   - MAXIMUM_WIDTH  : Bit-width of internal datapath (default: 32).
//   - FIFO_DEPTH     : Depth of the CDC FIFO buffer.
//
// Runtime Configuration (via registers):
//   - ses_window_size          : Common window size (Ww) for all stages.
//   - ses_decim_factor         : Output decimation factor.
//   - ses_sysclk_division      : Division factor for generating clk_fs_o.
//   - ses_activated_stages     : Thermometric bitmask to enable SES stages (contiguous '1's, right-aligned).
//   - ses_gain_stage           : Per-stage input gain (WgX).
//
// Ports:
//   - clk_sys_i, rst_ni        : System clock and active-low reset.
//   - dsm_i                    : 1-bit delta-sigma modulated input signal.
//   - clk_fs_o                 : Sampling clock derived from clk_sys_i.
//   - req_i, rsp_o             : Register bus interface.
//   - data_valid_o            : High when filtered PCM output is ready.
//   - data_ready_o            : 1 cc pulse when there is new data
//
// Control and status:
//   - ses_control              : Enables/disables the SES filter.
//   - ses_status               : Status register indicating filter state (PCM data Valid, activated).
//
// Output:
//   - rx_data (via FIFO window)
//
// Notes:
//   - Internally instantiates multiple `ses_stage` modules.
//   - clk_fs_o is derived by dividing clk_sys_i by ses_sysclk_division.
//   - Applies SES filtering, then decimates the result.
//   - Output is buffered across clock domains using a CDC FIFO.
//   - Results are accessed via the register-mapped window interface.
//   - If the DEBUG section is uncommented, it will print filtered output values directly to the console.

module SES_filter #(
    parameter type reg_req_t = logic,
    parameter type reg_rsp_t = logic,

    parameter integer MAXIMUM_WIDTH = 32  // Maximum width of the internal signals. If bigger than 32, risk of truncation
) (
    input logic ref_clk_i,
    input logic clk_sys_i,
    input logic rst_ni,

    input  logic dsm_i,
    output logic clk_fs_o,

    // Bus interface
    input  reg_pkg::reg_req_t req_i,
    output reg_pkg::reg_rsp_t rsp_o,

    // SES_active
    output logic [MAXIMUM_WIDTH-1:0] data_o,
    output logic data_valid_o,  // 1 cc pulse when new data is available
    output logic activated_o
);


  /* verilator lint_off UNUSED */
  /* verilator lint_off UNDRIVEN */
  ses_filter_reg_pkg::ses_filter_hw2reg_t hw2reg;
  ses_filter_reg_pkg::ses_filter_reg2hw_t reg2hw;
  /* verilator lint_on UNDRIVEN */
  /* verilator lint_on UNUSED */


  // SES filter registers
  ses_filter_reg_top #(
      .reg_req_t(reg_pkg::reg_req_t),
      .reg_rsp_t(reg_pkg::reg_rsp_t)
  ) u_ses_filter_reg_top (
      .clk_i    (clk_sys_i),
      .rst_ni   (rst_ni),
      .reg_req_i(req_i),
      .reg_rsp_o(rsp_o),
      .reg2hw   (reg2hw),
      .hw2reg   (hw2reg),
      .devmode_i(1'b0)
  );

  //--------------Parameters computed at compilation time--------------------
  localparam integer SysclkDivWidth = $bits(reg2hw.ses_sysclk_division.q);
  localparam integer StatusWidth = $bits(hw2reg.ses_status.d);
  localparam integer windowSizeWidth = $bits(reg2hw.ses_window_stage[0].q);
  localparam integer InputGainWidth = $bits(reg2hw.ses_gain_stage[0].q);
  localparam integer SesStageNumber = $bits(reg2hw.ses_activated_stages.q);
  localparam integer Log2SesStageNumber = $clog2(SesStageNumber);


  //--------------Link between the register and the hardware-----------------
  logic control;
  logic [SesStageNumber-1:0] stage_active;
  logic [SysclkDivWidth-1:0] sysclk_div;

  assign control = reg2hw.ses_control.q;
  assign activated_o = control;

  assign stage_active = (control) ? reg2hw.ses_activated_stages.q : '0;
  assign sysclk_div = reg2hw.ses_sysclk_division.q;

  //---------------Signal declaration---------------------------------------
  logic [     MAXIMUM_WIDTH-1:0] stage_input         [SesStageNumber+1];
  logic [     MAXIMUM_WIDTH-1:0] stage_output        [  SesStageNumber];
  logic                          ses_clk;
  logic [                   6:0] ses_clk_count;
  logic [                   7:0] ses_stage_clk_en;
  /* verilator lint_off UNUSED */
  logic [      SesStageNumber:0] ses_stage_clk_gated;
  /* verilator lint_on UNUSED */
  logic [      SesStageNumber:0] ses_stage_clk_mux;
  logic [      SesStageNumber:1] ses_stage_clk_mux_q;

  logic [Log2SesStageNumber-1:0] msb_index;

  //---------------Status register------------------------------------------
  logic [       StatusWidth-1:0] status;
  logic                          status_valid;

  //---------------Clock division-----------------------------

  clk_int_div #(
      .DIV_VALUE_WIDTH  (SysclkDivWidth),
      .DEFAULT_DIV_VALUE(1)
  ) u_clk_int_div (
      .clk_i(ref_clk_i),
      .rst_ni,
      .en_i(control),
      .test_mode_en_i('0),
      .div_i(sysclk_div),
      .div_valid_i('1),
      .div_ready_o(),
      .clk_o(ses_clk),
      .cycl_count_o()
  );


  always_ff @(posedge ses_clk or negedge rst_ni) begin
    if (!rst_ni) begin
      ses_clk_count <= '0;
    end else begin
      ses_clk_count <= ses_clk_count + 6'd1;
    end
  end

  tc_clk_inverter clk_inverter (
      .clk_i(ses_clk),
      .clk_o(ses_stage_clk_en[0])
  );


  genvar k;
  generate
    for (k = 1; k <= 7; k++) begin : gen_ses_stage_clk_en
      logic ses_stage_clk_en_q0;
      logic ses_stage_clk_en_q1;
      logic ses_stage_clk_en_edge;

      always_ff @(negedge ses_clk or negedge rst_ni) begin
        if (!rst_ni) begin
          ses_stage_clk_en_q0 <= '0;
          ses_stage_clk_en_q1 <= '0;
        end else begin
          ses_stage_clk_en_q1 <= ses_stage_clk_en_q0;
          ses_stage_clk_en_q0 <= ses_clk_count[k-1];
        end
      end

      assign ses_stage_clk_en_edge = ses_stage_clk_en_q0 & ~ses_stage_clk_en_q1;
      assign ses_stage_clk_en[k]   = ses_stage_clk_en_edge;
    end
  endgenerate

  //---------------Generation of the SES stages-----------------------------
  assign stage_input[0] = {{(MAXIMUM_WIDTH - 1) {1'b0}}, dsm_i};
  assign ses_stage_clk_mux[0] = ses_stage_clk_en[0];

  tc_clk_gating clk_gating_cell (
      .clk_i(ses_clk),
      .en_i(ses_stage_clk_mux[0]),
      .test_en_i(1'b0),
      .clk_o(ses_stage_clk_gated[0])
  );

  generate
    for (k = 0; k < SesStageNumber; k++) begin : gen_ses_stage
      assign ses_stage_clk_mux[k+1] = stage_active[k] ? ses_stage_clk_en[reg2hw.ses_decimation_factor_stage[k].q] : '0;


      always_ff @(negedge ses_clk or negedge rst_ni) begin
        if (!rst_ni) begin
          ses_stage_clk_mux_q[k+1] <= '0;
        end else begin
          if (reg2hw.ses_decimation_factor_stage[k].q == '0) begin
            ses_stage_clk_mux_q[k+1] <= 1'b1;
          end else begin
            ses_stage_clk_mux_q[k+1] <= ses_stage_clk_mux[k+1];
          end
        end
      end



      // FIXME: Remove the clk gating cell for k=0
      tc_clk_gating clk_gating_cell (
          .clk_i(ses_clk),
          .en_i(ses_stage_clk_mux_q[k+1]),
          .test_en_i(1'b0),
          .clk_o(ses_stage_clk_gated[k+1])
      );

      ses_stage #(
          .MAXIMUM_WIDTH(MAXIMUM_WIDTH),
          .WINDOW_SIZE_WIDTH(windowSizeWidth),
          .INPUT_GAIN_SIZE_WIDTH(InputGainWidth)
      ) u_ses_stage_i (
          .rst_ni(rst_ni),
          .clk_i(ses_stage_clk_gated[k]),
          .activated_i(stage_active[k]),
          .data_i(stage_input[k]),
          .Ww(reg2hw.ses_window_stage[k].q),
          .Wg(reg2hw.ses_gain_stage[k].q),
          .data_o(stage_output[k])
      );

      assign stage_input[k+1] = stage_output[k];

    end
  endgenerate





  assign clk_fs_o = ses_stage_clk_gated[0];

  //-----------------MUX for the stages output-------------------------------

  always_comb begin
    msb_index = '0;
    for (int i = SesStageNumber - 1; i >= 0; i--) begin
      if (stage_active[i]) begin
        msb_index = i[Log2SesStageNumber-1:0] + 1;
        break;
      end
    end
  end

  logic clk_fdec;
  assign clk_fdec = ses_stage_clk_mux[msb_index];
  assign data_o   = stage_input[msb_index];

  //----------------- Notification -------------------------------
  logic clk_fdec_syncd;
  edge_propagator sync_request (
      .clk_tx_i(ses_clk),
      .rstn_tx_i(rst_ni),
      .edge_i(clk_fdec),
      .clk_rx_i(clk_sys_i),
      .rstn_rx_i(rst_ni),  //@ToDo_heepokranios, sync this reset
      .edge_o(clk_fdec_syncd)
  );

  always_ff @(posedge clk_sys_i or negedge rst_ni) begin
    if (!rst_ni) begin
      data_valid_o <= 1'b0;
    end else begin
      data_valid_o <= control & clk_fdec_syncd;  // 1 clk_sys_i pulse on clk_fdec rising edge
    end
  end

  //---------------Status register------------------------------------------
  always_ff @(posedge clk_sys_i or negedge rst_ni) begin
    if (!rst_ni) begin
      status <= '0;
      status_valid <= 1'b0;

    end else begin
      status <= {data_valid_o, control};
      status_valid <= ~status_valid;
    end
  end

  assign hw2reg.data_out.d = data_o;
  assign hw2reg.data_out.de = data_valid_o;

  assign hw2reg.ses_status.d = status;
  assign hw2reg.ses_status.de = status_valid;


endmodule  // ses_filter
