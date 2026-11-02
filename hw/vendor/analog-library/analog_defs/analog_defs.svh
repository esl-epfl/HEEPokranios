`ifndef _ANALOG_PKG
`define _ANALOG_PKG

package analog_defs;
`ifdef SYNTHESIS
    // This typedef is only for the imports that expect to find this defined, but should not be used
    typedef logic analog_type;

    `ifndef POSTSYNTHESIS_SIM
        `ifndef POSTLAYOUT
            `define analog_t (* dont_touch = "true" *) wire
        `else
            `define analog_t logic
        `endif
    `else
        `define analog_t logic
    `endif

`else
    typedef logic signed [31:0] analog_type;
    `define analog_t analog_type
`endif
endpackage

`endif
