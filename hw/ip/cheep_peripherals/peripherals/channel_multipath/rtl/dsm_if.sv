`include "analog_defs.svh"
import analog_defs::analog_type;

interface dsm_if;
  import analog_defs::*;
  `analog_t vdd;
  `analog_t ibias;
  `analog_t vin_p;
  `analog_t vin_n;
  logic clk_i;
  logic dec_i;
  logic clk_o;
  logic out_o;

  reg_pkg::reg_req_t ctrl_req_i;
  reg_pkg::reg_rsp_t ctrl_rsp_o;

  reg_pkg::reg_req_t cic_req_i;
  reg_pkg::reg_rsp_t cic_rsp_o;
  reg_pkg::reg_req_t ses_req_i;
  reg_pkg::reg_rsp_t ses_rsp_o;

  modport signals(
      input vdd, ibias, vin_p, vin_n, clk_i, dec_i, ctrl_req_i, cic_req_i, ses_req_i,
      output clk_o, out_o, ctrl_rsp_o, cic_rsp_o, ses_rsp_o
  );

endinterface
