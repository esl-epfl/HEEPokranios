module LDO (
`ifdef USE_PG_PIN
    inout   wire        LDO_VSS,
`endif
    input   wire        LDO_VIN,
    output  wire        LDO_GATE_DEBUG,
    output  wire        LDO_VOUT,
    inout   wire        LDO_VDD
);
endmodule
