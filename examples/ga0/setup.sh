#!/bin/sh
set -eu

# SETUP.SH
# Installs EQ-Py into this application project directory

THIS=$( dirname $0 )
$THIS/../../src/install $THIS/ext/EQ-Py
