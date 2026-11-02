
`include "analog_defs.svh"
import analog_defs::analog_type;

module SE_BUFF_wrapper #()(
    /* verilator lint_off UNUSED */
    input `analog_t bvdd,
    input `analog_t ibias,
    input `analog_t vin,           // Input Voltage (uV)
    output `analog_t vout,         // Output voltage (uV)
    input logic en_ni
    /* verilator lint_on UNUSED */
);

`ifdef SYNTHESIS

    SE_BUFF u_SE_BUFF(
        .EN_N_PREBUF(en_ni),
        .IBIAS_IN(ibias),
        .VIN(vin),
        .VOUT(vout),
        .BVDD(bvdd)
    );

`else

    assign vout = vin;

`endif

endmodule
