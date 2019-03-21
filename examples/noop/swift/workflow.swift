
/**
   workflow.swift
   noop project
*/

import io;
import location;
import sys;
import files;
import python;

import EQPy;

string emews_root = getenv("EMEWS_PROJECT_ROOT");
string algo = argv("algorithm");

(void v) loop(location L)
{
  printf("Entering loop...");
  for (boolean b = true, int i = 1;
       b;
       b=c, i = i + 1)
  {
    result = EQPy_get(L);
    printf("swift: from EQ/Py: %s", result);
    boolean c;
    if (result == "FINAL")
    {
      printf("Exiting loop.") =>
        v = propagate() =>
        c = false;
    } else if (result == "EQPY_ABORT") {
        string why = EQPy_get(L);
        printf("%s", why) =>
        v = propagate() =>
        c = false;
    }
    else
    {
      data = int2string(string2int(result) + 1);
      printf("swift: to EQ/Py:   %s", data);
      EQPy_put(L, data) => c = true;
    }
  }

}

main() {
  printf("SWIFT WORKFLOW STARTING...");

  location L = locationFromRank(1);
  EQPy_init_package(L, algo) =>
  loop(L) =>
  EQPy_stop(L) =>
    printf("SWIFT WORKFLOW COMPLETE");
}
