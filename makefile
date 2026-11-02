# Copyright 2022 EPFL and Politecnico di Torino.
# Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
# SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
#
# File: makefile
# Author: Michele Caon, Luigi Giuffrida
# Date: 29/04/2024
# Description: Top-level makefile for cheep

# ----- CONFIGURATION ----- #

# Global configuration
ROOT_DIR			:= $(realpath .)
BUILD_DIR 			:= build

# FUSESOC and Python values (default)
ifndef CONDA_DEFAULT_ENV
$(info USING VENV)
FUSESOC = ./.venv/bin/fusesoc
PYTHON  = ./.venv/bin/python
else
$(info USING MINICONDA $(CONDA_DEFAULT_ENV))
FUSESOC := $(shell which fusesoc)
PYTHON  := $(shell which python)
endif

PROJECT ?= hello_world

# Implementation specific variables
# TARGET options are 'asic' (default) and 'pynq-z2'
TARGET ?= asic

# Set the default architecture to that enabling RVE
ARCH 	?= rv32imc

# X-HEEP configuration
XHEEP_DIR			:= $(ROOT_DIR)/hw/vendor/x-heep
X_HEEP_CFG			:= $(ROOT_DIR)/config/python_unsupported.hjson
PYTHON_CHEEP_CFG 	:= $(ROOT_DIR)/config/cheep_configs.py
PAD_CFG				?= $(ROOT_DIR)/config/cheep_pads.py

# CHEEP templated files
# Collects all .tpl files in the project excluding certain directories
CHEEP_GEN_TPLS	:= $(shell find . \( -path './hw/vendor' -o -path './sw/vendor' -o -path './sw/linker' \) -prune -o -name '*.tpl' -print)
EXTERNAL_MCU_GEN_TEMPLATES = $(addprefix $(HEEP_REL_PATH)/,$(CHEEP_GEN_TPLS))
# CHEEP_GEN_TPLS files without the .tpl extension
CHEEP_GEN_OUTS	:= $(patsubst %.tpl,%,$(CHEEP_GEN_TPLS))

GEN_TEMPLATES 	:= $(shell find . -name '*.tpl' -print)
GEN_OUTS 		:= $(patsubst %.tpl,%,$(GEN_TEMPLATES))

EXTERNAL_DOMAINS	:= 0

# Simulation DPI libraries
DPI_LIBS			:= $(BUILD_DIR)/sw/sim/uartdpi.so
DPI_CINC			:= -I$(dir $(shell which verilator))../share/verilator/include/vltstd

# Simulation configuration
LOG_LEVEL			?= LOG_FULL
# jtag: wait for JTAG, flash: boot from flash, force: load firmware into SRAM
BOOT_MODE			?= force
FIRMWARE			?= $(ROOT_DIR)/build/sw/app/main.hex
ifeq ($(BOOT_MODE), jtag)
FIRMWARE			= $(ROOT_DIR)/build/sw/app/main.hex.srec
LINKER 				= on_chip
else ifeq ($(BOOT_MODE), force)
FIRMWARE			= $(ROOT_DIR)/build/sw/app/main.hex
LINKER 				= on_chip
else
FIRMWARE			= $(ROOT_DIR)/build/sw/app/main.hex
LINKER 				= flash_load
endif
VCD_MODE			?= 0 # QuestaSim-only - 0: no dump, 1: dump always active, 2: dump triggered by GPIO 0
MAX_CYCLES			?= 1000000000
FUSESOC_FLAGS		?=
FUSESOC_ARGS		?=

# Flash file
FLASHWRITE_FILE		?= $(FIRMWARE)

# QuestaSim
FUSESOC_BUILD_DIR					= $(shell find $(BUILD_DIR) -type d -name 'epfl_cheep_cheep_*' 2>/dev/null | sort | head -n 1)
QUESTA_SIM_DIR						= $(FUSESOC_BUILD_DIR)/sim-modelsim

#Verilator
VERILATOR_SIM_DIR			= $(FUSESOC_BUILD_DIR)/sim-verilator

