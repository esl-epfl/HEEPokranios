## Build the simulation model
```bash
verilator -Wall --trace --cc ../Verilog/WPDT_tx.sv --exe tb.cpp
```
This will generate an `obj_dir` folder (if it doesn't exist yet).

## Build the executable

```bash
make -j -C obj_dir -f VWPDT_tx.mk VWPDT_tx
```

## Run the simulation

```bash
./obj_dir/VWPDT_tx
```

## Observe the waveforms

```
gtkwave waveforms.vcd
```