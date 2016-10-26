
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

string tproot = getenv("T_PROJECT_ROOT");
location L = locationFromRank(1);
location W = locationFromRank(0);

(void v) loop()
{
  printf("Beginning loop.");
  for (boolean b = true, int i = 1;
       b;
       b=c, i = i + 1)
  {
    result = EQPy_get(L);
    printf("swift: result: %s", result);
    boolean c;
    if (result == "FINAL")
    {
      printf("setting void") =>
        v = propagate() =>
        c = false;
    }
    else
    {
      data = fromint(toint(result) + 1);
      printf("swift: data: %s", data);
      EQPy_put(L, data) => c = true;
    }
  }

}

printf("WORKFLOW!");

EQPy_init_package(L, "algorithm") =>
  loop() =>
  EQPy_stop(L);
