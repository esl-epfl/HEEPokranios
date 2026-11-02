// Generated register defines for LC_ctrl

// Copyright information found in source file:
// Copyright 2026 EPFL contributors

// Licensing information found in source file:
// 
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1

#ifndef _LC_CTRL_REG_DEFS_
#define _LC_CTRL_REG_DEFS_

#ifdef __cplusplus
extern "C" {
#endif
// Register width
#define LC_CTRL_PARAM_REG_WIDTH 32

// Select the level widths
#define LC_CTRL_LVL_WIDTH_SEL_REG_OFFSET 0x0
#define LC_CTRL_LVL_WIDTH_SEL_LVL_WIDTH_SEL_MASK 0xf
#define LC_CTRL_LVL_WIDTH_SEL_LVL_WIDTH_SEL_OFFSET 0
#define LC_CTRL_LVL_WIDTH_SEL_LVL_WIDTH_SEL_FIELD \
  ((bitfield_field32_t) { .mask = LC_CTRL_LVL_WIDTH_SEL_LVL_WIDTH_SEL_MASK, .index = LC_CTRL_LVL_WIDTH_SEL_LVL_WIDTH_SEL_OFFSET })

// Select the direction widths
#define LC_CTRL_DIR_WIDTH_SEL_REG_OFFSET 0x4
#define LC_CTRL_DIR_WIDTH_SEL_DIR_WIDTH_SEL_MASK 0xf
#define LC_CTRL_DIR_WIDTH_SEL_DIR_WIDTH_SEL_OFFSET 0
#define LC_CTRL_DIR_WIDTH_SEL_DIR_WIDTH_SEL_FIELD \
  ((bitfield_field32_t) { .mask = LC_CTRL_DIR_WIDTH_SEL_DIR_WIDTH_SEL_MASK, .index = LC_CTRL_DIR_WIDTH_SEL_DIR_WIDTH_SEL_OFFSET })

// Select the follower capacitance
#define LC_CTRL_CAP_SEL_REG_OFFSET 0x8
#define LC_CTRL_CAP_SEL_CAP_SEL_MASK 0x3
#define LC_CTRL_CAP_SEL_CAP_SEL_OFFSET 0
#define LC_CTRL_CAP_SEL_CAP_SEL_FIELD \
  ((bitfield_field32_t) { .mask = LC_CTRL_CAP_SEL_CAP_SEL_MASK, .index = LC_CTRL_CAP_SEL_CAP_SEL_OFFSET })

#ifdef __cplusplus
}  // extern "C"
#endif
#endif  // _LC_CTRL_REG_DEFS_
// End generated register defines for LC_ctrl