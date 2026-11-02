module decimator #(
    parameter COUNTER_WIDTH = 4
) (
    input logic clk_i,
    input logic rst_i,
    input logic clr_i,

    // Actual decimation factor R
    input logic [COUNTER_WIDTH-1:0] par_decimation_index,

    input  logic en_i,
    output logic en_o
);

  logic [COUNTER_WIDTH-1:0] reg_counter;
  logic [COUNTER_WIDTH-1:0] decim_minus_1;

  assign decim_minus_1 = (par_decimation_index <= 1) ? '0 : par_decimation_index - 1'b1;

  assign en_o = en_i & (reg_counter == decim_minus_1);

  always_ff @(posedge clk_i or negedge rst_i) begin
    if (!rst_i) begin
      reg_counter <= '0;
    end else begin
      if (clr_i) begin
        reg_counter <= '0;
      end else if (en_i) begin
        if (reg_counter == decim_minus_1) reg_counter <= '0;
        else reg_counter <= reg_counter + 1'b1;
      end
    end
  end

endmodule
