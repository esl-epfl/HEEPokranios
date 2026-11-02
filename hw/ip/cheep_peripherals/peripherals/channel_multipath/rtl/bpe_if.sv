`include "analog_defs.svh"
import analog_defs::analog_type;

interface bpe_if;

  import analog_defs::*;

  `analog_t vdd;
  `analog_t vin_p;
  `analog_t vin_n;
  `analog_t vout_p;
  `analog_t vout_n;
  `analog_t ibias;
  `analog_t ibias_buf_p;
  `analog_t ibias_buf_n;

  logic [3:0] pwm_o;
  logic [3:0] pwm_i;

  logic comp_p_o;
  logic comp_n_o;

  reg_pkg::reg_req_t ctrl_req_i;
  reg_pkg::reg_rsp_t ctrl_rsp_o;

  reg_pkg::reg_req_t [3:0] pwm_req_i;
  reg_pkg::reg_rsp_t [3:0] pwm_rsp_o;

  reg_pkg::reg_req_t clock_divider_req_i;
  reg_pkg::reg_rsp_t clock_divider_rsp_o;


  modport signals(
      input vdd, vin_p, vin_n, ibias, ibias_buf_p, ibias_buf_n, pwm_i, ctrl_req_i, pwm_req_i, clock_divider_req_i,
      output vout_p, vout_n, pwm_o, ctrl_rsp_o, pwm_rsp_o, clock_divider_rsp_o, comp_p_o, comp_n_o
  );

endinterface
