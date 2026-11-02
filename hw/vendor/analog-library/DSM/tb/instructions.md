## Build the simulation model
```bash
verilator -Wall --trace --cc ../Verilog/DSM.sv --exe tb.cpp
```
This will generate an `obj_dir` folder (if it doesn't exist yet).

## Build the executable

```bash
make -j -C obj_dir -f VDSM.mk VDSM
```

## Run the simulation

```bash
./obj_dir/VDSM
```

## Observe the waveforms

```
gtkwave waveforms.vcd
```