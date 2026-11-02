`include "analog_defs.svh"
import analog_defs::analog_type;

interface lc_if;

  `analog_t vin;
  `analog_t ibias;
  `analog_t vdd;

  logic xing_o;
  logic dir_o;
  logic discharge_o;

  reg_pkg::reg_req_t ctrl_req_i;
  reg_pkg::reg_rsp_t ctrl_rsp_o;

  modport signals(input vin, ibias, vdd, ctrl_req_i, output xing_o, dir_o, discharge_o, ctrl_rsp_o);

endinterface
