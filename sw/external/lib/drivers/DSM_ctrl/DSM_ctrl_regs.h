// Generated register defines for DSM_ctrl

// Copyright information found in source file:
// Copyright 2026 EPFL contributors

// Licensing information found in source file:
// 
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1

#ifndef _DSM_CTRL_REG_DEFS_
#define _DSM_CTRL_REG_DEFS_

#ifdef __cplusplus
extern "C" {
#endif
// Register width
#define DSM_CTRL_PARAM_REG_WIDTH 32

// Enable signal for the FSM. Active LOW.
#define DSM_CTRL_FSM_EN_N_REG_OFFSET 0x0
#define DSM_CTRL_FSM_EN_N_FSM_EN_N_BIT 0

// Enable signal for the resonator. Active LOW.
#define DSM_CTRL_RESONATOR_EN_N_REG_OFFSET 0x4
#define DSM_CTRL_RESONATOR_EN_N_RESONATOR_EN_N_BIT 0

// Capacitor selection
#define DSM_CTRL_CAP_SEL_REG_OFFSET 0x8
#define DSM_CTRL_CAP_SEL_CAP_SEL_MASK 0x1f
#define DSM_CTRL_CAP_SEL_CAP_SEL_OFFSET 0
#define DSM_CTRL_CAP_SEL_CAP_SEL_FIELD \
  ((bitfield_field32_t) { .mask = DSM_CTRL_CAP_SEL_CAP_SEL_MASK, .index = DSM_CTRL_CAP_SEL_CAP_SEL_OFFSET })

// Current selection
#define DSM_CTRL_LOWPOWER_SEL_REG_OFFSET 0xc
#define DSM_CTRL_LOWPOWER_SEL_LOWPOWER_SEL_MASK 0x3
#define DSM_CTRL_LOWPOWER_SEL_LOWPOWER_SEL_OFFSET 0
#define DSM_CTRL_LOWPOWER_SEL_LOWPOWER_SEL_FIELD \
  ((bitfield_field32_t) { .mask = DSM_CTRL_LOWPOWER_SEL_LOWPOWER_SEL_MASK, .index = DSM_CTRL_LOWPOWER_SEL_LOWPOWER_SEL_OFFSET })

// Enable the LFP mode (instead of the default EAP mode)
#define DSM_CTRL_LFP_EN_REG_OFFSET 0x10
#define DSM_CTRL_LFP_EN_LFP_EN_BIT 0

// Output of the DSM
#define DSM_CTRL_OUT_REG_OFFSET 0x14
#define DSM_CTRL_OUT_OUT_BIT 0

#ifdef __cplusplus
}  // extern "C"
#endif
#endif  // _DSM_CTRL_REG_DEFS_
// End generated register defines for DSM_ctrl