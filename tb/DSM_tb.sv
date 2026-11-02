`ifndef VERILATOR
typedef logic signed [31:0] analog_tb_type;
`define analog_tb_t analog_tb_type
`endif

// DSM behavioral module meant to be used only in the testbench.
// Needs to be separate to not interfere with the actual DSM_wrapper
// module of the analog library, which it is based on.
module DSM_tb (
    /* verilator lint_off UNUSED */
    input  `analog_tb_t       bvdd,
    input  `analog_tb_t       vcm,
    input  `analog_tb_t       ibias,
    input  `analog_tb_t       vin_p,
    input  `analog_tb_t       vin_n,
    input  `analog_tb_t       avss,
    input  logic              fsm_en_ni,
    input  logic              resonator_en_ni,
    input  logic        [4:0] cap_sel_i,
    input  logic        [1:0] lowpower_sel_i,
    input  logic              lfp_en_i,         // Mode 0 or 1
    output logic              out_o,            // Bitstream Output (Pulse Density Modulation)
    input  logic              dsm_en_ni,        // Active LOW
    input  logic              clk_i,
    input  logic              rst_i             // Active HIGH
    /* verilator lint_on UNUSED */
);

  // The DSM inverts the clock input to make sure that the changes
  // are done a loooong time before the back-end samples the data
  logic dsm_clk;
  assign dsm_clk = ~clk_i;

  localparam int FULL_SCALE_UV = 1_000_000;
  `analog_tb_t accumulator;

  // Clamped input to prevent wrap-around errors if VIN > Full Scale
  `analog_tb_t vin_clamped_p;
  `analog_tb_t vin_clamped_n;
  `analog_tb_t delta_in;

  /* verilator lint_off UNUSED */
  logic mode_dummy;
  assign mode_dummy = lfp_en_i;
  /* verilator lint_on UNUSED */

  always_comb begin
    if ($signed(vin_p) > FULL_SCALE_UV) begin
      vin_clamped_p = FULL_SCALE_UV;
    end else if ($signed(vin_p) < 0) begin
      vin_clamped_p = 0;
    end else begin
      vin_clamped_p = vin_p;
    end
  end

  always_comb begin
    if ($signed(vin_n) > FULL_SCALE_UV) begin
      vin_clamped_n = FULL_SCALE_UV;
    end else if ($signed(vin_n) < 0) begin
      vin_clamped_n = 0;
    end else begin
      vin_clamped_n = vin_n;
    end
  end

  // -------------------------------------------------------------------------
  // Sequential Logic: First Order Delta-Sigma Modulator
  // -------------------------------------------------------------------------
  // Algorithm:
  // 1. Integrate the error (Accumulator += Input)
  // 2. If Accumulator >= Threshold (Reference), Output 1 and Subtract Reference
  // 3. Else, Output 0

  always_comb begin
    // 1. Calculate the current differential input
    delta_in = vin_clamped_p - vin_clamped_n;
  end

  always_ff @(posedge dsm_clk or posedge rst_i) begin
    if (rst_i) begin  // active HIGH reset
      accumulator <= '0;
      out_o       <= 1'b0;
    end else if (dsm_en_ni) begin  //active LOW enable
      accumulator <= '0;
      out_o       <= 1'b0;
    end else begin


      // 2. Determine Output and Feedback
      // We look at the accumulator from the PREVIOUS cycle.
      // If it's positive, we output a 1 and subtract the reference.
      // If it's negative (or below threshold), we output 0.
      if (accumulator >= 0) begin
        out_o       <= 1'b1;
        accumulator <= accumulator + delta_in - signed'(FULL_SCALE_UV);
      end else begin
        out_o       <= 1'b0;
        accumulator <= accumulator + delta_in + signed'(FULL_SCALE_UV);
      end
    end
  end

endmodule
