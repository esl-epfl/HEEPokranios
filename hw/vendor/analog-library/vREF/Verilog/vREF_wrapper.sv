// vREF dummy behavioral model
// SystemVerilog Model
// Juan Sapriza - 2025

`include "analog_defs.svh"
import analog_defs::analog_type;


module vREF_wrapper #()(
    /* verilator lint_off UNUSED */
    input   logic [vref_pkg::VrefCalibrationWidth-1:0] cal_i,
    
    input `analog_t hvdd,
    input `analog_t en,
    input `analog_t ibias_iin_0,
    input `analog_t ibias_iin_1,
    input `analog_t ibias_iin_2,
    output `analog_t vref_0v4_buff,
    output `analog_t vref_0v5_buff,
    output `analog_t vref_0v6_buff,
    output `analog_t vref_0v5_unbuff,
    input `analog_t bvdd
    /* verilator lint_on UNUSED */
);

`ifdef SYNTHESIS

    vREF u_vREF(
        .HVDD(hvdd),
        .EN(en),
        .IBIAS_IIN_0(ibias_iin_0),
        .IBIAS_IIN_1(ibias_iin_1),
        .IBIAS_IIN_2(ibias_iin_2),
        .VREF_0V4_BUFF(vref_0v4_buff),
        .VREF_0V5_BUFF(vref_0v5_buff),
        .VREF_0V6_BUFF(vref_0v6_buff),
        .VREF_0V5_UNBUFF(vref_0v5_unbuff),
        .BVDD(bvdd)
    );

`else

    assign vref_0v4_buff = 400_000;
    assign vref_0v5_buff = 500_000;
    assign vref_0v6_buff = 600_000;
    assign vref_0v5_unbuff = 500_000;

`endif

endmodule
