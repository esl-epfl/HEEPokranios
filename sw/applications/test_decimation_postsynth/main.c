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
volatile uint32_t window_intr_total = 0u;
volatile uint32_t trans_intr_total = 0u;
volatile uint32_t switched_to_single = 0u;
volatile uint32_t switch_winner_id = 0xFFFFFFFFu;
volatile uint32_t invalid_window_id = 0u;
volatile uint32_t window_intr_by_id[CHANNELS_N];


void dma_intr_handler_window_done(uint8_t channel) {
    if (channel != DMA_CHANNEL) {
        return;
    }

    volatile dma *dma_ch = dma_peri(channel);
    // debug='wind';
    uint8_t id = 0;

    do{
        // debug = 'even';
        // debug=dma_ch->WINDOW_ID;

        for (id = 0; id < CHANNELS_N; ++id) {
            if ((dma_ch->WINDOW_ID & (1u << id)) == 0u) {
                continue;
            }
            // debug = 'foun';
            // debug = id;

            // ATTEND THE INTERRUPT HERE
            // ---------------------------
            window_intr_total++;
            // window_intr_by_id[id]++;
            // if (!switched_to_single && window_intr_by_id[id] >= PHASE3_WINDOWS_TO_SINGLE) {
            //     dma_stop_circular(channel);
            //     switched_to_single = 1u;
            //     switch_winner_id = id;
            // }
            // ---------------------------

            dma_ch->WINDOW_ID &= ~(1u << id); // Clear the attended channel
            // debug = dma_ch->WINDOW_ID;
        }

    } while(dma_ch->WINDOW_ID != 0);
    // debug = window_intr_total;
}

void dma_intr_handler_trans_done(uint8_t channel) {
  if (channel == DMA_CHANNEL) {
    trans_intr_total++;
    uint32_t read = dma_peri(channel)->TRANSACTION_IFR;
  }
}

static int wait_for_data_available(void) {
  for (uint32_t i = 0; i < POLL_TIMEOUT; ++i) {
    if ((get_register(CHEEP_PERIPHERALS, CHEEP_PERIPHERALS_INPUT_DATA_AVAILABLE_REG_OFFSET) >> CHEEP_PERIPHERALS_INPUT_DATA_AVAILABLE_INPUT_DATA_AVAILABLE_BIT) & 0x1u) {
      return 0;
    }
  }
  return -1;
}

static int wait_for_dma_ready(uint8_t channel) {
  for (uint32_t i = 0; i < POLL_TIMEOUT; ++i) {
    if (dma_is_ready(channel)) {
      return 0;
    }
  }
  return -1;
}


static int dma_run_circular(uint16_t dispatched[CHANNELS_N][SAMPLE_COUNT],
                                        uint32_t words_per_id,
                                        dma_trans_mode_t mode,
                                        dma_trans_end_evt_t end_evt,
                                        uint32_t win_du,
                                        int wait_for_ready_after_launch) {
  static dma_target_t src_tgt;
  static dma_target_t dst_tgt;
  static dma_trans_t trans;

  dma_init(NULL);

  src_tgt.ptr = (uint8_t *)(CHEEP_PERIPHERALS + CHEEP_PERIPHERALS_INPUT_DATA_REG_OFFSET);
  src_tgt.trig = DMA_TRIG_SLOT_EXT_RX;
  src_tgt.inc_d1_du = 0u;
  src_tgt.type = DMA_DATA_TYPE_HALF_WORD;

  dst_tgt.ptr = (uint8_t *)dispatched[0]; //(uint8_t*) debug; ALSO CHANGE BELOW TO 0
  dst_tgt.inc_d1_du = 1;
  dst_tgt.trig = DMA_TRIG_MEMORY;
  dst_tgt.type = DMA_DATA_TYPE_HALF_WORD;

  trans.src = &src_tgt;
  trans.dst = &dst_tgt;
  trans.dim = DMA_DIM_CONF_1D;
  trans.mode = mode;
  trans.end = end_evt;
  trans.size_d1_du = words_per_id;
  trans.channel = DMA_CHANNEL;
  trans.win_du = win_du;
  trans.sign_ext = 0u;
  trans.dim_inv = 0u;
  trans.hw_fifo_en = 0u;

  dma_config_flags_t ret = dma_validate_transaction(&trans, DMA_ENABLE_REALIGN, DMA_PERFORM_CHECKS_INTEGRITY);
  if (ret != DMA_CONFIG_OK) {
    debug = 'ERR1';
    wait_n(100);
    debug = 0xE0010000u | ret;
    return -1;
  }

  ret = dma_load_transaction(&trans);
  if (ret != DMA_CONFIG_OK) {
    debug = 'ERR2';
    wait_n(100);
    debug = 0xE0020000u | ret;
    return -2;
  }

  volatile dma *dma_ch = dma_peri(DMA_CHANNEL);
  volatile uint32_t *dst_ptr_dispatch = &dma_ch->DST_PTR_DISPATCH0;
  for (uint32_t i = 0; i < CHANNELS_N; ++i) {
    dst_ptr_dispatch[i] = (uint32_t)&dispatched[i][0];
  }

  dma_ch->DISPATCH_EN = 1u;
  if ((dma_ch->DISPATCH_EN & 0x1u) == 0u) {
    debug = 'ERR3';
    wait_n(100);
    debug = 0xE0030000u;
    return -3;
  }

  ret = dma_launch(&trans);
  if ( ret != DMA_CONFIG_OK) {
    debug = 'ERR4';
    wait_n(100);
    debug = 0xE0040000u;
    return -4;
  }

  if (wait_for_ready_after_launch) {
    if (wait_for_dma_ready(DMA_CHANNEL) != 0) {
        debug = 'ERR5';
        wait_n(100);
      debug = 0xE0050000u;
      return -5;
    }
  }

  return 0;
}


