// BPE.sv

`include "analog_defs.svh"
import analog_defs::analog_type;

module BPE_wrapper #(
    parameter int window = 10
)(
      /* verilator lint_off UNUSED */
    input `analog_t bvdd,
    input `analog_t vref,
    input `analog_t vref_comp,
    input `analog_t ibias,
    input `analog_t ibias_buf_p,
    input `analog_t ibias_buf_n,
    input `analog_t vin_p,           // Input Voltage (uV)
    input `analog_t vin_n,           // Input Voltage (uV)
    output `analog_t vout_p,         // Output voltage (uV)
    output `analog_t vout_n,         // Output voltage (uV)
    input logic [5:0] ibias_sel,
    input logic [5:0] ch_en,
    input logic clk_i,
    input logic rst_ni,
    input logic [3:0] pwm_i,
    output logic comp_p_o,
    output logic comp_n_o,
    input logic en_ni
      /* verilator lint_on UNUSED */
);


    `ifdef SYNTHESIS

    BPE u_BPE(
        .CLK(clk_i),
        .EN_N(en_ni), //@juan its active low
        .COMP_P(comp_p_o),
        .COMP_N(comp_n_o),
        .PWM_GM_1( pwm_i[0]),
        .PWM_GM_2( pwm_i[1]),
        .PWM_GM_3( pwm_i[2]),
        .PWM_GM_LP_1(pwm_i[0]),
        .PWM_GM_LP_2(pwm_i[1]),
        .PWM_GM_LP_3(pwm_i[3]),
        .I_SEL(ibias_sel),
        .CH_EN(ch_en),
        .VIN_P(vin_p),
        .VIN_N(vin_n),
        .BVDD(bvdd),
        .VREF(vref),
        .COMP_VREF(vref_comp),
        .IBIAS_IIN(ibias),
        .IBIAS_IIN_BUF(ibias_buf_p),
        .IBIAS_IIN_BUF_N(ibias_buf_n),
        .VOUT_P_BUF(vout_p),
        .VOUT_N_BUF(vout_n)
    );


`else

      typedef longint signed acc_t;

    `analog_t vin_p_clamped;
    `analog_t vin_n_clamped;
    `analog_t vdiff;

    `analog_t pipeline [0:window-1];

    int unsigned ptr;
    int unsigned fill_count;

    acc_t sum_acc;
    acc_t sum_next;
    acc_t denom_next;

    `analog_t v_avg_next;

    assign comp_p_o = clk_i;
    assign comp_n_o = ~clk_i;

    always_comb begin
        vin_p_clamped = (vin_p > bvdd) ? bvdd : vin_p;
        vin_n_clamped = (vin_n > bvdd) ? bvdd : vin_n;
        vdiff = vin_p_clamped - vin_n_clamped;
    end

    always_comb begin
        sum_next   = sum_acc;
        denom_next = acc_t'(window);
        v_avg_next = '0;

        if (!en_ni) begin
            if (fill_count < window) begin
                sum_next   = sum_acc + acc_t'(vdiff);
                denom_next = acc_t'(fill_count) + acc_t'(1);
            end else begin
                sum_next   = sum_acc - acc_t'(pipeline[ptr]) + acc_t'(vdiff);
                denom_next = acc_t'(window);
            end

            v_avg_next = `analog_t'(sum_next / denom_next);
        end
    end

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            ptr        <= 0;
            fill_count <= 0;
            sum_acc    <= '0;
            pipeline   <= '{default: '0};

            vout_p <= `analog_t'(vref);
            vout_n <= `analog_t'(vref);

        end else if (en_ni) begin
            vout_p <= `analog_t'(vref);
            vout_n <= `analog_t'(vref);

        end else begin
            sum_acc <= sum_next;

            pipeline[ptr] <= vdiff;

            if (ptr >= window - 1)
                ptr <= 0;
            else
                ptr <= ptr + 1;

            if (fill_count < window)
                fill_count <= fill_count + 1;

            vout_p <= `analog_t'(vref + (v_avg_next / `analog_t'(2)));
            vout_n <= `analog_t'(vref - (v_avg_next / `analog_t'(2)));
        end
    end

    `endif

endmodule
