// Copyright 2022 EPFL and Politecnico di Torino.
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
//
// File: pad_cell_analog_hiz.sv
// Description: Behavioral model of an analog pad cell for RTL simulation.
//
// In RTL simulation, analog values are represented as 32-bit signed integers
// (see the analog_defs package). The analog pads are transparent: whatever the
// testbench (or an upper-level netlist) drives into the pad reaches the SoC
// unmodified. The supply pads provide fixed nominal values.

module pad_cell_analog_hiz (
    inout wire [31:0] io  // analog pad value
);
  // High-impedance analog pad: no internal driver, the external value flows through.
endmodule