#VCS
VCS_SIM_DIR		            = $(FUSESOC_BUILD_DIR)/sim-vcs

# Waves
SIM_VCD 			?= $(BUILD_DIR)/sim-common/questa-waves.fst

# Application data generation
# NOTE: the application makefile may accept additional parameters, e.g.:
# 	KERNEL_PARAMS="--row_a 8 --col_a 8 --col_b 256"
APP_MAKE 			:= $(wildcard sw/applications/$(PROJECT)/*akefile)

TOOLCHAIN ?= GCC
RISCV     ?= $(RISCV_XHEEP)

# Custom preprocessor definitions
CDEFS				?=

# Software build configuration
SW_DIR		:= sw
LINK_FOLDER := $(shell dirname "$(realpath $(firstword $(MAKEFILE_LIST)))")/sw/linker

# Testing flags
# Optional TEST_FLAGS options are '--compile-only'
TEST_FLAGS=

# Dummy target to force software rebuild
PARAMS = $(PROJECT)

# Conda environemnt variables
REQS_XHEEP 	:= hw/vendor/x-heep/util/python-requirements.txt
REQS_CHEEP 	:= util/cheep-python-requirements.txt
ENV_NAME 	:= heepokranios

# ----- BUILD RULES ----- #

# Get the path of this Makefile to pass to the Makefile help generator
MKFILE_PATH = $(shell dirname "$(realpath $(firstword $(MAKEFILE_LIST)))")
export FILE_FOR_HELP = $(MKFILE_PATH)/makefile
export XHEEP_DIR


## Print the Makefile help
## @param WHICH=xheep,all,<none> Which Makefile help to print. Leaving blank (<none>) prints only CHEEP's.
help:
ifndef WHICH
	${XHEEP_DIR}/util/MakefileHelp
else ifeq ($(filter $(WHICH),xheep x-heep),)
	${XHEEP_DIR}/util/MakefileHelp
	$(MAKE) -C $(XHEEP_DIR) help
else
	$(MAKE) -C $(XHEEP_DIR) help
endif

## @section Conda
.PHONY: conda
conda: environment.yml
	@if conda info --envs | grep -q $(ENV_NAME); then \
		echo "Environment exists, updating..."; \
		conda env update -f environment.yml --prune; \
	else \
		echo "Creating new environment..."; \
		conda env create -f environment.yml; \
	fi

# Regenerate environment.yml by passing both requirement files to the script
.PHONY: environment.yml
environment.yml:
	bash util/python-requirements2conda.sh $(REQS_XHEEP) $(REQS_CHEEP)

# Default alias
# -------------
.PHONY: all
all: mcu-gen


## Generate X-HEEP MCU system files
.PHONY: mcu-gen
mcu-gen: unlock-gend | $(BUILD_DIR)/
	@echo "### Building X-HEEP MCU for '$(TARGET)'..."
	$(MAKE) -f $(XHEEP_MAKE) mcu-gen \
		X_HEEP_CFG=$(X_HEEP_CFG) \
		PYTHON_X_HEEP_CFG=$(PYTHON_CHEEP_CFG) \
		PADS_CFG=$(PAD_CFG) \
		EXTERNAL_DOMAINS=$(EXTERNAL_DOMAINS) \
		EXTERNAL_MCU_GEN_TEMPLATES="$(EXTERNAL_MCU_GEN_TEMPLATES)"
	$(MAKE) format
	$(MAKE) lock-gend
	@echo "✅ DONE! X-HEEP MCU and CHEEP generated successfully"

.PHONY: lock-gend
lock-gend:
	@echo '🔒 Making generated files Read-Only'
	@for file in $(GEN_OUTS); do \
		if [ -f "$$file" ]; then chmod -w "$$file"; fi; \
	done

.PHONY: unlock-gend
unlock-gend:
	@echo '🔓 Making generated files Read-Write'
	@for file in $(GEN_OUTS); do \
		if [ -f "$$file" ]; then chmod +w "$$file"; fi; \
	done

.PHONY: view-padring
view-padring:
	xdg-open docs/img/floorplan.html

## @section Simulation

## @subsection Verilator RTL simulation

## Build simulation model (do not launch simulation)
.PHONY: verilator-build
verilator-build:
	@echo $(shell which verilator)
	$(FUSESOC) run --no-export --target sim --tool verilator --build $(FUSESOC_FLAGS) epfl:cheep:cheep \
		$(FUSESOC_ARGS)
	@echo "✅ Successfuly built simulation model"

## Launch simulation
.PHONY: verilator-run
verilator-run: | check-firmware .verilator-check-params
	$(FUSESOC) run --no-export --target sim --tool verilator --run $(FUSESOC_FLAGS) epfl:cheep:cheep \
		--log_level=$(LOG_LEVEL) \
		--firmware=$(FIRMWARE) \
		--boot_mode=$(BOOT_MODE) \
		--max_cycles=$(MAX_CYCLES) \
		$(FUSESOC_ARGS)
	cat $(BUILD_DIR)/sim-common/uart.log

## Launch simulation without waveform dumping
.PHONY: verilator-opt
verilator-opt: | check-firmware .verilator-check-params
	$(FUSESOC) run --no-export --target sim --tool verilator --run $(FUSESOC_FLAGS) epfl:cheep:cheep \
		--log_level=$(LOG_LEVEL) \
		--firmware=$(FIRMWARE) \
		--boot_mode=$(BOOT_MODE) \
		--max_cycles=$(MAX_CYCLES) \
		--trace=false \
		$(FUSESOC_ARGS)
	cat $(BUILD_DIR)/sim-common/uart.log

## Open dumped waveform with GTKWave
.PHONY: verilator-waves
verilator-waves: $(BUILD_DIR)/epfl_cheep_cheep_0.3.0/sim-verilator/logs/waves.fst | .check-gtkwave
	gtkwave -a util/cheep_wave_viewer.gtkw $<

## @subsection QuestaSim RTL simulation

## Build simulation model
.PHONY: questasim-build
questasim-build: $(DPI_LIBS)
	$(FUSESOC) run --no-export --target sim --tool modelsim --build $(FUSESOC_FLAGS) epfl:cheep:cheep \
		$(FUSESOC_ARGS)
	cd $(QUESTA_SIM_DIR) ; make opt

## Build simulation model and launch simulation
.PHONY: questasim-sim
questasim-sim: | check-firmware questasim-build $(QUESTA_SIM_DIR)/logs/
	$(FUSESOC) run --no-export --target sim --tool modelsim --run $(FUSESOC_FLAGS) epfl:cheep:cheep \
		--firmware=$(FIRMWARE) \
		--boot_mode=$(BOOT_MODE) \
		--vcd_mode=$(VCD_MODE) \
		--max_cycles=$(MAX_CYCLES) \
		$(FUSESOC_ARGS)
	cat $(BUILD_DIR)/sim-common/uart.log

## Launch simulation
.PHONY: questasim-run
questasim-run: | check-firmware $(QUESTA_SIM_DIR)/logs/
	$(FUSESOC) run --no-export --target sim --tool modelsim --run $(FUSESOC_FLAGS) epfl:cheep:cheep \
		--firmware=$(FIRMWARE) \
		--boot_mode=$(BOOT_MODE) \
		--vcd_mode=$(VCD_MODE) \
		--max_cycles=$(MAX_CYCLES) \
		$(FUSESOC_ARGS)
	cat $(BUILD_DIR)/sim-common/uart.log

## Launch simulation in GUI mode
.PHONY: questasim-gui
questasim-gui: | check-firmware $(QUESTA_SIM_DIR)/logs/
	$(MAKE) -C $(QUESTA_SIM_DIR) run-gui RUN_OPT=1 PLUSARGS="firmware=$(FIRMWARE) boot_mode=$(BOOT_MODE) vcd_mode=$(VCD_MODE)"

## Open dumped waveforms in GTKWave
.PHONY: questasim-waves
questasim-waves: $(SIM_VCD) | .check-gtkwave
	gtkwave -a tb/misc/questasim-waves.gtkw $<

$(BUILD_DIR)/sim-common/questa-waves.fst: $(BUILD_DIR)/sim-common/waves.vcd | .check-gtkwave
	@echo "### Converting $< to FST..."
	vcd2fst $< $@

# VCS RTL simulation
# ------------------------
# Build simulation model and launch simulation
.PHONY: vcs-build
vcs-build:
	rm -rf $(VCS_SIM_DIR) && \
	fusesoc run --no-export --target sim --tool vcs --build $(FUSESOC_FLAGS) epfl:cheep:cheep \
		$(FUSESOC_ARGS)

.PHONY: vcs-run
vcs-run:
	cd $(VCS_SIM_DIR) && \
	./epfl_cheep_cheep_0.3.0 +firmware=$(FIRMWARE) +boot_mode=$(BOOT_MODE)  +vcd_mode=$(VCD_MODE) +max_cycles=$(MAX_CYCLES) && \
	cat uart.log

.PHONY: vcs-gui
vcs-gui:
	cd $(VCS_SIM_DIR) && \
	./epfl_cheep_cheep_0.3.0 -gui +firmware=$(FIRMWARE) +boot_mode=$(BOOT_MODE)  +vcd_mode=$(VCD_MODE) && \
	cat uart.log

## DPI libraries for QuestaSim
.PHONY: tb-dpi
tb-dpi: $(DPI_LIBS)
$(BUILD_DIR)/sw/sim/uartdpi.so: hw/vendor/x-heep/hw/vendor/lowrisc/opentitan/hw/dv/dpi/uartdpi/uartdpi.c | $(BUILD_DIR)/sw/sim/
	$(CC) -shared -Bsymbolic -fPIC -o $@ $< -lutil


## @section FPGA implementation

## Synthesis for FPGA
.PHONY: vivado-fpga-synth
vivado-fpga-synth:
	@echo "### Running FPGA implementation..."
	$(FUSESOC) run --no-export --target $(TARGET) --build $(FUSESOC_FLAGS) epfl:cheep:cheep $(FUSESOC_ARGS)

## Program the FPGA using Vivado
.PHONY: vivado-fpga-pgm
vivado-fpga-pgm:
	@echo "### Programming the FPGA..."
	$(MAKE) -C $(FUSESOC_BUILD_DIR)/$(TARGET)-vivado pgm

## @section Software

## CHEEP applications
.PHONY: app
app: $(BUILD_DIR)/sw/app/
ifneq ($(APP_MAKE),)
	$(MAKE) -C $(dir $(APP_MAKE))
endif
ifeq ($(TOOLCHAIN), GCC)
	@echo "### Building application for SRAM execution with GCC compiler..."
	@echo "CDEFS: $(CDEFS)"
	@echo "XHEEP_MAKE: $(XHEEP_MAKE)"
	@echo "LINKER: $(LINKER)"
	@echo "LINK_FOLDER: $(LINK_FOLDER)"
	@echo "ARCH: rv32imc"
	@echo "RISCV: $(RISCV)"
	@echo "ARCH: $(rv32imc)"
	@echo "TOOLCHAIN: $(TOOLCHAIN)"
	@echo "FUSESOC_FLAGS: $(FUSESOC_FLAGS)"
	@echo "FUSESOC_ARGS: $(FUSESOC_ARGS)"
	CDEFS=$(CDEFS) $(MAKE) -f $(XHEEP_MAKE) $(MAKECMDGOALS) LINKER=$(LINKER) LINK_FOLDER=$(LINK_FOLDER) ARCH=$(ARCH) RISCV=$(RISCV)
		TOOLCHAIN=$(TOOLCHAIN) $(FUSESOC_FLAGS) $(FUSESOC_ARGS)
	find sw/build/ -maxdepth 1 -type f -name "main.*" -exec cp '{}' $(BUILD_DIR)/sw/app/ \;
	@echo "✅ Successfully built $(PROJECT) for linker $(LINKER) $(BOOT_MODE)"
else
	$(error ### ERROR: Unsupported toolchain: $(TOOLCHAIN))
endif

## Dummy target to force software rebuild
$(PARAMS):
	@echo "### Rebuilding software..."

## @section Utilities

## Check if the firmware is compiled
.PHONY: .check-firmware
check-firmware:
	@if [ ! -f $(FIRMWARE) ]; then \
		echo "\033[31mError: FIRMWARE has not been compiled! Simulation won't work!\033[0m"; \
		exit 1; \
	fi

## Update vendored IPs
.PHONY: vendor-update
vendor-update:
	@echo "### Updating vendored IPs..."
	@success=""; failed=""; \
	for f in hw/vendor/*.vendor.hjson; do \
		[ -e "$$f" ] || continue; \
		echo "### Updating $$f"; \
		if python3 util/vendor.py -vU "$$f"; then \
			success="$$success\n  ✅ $$f"; \
		else \
			failed="$$failed\n  ❌ $$f"; \
		fi; \
	done; \
	echo ""; \
	echo "### Vendor update summary"; \
	echo "Successful:"; \
	if [ -n "$$success" ]; then printf "$$success\n"; else echo "  none"; fi; \
	echo "Failed:"; \
	if [ -n "$$failed" ]; then printf "$$failed\n"; else echo "  none"; fi; \
	if [ -n "$$failed" ]; then exit 1; fi

## Check if fusesoc is available
.PHONY: .check-fusesoc
.check-fusesoc:
	@if [ ! `which fusesoc` ]; then \
	printf -- "### ERROR: 'fusesoc' is not in PATH. Is the correct conda environment active?\n" >&2; \
	exit 1; fi

## Check if GTKWave is available
.PHONY: .check-gtkwave
.check-gtkwave:
	@if [ ! `which gtkwave` ]; then \
	printf -- "### ERROR: 'gtkwave' is not in PATH. Is the correct conda environment active?\n" >&2; \
	exit 1; fi

## Check simulation parameters
.PHONY: .verilator-check-params
.verilator-check-params:
	@if [ "$(BOOT_MODE)" = "flash" ]; then \
		echo "### ERROR: Verilator simulation with flash boot is not supported" >&2; \
		exit 1; \
	fi

## Create directories
%/:
	mkdir -p $@


## @section Cleaning

## Clean build directory
.PHONY: clean
clean:
	$(RM) hw/ip/cheep_top.sv
	$(RM) hw/ip/pad-ring/pad-ring.sv
	$(RM) sw/device/include/cheep.h
	$(RM) -r $(BUILD_DIR)
	$(MAKE) -C $(HEEP_DIR) clean-all

.PHONY: cheep-clean
cheep-clean:
	@echo "🧼 Cleaning cheep of generated files"
	$(RM) $(CHEEP_GEN_OUTS)

## @section Format and Variables

## Verible format
.PHONY: format
format:
	util/format-verible
	$(MAKE) -C $(HEEP_DIR) format-python

## Lint with Verible
.PHONY: lint
lint:
	@echo "### Checking cheep syntax and code style..."
	$(FUSESOC) run --no-export --target lint epfl:cheep:cheep

## Print variables
.PHONY: .print
.print:
	@echo "APP_MAKE: $(APP_MAKE)"
	@echo "KERNEL_PARAMS: $(KERNEL_PARAMS)"
	@echo "FUSESOC_ARGS: $(FUSESOC_ARGS)"
	@echo "CHEEP_GEN_OUTS: $(CHEEP_GEN_OUTS)"


# ----- INCLUDE X-HEEP RULES ----- #
export CHEEP_CFG
export PAD_CFG
export EXTERNAL_DOMAINS
export FLASHWRITE_FILE
export HEEP_DIR = $(ROOT_DIR)/hw/vendor/x-heep
XHEEP_MAKE 		= $(HEEP_DIR)/external.mk
include $(XHEEP_MAKE)
