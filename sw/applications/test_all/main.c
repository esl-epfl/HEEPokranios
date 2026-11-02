#include <stdint.h>
#include <stdlib.h>

#include "PWM_regs.h"
#include "core_v_mini_mcu.h"
#include "cheep.h"
#include "cheep_peripherals_regs.h"
#include "channel_multipath_regs.h"
#include "pgm_clock_divider_regs.h"
#include "VCO_counter_regs.h"
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

#define DATA_LENGTH_N 100
#define DATA_LC_LENGTH_N 200
#define CHANNELS_N 5

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

volatile int32_t transactions_intr_flag = 0;

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

void dma_intr_handler_trans_done(uint8_t channel){
    transactions_intr_flag ++;
}

void main(){

    static int16_t ch_data[CHANNELS_N][DATA_LENGTH_N];
    static int32_t funneled_data[CHANNELS_N*DATA_LENGTH_N];
    static int32_t lc_rec_data[DATA_LC_LENGTH_N];
    static int32_t lc_rec_time[DATA_LC_LENGTH_N];
    static uint8_t ch_data_idx[CHANNELS_N];
    static uint8_t ch_idx = 0;
    static int32_t ch_offset[] = {CH_0, CH_1, CH_2, CH_3, CH_4};
    static uint8_t finished = 0;
    static int32_t data = 0;

    debug = 'live';

    /**********************************************************************************
     * WAIT FOR INTERFACE WORD TO BE WRITTEN
    ***********************************************************************************/

    if (CHEEP_PERIPHERALS + CHEEP_PERIPHERALS_INTERFACE_WORD_REG_OFFSET != 0x20080000 ){
        debug = 'intf';
        debug = 'word';
        debug = CHEEP_PERIPHERALS + CHEEP_PERIPHERALS_INTERFACE_WORD_REG_OFFSET;
        return 1;
    }

    debug='wait';

    /* Check that the interface word hasn't been written already*/
     if (get_register(CHEEP_PERIPHERALS, CHEEP_PERIPHERALS_INTERFACE_WORD_REG_OFFSET ) != 'good' ){
        /* Enable global interrupt. */
        CSR_SET_BITS(CSR_REG_MSTATUS, 0x8);
        /* Enable the external interrupt
        The irq_i of the CPU (seen in core_v_mini_mcu.sv) is a 31 bit input.
        The interrupts are packed in a `intr` vector, where the
        `intr_ext_peripheral_i` is the left-most, i.e. 1<<31.
        */
        CSR_SET_BITS(CSR_REG_MIE, (1<<31) );
        // Enable the external interrupt at the FIC level (the only not enabled by default)
        enable_fast_interrupt(kExt_peri_fic_e, 1);
        // Go to sleep until the itnerface word has been written
        wait_for_interrupt();
        debug = get_register(CHEEP_PERIPHERALS, CHEEP_PERIPHERALS_INTERFACE_WORD_REG_OFFSET );
        if(debug != 'good') return 1;
     }

    debug='lets';
    debug='go!';

    // Disable the fast interrupt not to wake up from the dLC all the time
    enable_fast_interrupt(kExt_peri_fic_e, 0);


    /**********************************************************************************
     * HALVE THE SYSTEM CLOCK SPEED
    ***********************************************************************************/

    set_register(SYSTEM_CLOCK_DIVIDER,  PGM_CLOCK_DIVIDER_DIVIDER_REG_OFFSET, 2);


    /**********************************************************************************
     * DISABLE SPI
    ***********************************************************************************/

    set_register(CHEEP_PERIPHERALS, CHEEP_PERIPHERALS_SPI_SLAVE_ENABLE_REG_OFFSET, 0);
    set_register(PAD_CONTROL_START_ADDRESS, PAD_CONTROL_PAD_MUX_DMUX_SEL_0_REG_OFFSET, 1);
    set_register(PAD_CONTROL_START_ADDRESS, PAD_CONTROL_PAD_MUX_DMUX_SEL_1_REG_OFFSET, 1);

    // Try receiving a longer word. This will have no effect, but we can see if the data passes
    set_register(CHEEP_PERIPHERALS, CHEEP_PERIPHERALS_WPDT_DOWNLINK_PAYLOAD_LENGTH_BITS_REG_OFFSET, 64);

    /**********************************************************************************
     * PWM
    ***********************************************************************************/
    debug = 'BPEe';
    // CONFIGURE THE PWMs TO DIFFERENT FREQUENCIES AND DUTY CYCLES
    set_register(CH_0_BPE_PWM_0,PWM_L_CC_REG_OFFSET, 90);
    set_register(CH_0_BPE_PWM_0,PWM_H_CC_REG_OFFSET, 10);

    set_register(CH_0_BPE_PWM_1,PWM_L_CC_REG_OFFSET, 90);
    set_register(CH_0_BPE_PWM_1,PWM_H_CC_REG_OFFSET, 10);

    set_register(CH_0_BPE_PWM_2,PWM_L_CC_REG_OFFSET, 99);
    set_register(CH_0_BPE_PWM_2,PWM_H_CC_REG_OFFSET, 1);

    set_register(CH_0_BPE_PWM_3,PWM_L_CC_REG_OFFSET, 500);
    set_register(CH_0_BPE_PWM_3,PWM_H_CC_REG_OFFSET, 100);

    // ENABLE THE PWMs
    set_register(CH_0,CHANNEL_MULTIPATH_PWM_EN_REG_OFFSET, 0b1111);

    wait();

    debug = 'BPEi';
    // Connect the PWMs internally to the BPE, so the dMUX is free to do other things
    set_register(CH_0,CHANNEL_MULTIPATH_BPE_CONNECT_INTERNALLY_REG_OFFSET, 1);

    wait();

    /**********************************************************************************
     * START THE MANUAL TESTING
    ***********************************************************************************/
    debug = 'man';

    // Set the dMUX control to "manual"
    set_register(CHEEP_PERIPHERALS, CHEEP_PERIPHERALS_DMUX_CPU_SEL_REG_OFFSET, 1);

    // Report that we are switching to GPIO mode, so the testbench can adapt accordingly
    // This will report to the testbench the 2 LSB dmux_sel bits of the first DMUX pad
    // No need to do this:
    //set_register(PAD_CONTROL,PAD_CONTROL_PAD_MUX_DMUX_SEL_0_REG_OFFSET, 1);
    //set_register(PAD_CONTROL,PAD_CONTROL_PAD_MUX_DMUX_SEL_1_REG_OFFSET, 1);
    // The pad will take the mux from the fact that dmux_cpu_sel was set to 1

    /**********************************************************************************
     * VCO
    ***********************************************************************************/
    debug = 'VCO';

    // Set the dMUX to see the VCO's output
    set_all_dmux(dmux_VCO);

    // Set the VCO level to trigger an overflow (ovf) pulse every N oscillation periods
    set_register(CH_0_VCO_P_COUNTER,VCO_COUNTER_COUNTER_OVF_RAISE_BIT_REG_OFFSET, 7);
    set_register(CH_0_VCO_P_COUNTER,VCO_COUNTER_COUNTER_OVF_FALL_BIT_REG_OFFSET, 6);
    // Set a refresh cycle that will update the counter difference (the integration period before the differentiation)
    set_register(CH_0_VCO_P_COUNTER,VCO_COUNTER_INTEGRATION_CC_REG_OFFSET, 8);
    set_register(CH_0_VCO_P_COUNTER,VCO_COUNTER_PERIOD_CC_REG_OFFSET, 8);
    // Enable the counter. This will have no effect until the CHANNEL_MULTIPATH_PDVCO_ENABLE_REG_OFFSET enabled
    set_register(CH_0_VCO_P_COUNTER,VCO_COUNTER_ENABLE_REG_OFFSET, 1);

    set_register(CH_0_VCO_N_COUNTER,VCO_COUNTER_INTEGRATION_CC_REG_OFFSET, 9);
    set_register(CH_0_VCO_N_COUNTER,VCO_COUNTER_ENABLE_REG_OFFSET, 1);

    // Enable both VCOs at the same time (and also enable in sync the VCO counters)
    set_register(CH_0, CHANNEL_MULTIPATH_PDVCO_EN_REG_OFFSET, 0b11);
    wait();
    wait();

    debug='d50%';
    set_register(CH_0_VCO_P_COUNTER,VCO_COUNTER_INTEGRATION_CC_REG_OFFSET, 7);
    set_register(CH_0_VCO_P_COUNTER,VCO_COUNTER_PERIOD_CC_REG_OFFSET, 8);
    set_register(CH_0_VCO_P_COUNTER,VCO_COUNTER_SETTLE_CC_REG_OFFSET, 4);
    set_register(CH_0_VCO_P_COUNTER,VCO_COUNTER_COOLDOWN_CC_REG_OFFSET, 5);
    wait();
    debug='<<1';
    set_register(CH_0_VCO_P_COUNTER,VCO_COUNTER_COUNT_DIFF_SHIFT_REG_OFFSET, 1);
    wait();

    debug='d12%';
    set_register(CH_0_VCO_P_COUNTER,VCO_COUNTER_INTEGRATION_CC_REG_OFFSET, 5);
    set_register(CH_0_VCO_P_COUNTER,VCO_COUNTER_PERIOD_CC_REG_OFFSET, 8);
    set_register(CH_0_VCO_P_COUNTER,VCO_COUNTER_SETTLE_CC_REG_OFFSET, 4);
    set_register(CH_0_VCO_P_COUNTER,VCO_COUNTER_COOLDOWN_CC_REG_OFFSET, 5);
    set_register(CH_0_VCO_P_COUNTER,VCO_COUNTER_COUNT_DIFF_SHIFT_REG_OFFSET, 3);
    wait();

    debug = 'phas';
    set_register(CH_0_VCO_P_COUNTER,VCO_COUNTER_INTEGRATION_CC_REG_OFFSET, 8);
    set_register(CH_0_VCO_P_COUNTER,VCO_COUNTER_PERIOD_CC_REG_OFFSET, 8);
    set_register(CH_0_VCO_P_COUNTER,VCO_COUNTER_SETTLE_CC_REG_OFFSET, 0);
    set_register(CH_0_VCO_P_COUNTER,VCO_COUNTER_COOLDOWN_CC_REG_OFFSET, 5);
    set_register(CH_0_VCO_P_COUNTER,VCO_COUNTER_COUNT_DIFF_SHIFT_REG_OFFSET, 0);
    set_register(CH_0, CHANNEL_MULTIPATH_VCO_PHASE_OUTPUT_REG_OFFSET, 1);
    wait();

    /**********************************************************************************
     * TOGGLE THE GPIO
     * (watch out, this will be done on PWM mode for the testbench)
     ***********************************************************************************/
    debug = 'gpio';

    // Set the dMUX 0 to be GPIO 0
    set_register(PAD_CONTROL_START_ADDRESS, PAD_CONTROL_PAD_MUX_DMUX_IO_0_REG_OFFSET, 0b100);

    // Toggle the GPIO 0
    gpio_cfg_t pin_cfg = { .pin = 0, .mode = GpioModeOutPushPull };
    gpio_config (pin_cfg);
    gpio_write(0, 1);
    gpio_write(0, 0);
    gpio_write(0, 1);

    wait();

    /**********************************************************************************
     * DSM + CIC
     ***********************************************************************************/
    debug = 'DSMe';

    // Set the dMUX 0 to be the DSM signals
    set_all_dmux(dmux_DSM);


    // Configure the SES filter
    set_register(CH_0_DSM_CIC, CIC_FILTER_CONTROL_REG_OFFSET, 0);
    set_register(CH_0_DSM_CIC, CIC_FILTER_CLKDIVIDX_REG_OFFSET, 1);
    set_register(CH_0_DSM_CIC, CIC_FILTER_CIC_ACTIVATED_STAGES_REG_OFFSET, 31 );
    set_register(CH_0_DSM_CIC, CIC_FILTER_CIC_DELAY_COMB_REG_OFFSET, 1);
    set_register(CH_0_DSM_CIC, CIC_FILTER_DECIMCIC_REG_OFFSET,  100 ); // It is halved, i.e. if you enter 100 it will let pass 1 sample every 50

    set_register(CH_0_DSM_CIC, CIC_FILTER_CONTROL_REG_OFFSET, 1);

    // Set the output buffer to get data from the DSM
    set_register(CH_0,CHANNEL_MULTIPATH_DATA_SOURCE_SEL_REG_OFFSET, source_DSM);

    debug = 'CIC';

    wait();

    // Get some values from the data mux
    for( int i = 0; i < DATA_LENGTH_N; i++){
        while( !(get_register( CH_0, CHANNEL_MULTIPATH_DATA_AVAILABLE_REG_OFFSET) )){}
        debug =  get_register( CH_0_DSM_CIC, CIC_FILTER_DATA_OUT_REG_OFFSET);
    }



    debug = 'DSMi';
    // Connect the DSM and decimation filter internally so there is no need for the dMUX
    set_register(CH_0,CHANNEL_MULTIPATH_DSM_CONNECT_INTERNALLY_REG_OFFSET, 1);
    wait();


    set_register(CH_0_DSM_CIC, CIC_FILTER_CONTROL_REG_OFFSET, 0);

    /**********************************************************************************
     * DSM + SES
     ***********************************************************************************/

    // Configure the SES filter
    set_register(CH_0_DSM_SES, SES_FILTER_SES_CONTROL_REG_OFFSET, 0);
    set_register(CH_0_DSM_SES, SES_FILTER_SES_SYSCLK_DIVISION_REG_OFFSET, 1);
    set_register(CH_0_DSM_SES, SES_FILTER_SES_ACTIVATED_STAGES_REG_OFFSET, 63); // 6 active stages
    set_register(CH_0_DSM_SES, SES_FILTER_SES_WINDOW_STAGE_0_REG_OFFSET, 5);
    set_register(CH_0_DSM_SES, SES_FILTER_SES_WINDOW_STAGE_1_REG_OFFSET, 5);
    set_register(CH_0_DSM_SES, SES_FILTER_SES_WINDOW_STAGE_2_REG_OFFSET, 5);
    set_register(CH_0_DSM_SES, SES_FILTER_SES_WINDOW_STAGE_3_REG_OFFSET, 5);
    set_register(CH_0_DSM_SES, SES_FILTER_SES_WINDOW_STAGE_4_REG_OFFSET, 4);
    set_register(CH_0_DSM_SES, SES_FILTER_SES_WINDOW_STAGE_5_REG_OFFSET, 4);

    set_register(CH_0_DSM_SES, SES_FILTER_SES_DECIMATION_FACTOR_STAGE_0_REG_OFFSET, 0);
    set_register(CH_0_DSM_SES, SES_FILTER_SES_DECIMATION_FACTOR_STAGE_1_REG_OFFSET, 0);
    set_register(CH_0_DSM_SES, SES_FILTER_SES_DECIMATION_FACTOR_STAGE_2_REG_OFFSET, 1);
    set_register(CH_0_DSM_SES, SES_FILTER_SES_DECIMATION_FACTOR_STAGE_3_REG_OFFSET, 1);
    set_register(CH_0_DSM_SES, SES_FILTER_SES_DECIMATION_FACTOR_STAGE_4_REG_OFFSET, 4);
    set_register(CH_0_DSM_SES, SES_FILTER_SES_DECIMATION_FACTOR_STAGE_5_REG_OFFSET, 5);
                                                              // total decimation: /32

    set_register(CH_0_DSM_SES, SES_FILTER_SES_GAIN_STAGE_0_REG_OFFSET, 16);
    // all other stages will remain with gain=0
    set_register(CH_0_DSM_SES, SES_FILTER_SES_CONTROL_REG_OFFSET, 1);

    debug = 'SES';

    wait();

    // Get 10 values from the data mux
    for( int i = 0; i < DATA_LENGTH_N; i++){
        while( !(get_register( CH_0, CHANNEL_MULTIPATH_DATA_AVAILABLE_REG_OFFSET) )){}
        debug = get_register( CH_0_DSM_SES, SES_FILTER_DATA_OUT_DATA_OUT_OFFSET);
    }


    /**********************************************************************************
     * DSM + SES + dLC
     ***********************************************************************************/
    debug = 'dLC';

    set_all_dmux(dmux_LC);

    uint32_t dlc_twos_complement    = 0; // 0 = ΔL NOT in two's complement
    uint32_t dlc_hysteresis         = 1; // 0 = NO hysteresis
    uint32_t dlc_discard_bits       = 1; // How many bits to discrd
    uint32_t dlc_lw_bits            = 7; // Level width, in bits
    uint32_t dlc_word_bits          = 8; // Bit width of the output word (8 or 16)
    uint32_t dlc_dt_bits            = 6; // How many bits to assign to the time part of the out data
    uint32_t dlc_dL_bits            = (dlc_twos_complement) ? dlc_word_bits-dlc_dt_bits:  dlc_word_bits-dlc_dt_bits - 1;
    uint32_t dlc_dL_mask            = (1 << (dlc_dL_bits)) - 1;
    uint32_t dlc_dt_mask            = (1 << (dlc_dt_bits)) - 1;

    set_register( CH_0_DLC, DLC_DLVL_FORMAT_REG_OFFSET, dlc_twos_complement);
    set_register( CH_0_DLC, DLC_HYSTERESIS_EN_REG_OFFSET, dlc_hysteresis);
    set_register( CH_0_DLC, DLC_DISCARD_BITS_REG_OFFSET, dlc_discard_bits);

    set_register( CH_0_DLC, DLC_DLVL_LOG_LEVEL_WIDTH_REG_OFFSET, dlc_lw_bits);
    set_register( CH_0_DLC, DLC_DLVL_N_BITS_REG_OFFSET, dlc_dL_bits);
    set_register( CH_0_DLC, DLC_DLVL_MASK_REG_OFFSET, dlc_dL_mask);
    set_register( CH_0_DLC, DLC_DT_MASK_REG_OFFSET, dlc_dt_mask);

    // Enable the use of the dLC on channel 0
    set_register( CH_0, CHANNEL_MULTIPATH_DLC_EN_REG_OFFSET, 1);

    // Set the output buffer to get data from the DSM (which will go through the dLC)
    set_register(CH_0,CHANNEL_MULTIPATH_DATA_SOURCE_SEL_REG_OFFSET, source_DSM);

    // Clear the buffer from readings
    set_register(CH_0,CHANNEL_MULTIPATH_BUFFER_FLUSH_REG_OFFSET, 1);
    set_register(CH_0,CHANNEL_MULTIPATH_BUFFER_FLUSH_REG_OFFSET, 0);

    // Get some values from the DSM+SES+dLC
    debug = ' rec';
    int16_t sign, dL = 0;
    uint32_t dn = 0;
    int32_t rec = 0;
    int32_t n = 0;
    for( int i = 0; i < DATA_LC_LENGTH_N; i++){
        while( !(get_register( CH_0, CHANNEL_MULTIPATH_DATA_AVAILABLE_REG_OFFSET) )){}
        data = (uint16_t)(get_register( CH_0, CHANNEL_MULTIPATH_DATA_OUT_REG_OFFSET));
        // Parse the data
        dL      = data & 1;
        sign    = (data & 2)>>1 ? -1 : 1;
        dn      = (data & 0b11111100)>>2;
        // Reconstruct the signal
        rec += (int16_t)(dL*sign);
        n += dn;
        // Print it for debug (time is implicit in the moment that the data was acquired)
        debug = rec;
    }

        // The value n represents how much time we were able to record with DATA_LENGTH_N samples of LC.
    // The larger the better (more efficient)
    debug = 'done';
    debug = n;
    debug = 'smpl';

    // Switch to a differences dLC (not differential, but rather taking slopes instead of amplitude)
    debug = 'diff';
    dlc_lw_bits = 4;
    set_register( CH_0, CHANNEL_MULTIPATH_DLC_EN_REG_OFFSET, 0);
    set_register( CH_0, CHANNEL_MULTIPATH_DLC_DERIVATIVE_REG_OFFSET, 1);
    set_register( CH_0_DLC, DLC_DLVL_LOG_LEVEL_WIDTH_REG_OFFSET, dlc_lw_bits);
    set_register( CH_0_DLC, DLC_DISCARD_BITS_REG_OFFSET, 0);
    set_register( CH_0_DLC, DLC_HYSTERESIS_EN_REG_OFFSET, 1);

    // For derivative LC, you might want to add an offset, as differences are very often 0,
    // meaning that the 0 level will be crossed constantly.
    // This can be compensated with hysteresis, but adds a lot of distortion.
    set_register( CH_0, CHANNEL_MULTIPATH_DLC_OFFSET_REG_OFFSET, 1<<(dlc_lw_bits-1));

    set_register( CH_0, CHANNEL_MULTIPATH_DLC_EN_REG_OFFSET, 1);

    int32_t ds, slope = 0;
    rec     = 0;
    n       = 0;

    // Clear the buffer from readings
    set_register(CH_0,CHANNEL_MULTIPATH_BUFFER_FLUSH_REG_OFFSET, 1);
    set_register(CH_0,CHANNEL_MULTIPATH_BUFFER_FLUSH_REG_OFFSET, 0);

    for( int i = 0; i < DATA_LC_LENGTH_N; i++){
        while( !(get_register( CH_0, CHANNEL_MULTIPATH_DATA_AVAILABLE_REG_OFFSET) )){}
        data = (uint16_t)(get_register( CH_0, CHANNEL_MULTIPATH_DATA_OUT_REG_OFFSET));
        // Parse the data
        ds      = data & 1;
        sign    = (data & 2)>>1 ? -1 : 1;
        dn      = (data & 0b11111100)>>2;
        // Reconstruct the signal
        slope += (int16_t)(ds*sign);
        rec += (int16_t)(slope*dn);
        n += dn;
        // Print it for debug (time is implicit in the moment that the data was acquired)
        debug = rec;

        lc_rec_data[i] = (int16_t)(ds*sign);
        lc_rec_time[i] = dn;
    }

    // Turn off the DSM, SES and dLC
    set_register( CH_0, CHANNEL_MULTIPATH_DSM_EN_REG_OFFSET, 0);
    set_register( CH_0_DSM_SES, SES_FILTER_SES_CONTROL_REG_OFFSET, 0);
    set_register( CH_0, CHANNEL_MULTIPATH_DLC_EN_REG_OFFSET, 0);

    // Perform correction a posteriori
    debug = 'rec!';
    debug = n;
    debug = 'smpl';

    wait();
    // Increasing the reconstruction value helps get a better resolution on the overall slope
    int32_t overall_slope_x10k = (10000*rec)/n; // because both rec and n started at 0
    debug = overall_slope_x10k;

    rec = 0;
    slope = -overall_slope_x10k;
    for( int i = 0; i < DATA_LC_LENGTH_N; i++){
        slope += (10000*lc_rec_data[i]);
        debug += (int32_t)(slope*lc_rec_time[i]);
        wait_n(10*lc_rec_time[i]); // Increase the time of delay to improve resolution
    }

    // rec = 0;
    // slope = -overall_slope_x10k;
    // for( int i = 0; i < DATA_LC_LENGTH_N; i++){
    //     slope += (10000*lc_rec_data[i]);
    //     rec += (int32_t)(slope*lc_rec_time[i]);
    //     lc_rec_data[i] = (int32_t)rec;
    // }

    // debug = 'recd';
    // wait();
    // n = 0;
    // for( int i = 0; i < DATA_LC_LENGTH_N; i++){
    //     wait_n(10*lc_rec_time[i]); // Increase the time of delay to improve resolution
    //     debug = lc_rec_data[i];
    // }

    /**********************************************************************************
     * dLC in DT overflow count mode
     ***********************************************************************************/
    debug = 'coar';

    // Assign one less bit to the time part of the packet, since the last bit will be
    // reserved for the DT overflow count flag
    dlc_dt_bits            = 5;
    dlc_dt_mask            = (1 << (dlc_dt_bits)) - 1; // Adjust the mask accordingly
    set_register( CH_0_DLC, DLC_DT_MASK_REG_OFFSET,                dlc_dt_mask);

    // To trigger more DT overflows, we increase the level width
    set_register( CH_0_DLC, DLC_DLVL_LOG_LEVEL_WIDTH_REG_OFFSET,   9 );

    // Disable the derivative LC mode
    set_register( CH_0, CHANNEL_MULTIPATH_DLC_DERIVATIVE_REG_OFFSET, 0);
    set_register( CH_0, CHANNEL_MULTIPATH_DLC_OFFSET_REG_OFFSET, 0 );
    set_register( CH_0_DLC, DLC_DISCARD_BITS_REG_OFFSET, 1);

    // Enable the DT overflow mode
    set_register( CH_0_DLC, DLC_CNT_DT_OVF_REG_OFFSET, 0 );

    set_register( CH_0, CHANNEL_MULTIPATH_DSM_EN_REG_OFFSET,        1);
    set_register( CH_0_DSM_SES, SES_FILTER_SES_CONTROL_REG_OFFSET,  1);
    set_register( CH_0, CHANNEL_MULTIPATH_DLC_EN_REG_OFFSET,        1);

    wait();
    wait();
    wait();
    wait();

    debug = 'dtov';
    // Enable the DT overflow mode
    set_register( CH_0_DLC, DLC_CNT_DT_OVF_REG_OFFSET, 1 );

    wait();
    wait();
    wait();
    wait();
    wait();

    /**********************************************************************************
     * dLC in single bit output mode
     ***********************************************************************************/
    debug = '1bit';

    set_register( CH_0_DLC, DLC_SINGLE_BIT_OUTPUT_REG_OFFSET, 1 );

    wait();
    wait();
    wait();
    wait();


    set_register( CH_0_DLC, DLC_SINGLE_BIT_OUTPUT_REG_OFFSET, 0 );
    set_register( CH_0, CHANNEL_MULTIPATH_DSM_EN_REG_OFFSET,        0);
    set_register( CH_0_DSM_SES, SES_FILTER_SES_CONTROL_REG_OFFSET,  0);
    set_register( CH_0, CHANNEL_MULTIPATH_DLC_EN_REG_OFFSET,        0);


    /**********************************************************************************
     * Wake up from dLC
     ***********************************************************************************/
    debug = 'wudl';

    // Set the level width to something large to only wake up on a large event
    set_register( CH_0_DLC, DLC_DLVL_LOG_LEVEL_WIDTH_REG_OFFSET, 9 );

    // Turn ON the DSM, SES and dLC
    set_register( CH_0, CHANNEL_MULTIPATH_DSM_EN_REG_OFFSET,        1);
    set_register( CH_0_DSM_SES, SES_FILTER_SES_CONTROL_REG_OFFSET,  1);
    set_register( CH_0, CHANNEL_MULTIPATH_DLC_EN_REG_OFFSET,        1);

    wait_n(200);

    // Enable the fast interrupt to wake up from the dLC
    enable_fast_interrupt(kExt_peri_fic_e, 1);
    debug = 'wait';
    wait_for_interrupt();

    // Turn Off the DSM, SES and dLC
    set_register( CH_0, CHANNEL_MULTIPATH_DSM_EN_REG_OFFSET,        0);
    set_register( CH_0_DSM_SES, SES_FILTER_SES_CONTROL_REG_OFFSET,  0);
    set_register( CH_0, CHANNEL_MULTIPATH_DLC_EN_REG_OFFSET,        0);

    /**********************************************************************************
     * LC ADC
     ***********************************************************************************/
    debug = 'LC';
    set_all_dmux(dmux_LC);

    for(  uint8_t i = 2; i< 5; i++){
        debug = i;
        set_register( CH_3_LC_CTRL, LC_CTRL_LVL_WIDTH_SEL_REG_OFFSET, i);
        wait();
    }


    /**********************************************************************************
     * LC ADC + dLC
     ***********************************************************************************/
    debug = '+dLC';

    // Set the output buffer to not get data from any of the ADCs
    set_register(CH_3,CHANNEL_MULTIPATH_DATA_SOURCE_SEL_REG_OFFSET, source_None );

    // Set the dLC to take the LC signal as input
    set_register( CH_3_DLC, DLC_LC_INPUT_REG_OFFSET, 1);

    // Set only the relevant parameters for the dLC
    set_register( CH_3_DLC, DLC_DLVL_FORMAT_REG_OFFSET, dlc_twos_complement);
    set_register( CH_3_DLC, DLC_HYSTERESIS_EN_REG_OFFSET, dlc_hysteresis);
    set_register( CH_3_DLC, DLC_DLVL_N_BITS_REG_OFFSET, dlc_dL_bits);
    set_register( CH_3_DLC, DLC_DLVL_MASK_REG_OFFSET, dlc_dL_mask);
    set_register( CH_3_DLC, DLC_DT_MASK_REG_OFFSET, dlc_dt_mask);

    // Enable the DT overflow mode
    set_register( CH_3_DLC, DLC_CNT_DT_OVF_REG_OFFSET, 1 );
    // Enable the use of the dLC on channel 3
    set_register( CH_3, CHANNEL_MULTIPATH_DLC_EN_REG_OFFSET, 1);

     wait();

    debug = 'LVL1';
    set_register( CH_3_LC_CTRL, LC_CTRL_LVL_WIDTH_SEL_REG_OFFSET, 1);
    wait();

    debug = 'LC1b';
    set_register(CHEEP_PERIPHERALS, CHEEP_PERIPHERALS_CH_3_DLC_OUTPUT_REG_OFFSET, 1);
    set_register( CH_3_DLC, DLC_SINGLE_BIT_OUTPUT_REG_OFFSET, 1 );

    wait();
    wait();
    set_register( CH_3, CHANNEL_MULTIPATH_DLC_EN_REG_OFFSET, 0);

    /**********************************************************************************
     * PD VCO
     ***********************************************************************************/
    debug = 'pdVC';

    // See the output of the VCO on the pads
    set_all_dmux(dmux_VCO);

    // Set the output buffer to get data from the VCO
    set_register(CH_0,CHANNEL_MULTIPATH_DATA_SOURCE_SEL_REG_OFFSET, source_PDVCO);

    // Fliush the buffers
    set_register(CH_0,CHANNEL_MULTIPATH_BUFFER_FLUSH_REG_OFFSET, 1);
    set_register(CH_0,CHANNEL_MULTIPATH_BUFFER_FLUSH_REG_OFFSET, 0);

    // Get 10 values from the PDVCO
    for( int i = 0; i < DATA_LENGTH_N; i++){
        while( !(get_register( CH_0, CHANNEL_MULTIPATH_DATA_AVAILABLE_REG_OFFSET) )){}
        ch_data[0][i] = (uint16_t)(get_register( CH_0, CHANNEL_MULTIPATH_DATA_OUT_REG_OFFSET));
    }

    for( int i = 0; i < DATA_LENGTH_N; i++){
        debug = ch_data[0][i];
    }

     // Turn off the VCO N (will only use the VCO P in the following test)
     set_register( CH_0, CHANNEL_MULTIPATH_PDVCO_EN_REG_OFFSET, 1);


    /**********************************************************************************
     * Test different channels
     ***********************************************************************************/

    debug = 'CHx4';

    // Set the output buffer to get data from the VCO
    set_register(CH_0,CHANNEL_MULTIPATH_DATA_SOURCE_SEL_REG_OFFSET, source_VCO_P);
    set_register(CH_2,CHANNEL_MULTIPATH_DATA_SOURCE_SEL_REG_OFFSET, source_VCO_P);
    set_register(CH_3,CHANNEL_MULTIPATH_DATA_SOURCE_SEL_REG_OFFSET, source_VCO_P);
    set_register(CH_4,CHANNEL_MULTIPATH_DATA_SOURCE_SEL_REG_OFFSET, source_VCO_P);

    set_register(CH_0_VCO_P_COUNTER,VCO_COUNTER_ENABLE_REG_OFFSET, 1);
    set_register(CH_0_VCO_N_COUNTER,VCO_COUNTER_ENABLE_REG_OFFSET, 0);

    set_register(CH_2, CHANNEL_MULTIPATH_PDVCO_EN_REG_OFFSET, 1);
    set_register(CH_2_VCO_COUNTER,VCO_COUNTER_COUNTER_OVF_RAISE_BIT_REG_OFFSET, 8);
    set_register(CH_2_VCO_COUNTER,VCO_COUNTER_COUNTER_OVF_FALL_BIT_REG_OFFSET, 7);
    set_register(CH_2_VCO_COUNTER,VCO_COUNTER_INTEGRATION_CC_REG_OFFSET, 1000);
    set_register(CH_2_VCO_COUNTER,VCO_COUNTER_ENABLE_REG_OFFSET, 1);

    set_register(CH_3, CHANNEL_MULTIPATH_PDVCO_EN_REG_OFFSET, 1);
    set_register(CH_3_VCO_COUNTER,VCO_COUNTER_COUNTER_OVF_RAISE_BIT_REG_OFFSET, 8);
    set_register(CH_3_VCO_COUNTER,VCO_COUNTER_COUNTER_OVF_FALL_BIT_REG_OFFSET, 7);
    set_register(CH_3_VCO_COUNTER,VCO_COUNTER_INTEGRATION_CC_REG_OFFSET, 1000);
    set_register(CH_3_VCO_COUNTER,VCO_COUNTER_ENABLE_REG_OFFSET, 1);

    set_register(CH_4, CHANNEL_MULTIPATH_PDVCO_EN_REG_OFFSET, 1);
    set_register(CH_4_VCO_COUNTER,VCO_COUNTER_COUNTER_OVF_RAISE_BIT_REG_OFFSET, 8);
    set_register(CH_4_VCO_COUNTER,VCO_COUNTER_COUNTER_OVF_FALL_BIT_REG_OFFSET, 7);
    set_register(CH_4_VCO_COUNTER,VCO_COUNTER_INTEGRATION_CC_REG_OFFSET, 500);
    set_register(CH_4_VCO_COUNTER,VCO_COUNTER_ENABLE_REG_OFFSET, 1);

    // Acquire data by polling each channel
    while(1){
        for( ch_idx=0; ch_idx<CHANNELS_N; ch_idx++ ){
            debug = ch_idx;
            if( get_register( ch_offset[ch_idx], CHANNEL_MULTIPATH_DATA_AVAILABLE_REG_OFFSET) ){
                data = get_register( ch_offset[ch_idx], CHANNEL_MULTIPATH_DATA_OUT_REG_OFFSET );
                ch_data[ch_idx][ch_data_idx[ch_idx]] = (int16_t)data;
                debug = data;
                if( ch_data_idx[ch_idx]++ >= DATA_LENGTH_N/10 ){
                    debug = 'done';
                    finished = 1;
                    break;
                };
            }
        }
        if(finished) break;
    }


    /**********************************************************************************
     * Acquire data through the DMA  -- ⚠️ REPLACED BY THE APP test_dma_dispatch ⚠️
     ***********************************************************************************/
    static dma_target_t tgt_src;
    static dma_target_t tgt_dst;
    static dma_trans_t trans;
    dma_config_flags_t res;

//     debug = 'DMA';

//      // Centralize all channels into a single circular buffer
//      set_register(CHEEP_PERIPHERALS, CHEEP_PERIPHERALS_FUNNEL_EN_REG_OFFSET, 1);


//     // Set the source target (where data is taken from) to the Circular buffer where all channels are accumulated
//     tgt_src.ptr = (uint8_t *) (uint32_t *)(CHEEP_PERIPHERALS + CHEEP_PERIPHERALS_OUTPUT_DATA_REG_OFFSET);

//     // Use the external trigger as a reception slot (whenever data is available it will be high)
//     tgt_src.trig = DMA_TRIG_SLOT_EXT_RX;
//     // Because the data is always taken from the same register, there should be no increment
//     tgt_src.inc_d1_du = 0;
//     // We will copy data in chunks of 32-bits, the width (enough to get the data + the id of the channel)
//     tgt_src.type = DMA_DATA_TYPE_WORD;

//     // Store the data into a wider buffer (data includes the ID, so it should be 32 bits)
//     tgt_dst.ptr = (uint8_t *) funneled_data;
//     // These data we will store in different places in memory, so the increment should be 1 data unit (du)
//     tgt_dst.inc_d1_du = 1;
//     // We will fill the buffer
//     trans.size_d1_du = (sizeof(funneled_data)/DMA_DATA_TYPE_2_SIZE(DMA_DATA_TYPE_WORD))/CHANNELS_N;
//     // We have nothing to mark the pace for the acquisition, so the slot will be simply the memory grants
//     tgt_dst.trig = DMA_TRIG_MEMORY;
//     // We will copy in chuncks of 4-bytes (16 bits of payload, + 3 of ID, but ain't nobody got a 19 bit SRAM)
//     tgt_dst.type = DMA_DATA_TYPE_WORD;

//     // Set the transaction
//     trans.src        = &tgt_src;
//     trans.dst        = &tgt_dst;
//     // Set that this will be a 1-Dimensional data transfer
//     trans.dim        = DMA_DIM_CONF_1D;

//     // We will not use the dLC, so no need to activate the HW fifo for now
//     trans.hw_fifo_en = 0;
//     // Set a single transaction (will copy data from begining to end, and then finish)
//     trans.mode = DMA_TRANS_MODE_SINGLE;
//     // Ask the DMA to trigger an interrput whenever it's done.
//     trans.end = DMA_TRANS_END_INTR;

// /*############################################################
// ####### LOAD THE CONFIGURATION ON THE DMA ###################*/

//     // Init the DMA (NULL because we will use the internal dma #0)
//     dma_init(NULL);

//     // Clear the buffer from readings
//     set_register(CHEEP_PERIPHERALS,CHEEP_PERIPHERALS_INPUT_BUFFER_FLUSH_REG_OFFSET, 1);
//     set_register(CHEEP_PERIPHERALS,CHEEP_PERIPHERALS_INPUT_BUFFER_FLUSH_REG_OFFSET, 0);

//     // Do some sanity checks to make sure that the entered values are valid
//     res = dma_validate_transaction(&trans, DMA_ENABLE_REALIGN, DMA_PERFORM_CHECKS_INTEGRITY);
//     if( res != DMA_CONFIG_OK ){
//         debug = 'ERR!';
//         debug = 'DMA';
//         debug = 'vald';
//         debug = res;
//         return EXIT_FAILURE;
//     }
//     // Load the values into the DMA registers.
//     res = dma_load_transaction(&trans);
//     if( res != DMA_CONFIG_OK ) {
//         debug = 'ERR!';
//         debug = 'DMA';
//         debug = 'load';
//         debug = res;
//         return EXIT_FAILURE;
//     }

//     if(dma_launch(&trans) != DMA_CONFIG_OK){
//         debug = 'ERR!';
//         debug = 'DMA';
//         debug = 'lch';
//         debug = res;
//         return EXIT_FAILURE;
//     }
//     debug = 'lchd';

//     while( !transactions_intr_flag ) {
//         CSR_CLEAR_BITS(CSR_REG_MSTATUS, 0x8);
//         if ( !transactions_intr_flag  ) {
//                 wait_for_interrupt();
//         }
//         CSR_SET_BITS(CSR_REG_MSTATUS, 0x8);
//     }

//     // Clean the channel data matrix to store the new samples
//     for( int i=0; i< DATA_LENGTH_N*CHANNELS_N; i++){
//         ((int16_t*)ch_data)[i] = 0;
//     }

//     // Read the obtained, funneled data and divide it into columns
//     uint8_t channel_id;

//     for( int i=0; i< CHANNELS_N; i++){
//         ch_data_idx[i] = 0;
//     }

//     debug='funl';
//     for( int i=0; i<sizeof(funneled_data)/DMA_DATA_TYPE_2_SIZE(DMA_DATA_TYPE_WORD)/CHANNELS_N; i++ ){
//         data        = funneled_data[i];
//         channel_id  = (data & 0x70000)>>16;
//         data        = data & 0x0000FFFF;
//         ch_data[channel_id][ch_data_idx[channel_id]++] = (int16_t)data;
//     }

//     // Assign into the debug region the value read from the channels 0 and 3
//     debug='ch0';
//     for( int i=0; i< DATA_LENGTH_N; i++){
//         debug = ch_data[0][i];
//     }
//     debug='ch3';
//     for( int i=0; i< DATA_LENGTH_N; i++){
//         debug = ch_data[3][i];
//     }


    /**********************************************************************************
     * Serialize data
     ***********************************************************************************/
    debug = '2ser';

    set_register(CHEEP_PERIPHERALS,CHEEP_PERIPHERALS_WPDT_RESET_DATA_REG_OFFSET, 1);
    set_register(CHEEP_PERIPHERALS,CHEEP_PERIPHERALS_WPDT_RESET_DATA_REG_OFFSET, 0);


    set_register(CHEEP_PERIPHERALS,CHEEP_PERIPHERALS_OUTPUT_BUFFER_FLUSH_REG_OFFSET, 1);
    set_register(CHEEP_PERIPHERALS,CHEEP_PERIPHERALS_OUTPUT_BUFFER_FLUSH_REG_OFFSET, 0);

    // Needed so that we send it to be encoded
    set_register(CHEEP_PERIPHERALS, CHEEP_PERIPHERALS_OUTPUT_HALF_SPEED_REG_OFFSET, 1);

    set_register(CHEEP_PERIPHERALS,CHEEP_PERIPHERALS_OUTPUT_DATA_REG_OFFSET, 0xDEAD);
    set_register(CHEEP_PERIPHERALS,CHEEP_PERIPHERALS_OUTPUT_DATA_REG_OFFSET, 0xBEEF);

    wait_n(100);
    set_register(PAD_CONTROL_START_ADDRESS, PAD_CONTROL_PAD_MUX_DMUX_IO_2_REG_OFFSET, 0b010);
    set_register(PAD_CONTROL_START_ADDRESS, PAD_CONTROL_PAD_MUX_DMUX_IO_3_REG_OFFSET, 0b010);

    set_register(CHEEP_PERIPHERALS,CHEEP_PERIPHERALS_OUTPUT_DATA_REG_OFFSET, 0xAAAAAAAA);
    set_register(CHEEP_PERIPHERALS,CHEEP_PERIPHERALS_OUTPUT_DATA_REG_OFFSET, 0xBBBBBBBB);

    set_register(CHEEP_PERIPHERALS,CHEEP_PERIPHERALS_OUTPUT_DATA_REG_OFFSET, 0xAAAAAAAA);
    set_register(CHEEP_PERIPHERALS,CHEEP_PERIPHERALS_OUTPUT_DATA_REG_OFFSET, 0xBBBBBBBB);

    wait_n(100);
    set_register(CHEEP_PERIPHERALS, CHEEP_PERIPHERALS_OUTPUT_BYTES_TO_SKIP_REG_OFFSET, 1);

    set_register(CHEEP_PERIPHERALS,CHEEP_PERIPHERALS_OUTPUT_DATA_REG_OFFSET, 0xCCCCCCCC);
    set_register(CHEEP_PERIPHERALS,CHEEP_PERIPHERALS_OUTPUT_DATA_REG_OFFSET, 0xDDDDDDDD);

    wait_n(100);
    set_register(CHEEP_PERIPHERALS, CHEEP_PERIPHERALS_OUTPUT_BYTES_TO_SKIP_REG_OFFSET, 2);

    set_register(CHEEP_PERIPHERALS,CHEEP_PERIPHERALS_OUTPUT_DATA_REG_OFFSET, 0xCCCCCCCC);
    set_register(CHEEP_PERIPHERALS,CHEEP_PERIPHERALS_OUTPUT_DATA_REG_OFFSET, 0xDDDDDDDD);

    wait_n(100);
    set_register(CHEEP_PERIPHERALS, CHEEP_PERIPHERALS_OUTPUT_BYTES_TO_SKIP_REG_OFFSET, 3);

    set_register(CHEEP_PERIPHERALS,CHEEP_PERIPHERALS_OUTPUT_DATA_REG_OFFSET, 0xCCCCCCCC);
    set_register(CHEEP_PERIPHERALS,CHEEP_PERIPHERALS_OUTPUT_DATA_REG_OFFSET, 0xDDDDDDDD);
    set_register(CHEEP_PERIPHERALS,CHEEP_PERIPHERALS_OUTPUT_DATA_REG_OFFSET, 0xEEEEEEEE);
    set_register(CHEEP_PERIPHERALS,CHEEP_PERIPHERALS_OUTPUT_DATA_REG_OFFSET, 0xFFFFFFFF);

    /**********************************************************************************
     * Parallel byte
     ***********************************************************************************/

    debug = 'byte';
    set_all_dmux(dmux_BYTE);
    wait();

    set_register(CHEEP_PERIPHERALS,CHEEP_PERIPHERALS_OUTPUT_BYTE_REG_OFFSET, 0b00000001);
    set_register(CHEEP_PERIPHERALS,CHEEP_PERIPHERALS_OUTPUT_BYTE_REG_OFFSET, 0b00000010);
    set_register(CHEEP_PERIPHERALS,CHEEP_PERIPHERALS_OUTPUT_BYTE_REG_OFFSET, 0b00000100);
    set_register(CHEEP_PERIPHERALS,CHEEP_PERIPHERALS_OUTPUT_BYTE_REG_OFFSET, 0b00001000);
    set_register(CHEEP_PERIPHERALS,CHEEP_PERIPHERALS_OUTPUT_BYTE_REG_OFFSET, 0b00010000);
    set_register(CHEEP_PERIPHERALS,CHEEP_PERIPHERALS_OUTPUT_BYTE_REG_OFFSET, 0b00100000);
    set_register(CHEEP_PERIPHERALS,CHEEP_PERIPHERALS_OUTPUT_BYTE_REG_OFFSET, 0b01000000);
    set_register(CHEEP_PERIPHERALS,CHEEP_PERIPHERALS_OUTPUT_BYTE_REG_OFFSET, 0b10000000);
    set_register(CHEEP_PERIPHERALS,CHEEP_PERIPHERALS_OUTPUT_BYTE_REG_OFFSET, 0b01000000);
    set_register(CHEEP_PERIPHERALS,CHEEP_PERIPHERALS_OUTPUT_BYTE_REG_OFFSET, 0b00100000);
    set_register(CHEEP_PERIPHERALS,CHEEP_PERIPHERALS_OUTPUT_BYTE_REG_OFFSET, 0b00010000);
    set_register(CHEEP_PERIPHERALS,CHEEP_PERIPHERALS_OUTPUT_BYTE_REG_OFFSET, 0b00001000);
    set_register(CHEEP_PERIPHERALS,CHEEP_PERIPHERALS_OUTPUT_BYTE_REG_OFFSET, 0b00000100);
    set_register(CHEEP_PERIPHERALS,CHEEP_PERIPHERALS_OUTPUT_BYTE_REG_OFFSET, 0b00000010);
    set_register(CHEEP_PERIPHERALS,CHEEP_PERIPHERALS_OUTPUT_BYTE_REG_OFFSET, 0b00000001);
    set_register(CHEEP_PERIPHERALS,CHEEP_PERIPHERALS_OUTPUT_BYTE_REG_OFFSET, 0b00000000);


    // debug= 'dma';

    // static uint8_t byte_sequence[] = {0, 1, 2, 3, 4, 5, 6, 7, 0};

    // tgt_src.ptr = (uint8_t *) byte_sequence;
    // tgt_src.trig = DMA_TRIG_MEMORY;
    // tgt_src.inc_d1_du = 1;
    // tgt_src.type = DMA_DATA_TYPE_BYTE;
    // tgt_dst.ptr = (uint8_t *) (uint32_t *)(CHEEP_PERIPHERALS + CHEEP_PERIPHERALS_OUTPUT_BYTE_REG_OFFSET);
    // tgt_dst.inc_d1_du = 0;
    // trans.size_d1_du = sizeof(byte_sequence);
    // tgt_dst.trig = DMA_TRIG_MEMORY;
    // tgt_dst.type = DMA_DATA_TYPE_BYTE;

    // // Set a single transaction (will copy data from begining to end, and then finish)
    // trans.mode = DMA_TRANS_MODE_SINGLE;
    // // Ask the DMA to trigger an interrput whenever it's done.
    // trans.end = DMA_TRANS_END_INTR;

    // res = dma_validate_transaction(&trans, DMA_ENABLE_REALIGN, DMA_PERFORM_CHECKS_INTEGRITY);
    // if( res != DMA_CONFIG_OK ){
    //     debug = 'ERR!';
    //     debug = 'DMA';
    //     debug = 'vald';
    //     debug = res;
    //     return EXIT_FAILURE;
    // }
    // // Load the values into the DMA registers.
    // res = dma_load_transaction(&trans);
    // if( res != DMA_CONFIG_OK ) {
    //     debug = 'ERR!';
    //     debug = 'DMA';
    //     debug = 'load';
    //     debug = res;
    //     return EXIT_FAILURE;
    // }

    // if(dma_launch(&trans) != DMA_CONFIG_OK){
    //     debug = 'ERR!';
    //     debug = 'DMA';
    //     debug = 'lch';
    //     debug = res;
    //     return EXIT_FAILURE;
    // }
    // debug = 'lchd';

    // while( !transactions_intr_flag ) {
    //     CSR_CLEAR_BITS(CSR_REG_MSTATUS, 0x8);
    //     if ( !transactions_intr_flag  ) {
    //             wait_for_interrupt();
    //     }
    //     CSR_SET_BITS(CSR_REG_MSTATUS, 0x8);
    // }

    // wait();



    /**********************************************************************************
     * Test the DMA trigger
     ***********************************************************************************/
    // debug = 'trig';

    //  // Set the DMUX sel 0 pin to 2, so it's the external DMA trigger
    //  set_register(PAD_CONTROL_START_ADDRESS, PAD_CONTROL_PAD_MUX_DMUX_SEL_0_REG_OFFSET, 2);

    // static uint8_t stimulation[] = {0xFF, 0x00};
    // tgt_src.ptr = (uint8_t *) stimulation;
    // tgt_src.trig = DMA_TRIG_MEMORY;
    // tgt_src.inc_d1_du = 1;
    // tgt_src.type = DMA_DATA_TYPE_BYTE;
    // tgt_dst.ptr = (uint8_t *) (uint32_t *)(CHEEP_PERIPHERALS + CHEEP_PERIPHERALS_OUTPUT_BYTE_REG_OFFSET);
    // tgt_dst.inc_d1_du = 0;
    // trans.size_d1_du = sizeof(stimulation);
    // tgt_dst.trig = DMA_TRIG_SLOT_EXT_TX; // Set the external trigger to make the DMA wait for the trigger
    // tgt_dst.type = DMA_DATA_TYPE_BYTE;
    // trans.mode = DMA_TRANS_MODE_SINGLE;
    // trans.end = DMA_TRANS_END_INTR;
    // trans.channel = 1;                  // Use the DMA 1, which has the slot connected to the ext trigger

    // debug = dma_validate_transaction(&trans, DMA_ENABLE_REALIGN, DMA_PERFORM_CHECKS_INTEGRITY);
    // debug = dma_load_transaction(&trans);
    // debug = dma_launch(&trans);

    // // Set the dMUX to byte to write the pattern
    // set_all_dmux(dmux_BYTE);
    // // Write the trigger pattern (that will be caught by the dma trigger block)
    // debug = 'trgd';
    // set_register(CHEEP_PERIPHERALS,CHEEP_PERIPHERALS_OUTPUT_BYTE_REG_OFFSET, 0b01101100);
    // set_register(CHEEP_PERIPHERALS,CHEEP_PERIPHERALS_OUTPUT_BYTE_REG_OFFSET, 0b00000000);

    // // wait_for_interrupt();

    /**********************************************************************************
     * iDAC
     ***********************************************************************************/
    debug = 'iDAC';

    set_register(IDAC_CTRL,IDAC_CTRL_CALIBRATION_1_REG_OFFSET, 0b00011);
    set_register(IDAC_CTRL,IDAC_CTRL_REFRESH_CYCLES_REG_OFFSET, 100);
    set_register(IDAC_CTRL,IDAC_CTRL_ENABLE_REG_OFFSET, 1);
    set_register(IDAC_CTRL,IDAC_CTRL_CURRENT_REG_OFFSET, 128);
    set_register(IDAC_CTRL,IDAC_CTRL_CURRENT_REG_OFFSET, 129);
    set_register(IDAC_CTRL,IDAC_CTRL_CURRENT_REG_OFFSET, 130);
    set_register(IDAC_CTRL,IDAC_CTRL_CURRENT_REG_OFFSET, 131);
    set_register(IDAC_CTRL,IDAC_CTRL_CURRENT_REG_OFFSET, 132);

     wait();

    /**********************************************************************************
    * The end
    ***********************************************************************************/
    debug = 'done';
    return 0;
}