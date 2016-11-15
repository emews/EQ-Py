#!/bin/bash
set -eu

if [[ ${PROJECT:-} == "" ]]
then
  echo "Error: You need to set environment variable PROJECT."
  exit 1
fi

THIS=$( cd $( dirname $0 ); /bin/pwd )

PATH=/lustre/beagle2/wozniak/Public/sfw/swift-t/py2Lr/stc/bin:$PATH

export LD_LIBRARY_PATH=
LD_LIBRARY_PATH+=/opt/gcc/4.9.2/snos/lib64:
LD_LIBRARY_PATH+=/lustre/beagle2/lpBuild/CANDLE/python/Python-2.7.12-inst/lib

export T_PROJECT_ROOT=$( cd $THIS/.. ; /bin/pwd )
EQP=$T_PROJECT_ROOT/ext/EQ-Py

export TURBINE_USER_LIB=$T_PROJECT_ROOT/Tcl/Tcl-Task
export PYTHONPATH=$T_PROJECT_ROOT/python:$EQP
export TURBINE_RESIDENT_WORK_WORKERS=1

export TURBINE_OUTPUT_ROOT=$PWD
export TURBINE_OUTPUT_FORMAT=out-%Q
export WALLTIME=01:00:00
PROCS=3
swift-t -m cray -p -I $EQP -r $EQP \
        -n $PROCS \
        $T_PROJECT_ROOT/swift/workflow.swift \
        --settings=$T_PROJECT_ROOT/swift/settings.json
