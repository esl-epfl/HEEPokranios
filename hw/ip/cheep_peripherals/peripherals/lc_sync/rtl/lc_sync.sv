// Copyright (c) 2026 EPFL.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 2.0 (the "License"); you may not use this file except in
// compliance with the License. You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-2.0. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.
//
// File: lc_sync.sv
// Author(s):
//   Juan Sapriza <juan.sapriza@epfl.ch>
//   Michele Caon <michele.caon@epfl.ch>
// Date: 13/06/2026
// Description: Alexander Supersampler 😎

// IMPORTANT:
// This module assumes that the asynchronous input signal remains stable to one
// of its stable for at least one clock cycle.

module lc_sync #(
    parameter int unsigned SYNC_STAGES = 3
) (
    input logic clk_i,
    input logic rst_ni,

    // Data signals
    input  logic xing_i,
    input  logic dir_i,
    output logic xing_o,
    output logic dir_o
);
  // INTERNAL SIGNALS
  // --------------------------------------------------------------------------
  // Inverted clock
  logic clk_inv;

  // Synchronized input data
  logic data_rising;
  logic data_falling;

  // Previous value FFs
  logic prev_rising_q;
  logic curr_falling_q;
  logic prev_falling_q;

  // --------------------------------------------------------------------------
  // SYNCHRONIZERS
  // --------------------------------------------------------------------------
  // Clock inverter
  assign clk_inv = ~clk_i;

  // Rising-edge synchronizer
  sync #(
      .STAGES(SYNC_STAGES)
  ) sync_rising (
      .clk_i   (clk_i),
      .rst_ni  (rst_ni),
      .serial_i(xing_i),
      .serial_o(data_rising)
  );

  // Falling-edge synchronizer
  // NOTE: constrain accordingly
  sync #(
      .STAGES(SYNC_STAGES)
  ) sync_falling (
      .clk_i   (clk_inv),
      .rst_ni  (rst_ni),
      .serial_i(xing_i),
      .serial_o(data_falling)
  );

  // Crossing direction synchronizer
  sync #(
      .STAGES(SYNC_STAGES)
  ) sync_dir (
      .clk_i   (clk_i),
      .rst_ni  (rst_ni),
      .serial_i(dir_i),
      .serial_o(dir_o)
  );

  // --------------------------------------------------------------------------
  // EDGE DETECTION LOGIC
  // --------------------------------------------------------------------------
  // Positive edge synchronizers
  // --------------------------------------------------------------------------
  // Synchronize current value sampled on negative edge
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) curr_falling_q <= 1'b0;
    else curr_falling_q <= data_falling;
  end

  // Previous value flip flops
  // --------------------------------------------------------------------------
  // Synchronize previous value sampled on rising edge
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) prev_rising_q <= 1'b0;
    else prev_rising_q <= data_rising;
  end

  // Synchronize previous value sampled on falling edge
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) prev_falling_q <= 1'b0;
    else prev_falling_q <= data_falling;
  end

  // Edge detection logic
  // --------------------------------------------------------------------------
  // The following expression is a possible mapping of the Karnaugh map derived
  // from the current and previous value of the input signal given the
  // assumption that the asynchronous input signlas never changes more than
  // once per clock cycle.
  assign xing_o = (~prev_rising_q & data_rising) | (~prev_falling_q & curr_falling_q & ~data_rising);
endmodule
