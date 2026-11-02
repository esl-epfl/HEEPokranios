// Copyright 2026 EPFL.
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
//
// File: VCO_counter.sv
// Author: Juan Sapriza

module VCO_counter #(
    parameter int COUNTER_W = 32
) (
    input logic clk_i,
    input logic rst_ni,

    input logic en_i,

    // Bus interface
    input  reg_pkg::reg_req_t req_i,
    output reg_pkg::reg_rsp_t rsp_o,

    // Interface with VCO
    input  logic phase_i,
    output logic ovf_o,
    output logic en_o,

    output logic [31:0] count_diff_o,

    output logic refresh_notif_o  // to the DMA
);

  /* verilator lint_off UNUSED */
  vco_counter_reg_pkg::vco_counter_hw2reg_t hw2reg;
  vco_counter_reg_pkg::vco_counter_reg2hw_t reg2hw;
  /* verilator lint_on UNUSED */

  // ------------------------------------------------------------
  // Registers
  // ------------------------------------------------------------
  vco_counter_reg_top #(
      .reg_req_t(reg_pkg::reg_req_t),
      .reg_rsp_t(reg_pkg::reg_rsp_t)
  ) u_vco_counter_reg_top (
      .clk_i    (clk_i),
      .rst_ni   (rst_ni),
      .reg_req_i(req_i),
      .reg_rsp_o(rsp_o),
      .reg2hw   (reg2hw),
      .hw2reg   (hw2reg),
      .devmode_i(1'b0)
  );



  // ------------------------------------------------------------
  // States
  // ------------------------------------------------------------

  // Generate a refresh signal at the end of integration. Also generate
  // a delayed version of the refresh signal 1, 2, and 3 cycles later.
  logic refresh;
  logic enable;
  /* verilator lint_off MULTIDRIVEN */
  logic [COUNTER_W-1:0] count, count_previous, count_syncd;
  /* verilator lint_on MULTIDRIVEN */

  logic manual_trigger_prev;
  logic duty_mode;

  typedef enum logic [1:0] {
    DutyOff,
    DutySettle,
    DutyIntegration,
    DutyCooldown
  } duty_state_e;

  duty_state_e duty_state;

  logic [31:0] duty_timer;
  logic [31:0] integration_cycles;
  logic [31:0] period_cycles;
  logic [31:0] settle_cycles;
  logic [31:0] period_room_cycles;
  logic [31:0] dark_off_cycles;
  logic [31:0] integration_timer_load;
  logic [31:0] settle_timer_load;
  logic [31:0] dark_off_timer_load;
  logic [31:0] cooldown_timer_load;
  logic [31:0] start_timer_load;
  logic [31:0] cooldown_cycles;
  logic [31:0] period_room_after_settle_cycles;

  logic duty_cfg_valid;
  duty_state_e start_duty_state;

  function automatic logic [31:0] cc_to_cycles(input logic [4:0] cc);
    cc_to_cycles = (32'd1 << cc);
  endfunction

  function automatic logic [31:0] cycles_to_timer_load(input logic [31:0] cycles);
    cycles_to_timer_load = (cycles == 32'd0) ? 32'd0 : (cycles - 32'd1);
  endfunction

  assign integration_cycles = cc_to_cycles(5'(reg2hw.integration_cc.q));
  assign period_cycles = cc_to_cycles(5'(reg2hw.period_cc.q));

  assign settle_cycles = (reg2hw.settle_cc.q == '0) ? 32'd0 : cc_to_cycles(5'(reg2hw.settle_cc.q));

  assign cooldown_cycles = (reg2hw.cooldown_cc.q == '0) ? 32'd0 : cc_to_cycles(5'(reg2hw.cooldown_cc.q));

  assign period_room_cycles = (period_cycles >= integration_cycles) ? (period_cycles - integration_cycles) : 32'd0;

  assign period_room_after_settle_cycles = (period_room_cycles >= settle_cycles) ? (period_room_cycles - settle_cycles) : 32'd0;

  assign duty_cfg_valid     = (period_cycles >= integration_cycles) &&
                            (period_room_cycles >= settle_cycles) &&
                            (period_room_after_settle_cycles >= cooldown_cycles);

  assign dark_off_cycles = duty_cfg_valid ? (period_room_after_settle_cycles - cooldown_cycles) : 32'd0;

  assign integration_timer_load = cycles_to_timer_load(integration_cycles);
  assign settle_timer_load = cycles_to_timer_load(settle_cycles);
  assign cooldown_timer_load = cycles_to_timer_load(cooldown_cycles);
  assign dark_off_timer_load = cycles_to_timer_load(dark_off_cycles);

  assign duty_mode = duty_cfg_valid && ((reg2hw.period_cc.q != reg2hw.integration_cc.q) || (reg2hw.settle_cc.q != '0));

  always_comb begin
    start_duty_state = DutyIntegration;
    start_timer_load = integration_timer_load;

    if (duty_mode && (dark_off_cycles != 32'd0)) begin
      start_duty_state = DutyOff;
      start_timer_load = dark_off_timer_load;
    end else if (duty_mode && (settle_cycles != 32'd0)) begin
      start_duty_state = DutySettle;
      start_timer_load = settle_timer_load;
    end
  end


  // ------------------------------------------------------------
  // Refresh and enable signals
  // ------------------------------------------------------------

  assign enable = reg2hw.enable.q & en_i;

  // The enable to turn on the VCO
  assign en_o   = (enable & (!duty_mode | (duty_state != DutyOff) | refresh));

  // ------------------------------------------------------------
  // Duty timer and refresh generation
  // ------------------------------------------------------------

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      manual_trigger_prev <= 1'b0;
      duty_state          <= DutyIntegration;
      duty_timer          <= '0;
    end else begin
      manual_trigger_prev <= reg2hw.manual_trigger.q;

      if ((reg2hw.manual_trigger.q && !manual_trigger_prev) || (enable && (duty_state == DutyIntegration) && (duty_timer == 32'd0))) begin
        refresh <= 1'b1;
      end else begin
        refresh <= '0;
      end

      if (!enable) begin
        duty_state <= start_duty_state;
        duty_timer <= start_timer_load;
      end else if (duty_timer != 32'd0) begin
        duty_timer <= duty_timer - 32'd1;
      end else begin
        case (duty_state)

          DutyOff: begin
            if (settle_cycles != 32'd0) begin
              duty_state <= DutySettle;
              duty_timer <= settle_timer_load;
            end else begin
              duty_state <= DutyIntegration;
              duty_timer <= integration_timer_load;
            end
          end

          DutySettle: begin
            duty_state <= DutyIntegration;
            duty_timer <= integration_timer_load;
          end

          DutyIntegration: begin
            if (duty_mode && (dark_off_cycles != 32'd0)) begin
              duty_state <= DutyCooldown;
              duty_timer <= cooldown_timer_load;
            end else if (duty_mode && (settle_cycles != 32'd0)) begin
              duty_state <= DutySettle;
              duty_timer <= settle_timer_load;
            end else begin
              duty_state <= DutyIntegration;
              duty_timer <= integration_timer_load;
            end
          end

          DutyCooldown: begin
            duty_state <= DutyOff;
            duty_timer <= dark_off_timer_load;
          end

          default: begin
            duty_state <= start_duty_state;
            duty_timer <= start_timer_load;
          end

        endcase
      end
    end
  end

  // -----------------------------------------------------------
  // Update difference on every refresh
  // -----------------------------------------------------------

  // @ToDo_heepokranios Syncronize the count so that we reduce the risk of reading trash

  logic count_update;
  edge_propagator sync_request (
      .clk_tx_i(clk_i),
      .rstn_tx_i(rst_ni),
      .edge_i(refresh),
      .clk_rx_i(phase_i),
      .rstn_rx_i(rst_ni),  //@ToDo_heepokranios, sync this reset
      .edge_o(count_update)
  );

  logic count_valid;
  always_ff @(negedge phase_i, negedge rst_ni) begin
    if (!rst_ni) begin
      count_syncd <= '0;
      count_valid <= '0;
    end else begin
      if (count_update) begin
        count_valid <= '1;
        count_syncd <= count;
      end else begin
        count_valid <= '0;
      end
    end
  end

  logic count_valid_syncd;
  edge_propagator sync_valid (
      .clk_tx_i(~phase_i),
      .rstn_tx_i(rst_ni),  //@ToDo_heepokranios, sync this reset
      .edge_i(count_valid),
      .clk_rx_i(clk_i),
      .rstn_rx_i(rst_ni),
      .edge_o(count_valid_syncd)
  );


  // Keeping the difference in the counters
  logic refresh_syncd;
  always_ff @(posedge clk_i, negedge rst_ni) begin
    if (!rst_ni) begin
      count_previous <= '0;
      count_diff_o   <= '0;
    end else begin
      if (!enable) begin
        count_previous <= '0;
        count_diff_o   <= '0;
        refresh_syncd  <= '0;
      end else if (!duty_mode & count_valid_syncd) begin
        // Make sure that the overflow will not cause any troubles to the difference
        count_diff_o   <= {{(32 - COUNTER_W) {1'b0}}, count_syncd - count_previous} << reg2hw.count_diff_shift.q;
        count_previous <= count_syncd;
        refresh_syncd  <= '1;
      end else if (count_valid_syncd) begin
        count_diff_o   <= count_syncd;
        count_previous <= '0;
        refresh_syncd  <= '1;
      end else begin
        refresh_syncd <= '0;
      end
    end
  end

  // -----------------------------------------------------------
  // Update output registers
  // -----------------------------------------------------------

  // Set the values of the registers (d) and enable them (de) at the appropriate time.
  assign hw2reg.count_out.d = 32'(count_syncd);
  assign hw2reg.count_out.de = refresh_syncd;

  assign hw2reg.count_diff.d = count_diff_o;
  assign hw2reg.count_diff.de = refresh_syncd;

  assign refresh_notif_o = refresh_syncd;


  // ------------------------------------------------------------
  // VCO phase ripple counter
  // ------------------------------------------------------------

  always_ff @(posedge phase_i or negedge rst_ni) begin
    if (!rst_ni) begin
      count <= '0;
    end else begin
      if (!enable | ((duty_state != DutyIntegration) & (duty_state != DutyCooldown))) begin
        count <= '0;
      end else begin
        count <= count + 1'b1;
      end
    end
  end

  // ------------------------------------------------------------
  // OVF FLAG
  // ------------------------------------------------------------

  logic ovf_set_tog;
  logic ovf_clr_tog;

  localparam int BIT_IDX_W = $clog2(COUNTER_W);

  logic ovf_raise_clk;
  logic ovf_fall_clk;

  assign ovf_raise_clk = (reg2hw.counter_ovf_raise_bit.q == '0) ? 1'b0 : count[BIT_IDX_W'(reg2hw.counter_ovf_raise_bit.q)];

  assign ovf_fall_clk  = count[BIT_IDX_W'(reg2hw.counter_ovf_fall_bit.q)];


  // Raise event: posedge of selected raise counter bit
  always_ff @(posedge ovf_raise_clk or negedge rst_ni) begin
    if (!rst_ni) begin
      ovf_set_tog <= 1'b0;
    end else begin
      if (!enable | (duty_state != DutyIntegration)) begin
        ovf_set_tog <= 1'b0;
      end else begin
        ovf_set_tog <= ~ovf_set_tog;
      end
    end
  end

  // Drop event: first posedge of selected fall counter bit after ovf_o is high
  always_ff @(posedge ovf_fall_clk or negedge rst_ni) begin
    if (!rst_ni) begin
      ovf_clr_tog <= 1'b0;
    end else begin
      if (!enable | (duty_state != DutyIntegration) | !ovf_o) begin
        ovf_clr_tog <= 1'b0;
      end else begin
        ovf_clr_tog <= ovf_set_tog;
      end
    end
  end

  assign ovf_o = ovf_set_tog ^ ovf_clr_tog;


endmodule
