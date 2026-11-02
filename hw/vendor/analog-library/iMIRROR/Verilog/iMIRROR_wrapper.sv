
`include "analog_defs.svh"
import analog_defs::analog_type;

module iMIRROR_wrapper (
      /* verilator lint_off UNUSED */
    input `analog_t bvdd,            
    input `analog_t iin,
    output `analog_t [18:0] iout
      /* verilator lint_on UNUSED */
);

    `ifdef SYNTHESIS

    iMIRROR u_iMIRROR (
        .BVDD(bvdd),
        .I_IN_1uA(iin),
        .I_OUT_1uA(iout)
    );

    `else

        assign iout = '{default: iin};

    `endif

endmodule
