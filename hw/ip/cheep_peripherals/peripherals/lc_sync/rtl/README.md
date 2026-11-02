# DDR Edge Detector
This module detects rising edges in an asynchronous input signal (`data_i`). When a rising edge is detected within a certain clock cycle, the `edge_detected_o` is asserted for exactly one cycle of the sampling clock.

To achieve this, the module samples and synchronizes the input signal on both the positive and negative edge of the sampling clock signal. The depth of the synchronization chanins is configurable.

> [!NOTE]
> The design assumes that the asynchronous input signals toggles _at most once every sampling clock signals_. If this condition does not hold, some edges will be missed.

## Quick Start
The projects includes a SystemVerilog testbench that generates an input signal randomly switching with a configurable probability. Check [`makefile`](./makefile) for the details about simulation parameters. The project supports Verilator for RTL simulation through FuseSoC.

### Prerequisites
Top simulate the design using the included testbench, you need the following tools:
- Verilator 5.040 avilable in PATH
- A Python 3.8 environment with with FuseSoC

If you are using [X-HEEP](https://github.com/x-heep/x-heep), the `core-v-mini-mcu` conda environment or any derivative already include the necessary dependencies.

### RTL Simulation
To build the simulation model with Verilator and run the RTL simulation, simply activate your Python environment and run:
```bash
make sim
```

## RTL Parameters
The [DDR edge detector](./rtl/ddr_edge_detector.sv) exposes the following RTL parameters:

| Parameter | Description |
| --------- | ----------- |
| `SYNC_STAGES` | Number of synchronization flip-flops to insert on the positive- and negative-edge sampling chains |

Additionally, the [testbench](./tb/ddr_edge_detector_tb.sv) exposes the following RTL parameters:
| Parameter | Description |
| --------- | ----------- |
| `SIM_CYCLES` | Number of simualtion cycles (referred to the sampling clock) |
| `SAMPLE_UPD_PROB` | Percentage probability tha the input sample changes value in each generation clock cycle |
| `DUT_CLK_DIV` | Ratio between the clock frequency of the input signal generator and the sampling clock frequency of the `ddr_edge_detector` module |
| `MONITOR_EN` | Enable monitor prints in the testbench |

All the parameter above can be set for RTL simulation directly when calling `make`. For example, if you want to run the RTL simulation for 100 cycles, run:
```bash
make sim SIM_CYCLES=100
```

## Simulation Waveforms
If you are using Vaporview, you can load the default waveform view from [`waves.json`](./tb/verilator/waves.json).

The `xing_delayed_q` is a copy of the sample `xing_i` that is delayed by `SYNC_STAGES` to ease debug: if this has a rising edge in a certain clock cycle, then `edge_detected_o` should be asserted in the same clock cycle.
