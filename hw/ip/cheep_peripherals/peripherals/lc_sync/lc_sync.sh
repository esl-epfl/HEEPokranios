# Copyright 2025 EPFL contributors
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

# File: DSM_ctrl.sh
# Author: Michele Caon, David Mallasen
# Description: Script to generate the DSM controller registers

# Capture the name of the containing folder
REG_DIR=$(dirname -- "$(readlink -f "$0")")
MOD_NAME=$(basename "$REG_DIR")

ROOT=$(realpath "$REG_DIR/../../../../../")
REGTOOL=$ROOT/hw/vendor/x-heep/hw/vendor/pulp_platform/register_interface/vendor/lowrisc_opentitan/util/regtool.py
HJSON_FILE=$REG_DIR/registers/${MOD_NAME}.hjson
RTL_DIR=$REG_DIR/rtl
SW_DIR=$ROOT/sw/external/lib/drivers/${MOD_NAME}

mkdir -p $RTL_DIR $SW_DIR

printf -- "Generating ${RTL_DIR}/${MOD_NAME} registers RTL..."
$REGTOOL -r -t $RTL_DIR $HJSON_FILE
[ $? -eq 0 ] && printf " OK\n" || exit $?

printf -- "Generating ${SW_DIR}/${MOD_NAME} software header..."
$REGTOOL --cdefines -o $SW_DIR/${MOD_NAME}_regs.h $HJSON_FILE
[ $? -eq 0 ] && printf " OK\n" || exit $?

printf -- "Generating ${MOD_NAME} documentation..."
$REGTOOL -d $HJSON_FILE > $SW_DIR/${MOD_NAME}_regs.md
[ $? -eq 0 ] && printf " OK\n" || exit $?