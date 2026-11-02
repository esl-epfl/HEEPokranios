// Generated register defines for channel_multipath

// Copyright information found in source file:
// Copyright 2026 EPFL contributors

// Licensing information found in source file:
// 
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1

#ifndef _CHANNEL_MULTIPATH_REG_DEFS_
#define _CHANNEL_MULTIPATH_REG_DEFS_

#ifdef __cplusplus
extern "C" {
#endif
// Register width
#define CHANNEL_MULTIPATH_PARAM_REG_WIDTH 32

// Enable the LNA
#define CHANNEL_MULTIPATH_LNA_EN_REG_OFFSET 0x0
#define CHANNEL_MULTIPATH_LNA_EN_LNA_EN_BIT 0

// Enable the BUFF
#define CHANNEL_MULTIPATH_BUFF_EN_REG_OFFSET 0x4
#define CHANNEL_MULTIPATH_BUFF_EN_BUFF_EN_BIT 0

// Enable the LFP
#define CHANNEL_MULTIPATH_BPE_EN_REG_OFFSET 0x8
#define CHANNEL_MULTIPATH_BPE_EN_BPE_EN_BIT 0

// Enable the DSM. The DSM block has an active LOW en, so this value is
// inverted to send it to the DSM.
#define CHANNEL_MULTIPATH_DSM_EN_REG_OFFSET 0xc
#define CHANNEL_MULTIPATH_DSM_EN_DSM_EN_BIT 0

// Enable the LC, active LOW
#define CHANNEL_MULTIPATH_LC_EN_REG_OFFSET 0x10
#define CHANNEL_MULTIPATH_LC_EN_LC_EN_BIT 0

// Enable the VCOs and their counters
#define CHANNEL_MULTIPATH_PDVCO_EN_REG_OFFSET 0x14
#define CHANNEL_MULTIPATH_PDVCO_EN_VCO_P_EN_BIT 0
#define CHANNEL_MULTIPATH_PDVCO_EN_VCO_N_EN_BIT 1

// Enable the PWMs in a coordinated fashion.
#define CHANNEL_MULTIPATH_PWM_EN_REG_OFFSET 0x18
#define CHANNEL_MULTIPATH_PWM_EN_PWM_EN_MASK 0xf
#define CHANNEL_MULTIPATH_PWM_EN_PWM_EN_OFFSET 0
#define CHANNEL_MULTIPATH_PWM_EN_PWM_EN_FIELD \
  ((bitfield_field32_t) { .mask = CHANNEL_MULTIPATH_PWM_EN_PWM_EN_MASK, .index = CHANNEL_MULTIPATH_PWM_EN_PWM_EN_OFFSET })

// Enable the dLC.
#define CHANNEL_MULTIPATH_DLC_EN_REG_OFFSET 0x1c
#define CHANNEL_MULTIPATH_DLC_EN_DLC_EN_BIT 0

// Differentiate the input to the dLC before it is compared.
#define CHANNEL_MULTIPATH_DLC_DERIVATIVE_REG_OFFSET 0x20
#define CHANNEL_MULTIPATH_DLC_DERIVATIVE_DLC_DERIVATIVE_BIT 0

// Add an offset at the input of the dLC to avoid common amplitude landing
// around a level.
#define CHANNEL_MULTIPATH_DLC_OFFSET_REG_OFFSET 0x24
#define CHANNEL_MULTIPATH_DLC_OFFSET_DLC_OFFSET_MASK 0x3f
#define CHANNEL_MULTIPATH_DLC_OFFSET_DLC_OFFSET_OFFSET 0
#define CHANNEL_MULTIPATH_DLC_OFFSET_DLC_OFFSET_FIELD \
  ((bitfield_field32_t) { .mask = CHANNEL_MULTIPATH_DLC_OFFSET_DLC_OFFSET_MASK, .index = CHANNEL_MULTIPATH_DLC_OFFSET_DLC_OFFSET_OFFSET })

// Difference of the VCO P counter's outputs
#define CHANNEL_MULTIPATH_VCO_P_OUT_REG_OFFSET 0x28

// Difference of the VCO N counter's outputs
#define CHANNEL_MULTIPATH_VCO_N_OUT_REG_OFFSET 0x2c

// Difference of the 2 VCO-counters' differences outputs
#define CHANNEL_MULTIPATH_PDVCO_OUT_REG_OFFSET 0x30

// Output the VCO's phase instead of the OVF flag
#define CHANNEL_MULTIPATH_VCO_PHASE_OUTPUT_REG_OFFSET 0x34
#define CHANNEL_MULTIPATH_VCO_PHASE_OUTPUT_VCO_PHASE_OUTPUT_BIT 0

// Output of the DSM decimation filter
#define CHANNEL_MULTIPATH_DSM_FILTER_OUT_REG_OFFSET 0x38

// Connect the output of the DSM to the input of the decimator, and the
// output of the decimator clock to the DSM input clock
#define CHANNEL_MULTIPATH_DSM_CONNECT_INTERNALLY_REG_OFFSET 0x3c
#define CHANNEL_MULTIPATH_DSM_CONNECT_INTERNALLY_DSM_CONNECT_INTERNALLY_BIT 0

// Connect the output of the PWM to the input of the BPE
#define CHANNEL_MULTIPATH_BPE_CONNECT_INTERNALLY_REG_OFFSET 0x40
#define CHANNEL_MULTIPATH_BPE_CONNECT_INTERNALLY_BPE_CONNECT_INTERNALLY_BIT 0

// Enable the base clock frequency change for the BPE. Otherwise, it will use
// the default division (/100)
#define CHANNEL_MULTIPATH_BPE_CHANGE_FREQ_REG_OFFSET 0x44
#define CHANNEL_MULTIPATH_BPE_CHANGE_FREQ_BPE_CHANGE_FREQ_BIT 0

// Output packet
#define CHANNEL_MULTIPATH_DATA_OUT_REG_OFFSET 0x48
#define CHANNEL_MULTIPATH_DATA_OUT_DATA_OUT_MASK 0xffff
#define CHANNEL_MULTIPATH_DATA_OUT_DATA_OUT_OFFSET 0
#define CHANNEL_MULTIPATH_DATA_OUT_DATA_OUT_FIELD \
  ((bitfield_field32_t) { .mask = CHANNEL_MULTIPATH_DATA_OUT_DATA_OUT_MASK, .index = CHANNEL_MULTIPATH_DATA_OUT_DATA_OUT_OFFSET })

// New data is available
#define CHANNEL_MULTIPATH_DATA_AVAILABLE_REG_OFFSET 0x4c
#define CHANNEL_MULTIPATH_DATA_AVAILABLE_DATA_AVAILABLE_BIT 0

// Flush the buffer containing data
#define CHANNEL_MULTIPATH_BUFFER_FLUSH_REG_OFFSET 0x50
#define CHANNEL_MULTIPATH_BUFFER_FLUSH_BUFFER_FLUSH_BIT 0

// Data source selection mask. Bit 0: DSM, Bit 1: VCO_P, Bit 2: VCO_N,
// (Combine bit 1+2 to get from the PDVCO) Bit 3: LC
#define CHANNEL_MULTIPATH_DATA_SOURCE_SEL_REG_OFFSET 0x54
#define CHANNEL_MULTIPATH_DATA_SOURCE_SEL_DATA_SOURCE_SEL_MASK 0xf
#define CHANNEL_MULTIPATH_DATA_SOURCE_SEL_DATA_SOURCE_SEL_OFFSET 0
#define CHANNEL_MULTIPATH_DATA_SOURCE_SEL_DATA_SOURCE_SEL_FIELD \
  ((bitfield_field32_t) { .mask = CHANNEL_MULTIPATH_DATA_SOURCE_SEL_DATA_SOURCE_SEL_MASK, .index = CHANNEL_MULTIPATH_DATA_SOURCE_SEL_DATA_SOURCE_SEL_OFFSET })

#ifdef __cplusplus
}  // extern "C"
#endif
#endif  // _CHANNEL_MULTIPATH_REG_DEFS_
// End generated register defines for channel_multipath