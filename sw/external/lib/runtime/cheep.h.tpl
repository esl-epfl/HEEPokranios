// Copyright 2022 EPFL and Politecnico di Torino.
// Solderpad Hardware License, Version 2.1, see LICENSE.md for details.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
//
// File: cheep.h
// Author: Michele Caon
// Date: 13/05/2023
// Description: Address map for cheep external peripherals.

<%
    cheep = xheep.get_extension('cheep')
    ext_peripherals = cheep["ext_peripherals"]
%>

#ifndef CHEEP_H_
#define CHEEP_H_

#ifdef __cplusplus
extern "C" {
#endif // __cplusplus

#include "core_v_mini_mcu.h"

// Number of masters and slaves on the external crossbar
#define EXT_XBAR_NMASTER ${cheep["xbar_nmasters"]}
#define EXT_XBAR_NSLAVE $cheep["{xbar_nslaves"]}

// Peripherals address map
// -----------------------
% for i, name in enumerate(ext_peripherals):
  <%
    upper_name = name.upper()
  %>
  #define ${upper_name}_START_ADDRESS (EXT_PERIPHERAL_START_ADDRESS + 0x${cheep[f"{name}_start_address"]})
  #define ${upper_name}_SIZE 0x${cheep[f"{name}_size"]}
  #define ${upper_name}_END_ADDRESS (${upper_name}_START_ADDRESS + ${upper_name}_SIZE)
% endfor

// Aliases

% for i, name in enumerate(ext_peripherals):
  #define ${name.upper()}   ${name.upper()}_START_ADDRESS
% endfor

#ifdef __cplusplus
} // extern "C"
#endif // __cplusplus

#endif /* CHEEP_H_ */
