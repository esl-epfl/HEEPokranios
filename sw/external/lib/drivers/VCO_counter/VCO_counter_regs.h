// Generated register defines for VCO_counter

// Copyright information found in source file:
// Copyright 2026 EPFL contributors

// Licensing information found in source file:
// 
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1

#ifndef _VCO_COUNTER_REG_DEFS_
#define _VCO_COUNTER_REG_DEFS_

#ifdef __cplusplus
extern "C" {
#endif
// Register width
#define VCO_COUNTER_PARAM_REG_WIDTH 32

// Bit to look at from the counter to raise the ovf flag
#define VCO_COUNTER_COUNTER_OVF_RAISE_BIT_REG_OFFSET 0x0
#define VCO_COUNTER_COUNTER_OVF_RAISE_BIT_COUNTER_OVF_RAISE_BIT_MASK 0x1f
#define VCO_COUNTER_COUNTER_OVF_RAISE_BIT_COUNTER_OVF_RAISE_BIT_OFFSET 0
#define VCO_COUNTER_COUNTER_OVF_RAISE_BIT_COUNTER_OVF_RAISE_BIT_FIELD \
  ((bitfield_field32_t) { .mask = VCO_COUNTER_COUNTER_OVF_RAISE_BIT_COUNTER_OVF_RAISE_BIT_MASK, .index = VCO_COUNTER_COUNTER_OVF_RAISE_BIT_COUNTER_OVF_RAISE_BIT_OFFSET })

// Bit to look at from the counter to lower the ovf flag
#define VCO_COUNTER_COUNTER_OVF_FALL_BIT_REG_OFFSET 0x4
#define VCO_COUNTER_COUNTER_OVF_FALL_BIT_COUNTER_OVF_FALL_BIT_MASK 0x1f
#define VCO_COUNTER_COUNTER_OVF_FALL_BIT_COUNTER_OVF_FALL_BIT_OFFSET 0
#define VCO_COUNTER_COUNTER_OVF_FALL_BIT_COUNTER_OVF_FALL_BIT_FIELD \
  ((bitfield_field32_t) { .mask = VCO_COUNTER_COUNTER_OVF_FALL_BIT_COUNTER_OVF_FALL_BIT_MASK, .index = VCO_COUNTER_COUNTER_OVF_FALL_BIT_COUNTER_OVF_FALL_BIT_OFFSET })

// VCO ADC count output
#define VCO_COUNTER_COUNT_OUT_REG_OFFSET 0x8

// VCO ADC count difference (wrt previous)
#define VCO_COUNTER_COUNT_DIFF_REG_OFFSET 0xc

// How long the integration should be. For no duty cycling, this should be
// equal to integration_cc. This is a bit idx (i.e. 10 will trigger every
// 1024 clk_i clock cycles).
#define VCO_COUNTER_INTEGRATION_CC_REG_OFFSET 0x10
#define VCO_COUNTER_INTEGRATION_CC_INTEGRATION_CC_MASK 0x1f
#define VCO_COUNTER_INTEGRATION_CC_INTEGRATION_CC_OFFSET 0
#define VCO_COUNTER_INTEGRATION_CC_INTEGRATION_CC_FIELD \
  ((bitfield_field32_t) { .mask = VCO_COUNTER_INTEGRATION_CC_INTEGRATION_CC_MASK, .index = VCO_COUNTER_INTEGRATION_CC_INTEGRATION_CC_OFFSET })

// The sampling period of the VCO. For no duty cycling, this should be equal
// to integration_cc. This is a bit idx (i.e. 10 will trigger every 1024
// clk_i clock cycles).
#define VCO_COUNTER_PERIOD_CC_REG_OFFSET 0x14
#define VCO_COUNTER_PERIOD_CC_PERIOD_CC_MASK 0x1f
#define VCO_COUNTER_PERIOD_CC_PERIOD_CC_OFFSET 0
#define VCO_COUNTER_PERIOD_CC_PERIOD_CC_FIELD \
  ((bitfield_field32_t) { .mask = VCO_COUNTER_PERIOD_CC_PERIOD_CC_MASK, .index = VCO_COUNTER_PERIOD_CC_PERIOD_CC_OFFSET })

// How long the VCO is on before integration of the counter begins (for duty
// cycling). This is a bit idx (i.e. 10 will trigger every 1024 clk_i clock
// cycles).
#define VCO_COUNTER_SETTLE_CC_REG_OFFSET 0x18
#define VCO_COUNTER_SETTLE_CC_SETTLE_CC_MASK 0x1f
#define VCO_COUNTER_SETTLE_CC_SETTLE_CC_OFFSET 0
#define VCO_COUNTER_SETTLE_CC_SETTLE_CC_FIELD \
  ((bitfield_field32_t) { .mask = VCO_COUNTER_SETTLE_CC_SETTLE_CC_MASK, .index = VCO_COUNTER_SETTLE_CC_SETTLE_CC_OFFSET })

// How long the VCO is on after integration of the counter ends (for duty
// cycling). This is a bit idx (i.e. 10 will trigger every 1024 clk_i clock
// cycles).
#define VCO_COUNTER_COOLDOWN_CC_REG_OFFSET 0x1c
#define VCO_COUNTER_COOLDOWN_CC_COOLDOWN_CC_MASK 0x1f
#define VCO_COUNTER_COOLDOWN_CC_COOLDOWN_CC_OFFSET 0
#define VCO_COUNTER_COOLDOWN_CC_COOLDOWN_CC_FIELD \
  ((bitfield_field32_t) { .mask = VCO_COUNTER_COOLDOWN_CC_COOLDOWN_CC_MASK, .index = VCO_COUNTER_COOLDOWN_CC_COOLDOWN_CC_OFFSET })

// A scaling applied to the counter difference when adjusting duty-cycling on
// run-time
#define VCO_COUNTER_COUNT_DIFF_SHIFT_REG_OFFSET 0x20
#define VCO_COUNTER_COUNT_DIFF_SHIFT_COUNT_DIFF_SHIFT_MASK 0x1f
#define VCO_COUNTER_COUNT_DIFF_SHIFT_COUNT_DIFF_SHIFT_OFFSET 0
#define VCO_COUNTER_COUNT_DIFF_SHIFT_COUNT_DIFF_SHIFT_FIELD \
  ((bitfield_field32_t) { .mask = VCO_COUNTER_COUNT_DIFF_SHIFT_COUNT_DIFF_SHIFT_MASK, .index = VCO_COUNTER_COUNT_DIFF_SHIFT_COUNT_DIFF_SHIFT_OFFSET })

// Trigger manually the refresh signal
#define VCO_COUNTER_MANUAL_TRIGGER_REG_OFFSET 0x24
#define VCO_COUNTER_MANUAL_TRIGGER_MANUAL_TRIGGER_BIT 0

// Enable signals for the VCOs and VCO decoder
#define VCO_COUNTER_ENABLE_REG_OFFSET 0x28
#define VCO_COUNTER_ENABLE_ENABLE_BIT 0

// Drivers the refresh_o signal
#define VCO_COUNTER_MANUAL_REFRESH_TRAIN0_REG_OFFSET 0x2c
#define VCO_COUNTER_MANUAL_REFRESH_TRAIN0_MANUAL_REFRESH_TRAIN0_BIT 0

// Drivers the clk of the vco_computation units
#define VCO_COUNTER_MANUAL_REFRESH_TRAIN1_REG_OFFSET 0x30
#define VCO_COUNTER_MANUAL_REFRESH_TRAIN1_MANUAL_REFRESH_TRAIN1_BIT 0

// Drivers the refresh_notif_o signal
#define VCO_COUNTER_MANUAL_REFRESH_TRAIN2_REG_OFFSET 0x34
#define VCO_COUNTER_MANUAL_REFRESH_TRAIN2_MANUAL_REFRESH_TRAIN2_BIT 0

#ifdef __cplusplus
}  // extern "C"
#endif
#endif  // _VCO_COUNTER_REG_DEFS_
// End generated register defines for VCO_counter