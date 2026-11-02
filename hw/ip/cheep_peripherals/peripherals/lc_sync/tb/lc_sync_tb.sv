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
// File: lc_sync_tb.sv
// Author(s):
//   Juan Sapriza <juan.sapriza@epfl.ch>
//   Michele Caon <michele.caon@epfl.ch>
// Date: 13/06/2026
// Description: TB

module lc_sync_tb #(
    parameter int unsigned SIM_CYCLES      = 'd1000,
    parameter int unsigned SAMPLE_UPD_PROB = 'd50,
    parameter int unsigned DUT_CLK_DIV     = 'd20,
    parameter int unsigned MONITOR_EN      = 'd1,
    parameter int unsigned SYNC_STAGES     = 'd2
);
  // PARAMETERS
  // --------------------------------------------------------------------------
  // The assumption is that the input signal is stable for at least one
  // sampling clock cycle.
  localparam int unsigned SampleMinPeriod = DUT_CLK_DIV + 'd1;
  localparam int unsigned DelayCycles = SYNC_STAGES * DUT_CLK_DIV;

  // INTERNAL SIGNALS
  // --------------------------------------------------------------------------
  logic                       clk;
  logic                       rst_n;

  // DUT clock generator
  logic                       dut_clk;
  logic [               31:0] dut_clk_cnt;

  // Input data generator
  logic [SampleMinPeriod-1:0] xing_samples_in;
  logic [SampleMinPeriod-1:0] dir_samples_in;
  logic                       xing_delay_queue[DelayCycles+1];
  logic                       dir_delay_queue [DelayCycles+1];
  logic                       xing_delayed_q;
  logic                       dir_delayed_q;
  logic                       xing_stable;
  logic                       dir_stable;

  // DUT output
  logic                       xing_out;
  logic                       dir_out;

  // --------------------------------------------------------------------------
  // CLOCK AND RESET GENERATION
  // --------------------------------------------------------------------------
  // Clock generator
  always begin
    #1 clk = 1'b0;
    #1 clk = 1'b1;
  end

  // Reset generator
  initial begin
    rst_n = 1'b0;
    repeat (2) @(posedge clk);
    rst_n = 1'b1;
    repeat (SIM_CYCLES) @(posedge clk);
    $finish();
  end

  // DUT clock divider
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      dut_clk_cnt <= '0;
    end else begin
      dut_clk_cnt <= dut_clk_cnt + 'h01;
    end
  end

  // DUT clock generator
  always_ff @(posedge clk or negedge rst_n) begin
    if (rst_n && dut_clk_cnt % (DUT_CLK_DIV / 32'd2) == '0) begin
      dut_clk <= ~dut_clk;
    end
  end

  // --------------------------------------------------------------------------
  // INPUT SIGNAL GENERATOR
  // --------------------------------------------------------------------------
  // Random level crossing event generator
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      xing_samples_in <= '0;
    end else begin
      // Generate a new sample with a certain probability
      // Use the newly generate input only if the current output has been stable
      // for SampleMinPeriod cycles.
      if (xing_stable && ($random() % 100 <= SAMPLE_UPD_PROB)) begin
        xing_samples_in[0] <= $urandom();
      end

      // Propagate xing_samples_in
      for (int unsigned i = 1; i < SampleMinPeriod; ++i) begin
        xing_samples_in[i] <= xing_samples_in[i-1];
      end
    end
  end

  // Random crossing direction generation
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      dir_samples_in <= '0;
    end else begin
      // Generate a new sample with a certain probability
      // Use the newly generate input only if the current output has been stable
      // for SampleMinPeriod cycles.
      if (dir_stable && ($random() % 100 <= SAMPLE_UPD_PROB)) begin
        dir_samples_in[0] <= $urandom();
      end

      // Propagate dir_samples_in
      for (int unsigned i = 1; i < SampleMinPeriod; ++i) begin
        dir_samples_in[i] <= dir_samples_in[i-1];
      end
    end
  end

  // Stable sample detector
  always_comb begin
    xing_stable = 1'b1;
    dir_stable  = 1'b1;
    foreach (xing_samples_in[i]) begin
      xing_stable &= xing_samples_in[i] == xing_samples_in[0];
      dir_stable &= dir_samples_in[i] == dir_samples_in[0];
    end
  end

  // --------------------------------------------------------------------------
  // MONITORS
  // --------------------------------------------------------------------------
  // DUT monitor
  generate
    if (MONITOR_EN != '0) begin : gen_monitor
      always_ff @(posedge clk) begin
        $display("[MONITOR] %5tns > sample_in: %b, dir_in: %b | xing_out: %d, dir_out", $time(), xing_samples_in[0], dir_samples_in[0], xing_out,
                 dir_out);
      end
    end
  endgenerate

  // Delayed sample input (delays input by SYNC_STAGES to ease debugging)
  assign xing_delay_queue[0] = xing_samples_in[0];
  assign dir_delay_queue[0]  = dir_samples_in[0];
  always_ff @(posedge clk or negedge rst_n) begin
    for (int unsigned i = 1; i <= DelayCycles; ++i) begin
      if (!rst_n) begin
        xing_delay_queue[i] <= 1'b0;
        dir_delay_queue[i]  <= 1'b0;
      end else begin
        xing_delay_queue[i] <= xing_delay_queue[i-1];
        dir_delay_queue[i]  <= dir_delay_queue[i-1];
      end
    end
  end
  assign xing_delayed_q = xing_delay_queue[DelayCycles];
  assign dir_delayed_q  = dir_delay_queue[DelayCycles];

  // --------------------------------------------------------------------------
  // DUT INSTANCE
  // --------------------------------------------------------------------------
  ddr_edge_detector #(
      .SYNC_STAGES(SYNC_STAGES)
  ) dut (
      .clk_i (dut_clk),
      .rst_ni(rst_n),
      .xing_i(xing_samples_in[0]),
      .dir_i (dir_samples_in[0]),
      .xing_o(xing_out),
      .dir_o (dir_out)
  );

  // --------------------------------------------------------------------------
  // DPI INTERFACE
  // --------------------------------------------------------------------------
  // Expose RTL parameters to C++ TB
  export "DPI-C" function tb_get_params;
  function automatic void tb_get_params(output int unsigned sim_cycles, output int unsigned sample_upd_prob, output int unsigned dut_clk_div,
                                        output int unsigned sync_stages);
    sim_cycles      = SIM_CYCLES;
    sample_upd_prob = SAMPLE_UPD_PROB;
    dut_clk_div     = DUT_CLK_DIV;
    sync_stages     = SYNC_STAGES;
  endfunction

  // --------------------------------------------------------------------------
  // ASSERTIONS
  // --------------------------------------------------------------------------
`ifndef VERILATOR
  property p_edge_detected;
    @(posedge dut_clk) disable iff (!rst_n) $rose(
        xing_samples_in[0]
    ) |-> ##SYNC_STAGES(xing_out ##1 !xing_out);
  endproperty

  a_edge_detected :
  assert property (p_edge_detected)
  else $error("[ASSERT] rising edge not detected");
`endif
endmodule
