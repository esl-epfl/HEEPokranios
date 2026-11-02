// Copyright 2022 EPFL and Politecnico di Torino.
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
//
// File: pad_cell_analog_io_vdd.sv
// Description: Behavioral model of an analog pad cell for RTL simulation.
//
// In RTL simulation, analog values are represented as 32-bit signed integers
// (see the analog_defs package). The analog pads are transparent: whatever the
// testbench (or an upper-level netlist) drives into the pad reaches the SoC
// unmodified. The supply pads provide fixed nominal values.

module pad_cell_analog_io_vdd (
    output logic [31:0] vdd,    // analog supply
    output logic        tacvdd  // supply timeout alert (never triggered in simulation)
);
  // Fixed-point encoding: 1.2 V
  assign vdd = 32'(1_200_000);
  assign tacvdd = 1'b0;
endmodule
