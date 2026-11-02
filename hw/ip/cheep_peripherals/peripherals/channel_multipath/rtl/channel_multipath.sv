// Copyright 2026 EPFL and contributors
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
//
// File: channel_multipath.sv
// Author: Juan Sapriza
// Date: 18/02/2026
// Description: A subsystem where the analog blocks will be instantiated.
// In the case of RTL-only simulations, the spice models are replaced for behavioral models.

`include "analog_defs.svh"
import analog_defs::analog_type;

`define UNUSED(x) initial begin if (0) $display(x); end

module channel_multipath #(
    parameter int PAYLOAD_WIDTH = 16,
    parameter logic INCLUDE_LNA = 0,
    parameter logic INCLUDE_BUFF = 0,
    parameter logic INCLUDE_SE_BUFF = 0,
    parameter logic INCLUDE_BPE = 0,
    parameter logic INCLUDE_DSM = 0,
    parameter logic INCLUDE_VCO = 0,
    parameter logic INCLUDE_PDVCO = 0,
    parameter logic INCLUDE_DLC = 0,
    parameter logic INCLUDE_LC = 0
) (
    lna_if.signals lna,
    buff_if.signals buff,
    bpe_if.signals bpe,
    dsm_if.signals dsm,
    pdvco_if.signals pdvco,
    dlc_if.signals dlc,
    lc_if.signals lc,

    /* verilator lint_off UNUSED */
    input `analog_t vref,
    input logic ref_clk_i,
    /* verilator lint_on UNUSED */

    output logic                     data_available_o,
    input  logic                     data_read_i,
    output logic [PAYLOAD_WIDTH-1:0] data_o,

    input logic clk_i,
    input logic rst_ni,
    input reg_pkg::reg_req_t req_i,
    output reg_pkg::reg_rsp_t rsp_o

);

  /* verilator lint_off UNDRIVEN */
  /* verilator lint_off UNUSED */
  channel_multipath_reg_pkg::channel_multipath_hw2reg_t hw2reg;
  channel_multipath_reg_pkg::channel_multipath_reg2hw_t reg2hw;
  /* verilator lint_on UNUSED */
  /* verilator lint_on UNDRIVEN */

  // VCO decoder registers
  channel_multipath_reg_top #(
      .reg_req_t(reg_pkg::reg_req_t),
      .reg_rsp_t(reg_pkg::reg_rsp_t)
  ) u_channel_multipath_reg_top (
      .clk_i    (clk_i),
      .rst_ni   (rst_ni),
      .reg_req_i(req_i),
      .reg_rsp_o(rsp_o),
      .reg2hw   (reg2hw),
      .hw2reg   (hw2reg),
      .devmode_i(1'b0)
  );

  generate  // LNA
    if (INCLUDE_LNA) begin : LNA

      logic [2:0] lna_pr;
      logic [1:0] lna_gain;
      logic [1:0] lna_cutoff;

      LNA_wrapper u_LNA (
          .bvdd(lna.vdd),
          .vcm(lna.vcm),
          .ibias(lna.ibias),
          .vin_p(lna.vin_p),
          .vin_n(lna.vin_n),
          .vout_p(lna.vout_p),
          .vout_n(lna.vout_n),
          .pr_i(lna_pr),
          .gain_i(lna_gain),
          .cutoff_i(lna_cutoff),
          .clk_i,
          .rst_i(~rst_ni),
          .en_ni(~reg2hw.lna_en.q)
      );

      LNA_ctrl u_LNA_ctrl (
          .pr_o(lna_pr),
          .gain_o(lna_gain),
          .cutoff_o(lna_cutoff),
          .clk_i,
          .rst_ni,
          .req_i(lna.lna_ctrl_req_i),
          .rsp_o(lna.lna_ctrl_rsp_o)
      );

    end else begin : NO_LNA
      assign lna.vout_p = 0;
      assign lna.vout_n = 0;
      `UNUSED(lna.vdd);
      `UNUSED(lna.vcm);
      `UNUSED(lna.vin_p);
      `UNUSED(lna.vin_n);
    end
  endgenerate

  generate  // BUFF
    if (INCLUDE_BUFF) begin : BUFF

      BUFF_wrapper u_BUFF (
          .bvdd(buff.vdd),
          .vcm(vref),
          .ibias(buff.ibias),
          .vin_p(buff.vin_p),
          .vin_n(buff.vin_n),
          .vout_p(buff.vout_p),
          .vout_n(buff.vout_n),
          .clk_i,
          .rst_ni,
          .en_ni(~reg2hw.buff_en.q)
      );

    end else if (INCLUDE_SE_BUFF) begin : SE_BUFF

      SE_BUFF_wrapper u_BUFF (
          .bvdd (buff.vdd),
          .ibias(buff.ibias),
          .vin  (buff.vin_p),
          .vout (buff.vout_p),
          .en_ni(~reg2hw.buff_en.q)
      );

      `UNUSED(buff.vin_n);
      `UNUSED(buff.vout_n);

    end else begin : NO_BUFF
      assign buff.vout_p = 0;
      assign buff.vout_n = 0;
      `UNUSED(buff.vin_p);
      `UNUSED(buff.vin_n);
      `UNUSED(buff.vdd);
    end
  endgenerate


  generate  // BPE
    if (INCLUDE_BPE) begin : BPE

      logic [5:0] bpe_ibias_sel;
      logic [5:0] bpe_ch_en;
      logic [3:0] bpe_pwm;
      logic [3:0] pwm_out;
      logic       bpe_clk;

      BPE_wrapper u_BPE (
          .clk_i(bpe_clk),
          .rst_ni,
          .bvdd(bpe.vdd),
          .vref,
          .vref_comp(lna.vcm),
          .ibias(bpe.ibias),
          .ibias_buf_p(bpe.ibias_buf_p),
          .ibias_buf_n(bpe.ibias_buf_n),
          .vin_p(bpe.vin_p),
          .vin_n(bpe.vin_n),
          .vout_p(bpe.vout_p),
          .vout_n(bpe.vout_n),
          .ibias_sel(bpe_ibias_sel),
          .ch_en(bpe_ch_en),
          .pwm_i(bpe_pwm),
          .comp_p_o(bpe.comp_p_o),
          .comp_n_o(bpe.comp_n_o),
          .en_ni(~reg2hw.bpe_en.q)     // Active LOW
      );

      BPE_ctrl u_BPE_ctrl (
          .clk_i,
          .rst_ni,
          .ibias_sel(bpe_ibias_sel),
          .ch_en(bpe_ch_en),
          .req_i(bpe.ctrl_req_i),
          .rsp_o(bpe.ctrl_rsp_o)
      );

      genvar i;
      for (i = 0; i < 4; i++) begin : PWM
        PWM u_pwm (
            .ref_clk_i(ref_clk_i),
            .clk_i    (clk_i),
            .rst_ni   (rst_ni),
            .enable_i (reg2hw.pwm_en.q[i]),
            .out_o    (pwm_out[i]),
            .req_i    (bpe.pwm_req_i[i]),
            .rsp_o    (bpe.pwm_rsp_o[i])
        );
      end

      pgm_clock_divider #(
          .DEFAULT_DIV_VALUE(100)
      ) u_bpe_clock_divider (
          .clk_i(clk_i),
          .rst_ni(rst_ni),
          .freq_div_valid_i(reg2hw.bpe_change_freq.q),  // Default 0 will set the default divisor set above
          .req_i(bpe.clock_divider_req_i),
          .rsp_o(bpe.clock_divider_rsp_o),
          .clk_o(bpe_clk)
      );

      always_comb begin
        if (reg2hw.bpe_connect_internally.q) begin
          bpe_pwm   = pwm_out;
          bpe.pwm_o = '0;
        end else begin
          bpe_pwm   = bpe.pwm_i;
          bpe.pwm_o = pwm_out;
        end
      end

    end else begin : NO_BPE
      assign bpe.vout_p = 0;
      assign bpe.vout_n = 0;
      assign bpe.pwm_o = '0;
      assign bpe.pwm_rsp_o = {4{reg_pkg::reg_rsp_t'(0)}};
      assign bpe.ctrl_rsp_o = reg_pkg::reg_rsp_t'(0);
      `UNUSED(bpe.pwm_i);
      `UNUSED(bpe.vdd);
      `UNUSED(bpe.vin_p);
      `UNUSED(bpe.vin_n);
      `UNUSED(bpe.pwm_req_i);
      `UNUSED(bpe.ctrl_req_i);
    end
  endgenerate

  /* verilator lint_off UNUSED */
  logic        dsm_filter_data_write_req;
  logic [31:0] dsm_filter_data_write;
  /* verilator lint_on UNUSED */

  generate  // DSM
    if (INCLUDE_DSM) begin : DSM

      logic       dsm_fsm_en_n;
      logic       dsm_resonator_en_n;
      logic [4:0] dsm_cap_sel;
      logic [1:0] dsm_lowpower_sel;
      logic       dsm_lfp_en_i;  // Mode 0 or 1

      logic       dsm_out;
      logic       dec_in;
      logic       dec_clk;
      logic       dsm_clk;

      DSM_wrapper u_DSM (
          .bvdd           (dsm.vdd),
          .vcm            (vref),
          .ibias          (dsm.ibias),
          .vin_p          (dsm.vin_p),
          .vin_n          (dsm.vin_n),
          .fsm_en_ni      (dsm_fsm_en_n),        // ACTIVE LOW
          .resonator_en_ni(dsm_resonator_en_n),  // ACTIVE LOW
          .cap_sel_i      (dsm_cap_sel),
          .lowpower_sel_i (dsm_lowpower_sel),
          .lfp_en_i       (dsm_lfp_en_i),        // Mode 0 or 1
          .out_o          (dsm_out),
          .dsm_en_ni      (~reg2hw.dsm_en.q),    // ENABLE IS ACTIVE LOW
          .clk_i          (dsm_clk),
          .rst_i          (~rst_ni)              // RESET IS ACTIVE HIGH!
      );

      DSM_ctrl u_DSM_ctrl (
          .fsm_en_no(dsm_fsm_en_n),
          .resonator_en_no(dsm_resonator_en_n),
          .cap_sel_o(dsm_cap_sel),
          .lowpower_sel_o(dsm_lowpower_sel),
          .lfp_en_o(dsm_lfp_en_i),
          .clk_i,  // TODO_heepokranios: manage CDC or add another clock source
          .rst_ni,
          .req_i(dsm.ctrl_req_i),
          .rsp_o(dsm.ctrl_rsp_o)
      );

      dsm_decimation u_dsm_decimation (
          .ref_clk_i,
          .clk_i,
          .rst_ni,
          .dsm_in_i(dec_in),
          .dsm_clk_o(dec_clk),
          .data_o(dsm_filter_data_write),
          .cic_req_i(dsm.cic_req_i),
          .cic_rsp_o(dsm.cic_rsp_o),
          .ses_filter_req_i(dsm.ses_req_i),
          .ses_filter_rsp_o(dsm.ses_rsp_o),
          .refresh_notif_o(dsm_filter_data_write_req)
      );


      always_comb begin
        if (reg2hw.dsm_connect_internally.q) begin
          dsm_clk = dec_clk;
          dec_in = dsm_out;
          dsm.clk_o = '0;
          dsm.out_o = '0;
        end else begin
          dsm_clk = dsm.clk_i;
          dec_in = dsm.dec_i;
          dsm.clk_o = dec_clk;
          dsm.out_o = dsm_out;
        end
      end


    end else begin : NO_DSM
      assign dsm.out_o = 0;
      assign dsm_filter_data_write = 0;
      assign dsm_filter_data_write_req = 0;
      `UNUSED(dsm.vdd);
      `UNUSED(dsm.ibias);
      `UNUSED(dsm.vin_p);
      `UNUSED(dsm.vin_n);
      `UNUSED(dsm.clk_i);
    end
  endgenerate

  /* verilator lint_off UNUSED */
  logic [vco_pkg::VcoDataWidth-1:0] vco_p_count_diff;
  logic vco_p_refresh_notif;
  logic [vco_pkg::VcoDataWidth-1:0] vco_n_count_diff;
  logic vco_n_refresh_notif;
  logic [31:0] pdvco_out;
  /* verilator lint_on UNUSED */

  generate  // PD VCO
    if (INCLUDE_PDVCO | INCLUDE_VCO) begin : PDVCO_P
      //   logic vco_refresh;
      logic vco_p_phase;
      logic vco_p_ovf;
      logic vco_p_en;

      VCO_wrapper u_VCO_p (
          .bvdd(pdvco.vdd),
          .vin(pdvco.vin_p),
          .clk_i,
          .rst_ni,
          .en_i(reg2hw.pdvco_en.vco_p_en.q & vco_p_en),
          .phase_o(vco_p_phase)
      );

      VCO_counter u_vco_p_counter (
          .clk_i(clk_i),
          .rst_ni(rst_ni),
          .en_i(reg2hw.pdvco_en.vco_p_en.q),
          .req_i(pdvco.vco_p_counter_req_i),
          .rsp_o(pdvco.vco_p_counter_rsp_o),
          .phase_i(vco_p_phase),
          .ovf_o(vco_p_ovf),
          .en_o(vco_p_en),
          .count_diff_o(vco_p_count_diff),
          .refresh_notif_o(vco_p_refresh_notif)
      );

      assign pdvco.vco_p_out_o   = reg2hw.vco_phase_output.q ? vco_p_phase : vco_p_ovf;

      assign hw2reg.vco_p_out.d  = vco_p_count_diff;
      assign hw2reg.vco_p_out.de = vco_p_refresh_notif;

      if (INCLUDE_PDVCO) begin : PDVCO

        logic vco_n_phase;
        logic vco_n_ovf;
        logic vco_n_en;

        VCO_wrapper u_VCO_n (
            .bvdd(pdvco.vdd),
            .vin(pdvco.vin_n),
            .clk_i,
            .rst_ni,
            .en_i(reg2hw.pdvco_en.vco_n_en.q & vco_n_en),
            .phase_o(vco_n_phase)
        );

        VCO_counter u_vco_n_counter (
            .clk_i(clk_i),
            .rst_ni(rst_ni),
            .en_i(reg2hw.pdvco_en.vco_n_en.q),
            .req_i(pdvco.vco_n_counter_req_i),
            .rsp_o(pdvco.vco_n_counter_rsp_o),
            .phase_i(vco_n_phase),
            .ovf_o(vco_n_ovf),
            .en_o(vco_n_en),
            .count_diff_o(vco_n_count_diff),
            .refresh_notif_o(vco_n_refresh_notif)
        );

        assign pdvco.vco_n_out_o   = reg2hw.vco_phase_output.q ? vco_n_phase : vco_n_ovf;

        assign hw2reg.vco_n_out.d  = vco_n_count_diff;
        assign hw2reg.vco_n_out.de = vco_n_refresh_notif;

        assign hw2reg.pdvco_out.d  = pdvco_out;
        assign hw2reg.pdvco_out.de = vco_p_refresh_notif | vco_n_refresh_notif;

        always_ff @(posedge clk_i, negedge rst_ni) begin
          // If any of the VCOs is not enabled, then reset the difference.
          if (!rst_ni) begin
            pdvco_out <= 0;
          end else begin
            if (!(reg2hw.pdvco_en.vco_p_en.q == '1) || !(reg2hw.pdvco_en.vco_n_en.q == '1)) begin
              pdvco_out <= 0;
            end else begin
              pdvco_out <= vco_p_count_diff - vco_n_count_diff;
            end
          end
        end
      end else begin : NO_PDVCO
        assign vco_n_count_diff = 0;
        assign vco_n_refresh_notif = 0;
        assign pdvco_out = 0;
        assign pdvco.vco_n_out_o = 1'b0;
        assign pdvco.vco_n_counter_rsp_o = reg_pkg::reg_rsp_t'(0);
        `UNUSED(pdvco.vin_n);
        `UNUSED(pdvco.vco_n_counter_req_i);
        `UNUSED(vco_p_count_diff);
        `UNUSED(vco_p_refresh_notif);

      end

    end else begin : NO_VCO

      assign vco_p_count_diff = 0;
      assign vco_p_refresh_notif = 0;
      assign pdvco.vco_p_out_o = 1'b0;
      assign pdvco.vco_p_counter_rsp_o = reg_pkg::reg_rsp_t'(0);
      `UNUSED(pdvco.vin_p);
      `UNUSED(pdvco.vdd);
      `UNUSED(pdvco.vco_p_counter_req_i);

      assign vco_n_count_diff = 0;
      assign vco_n_refresh_notif = 0;
      assign pdvco_out = 0;
      assign pdvco.vco_n_out_o = 1'b0;
      assign pdvco.vco_n_counter_rsp_o = reg_pkg::reg_rsp_t'(0);
      `UNUSED(pdvco.vin_n);
      `UNUSED(pdvco.vco_n_counter_req_i);
    end
  endgenerate


  /* verilator lint_off UNUSED */
  logic lc_xing_syncd;
  logic lc_dir_syncd;
  /* verilator lint_on UNUSED */

  generate  // LC

    if (INCLUDE_LC) begin : LC

      logic [3:0] lvl_width_sel;
      logic [3:0] dir_width_sel;
      logic [1:0] cap_sel;

      LC_wrapper u_LC (
          /* verilator lint_off UNUSED */
          .bvdd(lc.vdd),
          .vcm(vref),
          .ibias(lc.ibias),
          .vin(lc.vin),
          .w_lvl_sel(lvl_width_sel),
          .w_dir_sel(dir_width_sel),
          .cap_sel_i(cap_sel),
          .dir_o(lc.dir_o),
          .xing_o(lc.xing_o),
          .discharge_o(lc.discharge_o),
          .en_ni(reg2hw.lc_en.q),  //@juan make active LOW by default
          .clk_i,
          .rst_ni
      );

      LC_ctrl u_LC_ctrl (
          .clk_i,
          .rst_ni,
          .lvl_width_sel_o(lvl_width_sel),
          .dir_width_sel_o(dir_width_sel),
          .cap_sel_o(cap_sel),
          .req_i(lc.ctrl_req_i),
          .rsp_o(lc.ctrl_rsp_o)
      );

      lc_sync #(
          .SYNC_STAGES(2)
      ) u_lc_sync (
          .clk_i,
          .rst_ni,

          .xing_i(lc.xing_o),
          .dir_i (lc.dir_o),
          .xing_o(lc_xing_syncd),
          .dir_o (lc_dir_syncd)
      );

    end else begin : NO_LC

      assign lc_xing_syncd = 0;
      assign lc_dir_syncd = 0;

      assign lc.xing_o = 0;
      assign lc.dir_o = 0;
      `UNUSED(lc.ctrl_req_i);
      `UNUSED(lc.ctrl_rsp_o);

    end

  endgenerate



  /* verilator lint_off UNUSED */
  /* verilator lint_off UNDRIVEN */
  fifo_pkg::fifo_req_t  dlc_fifo_req;
  fifo_pkg::fifo_resp_t dlc_fifo_rsp;
  /* verilator lint_on UNDRIVEN */
  /* verilator lint_on UNUSED */

  generate  // dLC

    if (INCLUDE_DLC) begin : DLC
      dlc dlc_i (
          .clk_i,
          .rst_ni,
          .dlc_done_o(dlc.done_o),
          .reg_req_i(dlc.req_i),
          .reg_rsp_o(dlc.rsp_o),
          .hw_fifo_req_i(dlc_fifo_req),
          .hw_fifo_resp_o(dlc_fifo_rsp),
          .xing_i(lc_xing_syncd),
          .dir_i(lc_dir_syncd),
          .dlc_xing_o(dlc.xing_o),
          .dlc_dir_o(dlc.dir_o)
      );
    end else begin : NO_DLC
      assign dlc.done_o = 0;
      assign dlc.xing_o = 0;
      assign dlc.dir_o  = 0;
      `UNUSED(dlc_fifo_req);
      `UNUSED(dlc_fifo_rsp);
    end

  endgenerate




  // -------------------------------------------
  // ADC FUNNEL
  // -------------------------------------------

  // Force one-hot-encoding of the selection to go to the data multiplexer
  logic sel_dsm;
  logic sel_vco_p;
  logic sel_vco_n;
  logic sel_pdvco;

  always_comb begin
    sel_dsm   = 1'b0;
    sel_vco_p = 1'b0;
    sel_vco_n = 1'b0;
    sel_pdvco = 1'b0;

    unique case (reg2hw.data_source_sel.q)
      1: sel_dsm = 1;
      2: sel_vco_p = 1;
      4: sel_vco_n = 1;
      6: sel_pdvco = 1;
      default: ;
    endcase
  end

  logic [PAYLOAD_WIDTH-1:0] last_data_selected;
  logic [PAYLOAD_WIDTH-1:0] data_selected;
  logic data_selected_valid;

  logic [PAYLOAD_WIDTH-1:0] buffer_data_in;
  logic buffer_data_in_valid;

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      last_data_selected <= '0;
    end else begin
      // Only update the history when we actually have a new valid sample
      // and differential mode is active
      if (reg2hw.dlc_en.q && reg2hw.dlc_derivative.q && data_selected_valid) begin
        last_data_selected <= data_selected;
      end
    end
  end

  always_comb begin
    data_selected        = '0;
    data_selected_valid  = '0;
    buffer_data_in       = '0;
    buffer_data_in_valid = '0;

    if (sel_dsm) begin
      data_selected       = dsm_filter_data_write[PAYLOAD_WIDTH-1:0];
      data_selected_valid = dsm_filter_data_write_req;  // TODO_heepokranios: this could need CDC!!!
    end else if (sel_vco_p) begin
      data_selected       = vco_p_count_diff[PAYLOAD_WIDTH-1:0];
      data_selected_valid = vco_p_refresh_notif;  // TODO_heepokranios: this could need CDC!!!
    end else if (sel_vco_n) begin
      data_selected       = vco_n_count_diff[PAYLOAD_WIDTH-1:0];
      data_selected_valid = vco_n_refresh_notif;  // TODO_heepokranios: this could need CDC!!!
    end else if (sel_pdvco) begin
      data_selected       = pdvco_out[PAYLOAD_WIDTH-1:0];
      data_selected_valid = vco_p_refresh_notif | vco_n_refresh_notif;  // TODO_heepokranios: this could need CDC!!!
    end

    if (reg2hw.dlc_en.q) begin

      dlc_fifo_req.data = (reg2hw.dlc_derivative.q ? (32'(data_selected) - 32'(last_data_selected)) : 32'(data_selected)) + 32'(reg2hw.dlc_offset.q);

      dlc_fifo_req.push = data_selected_valid;
      dlc_fifo_req.pop = ~(dlc_fifo_rsp.empty);
      dlc_fifo_req.flush = reg2hw.buffer_flush.q;
      buffer_data_in = dlc_fifo_rsp.data[PAYLOAD_WIDTH-1:0];
      buffer_data_in_valid = ~(dlc_fifo_rsp.empty);

    end else begin
      buffer_data_in       = data_selected;
      buffer_data_in_valid = data_selected_valid;
      dlc_fifo_req         = '0;
    end

  end

  assign hw2reg.data_available.d = data_available_o;
  assign hw2reg.data_available.de = '1;

  assign data_o = hw2reg.data_out.d;

  circular_buffer u_output_buffer (
      .clk_i,
      .rst_ni,
      .flush_i(reg2hw.buffer_flush.q),
      .data_i(buffer_data_in),
      .data_push_i(buffer_data_in_valid),
      .data_pop_i(reg2hw.data_out.re | data_read_i),
      .data_not_empty_o(data_available_o),
      .data_o(hw2reg.data_out.d)
  );



endmodule
