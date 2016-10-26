#!/bin/sh
set -eu

THIS=$( dirname $0 )
$THIS/../../src/install $THIS/ext/EQ-Py
