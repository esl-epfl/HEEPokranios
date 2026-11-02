// Copyright 2022 EPFL and Politecnico di Torino.
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
//
// File: cheep_pkg.sv
// Author: Michele Caon, Luigi Giuffrida
// Date: 29/04/2024
// Description: Package containing memory map and other definitions.

<%
    cheep = xheep.get_extension('cheep')
    ext_peripherals = cheep["ext_peripherals"]
%>


package cheep_pkg;
  import addr_map_rule_pkg::*;
  import core_v_mini_mcu_pkg::*;

  // ---------------
  // CORE-V-MINI-MCU
  // ---------------

  // CPU
  localparam int unsigned CpuCorevPulp = 32'd${cheep["cpu_corev_pulp"]};
  localparam int unsigned CpuCorevXif = 32'd${cheep["cpu_corev_xif"]};
  localparam int unsigned CpuFpu = 32'd${cheep["cpu_fpu"]};
  localparam int unsigned CpuRiscvZfinx = 32'd${cheep["cpu_riscv_zfinx"]};

  // DMA
  localparam int unsigned DMAMasterPortsNum = DMA_NUM_MASTER_PORTS;
  localparam int unsigned DMACHNum = DMA_CH_NUM;

  // --------------------
  // CV-X-IF COPROCESSORS
  // --------------------


  // ----------------
  // EXTERNAL OBI BUS
  // ----------------

  // Number of masters and slaves
  localparam int unsigned ExtXbarNMaster = 32'd${cheep["xbar_nmasters"]};
  localparam int unsigned ExtXbarNSlave = 32'd${cheep["xbar_nslaves"]};
  localparam int unsigned LogExtXbarNMaster = ExtXbarNMaster > 32'd1 ? $clog2(ExtXbarNMaster) : 32'd1;
  localparam int unsigned LogExtXbarNSlave = ExtXbarNSlave > 32'd1 ? $clog2(ExtXbarNSlave) : 32'd1;

  // External slaves address map
  localparam addr_map_rule_t [ExtXbarNSlave-1:0] ExtSlaveAddrRules = '{default: '0};

  localparam int unsigned ExtSlaveDefaultIdx = 32'd0;


  // --------------------
  // EXTERNAL PERIPHERALS
  // --------------------

  // Number of external peripherals
  localparam int unsigned ExtPeriphNSlave = 32'd${cheep["periph_nslaves"]};
  localparam int unsigned LogExtPeriphNSlave = ExtPeriphNSlave > 32'd1 ? $clog2(ExtPeriphNSlave) : 32'd1;

  // Memory map
  // ----------
% for i, name in enumerate(ext_peripherals):
  <%
    sv_name = "Cheep" + "".join([p.title() if p.islower() else p for p in name.split('_')])
    idx_name = sv_name + "Idx"
    start_name = sv_name + "StartAddr"
    end_name = sv_name + "EndAddr"
  %>
  // ${name.replace('_', ' ')}
  localparam int unsigned ${idx_name} = 32'd${i};
  localparam logic [31:0] ${start_name} = EXT_PERIPHERAL_START_ADDRESS + 32'h${cheep[f"{name}_start_address"]};
  localparam logic [31:0] ${end_name} = ${start_name} + 32'h${cheep[f"{name}_size"]};
% endfor

  // External peripherals address map
  localparam addr_map_rule_t [ExtPeriphNSlave-1:0] ExtPeriphAddrRules = '{
% for name in ext_peripherals:
  <%
    sv_name = "Cheep" + "".join([p.title() if p.islower() else p for p in name.split('_')])
  %>\
    '{idx: ${sv_name}Idx, start_addr: ${sv_name}StartAddr, end_addr: ${sv_name}EndAddr}${"," if not loop.last else ""}
% endfor
  };

endpackage
