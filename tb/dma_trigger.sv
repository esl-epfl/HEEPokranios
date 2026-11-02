module dma_trigger (
    input logic sys_clk_i,
    input logic [7:0] dmux_i,
    output logic trigger_o
);

  localparam logic [7:0] PATTERN = 8'b0110_1110;
  // THIS PATTERN IS CORRUPTED BECAUSE IN THE BYTE CONFIGURATION THE DMUX CTRL
  // WILL WIRE SOME BITS TOGETHER

  typedef enum logic [2:0] {
    IDLE,
    WAIT_1,
    PULSE_1,
    WAIT_2,
    PULSE_2
  } state_t;

  state_t state = IDLE;
  int unsigned cnt = 0;

  logic [7:0] dmux_word;

  assign dmux_word = {dmux_i[7], dmux_i[6], dmux_i[5], dmux_i[4], dmux_i[3], dmux_i[2], dmux_i[1], dmux_i[0]};

  always_ff @(posedge sys_clk_i) begin
    trigger_o <= 1'b0;

    case (state)

      IDLE: begin
        cnt <= 0;
        if (dmux_word == PATTERN) state <= WAIT_1;
      end

      WAIT_1: begin
        if (cnt == 999) begin
          cnt   <= 0;
          state <= PULSE_1;
        end else begin
          cnt <= cnt + 1;
        end
      end

      PULSE_1: begin
        trigger_o <= 1'b1;

        if (cnt == 9) begin
          cnt   <= 0;
          state <= WAIT_2;
        end else begin
          cnt <= cnt + 1;
        end
      end

      WAIT_2: begin
        if (cnt == 989) begin
          cnt   <= 0;
          state <= PULSE_2;
        end else begin
          cnt <= cnt + 1;
        end
      end

      PULSE_2: begin
        trigger_o <= 1'b1;

        if (cnt == 9) begin
          cnt   <= 0;
          state <= IDLE;
        end else begin
          cnt <= cnt + 1;
        end
      end

      default: begin
        state <= IDLE;
        cnt <= 0;
        trigger_o <= 1'b0;
      end

    endcase
  end

endmodule
