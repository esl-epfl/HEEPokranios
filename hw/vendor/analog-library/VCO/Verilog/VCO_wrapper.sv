// VCO Module
// Verilog Model
// Filippo Quadri 2025, Juan Sapriza 2026

// =============================================================
//                       VCO Model Summary
// -------------------------------------------------------------
// This module simulates a digital Voltage-Controlled Oscillator
// (VCO) behavior.
//
// ------------------------- Ports -----------------------------
//  vin             : Integer, input voltage in microvolts
//  en_i            : Active-high enable signal
//  rst_ni          : Reset signal (active low)
//  clk_i           : System clock (for consistency, not used)
//  phase_o         : Oscillating output of one of the phases of the VCO
//
// ----------------------- Parameters --------------------------
//   VcoBhvf0_Hz    : Minimum oscillation frequency
//   VcoBhvCoef0_Hz : c_0
//   VcoBhvCoef1_HzmV : c_1.x
//   VcoBhvCoef2_HzmV2 : c_1.x^2
//  VcoBhvGain      : Scaling factor of the oscillation frequency so that it is observable during a simulation
// =============================================================


`include "analog_defs.svh"
import analog_defs::analog_type;

module VCO_wrapper (
    /* verilator lint_off UNUSED */
    input  `analog_t bvdd,
    input  `analog_t vin,
    /* verilator lint_on UNUSED */
    input  logic     clk_i,
    input  logic     rst_ni,
    input  logic     en_i,
    output logic     phase_o
);

    `ifdef SYNTHESIS
    // Synthesis instantiation remains unchanged
    VCO u_VCO (
        .BVDD(bvdd),
        .VCO_CTRL_DEBUG(),
        .VCO_VIN(vin),
        .VCO_REFRESH('0),
        .VCO_EN(en_i),
        .VCO_F_OUT(),
        .VCO_C_OUT(),
        .VCO_VN0(phase_o)
    );
    `else


    function automatic int transfer_uV_to_Hz(input logic [31:0] vin_uV);
        longint x_uV;
        longint acc;
        longint f_hz_raw;

        // x in uV = x in mV * 1000
        x_uV = longint'(vin_uV);

        if (vin_uV < 330_000) return 1;
        acc = 643;                      // 0.00643 * 1e5
        acc = (acc * x_uV) / 1000;      // multiply by x_mV
        acc = acc - 519_000;            // -5.19 * 1e5
        acc = (acc * x_uV) / 1000;      // multiply by x_mV
        acc = acc + 156_000_000;        // 1560 * 1e5
        acc = (acc * x_uV) / 1000;      // multiply by x_mV
        f_hz_raw = (acc / 100_000) - 165_000;

        return int'(f_hz_raw * vco_pkg::VcoBhvFreqGain);
    endfunction

    parameter longint unsigned CLK_FREQ_HZ = 100_000_000;
    parameter int unsigned PHASE_ACC_W = 96;

    logic [PHASE_ACC_W-1:0] phase_acc_q;

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            phase_acc_q <= '0;
            phase_o     <= 1'b0;
        end else if (!en_i) begin
            phase_acc_q <= '0;
            phase_o     <= 1'b0;
        end else begin
            int f_osc_Hz;
            /* verilator lint_off UNUSED */
            logic [127:0] step_full;
            logic [PHASE_ACC_W-1:0] phase_acc_d;
            /* verilator lint_on UNUSED */

            f_osc_Hz = transfer_uV_to_Hz(vin);
            if (f_osc_Hz < 1)
                f_osc_Hz = 1;

            // NCO step:
            // step = f_osc_Hz / CLK_FREQ_HZ * 2^PHASE_ACC_W
            step_full =
                (128'(f_osc_Hz) << PHASE_ACC_W) / 128'(CLK_FREQ_HZ);

            phase_acc_d = phase_acc_q + step_full[PHASE_ACC_W-1:0];

            phase_acc_q <= phase_acc_d;
            phase_o     <= phase_acc_d[PHASE_ACC_W-1];
        end
    end


    `endif

endmodule
