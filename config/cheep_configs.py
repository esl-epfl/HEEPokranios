# Copyright 2025 EPFL
# Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
# SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
#
# Author: Michele Caon, David Mallasén
# Description: X-HEEP and D-HEEP Blue configuration for mcu-gen.

import pathlib
import os
from x_heep_gen.xheep import XHeep
from x_heep_gen.cpu.cv32e20 import cv32e20
from x_heep_gen.bus_type import BusType
from x_heep_gen.memory_ss.memory_ss import MemorySS
from x_heep_gen.memory_ss.linker_section import LinkerSection
import x_heep_gen.peripherals.base_peripherals as base_peripherals
import x_heep_gen.peripherals.user_peripherals as user_peripherals
from x_heep_gen.peripherals import base_peripherals_domain
from x_heep_gen.peripherals import user_peripherals_domain

def config():
    # Parallel bus to provide bandwidth to the eGPU
    system = XHeep(BusType.NtoM)

    # Set cv32e40p CPU

    system.set_cpu(cv32e20( rv32e=False, rv32m='RV32MFast' ))

    # Memory subsystem (196kiB)
    # - 2 x 32kiB firmware and data
    # - 2x 64kiB interleaved banks (increase if the eGPU bandwidth is not enough)
    memory_ss = MemorySS()
    memory_ss.add_ram_banks([16] * 2)

    # Linker script sections
    memory_ss.add_linker_section(LinkerSection.by_size("code", 0, 0x00004000))
    memory_ss.add_linker_section(LinkerSection("data", 0x00004000, None))
    memory_ss.add_linker_section(LinkerSection.by_size("debug_mem", 0x000007FFC, 4))
    memory_ss.add_linker_section(LinkerSection.by_size("debug_spi",  0x000007F7C, 80))
    system.set_memory_ss(memory_ss)

    # Peripheral domains initialization
    base_peripheral_domain = base_peripherals_domain.BasePeripheralDomain()
    user_peripheral_domain = user_peripherals_domain.UserPeripheralDomain()

    # Base peripherals. All base peripherals must be added. They can be either added with "add_peripheral" or "add_missing_peripherals" (adds all base peripherals).
    # We don't need:
    # - SPI_memio, unless we decide to support  using flash as the main memory
    base_peripheral_domain.add_peripheral(base_peripherals.SOC_ctrl())
    base_peripheral_domain.add_peripheral(base_peripherals.DMA(ch_length=0x100, num_channels=2, num_master_ports=2, num_channels_per_master_port=2, fifo_depth=4, addr_mode='no', subaddr_mode='no', hw_fifo_mode='yes', ext_read_fifo_id_bits=3, zero_padding='no', dispatching='yes'))
    base_peripheral_domain.add_peripheral(base_peripherals.Pad_control())
    base_peripheral_domain.add_peripheral(base_peripherals.GPIO_ao())
    base_peripheral_domain.add_missing_peripherals()

    # User peripherals. All are optional. They must be added with "add_peripheral".
    user_peripheral_domain.add_peripheral(user_peripherals.UART())
    user_peripheral_domain.add_peripheral(user_peripherals.RV_timer())
    # user_peripheral_domain.add_peripheral(user_peripherals.RV_plic())
    # user_peripheral_domain.add_peripheral(user_peripherals.GPIO())

    # Add the peripheral domains to the system
    system.add_peripheral_domain(base_peripheral_domain)
    system.add_peripheral_domain(user_peripheral_domain)

    # Add D-HEEP Blue extensions
    system.add_extension("cheep", cheep_config())

    return system

def int2hexstr(n, nbits) -> str:
    return hex(n)[2:].zfill(nbits // 4).upper()

def cheep_config():

    peripherals_list = {
        "cheep_peripherals": {}, # Keep this one first so the interface words are left in a constant address
        "system_clock_divider": {},
        "dLC": {},
        "ch_0": {},
        "ch_1": {},
        "ch_2": {},
        "ch_3": {},
        "ch_4": {},
        "ch_0_lna_ctrl": {},
        "ch_0_bpe_ctrl": {},
        "ch_0_bpe_clock_divider": {},
        "ch_0_bpe_pwm_0": {},
        "ch_0_bpe_pwm_1": {},
        "ch_0_bpe_pwm_2": {},
        "ch_0_bpe_pwm_3": {},
        "ch_0_dsm_ctrl": {},
        "ch_0_dsm_cic": {},
        "ch_0_dsm_ses": {},
        "ch_0_vco_p_counter": {},
        "ch_0_vco_n_counter": {},
        "ch_0_dlc": {},
        "ch_1_lna_ctrl": {},
        "ch_1_dsm_ctrl": {},
        "ch_1_dsm_cic": {},
        "ch_1_dsm_ses": {},
        "ch_2_vco_counter": {},
        "ch_2_lc_ctrl": {},
        "ch_3_vco_counter": {},
        "ch_3_lna_ctrl": {},
        "ch_3_lc_ctrl": {},
        "ch_3_dlc": {},
        "ch_4_vco_counter": {},
        "ch_4_lc_ctrl": {},
        "idac_ctrl": {},
        "REFs_ctrl": {},
    }

    current_offset = 0x00000000
    default_length = 0x00000100

    kwargs = {
        "cpu_corev_pulp": 0,
        "cpu_fpu": 0,
        "cpu_riscv_zfinx": 0,
        "cpu_corev_xif": 0,
        "xbar_nmasters": 0,
        "xbar_nslaves": 7, # TODO_heepokranios: Verify if this needs to be dynamic
        "periph_nslaves": len(peripherals_list),
    }

    for name, attrs in peripherals_list.items():
        # Determine size (allow override if 'length' is ever added to input dict)
        size_int = attrs.get("length_int", default_length)

        # Create hex strings
        start_hex = int2hexstr(current_offset, 32)
        size_hex = int2hexstr(size_int, 32)

        # A. Update the peripheral sub-dictionary "a posteriori"
        attrs["offset"] = start_hex
        attrs["length"] = size_hex

        # B. Add flattened keys to kwargs to match your original format
        # This preserves the exact casing (e.g. "aMUX_ctrl" -> "aMUX_ctrl_start_address")
        kwargs[f"{name}_start_address"] = start_hex
        kwargs[f"{name}_size"] = size_hex

        # Increment offset for the next block
        current_offset += size_int

    kwargs["ext_peripherals"] = peripherals_list

    return kwargs

