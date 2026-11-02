#include <stdint.h>
#include <stdlib.h>

#include "PWM_regs.h"
#include "core_v_mini_mcu.h"
#include "cheep.h"
#include "cheep_peripherals_regs.h"
#include "channel_multipath_regs.h"
#include "pgm_clock_divider_regs.h"
#include "pad_control_regs.h"
#include "SES_filter_regs.h"
#include "CIC_filter_regs.h"
#include "dlc_regs.h"
#include "LC_ctrl_regs.h"
#include "gpio.h"
#include "dma.h"
#include "csr.h"
#include "fast_intr_ctrl.h"
#include "iDAC_ctrl_regs.h"
#include "vcd_util.h"
#include "gpio_regs.h"

#define DMA_CHANNEL             0u
#define POLL_TIMEOUT            2000000u
#define SOURCE_PDVCO            6u
#define ENABLED_CHANNEL_ID      0u
#define SENTINEL_WORD           0xA5A5
#define PHASE3_WINDOWS_TO_SINGLE 3u
#define SAMPLE_COUNT             128
#define PHASE3_WINDOW_DU         128
#define PHASE3_MAX_IRQ_EVENTS    3

#define DEBUG_ACQUIRED_VALUES   1

#define CHANNELS_N              5
#define CHANNEL_EVENT_MASK      ((1u << CHANNELS_N) - 1u)
#define DMA_WINDOW_EVENT_MASK   DMA_WINDOW_ID_ID_MASK

#define DATA_LENGTH_N 1000
#define DATA_LC_LENGTH_N 200
#define CHANNELS_N 5

#define VCD_ENABLE  *(volatile int32_t *)(GPIO_AO_START_ADDRESS+GPIO_GPIO_SET_REG_OFFSET) = 1;
#define VCD_DISABLE *(volatile int32_t *)(GPIO_AO_START_ADDRESS+GPIO_GPIO_CLEAR_REG_OFFSET) = 1;

#define PRINTF(fmt, ...) printf(fmt, ##__VA_ARGS__)

typedef enum{
    source_None      = 0,
    source_DSM      = 1,
    source_VCO_P    = 2,
    source_VCO_N    = 4,
    source_PDVCO    = 6,
    source_LC       = 8,
}channel_soure_t;

typedef enum{
    dmux_PWM = 0,
    dmux_DSM = 1,
    dmux_VCO = 2,
    dmux_LC  = 3,
    dmux_BYTE = 4,
    dmux_GPIO = 5,
} dmux_sel_t;

volatile int32_t VCD_count = 0;

static inline void set_register( peripheral, register_offset, value ){
    *(volatile int32_t *)(peripheral + register_offset) = value;
}

static inline int32_t get_register( peripheral, register_offset ){
    return *(volatile int32_t *)(peripheral + register_offset);
}

static inline void set_all_dmux(dmux_sel_t dmux_sel ){
    set_register(PAD_CONTROL_START_ADDRESS, PAD_CONTROL_PAD_MUX_DMUX_IO_0_REG_OFFSET, dmux_sel); // This will be communicated to the testbench
    set_register(PAD_CONTROL_START_ADDRESS, PAD_CONTROL_PAD_MUX_DMUX_IO_1_REG_OFFSET, dmux_sel);
    set_register(PAD_CONTROL_START_ADDRESS, PAD_CONTROL_PAD_MUX_DMUX_IO_2_REG_OFFSET, dmux_sel);
    set_register(PAD_CONTROL_START_ADDRESS, PAD_CONTROL_PAD_MUX_DMUX_IO_3_REG_OFFSET, dmux_sel);
    set_register(PAD_CONTROL_START_ADDRESS, PAD_CONTROL_PAD_MUX_DMUX_IO_4_REG_OFFSET, dmux_sel);
    set_register(PAD_CONTROL_START_ADDRESS, PAD_CONTROL_PAD_MUX_DMUX_IO_5_REG_OFFSET, dmux_sel);
    set_register(PAD_CONTROL_START_ADDRESS, PAD_CONTROL_PAD_MUX_DMUX_IO_6_REG_OFFSET, dmux_sel);
    set_register(PAD_CONTROL_START_ADDRESS, PAD_CONTROL_PAD_MUX_DMUX_IO_7_REG_OFFSET, dmux_sel);
}

static inline void wait(){
    for (int i = 0 ; i < 1000 ; i++) { asm volatile ("nop"); }
}

