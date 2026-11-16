#include <stdio.h>
#include <stdlib.h>
#include "core_v_mini_mcu.h"
#include "cheep.h"
#include "cheep_peripherals_regs.h"



static inline void set_register( peripheral, register_offset, value ){
    *(volatile int32_t *)(peripheral + register_offset) = value;
}

static inline int32_t get_register( peripheral, register_offset ){
    return *(volatile int32_t *)(peripheral + register_offset);
}


int main(int argc, char *argv[])
{
    /* write something to stdout */
    set_register(CHEEP_PERIPHERALS, CHEEP_PERIPHERALS_DMUX_CPU_SEL_REG_OFFSET, 1);

    printf("sup bro? this is HEEPokranios :P\n");
    return EXIT_SUCCESS;
}
