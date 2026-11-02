
#include <stdint.h>
#include <stdlib.h>
#include "core_v_mini_mcu.h"
#include "cheep.h"
#include "dma.h"
#include "csr.h"
#include "gpio_regs.h"

#define VCD_ENABLE  *(volatile int32_t *)(GPIO_AO_START_ADDRESS+GPIO_GPIO_SET_REG_OFFSET) = 1;
#define VCD_DISABLE *(volatile int32_t *)(GPIO_AO_START_ADDRESS+GPIO_GPIO_CLEAR_REG_OFFSET) = 1;


volatile uint32_t debug __attribute__((section(".debug_mem")));
volatile uint32_t buff_sram0[2000] __attribute__((section(".text.buff_sram0")));
volatile uint32_t buff_sram1[2000] __attribute__((section(".data.buff_sram1")));

volatile int32_t trans_intr_flag = 0;
volatile int32_t window_intr_total = 0;

void dma_intr_handler_trans_done(uint8_t channel){
    trans_intr_flag ++;
}

void dma_intr_handler_window_done(uint8_t channel) {
    window_intr_total++;
    *(volatile int32_t *)(DMA_START_ADDRESS+DMA_WINDOW_ID_REG_OFFSET) = 0;
}

int main(){


    static dma_target_t tgt_src;
    static dma_target_t tgt_dst;
    static dma_trans_t trans;
    dma_config_flags_t res;


    // Fill RAM0 with a specific word
    debug = '0xAB';
    for( uint32_t i = 0; i < sizeof(buff_sram0)/4; i++ ) buff_sram0[i] = 0xAAAAAAAA;

    dma_data_type_t data_type = DMA_DATA_TYPE_WORD;

    uint8_t types[] = {DMA_DATA_TYPE_WORD, DMA_DATA_TYPE_HALF_WORD, DMA_DATA_TYPE_BYTE};

    for (uint8_t i =0; i < 3; i++){

        for( uint32_t i = 0; i < sizeof(buff_sram1)/4; i++ ) buff_sram1[i] = 0;
        
        data_type           = types[i];

        debug               = data_type;
        tgt_src.ptr         = (uint8_t *) buff_sram0;
        tgt_src.trig        = DMA_TRIG_MEMORY;
        tgt_src.inc_d1_du   = 1;
        tgt_src.type        = data_type;

        tgt_dst.ptr         = (uint8_t *) buff_sram1;
        tgt_dst.inc_d1_du   = 1;
        trans.size_d1_du    = (sizeof(buff_sram0)/DMA_DATA_TYPE_2_SIZE(data_type));
        tgt_dst.trig        = DMA_TRIG_MEMORY;
        tgt_dst.type        = data_type;

        trans.src           = &tgt_src;
        trans.dst           = &tgt_dst;
        trans.dim           = DMA_DIM_CONF_1D;
        trans.win_du        = 0;

        trans.hw_fifo_en    = 0;
        trans.mode          = DMA_TRANS_MODE_SINGLE;
        trans.end           = DMA_TRANS_END_INTR;

        trans_intr_flag     = 0;

        dma_init(NULL);
        dma_validate_transaction(&trans, DMA_ENABLE_REALIGN, DMA_PERFORM_CHECKS_ONLY_SANITY);
        dma_load_transaction(&trans);
        dma_launch(&trans);

        VCD_ENABLE;
        while(  trans_intr_flag < 1 ) {
            CSR_CLEAR_BITS(CSR_REG_MSTATUS, 0x8);
            if ( trans_intr_flag < 1  ) {
                wait_for_interrupt();
                VCD_DISABLE;
            }
            CSR_SET_BITS(CSR_REG_MSTATUS, 0x8);
        }

    }

    return 0;
}