static inline void wait_n(int16_t cycles){
    #pragma GCC unroll 4
    for (int i = 0 ; i < cycles ; i++) { asm volatile ("nop"); }
}


volatile uint32_t debug __attribute__((section(".debug_mem")));



#define SES_NMAX 10

static const uint32_t W_REG[SES_NMAX] = {
    SES_FILTER_SES_WINDOW_STAGE_0_REG_OFFSET,
    SES_FILTER_SES_WINDOW_STAGE_1_REG_OFFSET,
    SES_FILTER_SES_WINDOW_STAGE_2_REG_OFFSET,
    SES_FILTER_SES_WINDOW_STAGE_3_REG_OFFSET,
    SES_FILTER_SES_WINDOW_STAGE_4_REG_OFFSET,
    SES_FILTER_SES_WINDOW_STAGE_5_REG_OFFSET,
    SES_FILTER_SES_WINDOW_STAGE_6_REG_OFFSET,
    SES_FILTER_SES_WINDOW_STAGE_7_REG_OFFSET,
    SES_FILTER_SES_WINDOW_STAGE_8_REG_OFFSET,
    SES_FILTER_SES_WINDOW_STAGE_9_REG_OFFSET
};

static const uint32_t R_REG[SES_NMAX] = {
    SES_FILTER_SES_DECIMATION_FACTOR_STAGE_0_REG_OFFSET,
    SES_FILTER_SES_DECIMATION_FACTOR_STAGE_1_REG_OFFSET,
    SES_FILTER_SES_DECIMATION_FACTOR_STAGE_2_REG_OFFSET,
    SES_FILTER_SES_DECIMATION_FACTOR_STAGE_3_REG_OFFSET,
    SES_FILTER_SES_DECIMATION_FACTOR_STAGE_4_REG_OFFSET,
    SES_FILTER_SES_DECIMATION_FACTOR_STAGE_5_REG_OFFSET,
    SES_FILTER_SES_DECIMATION_FACTOR_STAGE_6_REG_OFFSET,
    SES_FILTER_SES_DECIMATION_FACTOR_STAGE_7_REG_OFFSET,
    SES_FILTER_SES_DECIMATION_FACTOR_STAGE_8_REG_OFFSET,
    SES_FILTER_SES_DECIMATION_FACTOR_STAGE_9_REG_OFFSET
};

static int vcd_id = 0;

void run_ses_case(int K, int G, int w[], int r[])
{
    set_register(CH_0_DSM_SES, SES_FILTER_SES_CONTROL_REG_OFFSET, 0);
    set_register(CH_0_DSM_SES, SES_FILTER_SES_ACTIVATED_STAGES_REG_OFFSET, (1 << K) - 1);

    for (int i = 0; i < SES_NMAX; i++) {
        set_register(CH_0_DSM_SES, W_REG[i], i < K ? w[i] : 0);
        set_register(CH_0_DSM_SES, R_REG[i], i < K ? r[i] : 7);
    }

    set_register(CH_0_DSM_SES, SES_FILTER_SES_GAIN_STAGE_0_REG_OFFSET, G);

    debug = VCD_count;
    VCD_count++;

    set_register(CH_0_DSM_SES, SES_FILTER_SES_CONTROL_REG_OFFSET, 1);
    wait();
    VCD_ENABLE;
    wait();
    VCD_DISABLE;
    set_register(CH_0_DSM_SES, SES_FILTER_SES_CONTROL_REG_OFFSET, 0);
}

void run_ses_power_sweep(void)
{
    int w[SES_NMAX];
    int r[SES_NMAX];

    set_register(CH_0_DSM_SES, SES_FILTER_SES_SYSCLK_DIVISION_REG_OFFSET, 1);

    // 0..9: number of active stages
    for (int K = 1; K <= 10; K++) {
        for (int i = 0; i < K; i++) { w[i] = 4; r[i] = 0; }
        run_ses_case(K, 16, w, r);
    }

    // 10..14: W0 sweep, G=16 (w=4 already measured)
    int wvals[] = {0, 1, 2, 3, 5};
    for (int j = 0; j < 5; j++) {
        w[0] = wvals[j]; r[0] = 0;
        run_ses_case(1, 16, w, r);
    }

    // 15..19: W sweep on a normal downstream stage
    for (int j = 0; j < 5; j++) {
        w[0] = 4; w[1] = wvals[j];
        r[0] = 0; r[1] = 0;
        run_ses_case(2, 16, w, r);
    }

    // 20..25: G=8, complete W0 sweep
    for (int wi = 0; wi <= 5; wi++) {
        w[0] = wi; r[0] = 0;
        run_ses_case(1, 8, w, r);
    }

    // 26..32: stage-0 clock-rate sweep
    for (int ri = 1; ri <= 7; ri++) {
        w[0] = 4; r[0] = ri;
        run_ses_case(1, 16, w, r);
    }

    // 33..39: downstream-stage clock-rate sweep
    for (int ri = 1; ri <= 7; ri++) {
        w[0] = 4; w[1] = 4;
        r[0] = 0; r[1] = ri;
        run_ses_case(2, 16, w, r);
    }
}


