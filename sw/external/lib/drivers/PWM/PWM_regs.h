// Generated register defines for PWM

// Copyright information found in source file:
// Copyright 2026 EPFL contributors

// Licensing information found in source file:
// 
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1

#ifndef _PWM_REG_DEFS_
#define _PWM_REG_DEFS_

#ifdef __cplusplus
extern "C" {
#endif
// Register width
#define PWM_PARAM_REG_WIDTH 32

// Duration of the Low state, in input-clock cycles
#define PWM_L_CC_REG_OFFSET 0x0
#define PWM_L_CC_L_CC_MASK 0xffff
#define PWM_L_CC_L_CC_OFFSET 0
#define PWM_L_CC_L_CC_FIELD \
  ((bitfield_field32_t) { .mask = PWM_L_CC_L_CC_MASK, .index = PWM_L_CC_L_CC_OFFSET })

// Duration of the High state, in input-clock cycles
#define PWM_H_CC_REG_OFFSET 0x4
#define PWM_H_CC_H_CC_MASK 0xffff
#define PWM_H_CC_H_CC_OFFSET 0
#define PWM_H_CC_H_CC_FIELD \
  ((bitfield_field32_t) { .mask = PWM_H_CC_H_CC_MASK, .index = PWM_H_CC_H_CC_OFFSET })

#ifdef __cplusplus
}  // extern "C"
#endif
#endif  // _PWM_REG_DEFS_
// End generated register defines for PWM