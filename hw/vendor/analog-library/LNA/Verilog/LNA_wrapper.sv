`include "analog_defs.svh"
import analog_defs::analog_type;

module LNA_wrapper #(
    parameter int gain = 16,
    parameter int Vcm = 400_000,
    parameter int vmax = 1_000_000
)(
      /* verilator lint_off UNUSED */
    input `analog_t bvdd,   
    input  `analog_t ibias,            
    input `analog_t vcm,            // Common-mode voltage (0.4V)
    input `analog_t vin_p,           // Input Voltage (uV)
    input `analog_t vin_n,           // Input Voltage (uV)
    output `analog_t vout_p,         // Output voltage (uV)
    output `analog_t vout_n,         // Output voltage (uV)
    input [2:0] pr_i,
    input [1:0] gain_i,
    input [1:0] cutoff_i,
    input logic clk_i,
    input logic rst_i,
      /* verilator lint_on UNUSED */
    input logic en_ni
);

    `ifdef SYNTHESIS

    LNA u_LNA(
        .BVDD(bvdd),
        .IBIAS_IIN(ibias),
        .VCM_VIN(vcm),
        .VIN_N(vin_n),
        .VIN_P(vin_p),
        .VOUT_P(vout_p),
        .VOUT_N(vout_n),
        .pr_sel_0(pr_i[0]),
        .pr_sel_1(pr_i[1]),
        .pr_sel_2(pr_i[2]),
        .gain_sel_0(gain_i[0]),
        .gain_sel_1(gain_i[1]),
        .cutoff_sel_0(cutoff_i[0]),
        .cutoff_sel_1(cutoff_i[1]),
        .rst(rst_i),
        .en_n(en_ni)
    );

    `else
    /* verilator lint_off LATCH */

    `analog_t vin_p_clamped;
    `analog_t vin_n_clamped;
    `analog_t vdiff;
    `analog_t vampl;

    always_comb begin
        // Clamping Positive Input
        if (vin_p > vmax) vin_p_clamped = vmax;
        else vin_p_clamped = vin_p;

        // Clamping Negative Input
        if (vin_n > vmax) vin_n_clamped = vmax;
        else vin_n_clamped = vin_n;
    end

    always_comb begin
        if (en_ni) begin
            vout_p = Vcm;
            vout_n = Vcm;
            vdiff = '0;
            vampl = '0;

        end else begin
            vdiff = vin_p_clamped - vin_n_clamped;
            vampl = vdiff*gain;

            vout_p = (Vcm + vampl/2);
            vout_n = (Vcm - vampl/2);
        end
    end
/* verilator lint_on LATCH */
    `endif

endmodule
