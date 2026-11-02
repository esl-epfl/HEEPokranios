# AGENTS.md

HEEPokranios: an ASIC/FPGA SoC (based on [X-HEEP](https://github.com/esl-epfl/x-heep)) for intracranial EEG recording. SystemVerilog RTL + embedded C firmware, driven almost entirely by the root `makefile` (note: lowercase).

## Environment

- `make conda` creates the conda env `heepokranios` (Python deps for code generation + fusesoc); the makefile falls back to `./.venv/bin/fusesoc` if `CONDA_DEFAULT_ENV` is unset.
- Verilator must be v4.x, not v5. Also needed: RISC-V toolchain (`rv32imc`), Verible, GTKWave. QuestaSim/VCS targets exist but require local licenses.

## Code generation (critical)

- `make mcu-gen` generates RTL/software from `*.tpl` templates and the SoC config (`config/cheep_configs.py`, `config/cheep_pads.py`, `config/python_unsupported.hjson`), then runs `make format` and chmods all generated files **read-only**.
- Never edit generated files directly — e.g. `hw/ip/cheep_top.sv`, `hw/ip/pad-ring/pad-ring.sv`, `sw/device/include/cheep.h`, `tb/tb_util.svh`, linker scripts in `sw/linker/`. Edit the matching `.tpl` file or config instead, then re-run `make mcu-gen`. `make unlock-gend` / `lock-gend` toggle write permissions.
- `environment.yml` is generated too — edit `util/cheep-python-requirements.txt` (and x-heep's `python-requirements.txt`), which `util/python-requirements2conda.sh` combines into it.
- SoC structure (CPU, RAM banks, DMA config, peripheral base addresses) lives in `config/cheep_configs.py`; peripheral address space changes there propagate into generated headers/RTL on `mcu-gen`.

## Typical workflow

1. `make mcu-gen` (once, and after any config/`.tpl` change)
2. `make app PROJECT=<name>` — builds firmware from `sw/applications/<name>` (or `hw/vendor/x-heep/sw/applications/<name>`) into `build/sw/app/main.hex`. `BOOT_MODE` selects linker: `force` (default), `jtag`, or `flash` (`flash_load` linker).
3. Simulate:
   - Verilator: `make verilator-build`, then `make verilator-run` (or `verilator-opt` to skip wave dumping). Verilator does **not** support `BOOT_MODE=flash`. UART log: `build/sim-common/uart.log`; waves via `make verilator-waves`.
   - QuestaSim (needs a local license): `make questasim-build` / `make questasim-sim`.
4. `make help` lists targets; `make help WHICH=xheep` shows the vendored x-heep makefile help.
5. App tests: `python3 test/test_apps.py [--compile-only]` from the repo root compiles+runs all apps under QuestaSim. Per-app include/exclude is via the `WHITELIST`/`BLACKLIST` lists inside that file, not CLI args.

## Vendored code

- `hw/vendor/x-heep/` and `hw/vendor/analog-library/` are **hard copies** (no `.vendor.hjson` pin files), so `make vendor-update` iterates zero files and local edits there are safe — but keep them in sync with upstream manually.
- `hw/vendor/patches/` holds patches applied to x-heep.

## Adding a peripheral

Follow `hw/ip/How to add new peripherals.md` end-to-end. Key non-obvious steps:

- Register interfaces are generated **per-peripheral** by running its script, e.g. `cd hw/ip/cheep_peripherals/<BLOCK>_ctrl && . <BLOCK>_ctrl.sh` — this produces `<BLOCK>_ctrl_reg_pkg/top.sv` and drivers in `sw/external/lib/drivers/`. Use the template tooling in `hw/ip/cheep_peripherals/_template/`.
- The new peripheral must also be registered in `config/cheep_configs.py` (address offset/length) and wired in `cheep_top.sv.tpl` — edits to `cheep_top.sv` are lost on `mcu-gen`.
- Naming consistency (module, folder, hjson, pads) matters more than usual; generated code and scripts key off exact names.

## Formatting / lint

- `make format` runs Verible (column limit 150 via `util/format-verible`; lint allows line length 200). `make lint` runs Verible lint through fusesoc. Vendored files are excluded from formatting.
- Python files are formatted with `black` (pinned in the conda env).

## Gotchas

- Fusesoc core is `epfl:cheep:cheep` (`cheep.core`); builds land in `build/epfl_cheep_cheep_0.3.0/`. Passing extra simulator options: `FUSESOC_ARGS="..."`.
- `.gitignore` excludes all `*.txt` by default (with narrow exceptions) — don't rely on committing plain-text artifacts.
- Analog values are 32-bit fixed-point integers in RTL sim (`analog_defs` package); the analog pad cells (`hw/simulation/pad_cell_analog.sv`) are transparent behavioral stubs.
