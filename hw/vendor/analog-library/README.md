# WELCOME to the CHEEP's ~ ANALOG LIBRARY ~ 📚

> ⚠️ **Warning**  
> The layout view should have the same name as the block inside the flow. Otherwise it will not be found

Here you will find all the latest version of the analog blocks that can be used in CHEEPs. 
All analog (or mixed signal) blocks should have a well defined and unique name which will be used all accross this repo and on your cheep. 

For each block you should have ONLY one folder, containing:
* `Verilog/` behavioral model in .v or .sv for RTL simulation on Questasim
* `misc/` miscelaneous, eg. waivers for verilator
* `include/`  Packages with definitions, maybe we could also have header files with C defines
* `LEF/` for floor planning.  
* `LIB/` for liberty .lib files for synthesis. This can be fake if the block is surrounded by registers/FF. 
* `DB/`     for .db files (.lib translated to Cadence format). Can be generated calling `lib2db`     
* `spice/` for AMS simulations on VCS
* `GDS/ `for physical implementation
* `VerilogA/` behavioral model in .va -- OPTIONAL
* `CDL/` a type of spice? -- OPTIONAL
* `<block>_analog.core` a .core file for dependencies
* `LVS/` data relative to the last LVS run
* `DRC/` report of the last DRC run
* `<block>.hjson` a file needed to automatically update the different layout-related files

> Notice that the order in which this folder were described is (approximately) the order in which files will be needed in the flow.

Inside each folder there should be a file with the name of the block and the extension: `<block>.<ext>` e.g. `iDAC.sv` or` iDAC.gds`
The exception for capitalization is when the standard is to do something else, but the name should remain unchanged.

Example:

```
./iDAC
├── CDL
│   └── iDAC.cdl
├── GDS
│   └── iDAC.gds
├── iDAC_analog.core
├── include
│   └── idac_pkg.sv
├── LEF
├── spice
│   ├── iDAC_hspice.sp
│   └── iDAC_spectre.sp
├── Verilog
│   └── iDAC.sv
└── VerilogA
    └── iDAC.va
```

> 🔧 **Important**  
> All technology-related paths are defined in the tech.env file. This file is automatically sourced at startup, making the aliases available in your shell. If you need to switch to a different technology, simply update the relevant paths in the file and re-source it.

## Structure of the repo
This repository is automatically updated, so a strict structure is required. For each analog/mixed-signal block an associated folder **WITH THE EXACT BLOCK NAME** following the structure presented before is required. When creating a new block folder, only the non-layout related files are required and the `<block>.hjson` file, as the other will be automatically generated. A guide on how to create the `hjson` file is presented [here](./scripts/README_HJSON.md).

## Repository Update Instructions

This repository is automatically updated, meaning that the necessary files are generated to reflect the latest versions based on the current schematics and layouts of the various blocks.

A step-by-step guide to automate this file generation process can be found [here](./scripts/README.md).
