#include <stdint.h>
#include <stdlib.h>

#include "pgm_clock_divider_regs.h"
#include "pgm_clock_divider.h"
#include "cheep.h"

#include "soc_ctrl.h"

soc_ctrl_t soc_ctrl;
uint32_t clk_freq = 1000000;

int divide_clock_frequency( req_divider ){
    uint32_t obt_divider = 0;
    obt_divider = PCD_set_divider( SYSTEM_CLOCK_DIVIDER_START_ADDRESS, req_divider);
    if( obt_divider != req_divider ||  obt_divider != req_divider+1 ) return EXIT_FAILURE;
    clk_freq /= obt_divider;
    soc_ctrl_set_frequency(&soc_ctrl,clk_freq);
}


int main(){

    soc_ctrl.base_addr = mmio_region_from_addr((uintptr_t)SOC_CTRL_START_ADDRESS);
    soc_ctrl_set_frequency(&soc_ctrl,clk_freq);

    divide_clock_frequency(13);

    for (int i = 0 ; i < 200; i++) {
        asm volatile ("nop");
    }

    divide_clock_frequency(100);

    for (int i = 0 ; i < 20; i++) {
        asm volatile ("nop");
    }

    divide_clock_frequency(1);
    for (int i = 0 ; i < 200; i++) {
        asm volatile ("nop");
    }

    divide_clock_frequency(2000);
    for (int i = 0 ; i < 200; i++) {
        asm volatile ("nop");
    }

    return 0;
}