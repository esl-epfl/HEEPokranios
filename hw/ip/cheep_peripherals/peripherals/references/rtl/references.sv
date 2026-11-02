// Copyright 2025 EPFL and contributors
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
//
// File: references.sv
// Author: Juan Sapriza
// Date: 03/01/2026
// Description: A subsystem where the analog blocks will be instantiated.
// In the case of RTL-only simulations, the spice models are replaced for behavioral models.

module references (
    input logic clk_i,
    input logic rst_ni,

    input  reg_pkg::reg_req_t refs_ctrl_req_i,
    output reg_pkg::reg_rsp_t refs_ctrl_rsp_o,

`ifdef SYNTHESIS
    inout wire refs_vdd,
    inout wire iref_iout,
    inout wire vref_vout
`else
    output integer iref_iout_int_nA,
    output integer vref_vout_int_mV

`endif

);

  logic [iref_pkg::IrefCalibrationWidth-1:0] iref_calibration;  // Calibration control
  logic [vref_pkg::VrefCalibrationWidth-1:0] vref_calibration;  // Calibration control


`ifdef SYNTHESIS



  iREF u_iREF (
`ifdef USE_PG_PIN
      .IREF_VSS,
`endif
      .iref_calibration_i(iref_calibration),
      .IREF_IOUT(iref_iout),
      .IREF_VDD(refs_vdd),
      .IREF_GATE_DEBUG()
  );

  vREF u_vREF (
`ifdef USE_PG_PIN
      .VREF_VSS,
`endif
      .vref_calibration_i(vref_calibration),
      .VREF_VOUT(vref_vout),
      .VREF_VDD(refs_vdd),
      .VREF_GATE_DEBUG()
  );



`else

  // VERILOG BEHAVIORAL MODELS
  // -------------------------

  iREF u_iREF (
      .IOUT_int_nA(iref_iout_int_nA),
      .CAL(iref_calibration)
  );

  vREF u_vREF (
      .VOUT_int_mV(vref_vout_int_mV),
      .CAL(vref_calibration)
  );

`endif


  refs_ctrl u_refs_ctrl (
      .clk_i             (clk_i),
      .rst_ni            (rst_ni),
      .req_i             (refs_ctrl_req_i),
      .rsp_o             (refs_ctrl_rsp_o),
      .iref_calibration_o(iref_calibration),
      .vref_calibration_o(vref_calibration)
  );

endmodule
