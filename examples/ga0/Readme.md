
# GA0: Genetic Algorithm, Difficulty Zero

## Usage instructions

1. Do `./setup.sh`
2. Do `swift/run --settings=swift/settings.json`

## Overview

This runs a real EA with [DEAP](http://deap.readthedocs.io/en/master).  The objective function is simply:

_sin(4x) + sin(4y) - 2x + x² - 2y + y²_

It is expressed for the workflow in [task.tcl](https://github.com/emews/EQ-Py/blob/master/examples/ga0/Tcl/Tcl-Task/task.tcl) and for plotting in [f.m](https://github.com/emews/EQ-Py/blob/master/examples/ga0/plots/f.m)

## File index

### Entry points

* `setup.sh`: Installs the EQ-Py system into this project directory
* `swift/run`: Runs the workflow

### Supporting files

* `python/algorithm.py`: EQ-Py interface to DEAP
* `swift/settings.json`: Settings processed by `algorithm.py`
* `swift/workflow.swift`: The Swift script.  Receives parameters from DEAP, executes them on the objective function (`task()`), and returns results to DEAP
* `Tcl/Tcl-Task/task.tcl`: The implementation of the objective function in Tcl, used by Swift

### Plots

### File index

In the `plots/` directory:

#### Entry points

* `create-xyz.tcl`: Scans the Swift output and creates Octave-compatible data files {x,y,z}.dat .  These are the points sampled by DEAP.  Usage: `cd plots; ./create-xyz.tcl`
* `trajectory.m`: Combines the contour plot with data points from {x,y,z}.dat.  Usage: `cd plots; octave trajectory.m`.  Creates `plot.png`.

#### Supporting files

* `f.m`: The implementation of the objective function in Octave, used only for visualization
* `show_f.m`: Make a contour plot from `f.m`

#### Example output

Run with σ = 0.5:

https://github.com/emews/EQ-Py/raw/master/examples/ga0/plots/plot-s01.png

Run with σ = 0.1:

https://github.com/emews/EQ-Py/blob/master/examples/ga0/plots/plot-s05.png
