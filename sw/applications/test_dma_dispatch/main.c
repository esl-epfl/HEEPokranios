#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>

#include "core_v_mini_mcu.h"
#include "cheep.h"
#include "cheep_peripherals_regs.h"
#include "channel_multipath_regs.h"
#include "VCO_counter_regs.h"
#include "dma.h"

#define DMA_CHANNEL             0u
#define SAMPLE_COUNT            16u
#define POLL_TIMEOUT            2000000u
#define SOURCE_PDVCO            6u
#define SOURCE_VCO_P            2u
#define ENABLED_CHANNEL_ID      0u
#define SENTINEL_WORD           0xA5A5u
#define PHASE3_WINDOWS_TO_SINGLE 3u
#define PHASE3_WINDOW_DU         4u
#define PHASE3_MAX_IRQ_EVENTS    128u

#define CHANNELS_N              5
#define CHANNEL_EVENT_MASK      ((1u << CHANNELS_N) - 1u)
#define DMA_WINDOW_EVENT_MASK   DMA_WINDOW_ID_ID_MASK

#define PRINTF(fmt, ...) printf(fmt, ##__VA_ARGS__)

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
    debug='wind';
    uint8_t id = 0;

    do{
        debug = 'even';
        debug=dma_ch->WINDOW_ID;

        for (id = 0; id < CHANNELS_N; ++id) {
            if ((dma_ch->WINDOW_ID & (1u << id)) == 0u) {
                continue;
            }
            debug = 'foun';
            debug = id;

            // ATTEND THE INTERRUPT HERE
            // ---------------------------
            window_intr_total++;
            window_intr_by_id[id]++;
            if (!switched_to_single && window_intr_by_id[id] >= PHASE3_WINDOWS_TO_SINGLE) {
                dma_stop_circular(channel);
                switched_to_single = 1u;
                switch_winner_id = id;
            }
            // ---------------------------

            dma_ch->WINDOW_ID &= ~(1u << id); // Clear the attended channel
            debug = dma_ch->WINDOW_ID;
        }

    } while(dma_ch->WINDOW_ID != 0);
    debug = window_intr_total;
}

void dma_intr_handler_trans_done(uint8_t channel) {
  if (channel == DMA_CHANNEL) {
    trans_intr_total++;
    debug = 'tran';
    uint32_t read = dma_peri(channel)->TRANSACTION_IFR;
  }
}

static inline void reg_write(uint32_t base, uint32_t reg_offset, uint32_t value) {
  *(volatile uint32_t *)(base + reg_offset) = value;
}

static inline uint32_t reg_read(uint32_t base, uint32_t reg_offset) {
  return *(volatile uint32_t *)(base + reg_offset);
}

