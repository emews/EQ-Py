
# ALGORITHM.PY

# Provides parameters to and accepts input from Swift tasks

import eqpy

def run():
    print("starting")
    eqpy.OUT_put("1")
    result = eqpy.IN_get()
    eqpy.OUT_put("33" + 1)
    result = eqpy.IN_get()
    eqpy.OUT_put("FINAL")
