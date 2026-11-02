`include "analog_defs.svh"
import analog_defs::analog_type;

interface buff_if;
  import analog_defs::*;
  `analog_t vdd;
  `analog_t ibias;
  `analog_t vin_p;
  `analog_t vin_n;
  `analog_t vout_p;
  `analog_t vout_n;

  modport signals(input vdd, ibias, vin_p, vin_n, output vout_p, vout_n);

endinterface
