    `include "analog_defs.svh"
    import analog_defs::analog_type;

    module LC_wrapper (
        /* verilator lint_off UNUSED */
        input  `analog_t bvdd,
        input  `analog_t vcm,
        input  `analog_t ibias,
        input  `analog_t vin,

        input  logic [3:0] w_lvl_sel,
        input  logic [3:0] w_dir_sel,
        input logic [1:0] cap_sel_i,

        output logic       dir_o,
        output logic       xing_o,
        output logic       discharge_o,

        input logic         en_ni,
        input  logic       clk_i,
        input  logic       rst_ni
        /* verilator lint_on UNUSED */
    );

`ifdef SYNTHESIS

      LC u_LC (
          .en_n(en_ni), //active LOW
          .reset_n(rst_ni), // active LOW
          .In0_X(w_lvl_sel[0]),
          .In1_X(w_lvl_sel[1]),
          .In2_X(w_lvl_sel[2]),
          .In3_X(w_lvl_sel[3]),
          .In0_D(w_dir_sel[0]),
          .In1_D(w_dir_sel[1]),
          .In2_D(w_dir_sel[2]),
          .In3_D(w_dir_sel[3]),
          .cap_sel_0(cap_sel_i[0]),
          .cap_sel_1(cap_sel_i[1]),
          .Vin(vin),
          .Ibias(ibias),
          .Xing(xing_o),
          .Disc_O(discharge_o), //@juan use this to filter out the crossings during that process
          .Dir(dir_o),
          .Vref(vcm),
          .BVDD(bvdd)  
      );

`else

    `analog_t Vlvl_uV;
    `analog_t prev_vin;

    longint signed w_lvl_uV;
    longint signed w_lvl_mult;
    longint signed Vres_uV;
    longint signed vin_s;
    longint signed Vlvl_s;

    assign discharge_o = '0;

    always_comb begin
        unique case (w_lvl_sel)
        4'd0:    w_lvl_mult = 64'sd1;
        4'd1:    w_lvl_mult = 64'sd2;
        4'd2:    w_lvl_mult = 64'sd4;
        4'd3:    w_lvl_mult = 64'sd8;
        4'd4:    w_lvl_mult = 64'sd16;
        4'd5:    w_lvl_mult = 64'sd32;
        default: w_lvl_mult = 64'sd32;
        endcase

        w_lvl_uV = 64'sd10_000 * w_lvl_mult;
    end


    typedef enum logic {
        COMPARING,
        UPDATING
    } lc_state_e;

    lc_state_e state_q;

    logic [1:0] xing_cnt;
    logic       lvl_step_up;


    always_comb begin
        vin_s    = longint'($signed(vin));
        Vlvl_s   = longint'($signed(Vlvl_uV));
        Vres_uV  = vin_s - Vlvl_s;
    end

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
        Vlvl_uV     <= vcm;
        prev_vin    <= vcm;
        dir_o       <= 1'b0;
        xing_o      <= 1'b0;
        xing_cnt    <= 2'd0;
        lvl_step_up <= 1'b0;
        state_q     <= COMPARING;

        end else begin
        prev_vin <= vin;

        // Direction of derivative. 1 = going down.
        if ($signed(vin) > $signed(prev_vin)) begin
            dir_o <= 1'b0;
        end else if ($signed(vin) < $signed(prev_vin)) begin
            dir_o <= 1'b1;
        end

        unique case (state_q)

            COMPARING: begin
            xing_o   <= 1'b0;
            xing_cnt <= 2'd0;

            if (Vres_uV > w_lvl_uV) begin
                lvl_step_up <= 1'b1;
                state_q     <= UPDATING;

            end else if (Vres_uV < -w_lvl_uV) begin
                lvl_step_up <= 1'b0;
                state_q     <= UPDATING;
            end
            end

            UPDATING: begin
            xing_o <= 1'b1;

            if (xing_cnt == 2'd0) begin
                if (lvl_step_up) begin
                Vlvl_uV <= Vlvl_uV + `analog_t'(w_lvl_uV);
                end else begin
                    Vlvl_uV <= Vlvl_uV - `analog_t'(w_lvl_uV);
                end

                xing_cnt <= 2'd1;

            end else if (xing_cnt == 2'd1) begin
                xing_cnt <= 2'd2;

            end else begin
                xing_cnt <= 2'd0;
                state_q  <= COMPARING;
            end
            end

            default: begin
            xing_o   <= 1'b0;
            xing_cnt <= 2'd0;
            state_q  <= COMPARING;
            end

        endcase
        end
    end

`endif

    endmodule
