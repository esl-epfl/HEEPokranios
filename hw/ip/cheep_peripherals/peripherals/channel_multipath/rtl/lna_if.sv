`include "analog_defs.svh"
import analog_defs::analog_type;

interface lna_if;
  import analog_defs::*;
  `analog_t vdd;
  `analog_t vcm;
  `analog_t vin_p;
  `analog_t vin_n;
  `analog_t vout_p;
  `analog_t vout_n;
  `analog_t ibias;

  reg_pkg::reg_req_t lna_ctrl_req_i;
  reg_pkg::reg_rsp_t lna_ctrl_rsp_o;

  modport signals(input vdd, vcm, vin_p, vin_n, lna_ctrl_req_i, ibias, output vout_p, vout_n, lna_ctrl_rsp_o);

endinterface
