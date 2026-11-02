// Copyright 2022 EPFL and Politecnico di Torino.
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
//
// File: cheep_peripherals.sv
// Author: Michele Caon, Luigi Giuffrida, Juan Sapriza
// Date: 03/01/2026
// Description: cheep peripheral subsystem

`include "analog_defs.svh"
import analog_defs::analog_type;





module cheep_peripherals #(
    parameter int CHANNEL_PAYLOAD_WIDTH = 16
) (
    input  logic ref_clk_i,
    input  logic rst_ni,
    output logic dmux_cpu_sel_o,

    // System clock
    output logic system_clk_o,

    /* verilator lint_off UNUSED */
    /* verilator lint_off UNDRIVEN */

    input  reg_pkg::reg_req_t cheep_peripherals_req_i,
    output reg_pkg::reg_rsp_t cheep_peripherals_rsp_o,

    input  reg_pkg::reg_req_t system_clock_divider_req_i,
    output reg_pkg::reg_rsp_t system_clock_divider_rsp_o,

    input  reg_pkg::reg_req_t dlc_req_i,
    output reg_pkg::reg_rsp_t dlc_rsp_o,

    input  reg_pkg::reg_req_t ch_0_req_i,
    output reg_pkg::reg_rsp_t ch_0_rsp_o,

    input  reg_pkg::reg_req_t ch_1_req_i,
    output reg_pkg::reg_rsp_t ch_1_rsp_o,

    input  reg_pkg::reg_req_t ch_2_req_i,
    output reg_pkg::reg_rsp_t ch_2_rsp_o,

    input  reg_pkg::reg_req_t ch_3_req_i,
    output reg_pkg::reg_rsp_t ch_3_rsp_o,

    input  reg_pkg::reg_req_t ch_4_req_i,
    output reg_pkg::reg_rsp_t ch_4_rsp_o,

    input  reg_pkg::reg_req_t ch_0_lna_ctrl_req_i,
    output reg_pkg::reg_rsp_t ch_0_lna_ctrl_rsp_o,

    input  reg_pkg::reg_req_t ch_0_bpe_ctrl_req_i,
    output reg_pkg::reg_rsp_t ch_0_bpe_ctrl_rsp_o,

    input  reg_pkg::reg_req_t ch_0_bpe_clock_divider_req_i,
    output reg_pkg::reg_rsp_t ch_0_bpe_clock_divider_rsp_o,

    input  reg_pkg::reg_req_t ch_0_bpe_pwm_0_req_i,
    output reg_pkg::reg_rsp_t ch_0_bpe_pwm_0_rsp_o,

    input  reg_pkg::reg_req_t ch_0_bpe_pwm_1_req_i,
    output reg_pkg::reg_rsp_t ch_0_bpe_pwm_1_rsp_o,

    input  reg_pkg::reg_req_t ch_0_bpe_pwm_2_req_i,
    output reg_pkg::reg_rsp_t ch_0_bpe_pwm_2_rsp_o,

    input  reg_pkg::reg_req_t ch_0_bpe_pwm_3_req_i,
    output reg_pkg::reg_rsp_t ch_0_bpe_pwm_3_rsp_o,

    input  reg_pkg::reg_req_t ch_0_dsm_ctrl_req_i,
    output reg_pkg::reg_rsp_t ch_0_dsm_ctrl_rsp_o,

    input  reg_pkg::reg_req_t ch_0_dsm_cic_req_i,
    output reg_pkg::reg_rsp_t ch_0_dsm_cic_rsp_o,

    input  reg_pkg::reg_req_t ch_0_dsm_ses_req_i,
    output reg_pkg::reg_rsp_t ch_0_dsm_ses_rsp_o,

    input  reg_pkg::reg_req_t ch_0_vco_p_counter_req_i,
    output reg_pkg::reg_rsp_t ch_0_vco_p_counter_rsp_o,

    input  reg_pkg::reg_req_t ch_0_vco_n_counter_req_i,
    output reg_pkg::reg_rsp_t ch_0_vco_n_counter_rsp_o,

    input  reg_pkg::reg_req_t ch_0_dlc_req_i,
    output reg_pkg::reg_rsp_t ch_0_dlc_rsp_o,

    input  reg_pkg::reg_req_t ch_1_lna_ctrl_req_i,
    output reg_pkg::reg_rsp_t ch_1_lna_ctrl_rsp_o,

    input  reg_pkg::reg_req_t ch_1_dsm_ctrl_req_i,
    output reg_pkg::reg_rsp_t ch_1_dsm_ctrl_rsp_o,

    input  reg_pkg::reg_req_t ch_1_dsm_cic_req_i,
    output reg_pkg::reg_rsp_t ch_1_dsm_cic_rsp_o,

    input  reg_pkg::reg_req_t ch_1_dsm_ses_req_i,
    output reg_pkg::reg_rsp_t ch_1_dsm_ses_rsp_o,

    input  reg_pkg::reg_req_t ch_2_vco_counter_req_i,
    output reg_pkg::reg_rsp_t ch_2_vco_counter_rsp_o,

    input  reg_pkg::reg_req_t ch_2_lc_ctrl_req_i,
    output reg_pkg::reg_rsp_t ch_2_lc_ctrl_rsp_o,

    input  reg_pkg::reg_req_t ch_3_vco_counter_req_i,
    output reg_pkg::reg_rsp_t ch_3_vco_counter_rsp_o,

    input  reg_pkg::reg_req_t ch_3_lna_ctrl_req_i,
    output reg_pkg::reg_rsp_t ch_3_lna_ctrl_rsp_o,

    input  reg_pkg::reg_req_t ch_3_lc_ctrl_req_i,
    output reg_pkg::reg_rsp_t ch_3_lc_ctrl_rsp_o,

    input  reg_pkg::reg_req_t ch_3_dlc_req_i,
    output reg_pkg::reg_rsp_t ch_3_dlc_rsp_o,

    input  reg_pkg::reg_req_t ch_4_vco_counter_req_i,
    output reg_pkg::reg_rsp_t ch_4_vco_counter_rsp_o,

    input  reg_pkg::reg_req_t ch_4_lc_ctrl_req_i,
    output reg_pkg::reg_rsp_t ch_4_lc_ctrl_rsp_o,

    input  reg_pkg::reg_req_t idac_ctrl_req_i,
    output reg_pkg::reg_rsp_t idac_ctrl_rsp_o,

    input  reg_pkg::reg_req_t refs_ctrl_req_i,
    output reg_pkg::reg_rsp_t refs_ctrl_rsp_o,

    // Automatically added digital pins
    output logic wpdt2ser_sdo_o,
    output logic wpdt2ser_scko_o,
    output logic wpdt_scko_o,
    input  logic wpdt_scki_i,
    input  logic wpdt_sdi_i,
    output logic wpdt_ref_clk_o,
    input  logic ch_0_bpe_pwm_0_i,
    output logic ch_0_dsm_out_o,
    output logic ch_0_vco_n_out_o,
    output logic ch_3_lc_dir_o,
    output logic ch_4_lc_discharge_o,
    input  logic ch_0_bpe_pwm_1_i,
    input  logic ch_0_dec_in_i,
    output logic ch_2_vco_out_o,
    output logic ch_2_lc_dir_o,
    output logic ch_3_lc_discharge_o,
    input  logic ch_0_bpe_pwm_2_i,
    input  logic ch_0_dsm_clk_in_i,
    output logic reg2ser_sdo_o,
    output logic ch_0_dlc_dir_o,
    output logic ch_2_lc_discharge_o,
    input  logic ch_0_bpe_pwm_3_i,
    input  logic ch_1_dsm_clk_in_i,
    output logic reg2ser_scko_o,
    output logic ch_2_lc_xing_o,
    output logic ch_0_bpe_pwm_3_out_o,
    output logic ch_1_dsm_out_o,
    output logic ch_0_vco_p_out_o,
    output logic ch_3_lc_xing_o,
    output logic ch_0_bpe_comp_p_o,
    output logic ch_0_bpe_pwm_2_out_o,
    input  logic ch_1_dec_in_i,
    input  logic reg2ser_scki_i,
    output logic ch_4_lc_dir_o,
    output logic ch_0_bpe_comp_n_o,
    output logic ch_0_bpe_pwm_1_out_o,
    output logic ch_0_dsm_clk_out_o,
    output logic ch_3_vco_out_o,
    output logic ch_0_dlc_xing_o,
    output logic ch_0_bpe_pwm_0_out_o,
    output logic ch_1_dsm_clk_out_o,
    output logic ch_4_vco_out_o,
    output logic ch_4_lc_xing_o,


    // Automatically added analog pins
    input  `analog_t wpdt_data_clk_vin_io,
    output `analog_t vref_0v6_buff_io,
    output `analog_t imirror_iout_io,
    output `analog_t wpdt_rect_vout_io,
    input  `analog_t vref_en_io,
    input  `analog_t vref_hvdd_io,
    output `analog_t vref_0v5_unbuff_io,
    input  `analog_t wpdt_ldo_vin_io,
    output `analog_t wpdt_ldo_vout_io,
    input  `analog_t refs_vdd_io,
    output `analog_t iref_iout_io,
    input  `analog_t imirror_iin_io,
    output `analog_t vref_0v5_buff_io,
    input  `analog_t vref_vin_io,
    input  `analog_t ch_234_vdd_io,
    input  `analog_t ch_2_lc_vdd_io,
    output `analog_t ch_4_vin_io,
    input  `analog_t ch_3_vin_io,
    output `analog_t ch_3_buff_vout_io,
    input  `analog_t ch_3_lna_vin_io,
    input  `analog_t ch_2_lc_vin_io,
    input  `analog_t ch_2_vco_vin_io,
    input  `analog_t wpdt_blocks_vin_io,
    output `analog_t vref_0v4_buff_io,
    input  `analog_t lna_vcm_vin_io,
    input  `analog_t ch_1_lna_vin_p_io,
    output `analog_t ch_1_buff_vout_n_io,
    input  `analog_t ch_1_dsm_vin_n_io,
    output `analog_t ch_1_buff_vout_p_io,
    input  `analog_t ch_1_dsm_vin_p_io,
    input  `analog_t ch_01_lna_vin_n_io,
    output `analog_t ch_0_lna_vout_n_io,
    output `analog_t ch_0_lna_vout_p_io,
    input  `analog_t ch_0_lna_vin_p_io,
    input  `analog_t ch_0_lna_vdd_io,
    input  `analog_t ch_1_vdd_io,
    input  `analog_t ch_1_dsm_vdd_io,
    input  `analog_t ch_0_bpe_vin_p_io,
    input  `analog_t ch_0_bpe_vin_n_io,
    input  `analog_t ch_0_pdvco_vin_p_io,
    input  `analog_t ch_0_pdvco_vin_n_io,
    output `analog_t ch_0_bpe_vout_p_io,
    output `analog_t ch_0_bpe_vout_n_io,
    input  `analog_t ch_0_bpe_vdd_io,
    input  `analog_t ch_0_pdvco_vdd_io,
    input  `analog_t ch_0_dsm_vdd_io,
    input  `analog_t ch_0_dsm_vin_p_io,
    input  `analog_t ch_0_dsm_vin_n_io,

    /* verilator lint_on UNDRIVEN */
    /* verilator lint_on UNUSED */

    input `analog_t wpdt_ant_p_io,
    input `analog_t wpdt_ant_n_io,

    // Notification for the DMA to come collect data
    output logic data_available_o,
    output logic ch_0_dlc_done_o,
    output logic ch_3_dlc_done_o,

    // Byte to be connected to the dMUX
    output logic [7:0] output_byte_o,

    output logic wpdt2ser_cs_o,

    output logic spi_slave_enable_o,

    // EXT READ FIFO Interface
    /* verilator lint_off UNUSED */
    output fifo_pkg::fifo_req_t [core_v_mini_mcu_pkg::DMA_CH_NUM-1:0] ext_read_fifo_req_o,
    input fifo_pkg::fifo_resp_t [core_v_mini_mcu_pkg::DMA_CH_NUM-1:0] ext_read_fifo_resp_i,
    output logic [core_v_mini_mcu_pkg::DMA_CH_NUM-1:0][core_v_mini_mcu_pkg::DMA_EXT_READ_FIFO_ID_BITS-1:0] ext_read_fifo_req_id_o,
    /* verilator lint_on UNUSED */

    // Interrupts
    output logic intr_ext_peripheral_o,  // Connected to the Fast interrupt controller
    output [core_v_mini_mcu_pkg::NEXT_INT-1:0] ext_int_vector_o  // Connected to the PLIC
);
  import cheep_pkg::*;

  `analog_t [18:0] imirror_iout;

  // We dont have a PLIC, so this is useless, just tie to 0
  assign ext_int_vector_o[core_v_mini_mcu_pkg::NEXT_INT-1:0] = '0;

  assign intr_ext_peripheral_o = ch_0_dlc_xing_o | reg2hw.interface_word.qe;  // TODO_heepokranios, consider adding more things here


  /* verilator lint_off UNUSED */
  /* verilator lint_off UNDRIVEN */
  cheep_peripherals_reg_pkg::cheep_peripherals_hw2reg_t hw2reg;
  cheep_peripherals_reg_pkg::cheep_peripherals_reg2hw_t reg2hw;
  /* verilator lint_on UNDRIVEN */
  /* verilator lint_on UNUSED */

  cheep_peripherals_reg_top #(
      .reg_req_t(reg_pkg::reg_req_t),
      .reg_rsp_t(reg_pkg::reg_rsp_t)
  ) u_cheep_peripherals_reg_top (
      .clk_i    (ref_clk_i),                // TODO_heepokranios use CDC
      .rst_ni   (rst_ni),
      .reg_req_i(cheep_peripherals_req_i),
      .reg_rsp_o(cheep_peripherals_rsp_o),
      .reg2hw   (reg2hw),
      .hw2reg   (hw2reg),
      .devmode_i(1'b0)
  );

  // -------------------------------------------
  // WPDT
  // -------------------------------------------

  logic wpdt_decoded_valid;
  logic wpdt_decoded_data;

  logic serial_valid;
  logic serial_ready;
  logic [31:0] serial_data;
  logic wpdt2ser_data_reset;
  logic downlink_rst;

  WPDT_wrapper u_wpdt (
      .ant_p(wpdt_ant_p_io),
      .ant_n(wpdt_ant_n_io),
      .blocks_vin(wpdt_blocks_vin_io),
      .data_clk_vin(wpdt_data_clk_vin_io),
      .ibias_iin(imirror_iout[0]),
      .ldo_vin(wpdt_ldo_vin_io),
      .ldo_vout(wpdt_ldo_vout_io),
      .rect_vout(wpdt_rect_vout_io),

      .uplink_uncoded_data_i(wpdt_sdi_i),
      .uplink_encoding_clk_i(wpdt_scki_i),
      .uplink_rst_i(reg2hw.wpdt_uplink_reset.q),

      .downlink_decoded_clk_o(wpdt_scko_o),
      .downlink_decoded_data_o(wpdt_decoded_data),
      .downlink_decoded_valid_o(wpdt_decoded_valid),
      .downlink_rst_i(downlink_rst),

      .ref_clk_o(wpdt_ref_clk_o),

      .rst_i(~rst_ni)
  );

  WPDT2ser u_wpdt2ser (
      .detect_i(wpdt_decoded_valid),
      .payload_length_bits_i(reg2hw.wpdt_downlink_payload_length_bits.q),
      .sdo_i(wpdt_decoded_data),
      .scko_i(wpdt_scko_o),
      .sdo_o(wpdt2ser_sdo_o),
      .scko_o(wpdt2ser_scko_o),
      .valid_no(wpdt2ser_cs_o),
      .data_reset_o(wpdt2ser_data_reset),
      .clk_i(system_clk_o),
      .rst_ni
  );

  assign downlink_rst = wpdt2ser_data_reset | reg2hw.wpdt_downlink_reset.q;

  circular_buffer #(
      .DEPTH(5),
      .WIDTH(32)
  ) u_serial_output_buffer (
      .clk_i(system_clk_o),
      .rst_ni,
      .flush_i( reg2hw.output_buffer_flush.q ),
      .data_i(  reg2hw.output_data.q ),
      .data_push_i(reg2hw.output_data.qe),
      .data_pop_i(serial_ready ),
      .data_not_empty_o(  serial_valid   ),
      .data_o(   serial_data  )
  );

  reg2ser u_reg2ser (
      .clk_i(system_clk_o),
      .rst_ni,
      .scki_i(reg2ser_scki_i),
      .valid_i(serial_valid),
      .data_i(serial_data),
      .half_speed_i(reg2hw.output_half_speed.q),
      .bytes_to_skip_i(reg2hw.output_bytes_to_skip.q),
      .data_o(reg2ser_sdo_o),
      .scko_o(reg2ser_scko_o),
      .ready_o(serial_ready)
  );


  // -------------------------------------------
  // SYSTEM CLOCK DIVIDER
  // -------------------------------------------
  pgm_clock_divider u_system_clock_divider (
      .clk_i(ref_clk_i),
      .rst_ni(rst_ni),
      .freq_div_valid_i('1),  // It is safe to tie this to one if the default divider is 1
      .req_i(system_clock_divider_req_i),
      .rsp_o(system_clock_divider_rsp_o),
      .clk_o(system_clk_o)
  );


  // -------------------------------------------
  // MISCELANEOUS PINS
  // -------------------------------------------

  assign output_byte_o = reg2hw.output_byte.q;

  assign dmux_cpu_sel_o = reg2hw.dmux_cpu_sel.q;

  assign spi_slave_enable_o = reg2hw.spi_slave_enable.q;

  logic [4:0] ch_data_available;
  logic [4:0] ch_data_read;
  logic [4:0][CHANNEL_PAYLOAD_WIDTH-1:0] ch_data;


  // -------------------------------------------
  // CHANNEL 0
  // -------------------------------------------

  lna_if u_ch_0_lna ();
  buff_if u_ch_0_buff ();
  bpe_if u_ch_0_bpe ();
  dsm_if u_ch_0_dsm ();
  pdvco_if u_ch_0_pdvco ();
  dlc_if u_ch_0_dlc ();
  lc_if u_ch_0_lc ();

  channel_multipath #(
      .INCLUDE_LNA  (1),
      .INCLUDE_BPE  (1),
      .INCLUDE_DSM  (1),
      .INCLUDE_PDVCO(1),
      .INCLUDE_DLC  (1)
  ) u_channel_0 (
      .vref(vref_vin_io),
      .lna(u_ch_0_lna),
      .buff(u_ch_0_buff),
      .bpe(u_ch_0_bpe),
      .dsm(u_ch_0_dsm),
      .pdvco(u_ch_0_pdvco),
      .dlc(u_ch_0_dlc),
      .lc(u_ch_0_lc),
      .data_available_o(ch_data_available[0]),
      .data_read_i(ch_data_read[0]),
      .data_o(ch_data[0]),

      .ref_clk_i(ref_clk_i),
      .clk_i(system_clk_o),
      .rst_ni(rst_ni),
      .req_i(ch_0_req_i),
      .rsp_o(ch_0_rsp_o)
  );

  assign u_ch_0_lna.vdd                   = ch_0_lna_vdd_io;
  assign u_ch_0_lna.vcm                   = lna_vcm_vin_io;
  assign u_ch_0_lna.ibias                 = imirror_iout[1];
  assign u_ch_0_lna.vin_p                 = ch_0_lna_vin_p_io;
  assign u_ch_0_lna.vin_n                 = ch_01_lna_vin_n_io;
  assign ch_0_lna_vout_p_io               = u_ch_0_lna.vout_p;
  assign ch_0_lna_vout_n_io               = u_ch_0_lna.vout_n;
  assign u_ch_0_lna.lna_ctrl_req_i        = ch_0_lna_ctrl_req_i;
  assign ch_0_lna_ctrl_rsp_o              = u_ch_0_lna.lna_ctrl_rsp_o;

  assign u_ch_0_bpe.vdd                   = ch_0_bpe_vdd_io;
  assign u_ch_0_bpe.vin_p                 = ch_0_bpe_vin_p_io;
  assign u_ch_0_bpe.vin_n                 = ch_0_bpe_vin_n_io;
  assign u_ch_0_bpe.ibias                 = imirror_iout[2];
  assign u_ch_0_bpe.ibias_buf_p           = imirror_iout[3];
  assign u_ch_0_bpe.ibias_buf_n           = imirror_iout[4];
  assign ch_0_bpe_vout_p_io               = u_ch_0_bpe.vout_p;
  assign ch_0_bpe_vout_n_io               = u_ch_0_bpe.vout_n;
  assign u_ch_0_bpe.pwm_i[0]              = ch_0_bpe_pwm_0_i;
  assign u_ch_0_bpe.pwm_i[1]              = ch_0_bpe_pwm_1_i;
  assign u_ch_0_bpe.pwm_i[2]              = ch_0_bpe_pwm_2_i;
  assign u_ch_0_bpe.pwm_i[3]              = ch_0_bpe_pwm_3_i;

  assign ch_0_bpe_pwm_0_out_o             = u_ch_0_bpe.pwm_o[0];
  assign ch_0_bpe_pwm_1_out_o             = u_ch_0_bpe.pwm_o[1];
  assign ch_0_bpe_pwm_2_out_o             = u_ch_0_bpe.pwm_o[2];
  assign ch_0_bpe_pwm_3_out_o             = u_ch_0_bpe.pwm_o[3];
  assign u_ch_0_bpe.pwm_req_i[0]          = ch_0_bpe_pwm_0_req_i;
  assign ch_0_bpe_pwm_0_rsp_o             = u_ch_0_bpe.pwm_rsp_o[0];
  assign u_ch_0_bpe.pwm_req_i[1]          = ch_0_bpe_pwm_1_req_i;
  assign ch_0_bpe_pwm_1_rsp_o             = u_ch_0_bpe.pwm_rsp_o[1];
  assign u_ch_0_bpe.pwm_req_i[2]          = ch_0_bpe_pwm_2_req_i;
  assign ch_0_bpe_pwm_2_rsp_o             = u_ch_0_bpe.pwm_rsp_o[2];
  assign u_ch_0_bpe.pwm_req_i[3]          = ch_0_bpe_pwm_3_req_i;
  assign ch_0_bpe_pwm_3_rsp_o             = u_ch_0_bpe.pwm_rsp_o[3];

  assign u_ch_0_bpe.ctrl_req_i            = ch_0_bpe_ctrl_req_i;
  assign ch_0_bpe_ctrl_rsp_o              = u_ch_0_bpe.ctrl_rsp_o;

  assign u_ch_0_bpe.clock_divider_req_i   = ch_0_bpe_clock_divider_req_i;
  assign ch_0_bpe_clock_divider_rsp_o     = u_ch_0_bpe.clock_divider_rsp_o;

  assign ch_0_bpe_comp_p_o                = u_ch_0_bpe.comp_p_o;
  assign ch_0_bpe_comp_n_o                = u_ch_0_bpe.comp_n_o;

  assign u_ch_0_dsm.vdd                   = ch_0_dsm_vdd_io;
  assign u_ch_0_dsm.ibias                 = imirror_iout[5];
  assign u_ch_0_dsm.vin_p                 = ch_0_dsm_vin_p_io;
  assign u_ch_0_dsm.vin_n                 = ch_0_dsm_vin_n_io;
  assign u_ch_0_dsm.clk_i                 = ch_0_dsm_clk_in_i;
  assign u_ch_0_dsm.dec_i                 = ch_0_dec_in_i;
  assign ch_0_dsm_clk_out_o               = u_ch_0_dsm.clk_o;
  assign ch_0_dsm_out_o                   = u_ch_0_dsm.out_o;
  assign u_ch_0_dsm.ctrl_req_i            = ch_0_dsm_ctrl_req_i;
  assign ch_0_dsm_ctrl_rsp_o              = u_ch_0_dsm.ctrl_rsp_o;

  assign u_ch_0_dsm.cic_req_i             = ch_0_dsm_cic_req_i;
  assign ch_0_dsm_cic_rsp_o               = u_ch_0_dsm.cic_rsp_o;
  assign u_ch_0_dsm.ses_req_i             = ch_0_dsm_ses_req_i;
  assign ch_0_dsm_ses_rsp_o               = u_ch_0_dsm.ses_rsp_o;

  assign u_ch_0_pdvco.vdd                 = ch_0_pdvco_vdd_io;
  assign u_ch_0_pdvco.vin_p               = ch_0_pdvco_vin_p_io;
  assign u_ch_0_pdvco.vin_n               = ch_0_pdvco_vin_n_io;
  assign ch_0_vco_p_out_o                 = u_ch_0_pdvco.vco_p_out_o;
  assign ch_0_vco_n_out_o                 = u_ch_0_pdvco.vco_n_out_o;
  assign u_ch_0_pdvco.vco_p_counter_req_i = ch_0_vco_p_counter_req_i;
  assign ch_0_vco_p_counter_rsp_o         = u_ch_0_pdvco.vco_p_counter_rsp_o;
  assign u_ch_0_pdvco.vco_n_counter_req_i = ch_0_vco_n_counter_req_i;
  assign ch_0_vco_n_counter_rsp_o         = u_ch_0_pdvco.vco_n_counter_rsp_o;

  assign ch_0_dlc_rsp_o                   = u_ch_0_dlc.rsp_o;
  assign u_ch_0_dlc.req_i                 = ch_0_dlc_req_i;
  assign ch_0_dlc_done_o                  = u_ch_0_dlc.done_o;
  assign ch_0_dlc_dir_o                   = u_ch_0_dlc.dir_o;
  assign ch_0_dlc_xing_o                  = u_ch_0_dlc.xing_o;

  // -------------------------------------------
  // CHANNEL 1
  // -------------------------------------------

  lna_if u_ch_1_lna ();
  buff_if u_ch_1_buff ();
  bpe_if u_ch_1_bpe ();
  dsm_if u_ch_1_dsm ();
  pdvco_if u_ch_1_pdvco ();
  dlc_if u_ch_1_dlc ();
  lc_if u_ch_1_lc ();

  channel_multipath #(
      .INCLUDE_LNA (1),
      .INCLUDE_BUFF(1),
      .INCLUDE_DSM (1)
  ) u_channel_1 (
      .vref(vref_vin_io),
      .lna(u_ch_1_lna),
      .buff(u_ch_1_buff),
      .bpe(u_ch_1_bpe),
      .dsm(u_ch_1_dsm),
      .pdvco(u_ch_1_pdvco),
      .dlc(u_ch_1_dlc),
      .lc(u_ch_1_lc),
      .data_available_o(ch_data_available[1]),
      .data_read_i(ch_data_read[1]),
      .data_o(ch_data[1]),

      .ref_clk_i(ref_clk_i),
      .clk_i(system_clk_o),
      .rst_ni(rst_ni),
      .req_i(ch_1_req_i),
      .rsp_o(ch_1_rsp_o)
  );

  assign u_ch_1_lna.vdd            = ch_1_vdd_io;
  assign u_ch_1_buff.vdd           = ch_1_vdd_io;
  assign u_ch_1_lna.vcm            = lna_vcm_vin_io;
  assign u_ch_1_lna.ibias          = imirror_iout[6];
  assign u_ch_1_lna.vin_p          = ch_1_lna_vin_p_io;
  assign u_ch_1_lna.vin_n          = ch_01_lna_vin_n_io;
  assign u_ch_1_buff.vin_p         = u_ch_1_lna.vout_p;
  assign u_ch_1_buff.vin_n         = u_ch_1_lna.vout_n;
  assign ch_1_buff_vout_p_io       = u_ch_1_buff.vout_p;
  assign ch_1_buff_vout_n_io       = u_ch_1_buff.vout_n;
  assign u_ch_1_buff.ibias         = imirror_iout[7];
  assign u_ch_1_lna.lna_ctrl_req_i = ch_1_lna_ctrl_req_i;
  assign ch_1_lna_ctrl_rsp_o       = u_ch_1_lna.lna_ctrl_rsp_o;

  assign u_ch_1_dsm.vdd            = ch_1_dsm_vdd_io;
  assign u_ch_1_dsm.ibias          = imirror_iout[8];
  assign u_ch_1_dsm.vin_p          = ch_1_dsm_vin_p_io;
  assign u_ch_1_dsm.vin_n          = ch_1_dsm_vin_n_io;
  assign u_ch_1_dsm.clk_i          = ch_1_dsm_clk_in_i;
  assign u_ch_1_dsm.dec_i          = ch_1_dec_in_i;
  assign ch_1_dsm_clk_out_o        = u_ch_1_dsm.clk_o;
  assign ch_1_dsm_out_o            = u_ch_1_dsm.out_o;
  assign u_ch_1_dsm.ctrl_req_i     = ch_1_dsm_ctrl_req_i;
  assign ch_1_dsm_ctrl_rsp_o       = u_ch_1_dsm.ctrl_rsp_o;

  assign u_ch_1_dsm.cic_req_i      = ch_1_dsm_cic_req_i;
  assign ch_1_dsm_cic_rsp_o        = u_ch_1_dsm.cic_rsp_o;
  assign u_ch_1_dsm.ses_req_i      = ch_1_dsm_ses_req_i;
  assign ch_1_dsm_ses_rsp_o        = u_ch_1_dsm.ses_rsp_o;

  // -------------------------------------------
  // CHANNEL 2
  // -------------------------------------------

  lna_if u_ch_2_lna ();
  buff_if u_ch_2_buff ();
  bpe_if u_ch_2_bpe ();
  dsm_if u_ch_2_dsm ();
  pdvco_if u_ch_2_pdvco ();
  dlc_if u_ch_2_dlc ();
  lc_if u_ch_2_lc ();

  channel_multipath #(
      .INCLUDE_VCO(1),
      .INCLUDE_LC (1)
  ) u_channel_2 (
      .vref(vref_vin_io),
      .lna(u_ch_2_lna),
      .buff(u_ch_2_buff),
      .bpe(u_ch_2_bpe),
      .dsm(u_ch_2_dsm),
      .pdvco(u_ch_2_pdvco),
      .dlc(u_ch_2_dlc),
      .lc(u_ch_2_lc),
      .data_available_o(ch_data_available[2]),
      .data_read_i(ch_data_read[2]),
      .data_o(ch_data[2]),

      .ref_clk_i(ref_clk_i),
      .clk_i(system_clk_o),
      .rst_ni(rst_ni),
      .req_i(ch_2_req_i),
      .rsp_o(ch_2_rsp_o)
  );

  assign u_ch_2_pdvco.vdd = ch_234_vdd_io;
  assign u_ch_2_pdvco.vin_p = ch_2_vco_vin_io;
  assign ch_2_vco_out_o = u_ch_2_pdvco.vco_p_out_o;
  assign u_ch_2_pdvco.vco_p_counter_req_i = ch_2_vco_counter_req_i;
  assign ch_2_vco_counter_rsp_o = u_ch_2_pdvco.vco_p_counter_rsp_o;

  assign ch_2_lc_xing_o = u_ch_2_lc.xing_o;
  assign ch_2_lc_dir_o = u_ch_2_lc.dir_o;
  assign ch_2_lc_discharge_o = u_ch_2_lc.discharge_o;
  assign u_ch_2_lc.ctrl_req_i = ch_2_lc_ctrl_req_i;
  assign ch_2_lc_ctrl_rsp_o = u_ch_2_lc.ctrl_rsp_o;

  assign u_ch_2_lc.vin = ch_2_lc_vin_io;
  assign u_ch_2_lc.vdd = ch_2_lc_vdd_io;
  assign u_ch_2_lc.ibias = imirror_iout[11];


  // -------------------------------------------
  // CHANNEL 3
  // -------------------------------------------

  lna_if u_ch_3_lna ();
  buff_if u_ch_3_buff ();
  bpe_if u_ch_3_bpe ();
  dsm_if u_ch_3_dsm ();
  pdvco_if u_ch_3_pdvco ();
  dlc_if u_ch_3_dlc ();
  lc_if u_ch_3_lc ();

  channel_multipath #(
      .INCLUDE_LNA(1),
      .INCLUDE_BUFF(0),
      .INCLUDE_SE_BUFF(1),
      .INCLUDE_VCO(1),
      .INCLUDE_DLC(1),
      .INCLUDE_LC(1)
  ) u_channel_3 (
      .vref(vref_vin_io),
      .lna(u_ch_3_lna),
      .buff(u_ch_3_buff),
      .bpe(u_ch_3_bpe),
      .dsm(u_ch_3_dsm),
      .pdvco(u_ch_3_pdvco),
      .dlc(u_ch_3_dlc),
      .lc(u_ch_3_lc),
      .data_available_o(ch_data_available[3]),
      .data_read_i(ch_data_read[3]),
      .data_o(ch_data[3]),

      .ref_clk_i(ref_clk_i),
      .clk_i(system_clk_o),
      .rst_ni(rst_ni),
      .req_i(ch_3_req_i),
      .rsp_o(ch_3_rsp_o)
  );

  assign u_ch_3_lna.vdd                   = ch_234_vdd_io;
  assign u_ch_3_buff.vdd                  = ch_234_vdd_io;
  assign u_ch_3_lna.vcm                   = lna_vcm_vin_io;
  assign u_ch_3_lna.ibias                 = imirror_iout[9];
  assign u_ch_3_lna.vin_p                 = ch_3_lna_vin_io;
  assign u_ch_3_lna.vin_n                 = lna_vcm_vin_io;
  assign u_ch_3_lna.lna_ctrl_req_i        = ch_3_lna_ctrl_req_i;
  assign ch_3_lna_ctrl_rsp_o              = u_ch_3_lna.lna_ctrl_rsp_o;

  assign u_ch_3_buff.vin_p                = u_ch_3_lna.vout_p;
  assign ch_3_buff_vout_io                = u_ch_3_buff.vout_p;
  assign u_ch_3_buff.ibias                = imirror_iout[10];

  assign u_ch_3_pdvco.vdd                 = ch_234_vdd_io;
  assign u_ch_3_pdvco.vin_p               = ch_3_vin_io;
  assign ch_3_vco_out_o                   = u_ch_3_pdvco.vco_p_out_o;
  assign u_ch_3_pdvco.vco_p_counter_req_i = ch_3_vco_counter_req_i;
  assign ch_3_vco_counter_rsp_o           = u_ch_3_pdvco.vco_p_counter_rsp_o;

  assign ch_3_lc_xing_o                   = reg2hw.ch_3_dlc_output.q ? u_ch_3_dlc.xing_o : u_ch_3_lc.xing_o;
  assign ch_3_lc_dir_o                    = reg2hw.ch_3_dlc_output.q ? u_ch_3_dlc.dir_o : u_ch_3_lc.dir_o;
  assign ch_3_lc_discharge_o              = u_ch_3_lc.discharge_o;
  assign u_ch_3_lc.ctrl_req_i             = ch_3_lc_ctrl_req_i;
  assign ch_3_lc_ctrl_rsp_o               = u_ch_3_lc.ctrl_rsp_o;

  assign u_ch_3_lc.vin                    = ch_3_vin_io;
  assign u_ch_3_lc.vdd                    = ch_234_vdd_io;
  assign u_ch_3_lc.ibias                  = imirror_iout[12];

  assign ch_3_dlc_rsp_o                   = u_ch_3_dlc.rsp_o;
  assign u_ch_3_dlc.req_i                 = ch_3_dlc_req_i;
  assign ch_3_dlc_done_o                  = u_ch_3_dlc.done_o;

  // -------------------------------------------
  // CHANNEL 4
  // -------------------------------------------

  lna_if u_ch_4_lna ();
  buff_if u_ch_4_buff ();
  bpe_if u_ch_4_bpe ();
  dsm_if u_ch_4_dsm ();
  pdvco_if u_ch_4_pdvco ();
  dlc_if u_ch_4_dlc ();
  lc_if u_ch_4_lc ();

  channel_multipath #(
      .INCLUDE_VCO(1),
      .INCLUDE_LC (1)
  ) u_channel_4 (
      .vref(vref_vin_io),
      .lna(u_ch_4_lna),
      .buff(u_ch_4_buff),
      .bpe(u_ch_4_bpe),
      .dsm(u_ch_4_dsm),
      .pdvco(u_ch_4_pdvco),
      .dlc(u_ch_4_dlc),
      .lc(u_ch_4_lc),
      .data_available_o(ch_data_available[4]),
      .data_read_i(ch_data_read[4]),
      .data_o(ch_data[4]),

      .ref_clk_i(ref_clk_i),
      .clk_i(system_clk_o),
      .rst_ni(rst_ni),
      .req_i(ch_4_req_i),
      .rsp_o(ch_4_rsp_o)
  );

  assign u_ch_4_pdvco.vdd = ch_234_vdd_io;
  assign u_ch_4_pdvco.vin_p = ch_4_vin_io;
  assign ch_4_vco_out_o = u_ch_4_pdvco.vco_p_out_o;
  assign u_ch_4_pdvco.vco_p_counter_req_i = ch_4_vco_counter_req_i;
  assign ch_4_vco_counter_rsp_o = u_ch_4_pdvco.vco_p_counter_rsp_o;

  assign ch_4_lc_xing_o = u_ch_4_lc.xing_o;
  assign ch_4_lc_dir_o = u_ch_4_lc.dir_o;
  assign ch_4_lc_discharge_o = u_ch_4_lc.discharge_o;
  assign u_ch_4_lc.ctrl_req_i = ch_4_lc_ctrl_req_i;
  assign ch_4_lc_ctrl_rsp_o = u_ch_4_lc.ctrl_rsp_o;

  assign u_ch_4_lc.vin = ch_4_vin_io;
  assign u_ch_4_lc.vdd = ch_234_vdd_io;
  assign u_ch_4_lc.ibias = imirror_iout[13];


  // -------------------------------------------
  // CHANNEL FUNNEL
  // -------------------------------------------

  logic [CHANNEL_PAYLOAD_WIDTH-1:0] data_write;
  logic data_write_req;


  // --- State Variable ---
  logic [2:0] sel_ch;
  logic [2:0] last_served_q; // Remembers the last channel that successfully wrote
  logic [2:0] check_idx;     // Temporary variable for the loop

  // --- Combinational Logic for Next Channel Selection ---
  always_comb begin
    // Default to the last served channel if nothing is available
    sel_ch = last_served_q;

    // Look ahead up to 5 times to find the next available channel
    for (int i = 1; i <= 5; i++) begin
      check_idx = last_served_q + i[2:0];

      // Modulo wrap-around (avoids synthesis issues with the '%' operator)
      if (check_idx >= 5) begin
        check_idx = check_idx - 5;
      end

      // The first active bit we hit is the fairest choice
      if (ch_data_available[check_idx]) begin
        sel_ch = check_idx;
        break;
      end
    end
  end

  always_comb begin
    data_write[CHANNEL_PAYLOAD_WIDTH-1:0] = '0;
    data_write_req                        = 1'b0;
    ch_data_read                          = '0;

    if (reg2hw.funnel_en.q && ch_data_available != 5'b0) begin
      data_write           = ch_data[sel_ch];
      data_write_req       = 1'b1;  // Assuming we write whenever data is available
      ch_data_read[sel_ch] = 1'b1;
    end
  end

  // --- Sequential Logic to Update State ---
  // This updates the 'last_served_q' state only when a write actually happens.
  always_ff @(posedge system_clk_o or negedge rst_ni) begin
    if (!rst_ni) begin
      last_served_q <= '0;
    end else if (data_write_req) begin
      // Once a write request is granted, log this channel as the last served
      last_served_q <= sel_ch;
    end

  end

  logic [CHANNEL_PAYLOAD_WIDTH-1:0] input_buffer_data;
  logic [core_v_mini_mcu_pkg::DMA_EXT_READ_FIFO_ID_BITS-1:0] input_buffer_id;
  logic [core_v_mini_mcu_pkg::DMA_EXT_READ_FIFO_ID_BITS+CHANNEL_PAYLOAD_WIDTH-1:0] input_buffer_payload;
  logic input_buffer_not_empty;
  logic ext_read_fifo_push;
  logic input_buffer_pop;
  logic [core_v_mini_mcu_pkg::DMA_EXT_READ_FIFO_ID_BITS-1:0] data_write_id;
  logic [core_v_mini_mcu_pkg::DMA_EXT_READ_FIFO_ID_BITS+CHANNEL_PAYLOAD_WIDTH-1:0] data_write_payload;

  // The ext-read FIFO path is wired on DMA channel 0.
  // NOTE: ext_read_fifo_* port typedefs are bit-compatible but semantically swapped.

  assign hw2reg.input_data_available.d = input_buffer_not_empty;
  assign hw2reg.input_data_available.de = '1;
  assign data_available_o = input_buffer_not_empty;
  assign input_buffer_id = input_buffer_payload[core_v_mini_mcu_pkg::DMA_EXT_READ_FIFO_ID_BITS+CHANNEL_PAYLOAD_WIDTH-1:CHANNEL_PAYLOAD_WIDTH];
  assign input_buffer_data = input_buffer_payload[CHANNEL_PAYLOAD_WIDTH-1:0];
  assign hw2reg.input_data.d = input_buffer_payload;

  assign ext_read_fifo_push = input_buffer_not_empty && !ext_read_fifo_resp_i[0].full;  // TODO: we use DMA's channel 0 for now
  assign input_buffer_pop = reg2hw.input_data.re | ext_read_fifo_push; // To allow us to read from the buffer even without the DMA (but the CPU needs to take care of this data)
  assign data_write_id = core_v_mini_mcu_pkg::DMA_EXT_READ_FIFO_ID_BITS'(sel_ch);
  assign data_write_payload = {data_write_id, data_write};

  circular_buffer #(
      .DEPTH(10),
      .WIDTH(core_v_mini_mcu_pkg::DMA_EXT_READ_FIFO_ID_BITS + CHANNEL_PAYLOAD_WIDTH)
  ) u_input_buffer (
      .clk_i(system_clk_o),
      .rst_ni,
      .flush_i(reg2hw.input_buffer_flush.q),
      .data_i(data_write_payload),
      .data_push_i(data_write_req),
      .data_pop_i(input_buffer_pop),
      .data_not_empty_o(input_buffer_not_empty),
      .data_o(input_buffer_payload)
  );

  always_comb begin
    ext_read_fifo_req_o = '0;
    ext_read_fifo_req_id_o = '0;
    ext_read_fifo_req_o[0].pop = 1'b0;
    ext_read_fifo_req_o[0].push = ext_read_fifo_push;
    ext_read_fifo_req_o[0].flush = 1'b0;
    ext_read_fifo_req_o[0].data = {{(32 - CHANNEL_PAYLOAD_WIDTH) {1'b0}}, input_buffer_data};
    ext_read_fifo_req_id_o[0] = input_buffer_id;
  end

  // TODO_heepokranios decide wisely which clock should drive all these



  // -------------------------------------------
  // iDAC
  // -------------------------------------------

  logic idac_refresh;
  logic idac_enable;
  logic [7:0] idac_current;
  logic [4:0] idac_calibration;

  /* verilator lint_off UNUSED */
  logic idac_refresh_notif;
  /* verilator lint_on UNUSED */

  idac_ctrl u_idac_ctrl (
      .clk_i          (system_clk_o),
      .rst_ni         (rst_ni),
      .req_i          (idac_ctrl_req_i),
      .rsp_o          (idac_ctrl_rsp_o),
      .enable_1_o     (idac_enable),
      .current_1_o    (idac_current),
      .calibration_1_o(idac_calibration),
      .enable_2_o     (),
      .current_2_o    (),
      .calibration_2_o(),
      .refresh_o      (idac_refresh),
      .refresh_notif_o(idac_refresh_notif)
  );

  iDAC_wrapper u_iDAC (
      .en_i(idac_enable),
      .refresh_i(idac_refresh),
      .cal_i(idac_calibration),
      .value_i(idac_current),
      .iin(imirror_iout[14]),
      .iout(ch_4_vin_io),  // TODO_heepokranios check this out
      .bvdd(ch_234_vdd_io)
  );


  // -------------------------------------------
  // REFs
  // -------------------------------------------

  logic [9:0] iref_calibration;
  logic [4:0] vref_calibration;

  refs_ctrl u_refs_ctrl (
      .clk_i(system_clk_o),
      .rst_ni,

      // Bus interface
      .req_i(refs_ctrl_req_i),
      .rsp_o(refs_ctrl_rsp_o),

      .iref_calibration_o(iref_calibration),
      .vref_calibration_o(vref_calibration)
  );

  iREF_wrapper u_iREF (
      .cal_i(iref_calibration),
      .iout (iref_iout_io),
      .bvdd (refs_vdd_io)
  );

  vREF_wrapper u_vREF (
      .cal_i(vref_calibration),
      .hvdd(vref_hvdd_io),
      .en(vref_en_io),
      .ibias_iin_0(imirror_iout[15]),
      .ibias_iin_1(imirror_iout[16]),
      .ibias_iin_2(imirror_iout[17]),
      .vref_0v4_buff(vref_0v4_buff_io),
      .vref_0v5_buff(vref_0v5_buff_io),
      .vref_0v6_buff(vref_0v6_buff_io),
      .vref_0v5_unbuff(vref_0v5_unbuff_io),
      .bvdd(refs_vdd_io)
  );

  // -------------------------------------------
  // iMIRROR
  // -------------------------------------------

  iMIRROR_wrapper u_iMIRROR (
      .bvdd(refs_vdd_io),
      .iin (imirror_iin_io),
      .iout(imirror_iout)
  );

  assign imirror_iout_io = imirror_iout[18];


endmodule
