
/**
   workflow.swift
*/

import io;
import location;
import string;
import sys;

import EQPy;

N = 10;

(string result)
task(string params)
"task" "0.1"
[ "set <<result>> [ task <<params>> ]" ];

location GA = locationFromRank(0);

(void v)
loop(int N)
{
  for (boolean b = true;
       b;
       b=c)
  {
    message = EQPy_get(GA);
    // printf("swift: message: %s", message);
    boolean c;
    if (message == "COMPLETE")
    {
      printf("setting void") =>
        v = make_void() =>
        c = false;
    }
    else
    {
      string params[] = split(message, ";");
      string results[];
      foreach p,i in params
      {
        t = task(p);
        results[i] = p+"-> "+t;
      }
      result = join(results, ";");
      // printf("swift: result: %s", result);
      EQPy_put(GA, result) => c = true;
    }
  }

}

EQPy_init_package(GA, "deap_ga") =>
  loop(N) =>
  EQPy_stop(GA);
