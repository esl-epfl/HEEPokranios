## Build the simulation model
```bash
verilator -Wall --trace --cc ../Verilog/LNA.sv --exe tb.cpp
```
This will generate an `obj_dir` folder (if it doesn't exist yet).

## Build the executable

```bash
make -j -C obj_dir -f VLNA.mk VLNA
```

## Run the simulation

```bash
./obj_dir/VLNA
```

## Observe the waveforms

```
gtkwave waveforms.vcd
```