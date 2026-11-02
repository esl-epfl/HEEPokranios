// Generated register defines for CIC_filter

// Copyright information found in source file:
// Copyright 2025 EPFL

// Licensing information found in source file:
// 
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1

#ifndef _CIC_FILTER_REG_DEFS_
#define _CIC_FILTER_REG_DEFS_

#ifdef __cplusplus
extern "C" {
#endif
// Register width
#define CIC_FILTER_PARAM_REG_WIDTH 32

// Decimation ratio from the sys_clk to the sampling frequency
#define CIC_FILTER_CLKDIVIDX_REG_OFFSET 0x0
#define CIC_FILTER_CLKDIVIDX_COUNT_MASK 0xffff
#define CIC_FILTER_CLKDIVIDX_COUNT_OFFSET 0
#define CIC_FILTER_CLKDIVIDX_COUNT_FIELD \
  ((bitfield_field32_t) { .mask = CIC_FILTER_CLKDIVIDX_COUNT_MASK, .index = CIC_FILTER_CLKDIVIDX_COUNT_OFFSET })

// Control register
#define CIC_FILTER_CONTROL_REG_OFFSET 0x4
#define CIC_FILTER_CONTROL_ENABL_BIT 0
#define CIC_FILTER_CONTROL_CLEAR_BIT 1

// Status register
#define CIC_FILTER_STATUS_REG_OFFSET 0x8
#define CIC_FILTER_STATUS_EMPTY_BIT 0
#define CIC_FILTER_STATUS_FULLL_BIT 1

// Thermometric value of the activated stages (The 1s should be contiguous
// and right-aligned)
#define CIC_FILTER_CIC_ACTIVATED_STAGES_REG_OFFSET 0xc
#define CIC_FILTER_CIC_ACTIVATED_STAGES_CIC_ACTIVATED_STAGES_MASK 0x1f
#define CIC_FILTER_CIC_ACTIVATED_STAGES_CIC_ACTIVATED_STAGES_OFFSET 0
#define CIC_FILTER_CIC_ACTIVATED_STAGES_CIC_ACTIVATED_STAGES_FIELD \
  ((bitfield_field32_t) { .mask = CIC_FILTER_CIC_ACTIVATED_STAGES_CIC_ACTIVATED_STAGES_MASK, .index = CIC_FILTER_CIC_ACTIVATED_STAGES_CIC_ACTIVATED_STAGES_OFFSET })

// delay in each comb block (D)
#define CIC_FILTER_CIC_DELAY_COMB_REG_OFFSET 0x10
#define CIC_FILTER_CIC_DELAY_COMB_CIC_DELAY_COMB_MASK 0x3
#define CIC_FILTER_CIC_DELAY_COMB_CIC_DELAY_COMB_OFFSET 0
#define CIC_FILTER_CIC_DELAY_COMB_CIC_DELAY_COMB_FIELD \
  ((bitfield_field32_t) { .mask = CIC_FILTER_CIC_DELAY_COMB_CIC_DELAY_COMB_MASK, .index = CIC_FILTER_CIC_DELAY_COMB_CIC_DELAY_COMB_OFFSET })

// Samples count after which to decimate in the CIC filter.
#define CIC_FILTER_DECIMCIC_REG_OFFSET 0x14
#define CIC_FILTER_DECIMCIC_COUNT_MASK 0x3ff
#define CIC_FILTER_DECIMCIC_COUNT_OFFSET 0
#define CIC_FILTER_DECIMCIC_COUNT_FIELD \
  ((bitfield_field32_t) { .mask = CIC_FILTER_DECIMCIC_COUNT_MASK, .index = CIC_FILTER_DECIMCIC_COUNT_OFFSET })

// Output sample
#define CIC_FILTER_DATA_OUT_REG_OFFSET 0x18

#ifdef __cplusplus
}  // extern "C"
#endif
#endif  // _CIC_FILTER_REG_DEFS_
// End generated register defines for CIC_filter