`include "analog_defs.svh"
import analog_defs::analog_type;

interface pdvco_if;
  import analog_defs::*;
  `analog_t vdd;
  `analog_t vin_p;
  `analog_t vin_n;
  logic vco_p_out_o;
  logic vco_n_out_o;
  reg_pkg::reg_req_t vco_p_counter_req_i;
  reg_pkg::reg_rsp_t vco_p_counter_rsp_o;
  reg_pkg::reg_req_t vco_n_counter_req_i;
  reg_pkg::reg_rsp_t vco_n_counter_rsp_o;

  modport signals(
      input vdd, vin_p, vin_n, vco_p_counter_req_i, vco_n_counter_req_i,
      output vco_p_out_o, vco_n_out_o, vco_p_counter_rsp_o, vco_n_counter_rsp_o
  );

endinterface
