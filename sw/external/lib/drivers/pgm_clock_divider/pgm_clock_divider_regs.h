// Generated register defines for pgm_clock_divider

// Copyright information found in source file:
// Copyright 2025 EPFL contributors

// Licensing information found in source file:
// 
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1

#ifndef _PGM_CLOCK_DIVIDER_REG_DEFS_
#define _PGM_CLOCK_DIVIDER_REG_DEFS_

#ifdef __cplusplus
extern "C" {
#endif
// Register width
#define PGM_CLOCK_DIVIDER_PARAM_REG_WIDTH 32

// How many times to divide the input clock
#define PGM_CLOCK_DIVIDER_DIVIDER_REG_OFFSET 0x0
#define PGM_CLOCK_DIVIDER_DIVIDER_DIVIDER_MASK 0x3ff
#define PGM_CLOCK_DIVIDER_DIVIDER_DIVIDER_OFFSET 0
#define PGM_CLOCK_DIVIDER_DIVIDER_DIVIDER_FIELD \
  ((bitfield_field32_t) { .mask = PGM_CLOCK_DIVIDER_DIVIDER_DIVIDER_MASK, .index = PGM_CLOCK_DIVIDER_DIVIDER_DIVIDER_OFFSET })

// Enable the division (1) or output nothing (0)
#define PGM_CLOCK_DIVIDER_ENABLE_REG_OFFSET 0x4
#define PGM_CLOCK_DIVIDER_ENABLE_ENABLE_BIT 0

// If 1, then output the input clock without division
#define PGM_CLOCK_DIVIDER_BYPASS_REG_OFFSET 0x8
#define PGM_CLOCK_DIVIDER_BYPASS_BYPASS_BIT 0

#ifdef __cplusplus
}  // extern "C"
#endif
#endif  // _PGM_CLOCK_DIVIDER_REG_DEFS_
// End generated register defines for pgm_clock_divider