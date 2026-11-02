// Copyright 2025 EPFL contributors
// SPDX-License-Identifier: Apache-2.0
//
// Author: Juan Sapriza
// Description: Drivers for the programmable clock divider controller

#ifndef PGM_CLOCK_DIVIDER_H
#define PGM_CLOCK_DIVIDER_H

#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include "pgm_clock_divider_regs.h"
#include "cheep.h"


/**
* @brief Set frequency division
*
* @param divider How may times to divide the clock by (must be even).
* @return The effective value of the division:
*           - 0: Not applied (larger than the maximum)
*           - 1: Bypass (clk_out = clk_in)
*           - x: The effective requested frequency (divider+1 if divider is odd)
*/
static inline uint32_t PCD_set_divider( int start_address, int divider ) {
    if( divider & 1 ){  // Check that the value is even
        divider+=1;     // Make it even if not
    }
    if( divider == 1 ){
        *(volatile uint32_t *)(start_address + PGM_CLOCK_DIVIDER_BYPASS_REG_OFFSET) = 1;
        return 1;
    }
    if( divider <= PGM_CLOCK_DIVIDER_DIVIDER_DIVIDER_MASK){ // check that it's below the maximum possible divider
        *(volatile uint32_t *)(start_address + PGM_CLOCK_DIVIDER_DIVIDER_REG_OFFSET) = divider;
        *(volatile uint32_t *)(start_address + PGM_CLOCK_DIVIDER_BYPASS_REG_OFFSET) = 0;
            return divider;
    }
    return 0;
}


#endif //PGM_CLOCK_DIVIDER_H