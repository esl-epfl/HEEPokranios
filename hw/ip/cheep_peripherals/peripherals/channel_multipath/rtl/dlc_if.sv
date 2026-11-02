`include "analog_defs.svh"
import analog_defs::analog_type;

interface dlc_if;

  logic done_o;
  logic xing_o;
  logic dir_o;

  reg_pkg::reg_req_t req_i;
  reg_pkg::reg_rsp_t rsp_o;

  modport signals(input req_i, output done_o, xing_o, dir_o, rsp_o);

endinterface
