# HEEPokranios

<p align="center"><img src="./docs/img/cheep_logo.png" width="400"></p>

HEEPokranios is a RISC-V SoC based on the open-source [X-HEEP](https://github.com/esl-epfl/x-heep) platform, designed to record intracranial EEG. Its 5 recording channels can be configured by the on-chip CPU and streamed out via DMA and different transmission options.

## SoC overview

- **MCU** — [X-HEEP](./hw/vendor/x-heep/): Ibex CPU, 2× DMA with dispatching mode, SPI (also used to load programs into SRAM wirelessly), JTAG, UART, 32 kB RAM, interrupts and timers.
- **Wireless power and data transfer** — [WPDT](./hw/vendor/analog-library/WPDT/): power from a 433 MHz inductive link, Manchester-encoded downlink (forwarded to the SPI) and uplink (serialized from a register), and a 1 MHz clock usable as system clock.
- **Power regulation** — [vREF](./hw/vendor/analog-library/vREF/), [iREF](./hw/vendor/analog-library/iREF/) and [iMIRROR](./hw/vendor/analog-library/iMIRROR/) generate the supplies and bias currents for the analog blocks from the WPDT rectifier output.
- **5× recording channels** — built as flavours of the [channel-multipath](./hw/ip/cheep_peripherals/peripherals/channel_multipath/) skeleton, combining acquisition blocks such as a low-noise amplifier ([LNA](./hw/vendor/analog-library/LNA/)), ΔΣ ADC ([DSM](./hw/vendor/analog-library/DSM/)), VCO-based ADC ([VCO](./hw/vendor/analog-library/VCO/)), level-crossing ADC ([LC](./hw/vendor/analog-library/LC/), [dLC](./hw/ip/cheep_peripherals/peripherals/dlc/)), band-power extraction ([BPE](./hw/vendor/analog-library/BPE/)) and an impedance-monitoring current DAC ([iDAC](./hw/vendor/analog-library/iDAC/)).

As a testing chip, most block inputs/outputs are exposed on pads, to be shorted at PCB level or at wire-bonding time.

<p align="center"><img src="./docs/img/HEEPokranios_diagrams-Tapeout_overlay.svg" width="700"></p>

## Getting started

1. Install the conda environment (Python tooling + fusesoc) and activate it:
   ```bash
   make conda
   conda activate heepokranios
   ```
   Make sure the following are also in your `PATH`: a RISC-V toolchain (supporting at least `rv32imc`), Verilator **4**, Verible and GTKWave. See _X-HEEP_'s [prerequisites](https://github.com/esl-epfl/x-heep#prerequisite) for details.

2. Generate the RTL and software from the SoC configuration (only needed once, and after any change to `config/cheep_configs.py` or a `.tpl` template):
   ```bash
   make mcu-gen
   ```

3. Build an application and run it on the Verilator simulation:
   ```bash
   make app PROJECT=hello_world
   make verilator-build
   make verilator-run
   ```
   The UART log is written to `build/sim-common/uart.log`, and waveforms can be inspected with `make verilator-waves`. `BOOT_MODE` defaults to `force` (firmware loaded directly into SRAM); `jtag` and `flash` boot are also supported.

`make help` lists all targets (use `make help WHICH=xheep` for the vendored _X-HEEP_ makefile).

## Documentation

- [_X-HEEP_ documentation](./hw/vendor/x-heep/docs/source/index.rst) — platform internals, configuration, programming and debugging.
- [HEEPokranios documentation](./docs/source/) — [analog front-end overview](./docs/source/Overview/Overview.md), [digital back-end](./docs/source/DBE/CIC_filter.md) and [LDO](./docs/source/FB/LDO.md) descriptions.
- [How to add new peripherals](./hw/ip/How%20to%20add%20new%20peripherals.md).
- [Analog library](./hw/vendor/analog-library/README.md) — structure and behavioral models of the analog blocks.

## License

HEEPokranios is distributed under the [Solderpad Hardware License v2.1](./LICENSE.md) (Apache-2.0 WITH SHL-2.1). The vendored [_X-HEEP_](./hw/vendor/x-heep/) and the analog library carry their own license terms.