void run_cic_case(int N, int R)
{
    set_register(CH_0_DSM_CIC, CIC_FILTER_CONTROL_REG_OFFSET, 0);

    set_register(CH_0_DSM_CIC, CIC_FILTER_CLKDIVIDX_REG_OFFSET, 1);
    set_register(CH_0_DSM_CIC, CIC_FILTER_CIC_ACTIVATED_STAGES_REG_OFFSET, (1 << N) - 1);
    set_register(CH_0_DSM_CIC, CIC_FILTER_CIC_DELAY_COMB_REG_OFFSET, 1);
    set_register(CH_0_DSM_CIC, CIC_FILTER_DECIMCIC_REG_OFFSET, R);

    debug = VCD_count;
    VCD_count++;

    set_register(CH_0_DSM_CIC, CIC_FILTER_CONTROL_REG_OFFSET, 1);
    wait();
    VCD_ENABLE;
    wait();
    VCD_DISABLE;
    set_register(CH_0_DSM_CIC, CIC_FILTER_CONTROL_REG_OFFSET, 0);
}


void run_cic_power_sweep(void)
{
    // ---------------------------------------------------------
    // 0..4: sweep number of stages at reference R = 32
    // ---------------------------------------------------------
    for (int N = 1; N <= 5; N++) {
        run_cic_case(N, 32);
    }

    // ---------------------------------------------------------
    // 6..11: sweep R at N = 5
    // R=32 already measured above
    // ---------------------------------------------------------
    int Rvals[] = {2, 4, 8, 16, 64, 100};

    for (int j = 0; j < 6; j++) {
        run_cic_case(5, Rvals[j]);
    }
}

void main(){

    debug = 'live';

    /**********************************************************************************
     * CONFIGURE THE DMA
    ***********************************************************************************/

    static uint16_t dispatched_data[CHANNELS_N][SAMPLE_COUNT];

    // Activate the funnel from the channels
    set_register(CHEEP_PERIPHERALS, CHEEP_PERIPHERALS_FUNNEL_EN_REG_OFFSET, 1u);

    // Select the source for each channel
    set_register(CH_0, CHANNEL_MULTIPATH_DATA_SOURCE_SEL_REG_OFFSET, 0);
    set_register(CH_0, CHANNEL_MULTIPATH_DATA_SOURCE_SEL_REG_OFFSET, 0);
    // These will not be used anyways
    set_register(CH_2, CHANNEL_MULTIPATH_DATA_SOURCE_SEL_REG_OFFSET, 1);
    set_register(CH_3, CHANNEL_MULTIPATH_DATA_SOURCE_SEL_REG_OFFSET, 1);
    set_register(CH_4, CHANNEL_MULTIPATH_DATA_SOURCE_SEL_REG_OFFSET, 1);

    /**********************************************************************************
     * CONFIGURE THE DMUX
    ***********************************************************************************/
    set_register(CHEEP_PERIPHERALS, CHEEP_PERIPHERALS_DMUX_CPU_SEL_REG_OFFSET, 1);
    set_all_dmux(dmux_DSM);

    // Set the output buffer to get data from the DSM
    set_register(CH_0,CHANNEL_MULTIPATH_DATA_SOURCE_SEL_REG_OFFSET, source_DSM);

    /**********************************************************************************
     * RUN the SWEEPs
    ***********************************************************************************/
    debug = 'SES';
    wait();
    run_ses_power_sweep();

    debug = 'CIC';
    wait();
    run_cic_power_sweep();

    debug = 'done';
    return 0;
}


// Extract the power from the dumped VCDs (one per sweep point) with a power
// analysis flow of your choice.