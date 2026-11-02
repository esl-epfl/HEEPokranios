`include "analog_defs.svh"
import analog_defs::analog_type;

module WPDT_wrapper #(
    parameter integer CLOCKS_PER_BIT  = 8,
    parameter integer MAX_BITS        = 64
) (
    /* verilator lint_off UNDRIVEN*/
    /* verilator lint_off UNUSED*/
    input  `analog_t ant_p,
    input  `analog_t ant_n,
    input `analog_t blocks_vin,
    input `analog_t data_clk_vin,
    input `analog_t ibias_iin,
    input `analog_t ldo_vin,
    output `analog_t ldo_vout, 
    output `analog_t rect_vout,

    // Uplink
    input  logic uplink_uncoded_data_i,
    input  logic uplink_encoding_clk_i,
    input  logic uplink_rst_i,

    // Downlink
    output logic downlink_decoded_clk_o,
    output logic downlink_decoded_data_o,
    output logic downlink_decoded_valid_o,
    input logic downlink_rst_i,

    // Output clock
    output logic ref_clk_o,

    input logic rst_i // active high!
    /* verilator lint_on UNUSED*/
    /* verilator lint_on UNDRIVEN*/
);

  `ifdef SYNTHESIS


  WPDT u_wpdt(
    .ref_clk_o,
    .uplink_uncoded_data_i,
    .uplink_encoding_clk_i,
    .uplink_rst_i,
    .downlink_decoded_clk_o,
    .downlink_decoded_data_o,
    .downlink_decoded_valid_o,
    .downlink_rst_i,
    .BLOCKS_VIN(blocks_vin),
    .DATA_CLK_VIN(data_clk_vin),
    .IBIAS_IIN(ibias_iin),
    .LDO_VIN(ldo_vin),
    .RECT_VOUT(rect_vout),
    .LDO_VOUT(ldo_vout)   
    );


  `else

    localparam integer HALF_PERIOD    = (CLOCKS_PER_BIT / 2);
    localparam integer QUARTER_PERIOD = ((CLOCKS_PER_BIT / 4) < 1) ? 1 : (CLOCKS_PER_BIT / 4);

    localparam logic [1:0]
      ST_SEARCH_SYNC     = 2'd0,
      ST_SEARCH_PREAMBLE = 2'd1,
      ST_PAYLOAD         = 2'd2;

    logic carrier_clk;
    assign carrier_clk = ant_n[0];

    logic downlink_encoded_data;
    assign downlink_encoded_data = ant_p[0];

    // assign ldo_vout_o = 2*ldo_vin_i; // 1V output, but its treated as an input for the synthesis to accept that the digital pins are referenced to this voltage

    logic sync_bits     [0:MAX_BITS-1];
    logic preamble_bits [0:MAX_BITS-1];

    logic sync_man      [0:(2*MAX_BITS)-1];
    logic preamble_man  [0:(2*MAX_BITS)-1];

    integer sync_len;
    integer preamble_len;
    integer sync_man_len;
    integer preamble_man_len;

    logic [1:0] state;
    integer sample_countdown;
    integer sync_match_idx;
    integer preamble_match_idx;

    logic payload_half_phase;
    logic first_half_sample;
    logic pending_decoded_bit;
    logic pending_decoded_valid;

    logic   decoded_clk_q;
    logic   clk_enabled;
    integer clk_toggle_countdown;

    logic downlink_decoded_detected;

    logic tx_enable;
    logic tx_uncoded_sampled;

    logic ant_p_q;
    logic reset_data_q;

    integer i;
    integer fd;
    integer scan_result;
    integer slen;
    string  line;

    /* verilator lint_off UNUSED */
    logic uplink_encoded_data_o; // This is not an output, its just for debugging
    /* verilator lint_on UNUSED */

                                                    // At some point we thought of removing this AND in
                                                    // the circuit, but it introduced other issues.

    assign downlink_decoded_clk_o = ~decoded_clk_q & downlink_decoded_valid_o;

    task automatic load_bits_file(
        input string  filename,
        input integer which_file
    );
      begin
        fd = $fopen(filename, "r");
        if (fd == 0) begin
          $display("WPDT_wrapper: Warning: could not open '%s'", filename);
        end else begin
          while (!$feof(fd)) begin
            scan_result = $fgets(line, fd);
            if (scan_result != 0) begin
              slen = line.len();

              while (slen > 0 &&
                    (line[slen-1] == "\n" || line[slen-1] == "\r" || line[slen-1] == " ")) begin
                line = line.substr(0, slen - 2);
                slen = slen - 1;
              end

              if (slen == 0) begin
              end else if (line[0] != "0" && line[0] != "1") begin
              end else begin
                for (i = 0; i < slen; i = i + 1) begin
                  if (line[i] == "0" || line[i] == "1") begin
                    if (which_file == 0) begin
                      if (sync_len < MAX_BITS) begin
                        sync_bits[sync_len] = (line[i] == "1") ? 1'b1 : 1'b0;
                        sync_len            = sync_len + 1;
                      end
                    end else begin
                      if (preamble_len < MAX_BITS) begin
                        preamble_bits[preamble_len] = (line[i] == "1") ? 1'b1 : 1'b0;
                        preamble_len               = preamble_len + 1;
                      end
                    end
                  end
                end
              end
            end
          end
          $fclose(fd);
        end
      end
    endtask

    task automatic build_expected_patterns;
      begin
        sync_man_len = 2 * sync_len;
        for (i = 0; i < sync_len; i = i + 1) begin
          sync_man[2*i]     = sync_bits[i] ? 1'b0 : 1'b1;
          sync_man[2*i + 1] = sync_bits[i] ? 1'b1 : 1'b0;
        end

        preamble_man_len = 2 * preamble_len;
        for (i = 0; i < preamble_len; i = i + 1) begin
          preamble_man[2*i]     = preamble_bits[i] ? 1'b0 : 1'b1;
          preamble_man[2*i + 1] = preamble_bits[i] ? 1'b1 : 1'b0;
        end
      end
    endtask

    initial begin
      sync_len         = 0;
      preamble_len     = 0;
      sync_man_len     = 0;
      preamble_man_len = 0;

      load_bits_file("wpdt_sync.txt",     0);
      load_bits_file("wpdt_preamble.txt", 1);
      build_expected_patterns();

      state                  = ST_SEARCH_SYNC;
      sample_countdown       = QUARTER_PERIOD;
      sync_match_idx         = 0;
      preamble_match_idx     = 0;
      payload_half_phase     = 1'b0;
      first_half_sample      = 1'b0;
      pending_decoded_bit    = 1'b0;
      pending_decoded_valid  = 1'b0;

      downlink_decoded_data_o  = 1'b0;

      decoded_clk_q        = 1'b0;
      clk_enabled          = 1'b0;
      clk_toggle_countdown = 0;

      tx_enable          = 1'b1;
      tx_uncoded_sampled = 1'b0;
      uplink_encoded_data_o = 1'b0;

      ant_p_q      = 1'b0;
      reset_data_q = 1'b0;
    end

    always @(posedge uplink_encoding_clk_i or posedge rst_i) begin
      if (rst_i) begin
        uplink_encoded_data_o <= 1'b0;
        tx_uncoded_sampled    <= 1'b0;
      end else if (tx_enable) begin
        uplink_encoded_data_o <= tx_uncoded_sampled ? 1'b1 : 1'b0;
        tx_uncoded_sampled    <= uplink_uncoded_data_i;
      end else begin
        uplink_encoded_data_o <= 1'b0;
        tx_uncoded_sampled    <= uplink_uncoded_data_i;
      end
    end

    assign ref_clk_o = carrier_clk;

    always_ff @(posedge decoded_clk_q or posedge rst_i) begin
      if (rst_i) begin
        downlink_decoded_valid_o <= 1'b0;
      end else if (downlink_rst_i) begin
        downlink_decoded_valid_o <= 1'b0;
      end else begin
        downlink_decoded_valid_o <= downlink_decoded_detected;
      end
    end

    always @(posedge carrier_clk or posedge rst_i) begin
      logic ant_p_edge_now;
      logic reset_data_rise_now;

      if (rst_i) begin
        ant_p_q                  <= 1'b0;
        reset_data_q             <= 1'b0;

        sample_countdown         <= QUARTER_PERIOD;
        clk_toggle_countdown     <= 0;
        clk_enabled              <= 1'b0;
        decoded_clk_q            <= 1'b0;

        downlink_decoded_data_o  <= 1'b0;
        downlink_decoded_detected <= 1'b0;

        pending_decoded_bit      <= 1'b0;
        pending_decoded_valid    <= 1'b0;

        state                    <= ST_SEARCH_SYNC;
        sync_match_idx           <= 0;
        preamble_match_idx       <= 0;
        payload_half_phase       <= 1'b0;
        first_half_sample        <= 1'b0;

      end else begin
        ant_p_edge_now = (downlink_encoded_data != ant_p_q);
        reset_data_rise_now = downlink_rst_i && !reset_data_q;

        ant_p_q      <= downlink_encoded_data;
        reset_data_q <= downlink_rst_i;

        if (ant_p_edge_now) begin
          sample_countdown <= QUARTER_PERIOD;
        end else begin
          if (sample_countdown == 1) begin
            sample_countdown <= HALF_PERIOD;
          end else begin
            sample_countdown <= sample_countdown - 1;
          end
        end

        // Independent decoded clock generator.
        // Do not gate or reset this with downlink_rst_i.
        if (clk_enabled) begin
          if (clk_toggle_countdown == 1) begin
            if (decoded_clk_q == 1'b0) begin
              if (pending_decoded_valid) begin
                downlink_decoded_data_o <= pending_decoded_bit;
                pending_decoded_valid   <= 1'b0;
              end
            end

            decoded_clk_q        <= ~decoded_clk_q;
            clk_toggle_countdown <= HALF_PERIOD;
          end else begin
            clk_toggle_countdown <= clk_toggle_countdown - 1;
          end
        end

        if (reset_data_rise_now) begin
          state                   <= ST_SEARCH_PREAMBLE;
          preamble_match_idx      <= 0;
          payload_half_phase      <= 1'b0;
          pending_decoded_valid   <= 1'b0;
          downlink_decoded_detected <= 1'b0;
        end else if (sample_countdown == 1) begin
          case (state)
            ST_SEARCH_SYNC: begin
              if (sync_man_len != 0) begin
                if (downlink_encoded_data == sync_man[sync_match_idx]) begin
                  if (sync_match_idx == (sync_man_len - 1)) begin
                    state                <= ST_SEARCH_PREAMBLE;
                    sync_match_idx       <= 0;
                    preamble_match_idx   <= 0;
                    payload_half_phase   <= 1'b0;

                    clk_enabled          <= 1'b1;
                    decoded_clk_q        <= 1'b0;
                    clk_toggle_countdown <= HALF_PERIOD + 1;
                  end else begin
                    sync_match_idx <= sync_match_idx + 1;
                  end
                end else begin
                  sync_match_idx <= (downlink_encoded_data == sync_man[0]) ? 1 : 0;
                end
              end
            end

            ST_SEARCH_PREAMBLE: begin
              if (preamble_man_len != 0) begin
                if (downlink_encoded_data == preamble_man[preamble_match_idx]) begin
                  if (preamble_match_idx == (preamble_man_len - 1)) begin
                    state                    <= ST_PAYLOAD;
                    preamble_match_idx       <= 0;
                    payload_half_phase       <= 1'b0;
                    downlink_decoded_detected <= 1'b1;
                  end else begin
                    preamble_match_idx <= preamble_match_idx + 1;
                  end
                end else begin
                  preamble_match_idx <= (downlink_encoded_data == preamble_man[0]) ? 1 : 0;
                end
              end
            end

            ST_PAYLOAD: begin
              if (payload_half_phase == 1'b0) begin
                first_half_sample  <= downlink_encoded_data;
                payload_half_phase <= 1'b1;
              end else begin
                if ((first_half_sample == 1'b0) && (downlink_encoded_data == 1'b1)) begin
                  pending_decoded_bit   <= 1'b1;
                  pending_decoded_valid <= 1'b1;
                end else if ((first_half_sample == 1'b1) && (downlink_encoded_data == 1'b0)) begin
                  pending_decoded_bit   <= 1'b0;
                  pending_decoded_valid <= 1'b1;
                end
                payload_half_phase <= 1'b0;
              end
            end

            default: begin
              state <= ST_SEARCH_SYNC;
            end
          endcase
        end
      end
    end
  `endif

endmodule
