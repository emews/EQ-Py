
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

(void v) loop(location loc)
{
  printf("Beginning loop.");
  for (boolean b = true, int i = 1;
       b;
       b=c, i = i + 1)
  {
    result = EQPy_get(loc);
    printf("swift: result: %s", result);
    boolean c;
    if (result == "FINAL")
    {
      printf("setting void") =>
        v = propagate() =>
        c = false;
    } else if (result == "EQPY_ABORT") {
        string why = EQPy_get(loc);
        printf("%s", why) =>
        v = propagate() =>
        c = false;
    }
    else
    {
      data = fromint(toint(result) + 1);
      printf("swift: data: %s", data);
      EQPy_put(loc, data) => c = true;
    }
  }

}

main() {
  printf("WORKFLOW!");

  location L = locationFromRank(1);
  EQPy_init_package(L, algo) =>
  loop(L) =>
  EQPy_stop(L);
}
