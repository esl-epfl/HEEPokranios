
`include "analog_defs.svh"
import analog_defs::analog_type;

module <EXAMPLE>_wrapper #(
    parameter int gain = 16,
    parameter int Vcm = 500_000,
    parameter int vmax = 1_000_000
)(
      /* verilator lint_off UNUSED */
    input `analog_t vdd,            // Kept for interface compatibility
    input `analog_t vin_p,           // Input Voltage (uV)
    input `analog_t vin_n,           // Input Voltage (uV)
    output `analog_t vout_p,         // Output voltage (uV)
    output `analog_t vout_n,         // Output voltage (uV)
    input logic clk_i,
    input logic rst_ni,
      /* verilator lint_on UNUSED */
    input logic en_i
);

    `ifdef SYNTHESIS

    <EXAMPLE> u_<EXAMPLE>(
        .clk_i,
        .en_i
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
        if (!en_i) begin
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