static int wait_for_data_available(void) {
  for (uint32_t i = 0; i < POLL_TIMEOUT; ++i) {
    if ((reg_read(CHEEP_PERIPHERALS, CHEEP_PERIPHERALS_INPUT_DATA_AVAILABLE_REG_OFFSET) >> CHEEP_PERIPHERALS_INPUT_DATA_AVAILABLE_INPUT_DATA_AVAILABLE_BIT) & 0x1u) {
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

static void configure_channel0_pdvco_stream(void) {
  // Set the VCO level to trigger an overflow (ovf) pulse every N oscillation periods
  reg_write(CH_0_VCO_P_COUNTER,VCO_COUNTER_INTEGRATION_CC_REG_OFFSET, 8);
  reg_write(CH_0_VCO_P_COUNTER,VCO_COUNTER_PERIOD_CC_REG_OFFSET, 8);
  // Enable the counter. This will have no effect until the CHANNEL_MULTIPATH_PDVCO_ENABLE_REG_OFFSET enabled
  reg_write(CH_0_VCO_P_COUNTER,VCO_COUNTER_ENABLE_REG_OFFSET, 1);

  reg_write(CH_0_VCO_N_COUNTER,VCO_COUNTER_INTEGRATION_CC_REG_OFFSET, 8);
  reg_write(CH_0_VCO_N_COUNTER,VCO_COUNTER_ENABLE_REG_OFFSET, 1);

  reg_write(CH_0, CHANNEL_MULTIPATH_PDVCO_EN_REG_OFFSET, 0b11);
  reg_write(CH_0, CHANNEL_MULTIPATH_DATA_SOURCE_SEL_REG_OFFSET, SOURCE_PDVCO);
}

static void configure_test_all_like_multichannel_stream(void) {
    reg_write(CH_0, CHANNEL_MULTIPATH_DATA_SOURCE_SEL_REG_OFFSET, SOURCE_VCO_P);
    reg_write(CH_2, CHANNEL_MULTIPATH_DATA_SOURCE_SEL_REG_OFFSET, SOURCE_VCO_P);
    reg_write(CH_3, CHANNEL_MULTIPATH_DATA_SOURCE_SEL_REG_OFFSET, SOURCE_VCO_P);
    reg_write(CH_4, CHANNEL_MULTIPATH_DATA_SOURCE_SEL_REG_OFFSET, SOURCE_VCO_P);

    reg_write(CH_0_VCO_P_COUNTER, VCO_COUNTER_ENABLE_REG_OFFSET, 1u);
    reg_write(CH_0_VCO_P_COUNTER, VCO_COUNTER_INTEGRATION_CC_REG_OFFSET, 8);
    reg_write(CH_0_VCO_P_COUNTER, VCO_COUNTER_PERIOD_CC_REG_OFFSET, 8);
    reg_write(CH_0_VCO_N_COUNTER, VCO_COUNTER_ENABLE_REG_OFFSET, 0u);
    reg_write(CH_0, CHANNEL_MULTIPATH_PDVCO_EN_REG_OFFSET, 1u);

    reg_write(CH_2, VCO_COUNTER_ENABLE_REG_OFFSET, 1u);
    reg_write(CH_2_VCO_COUNTER, VCO_COUNTER_INTEGRATION_CC_REG_OFFSET, 9);
    reg_write(CH_2_VCO_COUNTER, VCO_COUNTER_PERIOD_CC_REG_OFFSET, 9);
    reg_write(CH_2_VCO_COUNTER, VCO_COUNTER_ENABLE_REG_OFFSET, 1u);
    reg_write(CH_2, CHANNEL_MULTIPATH_PDVCO_EN_REG_OFFSET, 1u);

    reg_write(CH_3, VCO_COUNTER_ENABLE_REG_OFFSET, 1u);
    reg_write(CH_3_VCO_COUNTER, VCO_COUNTER_INTEGRATION_CC_REG_OFFSET, 9);
    reg_write(CH_3_VCO_COUNTER, VCO_COUNTER_PERIOD_CC_REG_OFFSET, 9);
    reg_write(CH_3_VCO_COUNTER, VCO_COUNTER_ENABLE_REG_OFFSET, 1u);
    reg_write(CH_3, CHANNEL_MULTIPATH_PDVCO_EN_REG_OFFSET, 1u);

    reg_write(CH_4, VCO_COUNTER_ENABLE_REG_OFFSET, 1u);
    reg_write(CH_4_VCO_COUNTER, VCO_COUNTER_INTEGRATION_CC_REG_OFFSET, 7);
    reg_write(CH_4_VCO_COUNTER, VCO_COUNTER_PERIOD_CC_REG_OFFSET, 7);
    reg_write(CH_4_VCO_COUNTER, VCO_COUNTER_ENABLE_REG_OFFSET, 1u);
    reg_write(CH_4, CHANNEL_MULTIPATH_PDVCO_EN_REG_OFFSET, 1u);
}

static int run_ext_read_fifo_dma_config(uint16_t dispatched[CHANNELS_N][SAMPLE_COUNT],
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

  dst_tgt.ptr = (uint8_t *)dispatched[0];
  dst_tgt.trig = DMA_TRIG_MEMORY;
  dst_tgt.inc_d1_du = 1u;
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
    debug = 0xE0010000u | ret;
    PRINTF("[ERR] dma_validate_transaction failed: ret=%lu code=0x%08lX\n",
           (unsigned long)ret, (unsigned long)debug);
    return -1;
  }

  ret = dma_load_transaction(&trans);
  if (ret != DMA_CONFIG_OK) {
    debug = 0xE0020000u | ret;
    PRINTF("[ERR] dma_load_transaction failed: ret=%lu code=0x%08lX\n",
           (unsigned long)ret, (unsigned long)debug);
    return -2;
  }

  volatile dma *dma_ch = dma_peri(DMA_CHANNEL);
  volatile uint32_t *dst_ptr_dispatch = &dma_ch->DST_PTR_DISPATCH0;
  for (uint32_t i = 0; i < CHANNELS_N; ++i) {
    dst_ptr_dispatch[i] = (uint32_t)&dispatched[i][0];
  }

  dma_ch->DISPATCH_EN = 1u;
  if ((dma_ch->DISPATCH_EN & 0x1u) == 0u) {
    debug = 0xE0030000u;
    PRINTF("[ERR] DMA dispatch enable failed: code=0x%08lX\n",
           (unsigned long)debug);
    return -3;
  }

  if (dma_launch(&trans) != DMA_CONFIG_OK) {
    debug = 0xE0040000u;
    PRINTF("[ERR] dma_launch failed: code=0x%08lX\n", (unsigned long)debug);
    return -4;
  }

  if (wait_for_ready_after_launch) {
    if (wait_for_dma_ready(DMA_CHANNEL) != 0) {
      debug = 0xE0050000u;
      PRINTF("[ERR] wait_for_dma_ready timeout: channel=%u code=0x%08lX\n",
             DMA_CHANNEL, (unsigned long)debug);
      return -5;
    }
  }

  return 0;
}

static int run_ext_read_fifo_dma(uint16_t dispatched[CHANNELS_N][SAMPLE_COUNT],
                                 uint32_t words_per_id) {
  return run_ext_read_fifo_dma_config(dispatched,
                                      words_per_id,
                                      DMA_TRANS_MODE_SINGLE,
                                      DMA_TRANS_END_POLLING,
                                      0u,
                                      1);
}

static void dump_dispatched_data(const char *label, uint16_t dispatched[CHANNELS_N][SAMPLE_COUNT]) {
  PRINTF("[DUMP] %s\n", label);
  for (uint32_t id = 0; id < CHANNELS_N; ++id) {
    PRINTF("id=%lu:", (unsigned long)id);
    for (uint32_t i = 0; i < SAMPLE_COUNT; ++i) {
        if(dispatched[id][i] == SENTINEL_WORD ){
            PRINTF(" ----");
        }else{
            PRINTF(" %04lX", (unsigned int) dispatched[id][i]);
        }
    }
    PRINTF("\n");
  }
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









int main(void) {
    static uint16_t dispatched_data[CHANNELS_N][SAMPLE_COUNT];

  debug = 'INIT';

  // Activate the funnel from the channels
  reg_write(CHEEP_PERIPHERALS, CHEEP_PERIPHERALS_FUNNEL_EN_REG_OFFSET, 1u);

  configure_test_all_like_multichannel_stream();

  debug = 'RACE';

  // Fill with sentinel words
  for (uint32_t id = 0; id < CHANNELS_N; ++id) {
      for (uint32_t i = 0; i < SAMPLE_COUNT; ++i) { dispatched_data[id][i] = SENTINEL_WORD; }
    }

  // Flush buffer
  reg_write(CHEEP_PERIPHERALS, CHEEP_PERIPHERALS_INPUT_BUFFER_FLUSH_REG_OFFSET, 1u);
  reg_write(CHEEP_PERIPHERALS, CHEEP_PERIPHERALS_INPUT_BUFFER_FLUSH_REG_OFFSET, 0u);

  wait_for_data_available();
  run_ext_read_fifo_dma_config( dispatched_data,
                                SAMPLE_COUNT,
                                DMA_TRANS_MODE_SINGLE,
                                DMA_TRANS_END_POLLING,
                                0u,
                                1);
  dump_dispatched_data("Race to the end!", dispatched_data);


    debug = 'WIND';

    // Fill with sentinel words
  for (uint32_t id = 0; id < CHANNELS_N; ++id) {
    for (uint32_t i = 0; i < SAMPLE_COUNT; ++i) { dispatched_data[id][i] = SENTINEL_WORD; }
  }
  reset_irq_state();

   // Flush buffer
  reg_write(CHEEP_PERIPHERALS, CHEEP_PERIPHERALS_INPUT_BUFFER_FLUSH_REG_OFFSET, 1u);
  reg_write(CHEEP_PERIPHERALS, CHEEP_PERIPHERALS_INPUT_BUFFER_FLUSH_REG_OFFSET, 0u);

  wait_for_data_available();

  run_ext_read_fifo_dma_config( dispatched_data,
                                SAMPLE_COUNT,
                                DMA_TRANS_MODE_CIRCULAR,
                                DMA_TRANS_END_INTR,
                                PHASE3_WINDOW_DU,
                                0);

  while (trans_intr_total == 0u && (window_intr_total + trans_intr_total) < PHASE3_MAX_IRQ_EVENTS) {
    debug = 'slep';
    wait_for_interrupt();
  }
  debug='back';


  for (uint32_t id = 0; id < CHANNELS_N; ++id) {
    debug = id;
    debug = window_intr_by_id[id];
    PRINTF("> %d\t%d\n",id, window_intr_by_id[id] );
  }

  return EXIT_SUCCESS;
}
