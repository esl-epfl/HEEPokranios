module WPDT2ser #(
    parameter logic [7:0] WAIT_SYS_CLK_CC = 8'd255
) (
    input logic clk_i,
    input logic rst_ni,
    input logic detect_i,  // Enable for the clock
    input logic [9:0] payload_length_bits_i,
    input logic sdo_i,  // Data in
    input logic scko_i,  // Clock

    output logic sdo_o,
    output logic scko_o,
    output logic valid_no,
    output logic data_reset_o
);

  logic detect_q;
  logic detect_q_delay;
  logic [9:0] payload_cnt;
  logic [7:0] post_cnt;

  // sdo_o and scko_o are just gated versions of sdo_i and scko_i, gated by detect
  assign sdo_o  = detect_i ? sdo_i : 1'b0;
  assign scko_o = (detect_q_delay & detect_q & ~data_reset_o) ? scko_i : 1'b0;

  // Delay detect
  always_ff @(posedge scko_i or negedge rst_ni) begin
    if (!rst_ni) begin
      detect_q <= 1'b0;
    end else begin
      if (data_reset_o) begin
        detect_q <= 1'b0;
      end else begin
        detect_q <= detect_i;
      end
    end
  end

  always_ff @(negedge scko_i or negedge rst_ni) begin
    if (!rst_ni) begin
      detect_q_delay <= 1'b0;
    end else begin
      if (data_reset_o) begin
        detect_q_delay <= 1'b0;
      end else begin
        detect_q_delay <= detect_q;
      end
    end
  end

  // Count cycles after detect_i goes high
  always_ff @(posedge scko_i or negedge rst_ni) begin
    if (!rst_ni) begin
      payload_cnt <= '0;
    end else begin
      if (detect_i) begin
        if (!detect_q) begin
          payload_cnt <= '0;
        end else begin
          payload_cnt <= payload_cnt + 1;
        end
      end
    end
  end

  // Count cycles after detect_i goes low to keep valid_no low for 24 more cycles
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      post_cnt <= WAIT_SYS_CLK_CC;  // Start at 24 so that valid_no starts high
    end else begin
      if (detect_i) begin
        post_cnt <= '0;
      end else begin
        if (post_cnt < WAIT_SYS_CLK_CC) begin
          post_cnt <= post_cnt + 1;
        end
      end
    end
  end

  // valid_no is low when detect_i is high, and stays low for 24 more cycles after detect_i goes low
  // to check if there is a new detect_i rising edge within that time (which would indicate a new transaction)
  assign valid_no = !(detect_i || (post_cnt < WAIT_SYS_CLK_CC));

  // Pulse data_reset_o for one scko_i cycle payload_length_bits_i cycles after detect_i starts
  always_ff @(negedge scko_i or negedge rst_ni) begin
    if (!rst_ni) begin
      data_reset_o <= 1'b0;
    end else begin
      if (detect_i && payload_cnt == payload_length_bits_i) begin
        data_reset_o <= 1'b1;
      end else begin
        data_reset_o <= 1'b0;
      end
    end
  end

endmodule
