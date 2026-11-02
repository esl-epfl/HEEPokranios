module dmux_ctrl (
    input logic       clk_i,
    inout wire  [7:0] dmux,
    input wire  [1:0] dmux_sel
);

  // State definitions
  typedef enum logic [2:0] {
    PWM  = 3'b00,
    DSM  = 3'b01,
    VCO  = 3'b10,
    DLC  = 3'b11,
    NONE = 3'b100
  } state_e;

  logic [7:0] dmux_out;
  logic [7:0] dmux_oe;  // 1 = drive, 0 = Z

  // Drive control
  always_comb begin
    dmux_out = '0;
    dmux_oe  = '0;

    // IMPORTANT: REMEMBER THAT THE LOGIC IS INVERTED HERE!
    // WHATEVER YOU ASSIGN HERE AS "OUTPUT" IS BECAUSE IT WILL
    // BE AN INPUT TO THE CHIP!

    if (state_e'({1'b0, dmux_sel}) == DSM) begin
      // ch 0  DSM out (0) -> decimator in (1)
      dmux_out[1] = dmux[0];
      dmux_oe[1]  = 1;

      // ch 0 DSM clock out (6) -> DSM clock in (2)
      dmux_out[2] = dmux[6];
      dmux_oe[2]  = 1;

      // ch 1  DSM out (0) -> decimator in (1)
      dmux_out[5] = dmux[4];
      dmux_oe[5]  = 1;

      // ch 1 DSM clock out (6) -> DSM clock in (2)
      dmux_out[3] = dmux[7];
      dmux_oe[3]  = 1;

    end

    if (state_e'({1'b0, dmux_sel}) == PWM) begin
      dmux_out[0] = dmux[4];
      dmux_out[1] = dmux[5];
      dmux_out[2] = dmux[6];
      dmux_out[3] = dmux[7];
      dmux_oe[0]  = 1;
      dmux_oe[1]  = 1;
      dmux_oe[2]  = 1;
      dmux_oe[3]  = 1;
    end

    if (state_e'({1'b0, dmux_sel}) == VCO) begin
      dmux_oe = 8'b00100000;
      dmux_out[5] = clk_i;
    end

    if (state_e'({1'b0, dmux_sel}) == NONE) begin
      dmux_oe = '0;
    end

  end



  // Single driver per bit
  genvar i;
  generate
    for (i = 0; i < 8; i++) begin : gen_dmux
      assign dmux[i] = dmux_oe[i] ? dmux_out[i] : 1'bz;
    end
  endgenerate

  // This module never drives the upper 4 bits; leave them as high-impedance
  assign dmux[7:4] = 4'bzzzz;
  /* verilator lint_off UNUSED */
  wire dummy_consume_dmux = &dmux;
  /* verilator lint_on UNUSED */

endmodule
