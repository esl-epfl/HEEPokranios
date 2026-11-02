module reg2ser #(
) (
    input logic clk_i,
    input logic rst_ni,

    input logic scki_i,

    input logic        valid_i,
    input logic [31:0] data_i,
    input logic        half_speed_i,
    input logic [ 1:0] bytes_to_skip_i,

    output logic data_o,
    output logic scko_o,

    output logic ready_o
);

  typedef enum logic {
    ST_IDLE,
    ST_BUSY
  } state_e;

  state_e        state_q;

  logic   [31:0] data_hold_clk;
  logic          half_speed_hold_clk;
  logic   [ 1:0] bytes_to_skip_hold_clk;
  logic          start_toggle_clk;

  logic          done_toggle_scko;
  logic          done_meta_clk;
  logic          done_sync_clk;
  logic          done_seen_clk;

  logic          ready_q;

  assign ready_o = ready_q;

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      state_q                <= ST_IDLE;
      data_hold_clk          <= 32'h0;
      half_speed_hold_clk    <= 1'b0;
      bytes_to_skip_hold_clk <= 2'd0;
      start_toggle_clk       <= 1'b0;
      done_meta_clk          <= 1'b0;
      done_sync_clk          <= 1'b0;
      done_seen_clk          <= 1'b0;
      ready_q                <= 1'b0;
    end else begin
      ready_q <= 1'b0;

      done_meta_clk <= done_toggle_scko;
      done_sync_clk <= done_meta_clk;

      unique case (state_q)

        ST_IDLE: begin
          if (valid_i) begin
            data_hold_clk          <= data_i;
            half_speed_hold_clk    <= half_speed_i;
            bytes_to_skip_hold_clk <= bytes_to_skip_i;
            start_toggle_clk       <= ~start_toggle_clk;
            ready_q                <= 1'b1;
            state_q                <= ST_BUSY;
          end
        end

        ST_BUSY: begin
          if (done_sync_clk != done_seen_clk) begin
            done_seen_clk <= done_sync_clk;
            state_q       <= ST_IDLE;
          end
        end

      endcase
    end
  end

  logic        start_meta_scko;
  logic        start_sync_scko;
  logic        start_seen_scko;

  logic [31:0] word_scko;
  logic [ 5:0] bit_cnt;
  logic [ 5:0] last_bit_idx;
  logic        busy_scko;
  logic        scko_en_q;
  logic        half_speed_scko;
  logic        repeat_q;

  assign scko_o = scko_en_q ? scki_i : 1'b0;

  always_ff @(negedge scki_i or negedge rst_ni) begin
    if (!rst_ni) begin
      start_meta_scko  <= 1'b0;
      start_sync_scko  <= 1'b0;
      start_seen_scko  <= 1'b0;

      word_scko        <= 32'h0;
      bit_cnt          <= 6'd0;
      last_bit_idx     <= 6'd31;
      busy_scko        <= 1'b0;
      scko_en_q        <= 1'b0;
      half_speed_scko  <= 1'b0;
      repeat_q         <= 1'b0;
      data_o           <= 1'b0;
      done_toggle_scko <= 1'b0;
    end else begin
      start_meta_scko <= start_toggle_clk;
      start_sync_scko <= start_meta_scko;

      data_o <= 1'b0;

      if (!busy_scko) begin
        scko_en_q <= 1'b0;
        repeat_q  <= 1'b0;

        if (start_sync_scko != start_seen_scko) begin
          start_seen_scko <= start_sync_scko;

          word_scko       <= data_hold_clk;
          half_speed_scko <= half_speed_hold_clk;

          unique case (bytes_to_skip_hold_clk)
            2'd0: last_bit_idx <= 6'd31;
            2'd1: last_bit_idx <= 6'd23;
            2'd2: last_bit_idx <= 6'd15;
            default: last_bit_idx <= 6'd7;
          endcase

          data_o    <= data_hold_clk[31];
          bit_cnt   <= 6'd0;
          busy_scko <= 1'b1;
          scko_en_q <= 1'b1;
          repeat_q  <= 1'b0;
        end

      end else begin
        if (half_speed_scko && !repeat_q) begin
          repeat_q <= 1'b1;
          data_o   <= word_scko[31-bit_cnt];

        end else begin
          repeat_q <= 1'b0;

          if (bit_cnt < last_bit_idx) begin
            bit_cnt <= bit_cnt + 6'd1;
            data_o  <= word_scko[30-bit_cnt];
          end else begin
            busy_scko        <= 1'b0;
            scko_en_q        <= 1'b0;
            done_toggle_scko <= ~done_toggle_scko;
          end
        end
      end
    end
  end

endmodule
