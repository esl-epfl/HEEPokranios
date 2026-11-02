// iREF dummy behavioral model
// SystemVerilog Model
// Juan Sapriza - 2025

`include "analog_defs.svh"
import analog_defs::analog_type;


module iREF_wrapper #()(
    /* verilator lint_off UNUSED */
    input   logic [iref_pkg::IrefCalibrationWidth-1:0] cal_i, // Calibration bits (5-bit)
    output `analog_t iout,
    input `analog_t bvdd
    /* verilator lint_on UNUSED */
);

`ifdef SYNTHESIS

    iREF u_iREF(
        .iref_calibration_i(cal_i),
        .IREF_IOUT(iout),
        .BVDD(bvdd)
    );

`else

    assign iout = 1_000;

`endif

endmodule

