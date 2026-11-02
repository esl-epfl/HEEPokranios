module WPDT_tx #(
    parameter integer CLOCKS_PER_BIT = 8
) (
    input  wire ref_clk_i,
    output reg  modulated_data_o
);

  localparam integer HALF_PERIOD = CLOCKS_PER_BIT / 2;
  localparam integer MAX_CMDS    = 65536;

  reg     cmd_type     [0:MAX_CMDS-1];
  reg     cmd_bit_val  [0:MAX_CMDS-1];
  integer cmd_wait_cnt [0:MAX_CMDS-1];
  integer num_cmds;

  localparam [1:0]
    ST_LOAD = 2'd0,
    ST_WAIT = 2'd1,
    ST_MAN1 = 2'd2,
    ST_MAN2 = 2'd3;

  reg [1:0] state;
  integer   cmd_idx;
  integer   counter;
  reg       current_bit;

  task automatic load_file(input string filename);
    integer fd, scan_result, wait_cycles, slen;
    string  line;
    integer i;
    fd = $fopen(filename, "r");
    if (fd == 0) begin
      $display("WPDT_tx: Warning: could not open '%s'", filename);
      return;
    end
    while (!$feof(fd)) begin
      scan_result = $fgets(line, fd);
      if (scan_result == 0) break;
      slen = line.len();
      while (slen > 0 &&
             (line[slen-1] == "\n" || line[slen-1] == "\r" || line[slen-1] == " ")) begin
        line = line.substr(0, slen - 2);
        slen = slen - 1;
      end
      if (slen == 0) begin
      end else if ($sscanf(line, "wait:%d", wait_cycles) == 1) begin
        cmd_type[num_cmds]     = 1'b1;
        cmd_wait_cnt[num_cmds] = wait_cycles;
        num_cmds               = num_cmds + 1;
      end else begin
        for (i = 0; i < slen; i = i + 1) begin
          if (line[i] == "1" || line[i] == "0") begin
            cmd_type[num_cmds]    = 1'b0;
            cmd_bit_val[num_cmds] = (line[i] == "1") ? 1'b1 : 1'b0;
            num_cmds              = num_cmds + 1;
          end
        end
      end
    end
    $fclose(fd);
  endtask

  initial begin
    if ((CLOCKS_PER_BIT < 2) || (CLOCKS_PER_BIT % 2 != 0)) begin
      $display("WPDT_tx: ERROR: CLOCKS_PER_BIT must be even and >= 2");
      $finish;
    end

    num_cmds = 0;
    load_file("wpdt_sync.txt");
    load_file("wpdt_data.txt");

    modulated_data_o = 1'b0;
    state            = ST_LOAD;
    cmd_idx          = 0;
    counter          = 0;
    current_bit      = 1'b0;
  end

  always @(posedge ref_clk_i) begin
    case (state)

      ST_LOAD: begin
        if (cmd_idx >= num_cmds) begin
          modulated_data_o <= 1'b0;
          state            <= ST_LOAD;
        end else if (cmd_type[cmd_idx]) begin
          // wait command
          if (cmd_wait_cnt[cmd_idx] <= 0) begin
            cmd_idx <= cmd_idx + 1;
          end else begin
            modulated_data_o <= 1'b0;
            counter          <= cmd_wait_cnt[cmd_idx] - 1;
            cmd_idx          <= cmd_idx + 1;
            state            <= ST_WAIT;
          end
        end else begin
          // first Manchester half starts NOW
          current_bit      <= cmd_bit_val[cmd_idx];
          modulated_data_o <= cmd_bit_val[cmd_idx] ? 1'b0 : 1'b1;
          counter          <= HALF_PERIOD - 1;
          cmd_idx          <= cmd_idx + 1;
          state            <= ST_MAN1;
        end
      end

      ST_WAIT: begin
        if (counter == 0) begin
          // immediately load next command next cycle
          state <= ST_LOAD;
        end else begin
          counter <= counter - 1;
        end
      end

      ST_MAN1: begin
        if (counter == 0) begin
          // second half starts NOW
          modulated_data_o <= current_bit ? 1'b1 : 1'b0;
          counter          <= HALF_PERIOD - 1;
          state            <= ST_MAN2;
        end else begin
          counter <= counter - 1;
        end
      end

      ST_MAN2: begin
        if (counter == 0) begin
          // immediately start next symbol if there is one
          if (cmd_idx >= num_cmds) begin
            modulated_data_o <= 1'b0;
            state            <= ST_LOAD;
          end else if (cmd_type[cmd_idx]) begin
            if (cmd_wait_cnt[cmd_idx] <= 0) begin
              cmd_idx <= cmd_idx + 1;
              state   <= ST_LOAD;
            end else begin
              modulated_data_o <= 1'b0;
              counter          <= cmd_wait_cnt[cmd_idx] - 1;
              cmd_idx          <= cmd_idx + 1;
              state            <= ST_WAIT;
            end
          end else begin
            current_bit      <= cmd_bit_val[cmd_idx];
            modulated_data_o <= cmd_bit_val[cmd_idx] ? 1'b0 : 1'b1;
            counter          <= HALF_PERIOD - 1;
            cmd_idx          <= cmd_idx + 1;
            state            <= ST_MAN1;
          end
        end else begin
          counter <= counter - 1;
        end
      end

      default: begin
        modulated_data_o <= 1'b0;
        state            <= ST_LOAD;
      end

    endcase
  end

endmodule
