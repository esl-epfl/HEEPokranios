#include <stdio.h>
#include <stdlib.h>

#include "core_v_mini_mcu.h"
#include "x-heep.h"
#include "cheep.h"
#include "dma.h"
#include "dlc.h"
#include "csr.h"
#include "rv_plic.h"
#include "hart.h"
#include "timer_sdk.h"
#include "fast_intr_ctrl.h"
#include "vcd_util.h"

static rv_timer_t timer_0_1;
static const uint64_t kTickFreqHz = 1000 * 1000; // 1 MHz
volatile int8_t intr_flag;


void __attribute__((aligned(4), interrupt)) handler_irq_timer(void) {
    vcd_disable();
    timer_arm_stop();
    timer_irq_clear();
    return;
}

int main(int argc, char *argv[])
{
    vcd_init();

    CSR_SET_BITS(CSR_REG_MSTATUS, 0x8);
    CSR_SET_BITS(CSR_REG_MIE, 1 << 7);
   
    enable_timer_interrupt();
    vcd_enable();
    timer_wait_us(1000);
    return EXIT_SUCCESS;
}

// To dump VCDs from a QuestaSim run, build and run the simulation with
// VCD_MODE=2, then extract the power from the resulting waves with a power
// analysis flow of your choice.