// Copyright 2026 EPFL.
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
//
// File: heartbeat.sv
// Author: Juan Sapriza

module heartbeat #(
    parameter int DIVIDER = 10  //20
) (
    input  logic clk_i,       // Clock input
    input  logic rst_ni,      // Active-low asynchronous reset
    input  logic alive_i,     // Status input (high = fast blink, low = slow blink)
    output logic heartbeat_o  // Toggling output signal
);

  logic [21:0] counter_q;

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      counter_q <= '0;
    end else begin
      counter_q <= counter_q + 1'b1;
    end
  end

  always_comb begin
    if (alive_i) begin
      heartbeat_o = counter_q[DIVIDER-1];
    end else begin
      heartbeat_o = counter_q[DIVIDER];
    end
  end

endmodule
