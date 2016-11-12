
Usage instructions

1. Do `./setup.sh`
2. Do `swift/run --settings=swift/settings.json`

This runs a real EA with DEAP.  The objective function is simply:

_sin(4x) + sin(4y) - 2x + x² - 2y + y²_

It is expressed for the workflow in [task.tcl](https://github.com/emews/EQ-Py/blob/master/examples/ga0/Tcl/Tcl-Task/task.tcl) and for plotting in [f.m](https://github.com/emews/EQ-Py/blob/master/examples/ga0/plots/f.m)