static void reset_irq_state(void) {
  window_intr_total = 0u;
  trans_intr_total = 0u;
  switched_to_single = 0u;
  switch_winner_id = 0xFFFFFFFFu;
  invalid_window_id = 0u;
  for (uint32_t id = 0; id < CHANNELS_N; ++id) {
    window_intr_by_id[id] = 0u;
  }
}


void main(){

    static uint8_t ch_idx = 0;
    static int32_t ch_offset[] = {CH_0, CH_1, CH_2, CH_3, CH_4};
    static uint8_t finished = 0;
    static int32_t data = 0;
    static int32_t lc_rec_data[DATA_LC_LENGTH_N];
    static int32_t lc_rec_time[DATA_LC_LENGTH_N];
    uint32_t id = 0;

    debug = 'live';

    /**********************************************************************************
     * HALVE THE SYSTEM CLOCK SPEED
    ***********************************************************************************/

    // set_register(SYSTEM_CLOCK_DIVIDER,  PGM_CLOCK_DIVIDER_DIVIDER_REG_OFFSET, 2);


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

    // // Fill with sentinel words
    // for (uint32_t id = 0; id < CHANNELS_N; ++id) {
    //     for (uint32_t i = 0; i < SAMPLE_COUNT; ++i) { dispatched_data[id][i] = SENTINEL_WORD; }
    // }
    // reset_irq_state();

    // Flush buffer
    set_register(CHEEP_PERIPHERALS, CHEEP_PERIPHERALS_INPUT_BUFFER_FLUSH_REG_OFFSET, 1u);
    set_register(CHEEP_PERIPHERALS, CHEEP_PERIPHERALS_INPUT_BUFFER_FLUSH_REG_OFFSET, 0u);

    /**********************************************************************************
     * CONFIGURE THE DMUX
    ***********************************************************************************/
    set_register(CHEEP_PERIPHERALS, CHEEP_PERIPHERALS_DMUX_CPU_SEL_REG_OFFSET, 1);
    set_all_dmux(dmux_DSM);

    // Set the output buffer to get data from the DSM
    set_register(CH_0,CHANNEL_MULTIPATH_DATA_SOURCE_SEL_REG_OFFSET, source_DSM);

    /**********************************************************************************
     * CONFIGURE DSM + SES
     ***********************************************************************************/

    // Configure the SES filter
    set_register(CH_0_DSM_SES, SES_FILTER_SES_CONTROL_REG_OFFSET, 0);
    set_register(CH_0_DSM_SES, SES_FILTER_SES_SYSCLK_DIVISION_REG_OFFSET, 1);
    set_register(CH_0_DSM_SES, SES_FILTER_SES_ACTIVATED_STAGES_REG_OFFSET, 7); // 3 active stages
    set_register(CH_0_DSM_SES, SES_FILTER_SES_WINDOW_STAGE_0_REG_OFFSET, 5);
    set_register(CH_0_DSM_SES, SES_FILTER_SES_WINDOW_STAGE_1_REG_OFFSET, 5);
    set_register(CH_0_DSM_SES, SES_FILTER_SES_WINDOW_STAGE_2_REG_OFFSET, 4);
    set_register(CH_0_DSM_SES, SES_FILTER_SES_WINDOW_STAGE_3_REG_OFFSET, 0);
    set_register(CH_0_DSM_SES, SES_FILTER_SES_WINDOW_STAGE_4_REG_OFFSET, 0);
    set_register(CH_0_DSM_SES, SES_FILTER_SES_WINDOW_STAGE_5_REG_OFFSET, 0);

    set_register(CH_0_DSM_SES, SES_FILTER_SES_DECIMATION_FACTOR_STAGE_0_REG_OFFSET, 0);
    set_register(CH_0_DSM_SES, SES_FILTER_SES_DECIMATION_FACTOR_STAGE_1_REG_OFFSET, 4);
    set_register(CH_0_DSM_SES, SES_FILTER_SES_DECIMATION_FACTOR_STAGE_2_REG_OFFSET, 5);
                                                                // total decimation: /32
    // The remaining stages are almost-clock-gated
    set_register(CH_0_DSM_SES, SES_FILTER_SES_DECIMATION_FACTOR_STAGE_3_REG_OFFSET, 7);
    set_register(CH_0_DSM_SES, SES_FILTER_SES_DECIMATION_FACTOR_STAGE_4_REG_OFFSET, 7);
    set_register(CH_0_DSM_SES, SES_FILTER_SES_DECIMATION_FACTOR_STAGE_5_REG_OFFSET, 7);
    set_register(CH_0_DSM_SES, SES_FILTER_SES_DECIMATION_FACTOR_STAGE_6_REG_OFFSET, 7);
    set_register(CH_0_DSM_SES, SES_FILTER_SES_DECIMATION_FACTOR_STAGE_7_REG_OFFSET, 7);
    set_register(CH_0_DSM_SES, SES_FILTER_SES_DECIMATION_FACTOR_STAGE_8_REG_OFFSET, 7);
    set_register(CH_0_DSM_SES, SES_FILTER_SES_DECIMATION_FACTOR_STAGE_9_REG_OFFSET, 7);


    set_register(CH_0_DSM_SES, SES_FILTER_SES_GAIN_STAGE_0_REG_OFFSET, 16);
    // all other stages will remain with gain=0

    /**********************************************************************************
     * DSM + SES + DMA
     ***********************************************************************************/

    dma_run_circular( dispatched_data, SAMPLE_COUNT, DMA_TRANS_MODE_CIRCULAR, DMA_TRANS_END_INTR, PHASE3_WINDOW_DU, 0);
    reset_irq_state();
    set_register(CH_0_DSM_SES, SES_FILTER_SES_CONTROL_REG_OFFSET, 1);

    debug = 'SES';
    wait_n(100);
    VCD_ENABLE; // 0 - SES filter
    wait();
    VCD_DISABLE;

    debug = 'wait';
    dma_stop_circular(0);
    wait_for_interrupt();
    set_register(CH_0_DSM_SES, SES_FILTER_SES_CONTROL_REG_OFFSET, 0);

    /**********************************************************************************
     * DSM + SES + DMA + CPU asleep
     ***********************************************************************************/
    debug = 'slep';

    dma_run_circular( dispatched_data, SAMPLE_COUNT, DMA_TRANS_MODE_CIRCULAR, DMA_TRANS_END_INTR, PHASE3_WINDOW_DU, 0);
    reset_irq_state();
    set_register(CH_0_DSM_SES, SES_FILTER_SES_CONTROL_REG_OFFSET, 1);

    VCD_ENABLE; // 1 - SES sleep
    while (trans_intr_total == 0u && (window_intr_total + trans_intr_total) < PHASE3_MAX_IRQ_EVENTS) {
        wait_for_interrupt();
    }
    VCD_DISABLE;

    debug = 'wait';
    dma_stop_circular(0);
    wait_for_interrupt();
    set_register(CH_0_DSM_SES, SES_FILTER_SES_CONTROL_REG_OFFSET, 0);

    if(DEBUG_ACQUIRED_VALUES){
        /**********************************************************************************
         * Print SES acquired values for debug
         ***********************************************************************************/
        debug='dump';
        wait_n(100);

        for (uint32_t i = 0; i < SAMPLE_COUNT; ++i) {
            if(dispatched_data[id][i] == SENTINEL_WORD ){
                debug = 0;
            }else{
                debug =  dispatched_data[id][i];
            }
        }
    }


    /**********************************************************************************
     * CONFIGURE THE CIC
     ***********************************************************************************/

    // Configure the CIC filter
    set_register(CH_0_DSM_CIC, CIC_FILTER_CONTROL_REG_OFFSET, 0);
    set_register(CH_0_DSM_CIC, CIC_FILTER_CLKDIVIDX_REG_OFFSET, 1);
    set_register(CH_0_DSM_CIC, CIC_FILTER_CIC_ACTIVATED_STAGES_REG_OFFSET, 7 );
    set_register(CH_0_DSM_CIC, CIC_FILTER_CIC_DELAY_COMB_REG_OFFSET, 1);
    set_register(CH_0_DSM_CIC, CIC_FILTER_DECIMCIC_REG_OFFSET, 32 );

    /**********************************************************************************
     * DSM + CIC + DMA
     ***********************************************************************************/

    dma_run_circular( dispatched_data, SAMPLE_COUNT, DMA_TRANS_MODE_CIRCULAR, DMA_TRANS_END_INTR, PHASE3_WINDOW_DU, 0);
    reset_irq_state();
    set_register(CH_0_DSM_CIC, CIC_FILTER_CONTROL_REG_OFFSET, 1);

    debug = 'CIC';
    wait_n(100);
    VCD_ENABLE; // 2 - CIC filter
    wait();
    VCD_DISABLE;

    debug = 'wait';
    dma_stop_circular(0);
    wait_for_interrupt();
    set_register(CH_0_DSM_CIC, CIC_FILTER_CONTROL_REG_OFFSET, 0);

    /**********************************************************************************
     * DSM + CIC + DMA + CPU asleep
     ***********************************************************************************/

    dma_run_circular( dispatched_data, SAMPLE_COUNT, DMA_TRANS_MODE_CIRCULAR, DMA_TRANS_END_INTR, PHASE3_WINDOW_DU, 0);
    reset_irq_state();
    set_register(CH_0_DSM_CIC, CIC_FILTER_CONTROL_REG_OFFSET, 1);

    debug = 'slep';
    wait_n(100);

    VCD_ENABLE; // 3 - CIC sleep
    while (trans_intr_total == 0u && (window_intr_total + trans_intr_total) < PHASE3_MAX_IRQ_EVENTS) {
        wait_for_interrupt();
    }
    VCD_DISABLE;

    debug = 'wait';
    dma_stop_circular(0);
    wait_for_interrupt();
    set_register(CH_0_DSM_CIC, CIC_FILTER_CONTROL_REG_OFFSET, 0);

    if(DEBUG_ACQUIRED_VALUES){
        /**********************************************************************************
         * Print CIC acquired values for debug
         ***********************************************************************************/
        debug='dump';
        wait_n(100);

        for (uint32_t i = 0; i < SAMPLE_COUNT; ++i) {
            if(dispatched_data[id][i] == SENTINEL_WORD ){
                debug = 0;
            }else{
                debug =  dispatched_data[id][i];
            }
        }
    }

    /**********************************************************************************
     * CONFIGURE THE dLC
     ***********************************************************************************/


    uint32_t dlc_twos_complement    = 0; // 0 = ΔL NOT in two's complement
    uint32_t dlc_hysteresis         = 1; // 0 = NO hysteresis
    uint32_t dlc_discard_bits       = 1; // How many bits to discrd
    uint32_t dlc_lw_bits            = 11; // Level width, in bits
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

    /**********************************************************************************
     * DSM + SES + dLC + DMA
     ***********************************************************************************/

    dma_run_circular( dispatched_data, SAMPLE_COUNT, DMA_TRANS_MODE_CIRCULAR, DMA_TRANS_END_INTR, PHASE3_WINDOW_DU, 0);
    reset_irq_state();
    set_register(CH_0_DSM_SES, SES_FILTER_SES_CONTROL_REG_OFFSET, 1);

    debug = 'dLC';
    wait_n(100);

    VCD_ENABLE; // 4 - SES + dLC
    wait();
    VCD_DISABLE;

    debug = 'wait';
    dma_stop_circular(0);
    wait_for_interrupt();
    set_register(CH_0_DSM_SES, SES_FILTER_SES_CONTROL_REG_OFFSET, 0);

    /**********************************************************************************
     * DSM + SES + dLC + DMA + CPU asleep
     ***********************************************************************************/

    dma_run_circular( dispatched_data, SAMPLE_COUNT, DMA_TRANS_MODE_CIRCULAR, DMA_TRANS_END_INTR, PHASE3_WINDOW_DU, 0);
    reset_irq_state();
    set_register(CH_0_DSM_SES, SES_FILTER_SES_CONTROL_REG_OFFSET, 1);

    debug = 'slep';
    wait_n(100);

    VCD_ENABLE; // 5 - dLC sleep
    reset_irq_state();
    while (trans_intr_total == 0u && (window_intr_total + trans_intr_total) < PHASE3_MAX_IRQ_EVENTS) {
        wait_for_interrupt();
    }
    VCD_DISABLE;

    debug = 'wait';
    dma_stop_circular(0);
    wait_for_interrupt();
    set_register(CH_0_DSM_SES, SES_FILTER_SES_CONTROL_REG_OFFSET, 0);

    int16_t sign, dL = 0;
    uint32_t dn = 0;
    int32_t rec = 0;
    int32_t n = 0;

    if(DEBUG_ACQUIRED_VALUES){
        /**********************************************************************************
         * Print dLC acquired values for debug
         ***********************************************************************************/
        debug = ' rec';
        wait_n(100);

        for (uint32_t i = 0; i < SAMPLE_COUNT; ++i) {
            if(dispatched_data[id][i] == SENTINEL_WORD ){
                debug = 0;
            }else{
                data =  dispatched_data[id][i];
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
        }


    }

    /**********************************************************************************
    * The end
    ***********************************************************************************/
    debug = 'done';
    return 0;
}