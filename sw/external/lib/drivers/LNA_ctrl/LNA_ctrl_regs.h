// Generated register defines for LNA_ctrl

// Copyright information found in source file:
// Copyright 2026 EPFL contributors

// Licensing information found in source file:
// 
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1

#ifndef _LNA_CTRL_REG_DEFS_
#define _LNA_CTRL_REG_DEFS_

#ifdef __cplusplus
extern "C" {
#endif
// Register width
#define LNA_CTRL_PARAM_REG_WIDTH 32

// Pseudo-resistor configuration selection
#define LNA_CTRL_PR_REG_OFFSET 0x0
#define LNA_CTRL_PR_PR_MASK 0x7
#define LNA_CTRL_PR_PR_OFFSET 0
#define LNA_CTRL_PR_PR_FIELD \
  ((bitfield_field32_t) { .mask = LNA_CTRL_PR_PR_MASK, .index = LNA_CTRL_PR_PR_OFFSET })

// Gain of the LNA amplification selection
#define LNA_CTRL_GAIN_REG_OFFSET 0x4
#define LNA_CTRL_GAIN_GAIN_MASK 0x3
#define LNA_CTRL_GAIN_GAIN_OFFSET 0
#define LNA_CTRL_GAIN_GAIN_FIELD \
  ((bitfield_field32_t) { .mask = LNA_CTRL_GAIN_GAIN_MASK, .index = LNA_CTRL_GAIN_GAIN_OFFSET })

// Cutoff frequency selection
#define LNA_CTRL_CUTOFF_REG_OFFSET 0x8
#define LNA_CTRL_CUTOFF_CUTOFF_MASK 0x3
#define LNA_CTRL_CUTOFF_CUTOFF_OFFSET 0
#define LNA_CTRL_CUTOFF_CUTOFF_FIELD \
  ((bitfield_field32_t) { .mask = LNA_CTRL_CUTOFF_CUTOFF_MASK, .index = LNA_CTRL_CUTOFF_CUTOFF_OFFSET })

#ifdef __cplusplus
}  // extern "C"
#endif
#endif  // _LNA_CTRL_REG_DEFS_
// End generated register defines for LNA_ctrl