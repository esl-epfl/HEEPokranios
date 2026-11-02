// Copyright 2026 EPFL and contributors
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
//
// File: circular_buffer.sv
// Author: Juan Sapriza
// Date: 28/4/2026

module circular_buffer #(
    parameter int DEPTH = 5,
    parameter int WIDTH = 16
) (
    input  logic               clk_i,
    input  logic               rst_ni,
    input  logic               flush_i,           // Flush the buffer to clean it
    input  logic [WIDTH - 1:0] data_i,            // Input data to be added to the circular buffer
    input  logic               data_push_i,       // Flag to add the input data into the circular buffer
    output logic [WIDTH - 1:0] data_o,            // Output word taken from the
    output logic               data_not_empty_o,  // Flag to signal that output data is available
    input  logic               data_pop_i         // Flag to signal that the output word has been read from outside
);

  localparam int CNT_WIDTH = $clog2(DEPTH + 1);
  localparam int PTR_WIDTH = (DEPTH > 1) ? $clog2(DEPTH) : 1;
  localparam logic [CNT_WIDTH-1:0] MAX_COUNT = CNT_WIDTH'(DEPTH);
  localparam logic [PTR_WIDTH-1:0] MAX_IDX = PTR_WIDTH'(DEPTH - 1);

  // Storage array
  logic [  WIDTH - 1:0] buffer [DEPTH];

  // Dynamically sized Pointers and Counter
  logic [PTR_WIDTH-1:0] wr_ptr;
  logic [PTR_WIDTH-1:0] rd_ptr;
  logic [CNT_WIDTH-1:0] count;

  // Status signals
  logic full, empty;

  assign full  = (count == MAX_COUNT);
  assign empty = (count == '0);

  // --- Circular Buffer Logic ---
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      buffer <= '{default: '0};
      wr_ptr <= '0;
      rd_ptr <= '0;
      count  <= '0;
    end else begin
      if (flush_i) begin
        buffer <= '{default: '0};
        wr_ptr <= '0;
        rd_ptr <= '0;
        count  <= '0;
      end else begin
        case ({
          data_push_i, data_pop_i
        })

          // CASE 1: Write Only
          2'b10: begin
            buffer[wr_ptr] <= data_i;

            // Explicit width casting on the incrementer (PTR_WIDTH'(1))
            wr_ptr <= (wr_ptr == MAX_IDX) ? '0 : wr_ptr + PTR_WIDTH'(1);

            if (full) begin
              rd_ptr <= (rd_ptr == MAX_IDX) ? '0 : rd_ptr + PTR_WIDTH'(1);
            end else begin
              count <= count + CNT_WIDTH'(1);
            end
          end

          // CASE 2: Read Only
          2'b01: begin
            if (!empty) begin
              rd_ptr <= (rd_ptr == MAX_IDX) ? '0 : rd_ptr + PTR_WIDTH'(1);
              count  <= count - CNT_WIDTH'(1);
            end
          end

          // CASE 3: Simultaneous Write and Read
          2'b11: begin
            buffer[wr_ptr] <= data_i;
            wr_ptr <= (wr_ptr == MAX_IDX) ? '0 : wr_ptr + PTR_WIDTH'(1);

            rd_ptr <= (rd_ptr == MAX_IDX) ? '0 : rd_ptr + PTR_WIDTH'(1);

            if (empty) begin
              count <= CNT_WIDTH'(1);
            end
          end

          default: ;  // Do nothing
        endcase
      end
    end
  end

  // --- Output Logic ---
  assign data_o           = buffer[rd_ptr];
  assign data_not_empty_o = !empty;

endmodule
