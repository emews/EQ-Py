
/**
   EMEWS workflow.swift
*/

import assert;
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
handshake(string settings_filename)
{
  message = EQPy_get(GA) =>
    v = EQPy_put(GA, settings_filename);
  assert(message == "Settings", "Error in handshake.");
}

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

settings_filename = argv("settings");

EQPy_init_package(GA, "deap_ga") =>
  handshake(settings_filename) =>
  loop(N) =>
  EQPy_stop(GA);
