## Build the simulation model
```bash
verilator -Wall --trace   -I../../analog_defs   --cc ../Verilog/LC_wrapper.sv   --exe tb.cpp   --build
```
This will generate an `obj_dir` folder (if it doesn't exist yet).

## Build the executable

```bash
make -j -C obj_dir -f VLC_wrapper.mk VLC_wrapper
```

## Run the simulation

```bash
./obj_dir/VLC_wrapper
```

## Observe the waveforms

```
gtkwave waveforms.vcd
```