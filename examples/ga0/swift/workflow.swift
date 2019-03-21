
/**
   EMEWS workflow.swift
*/

import assert;
import io;
import location;
import python;
import string;
import sys;

import EQPy;

N = 10;

/** The objective function */
(string result)
task(string params)
{
  result = python(
"""
from math import sin,cos
x,y=%s
result = sin(4*x)+sin(4*y)+-2*x+x**2-2*y+y**2
""" % params,
"repr(result)"
  );
}

location L = locationFromRank(turbine_workers()-1);

(void v)
handshake(string settings_filename)
{
  message = EQPy_get(L) =>
    v = EQPy_put(L, settings_filename);
  assert(message == "Settings", "Error in handshake.");
}

(void v)
loop(int N)
{
  for (boolean b = true;
       b;
       b=c)
  {
    message = EQPy_get(L);
    // printf("swift: message: %s", message);
    boolean c;
    if (message == "FINAL")
    {
      printf("Swift: FINAL") =>
        v = make_void() =>
        c = false;
      finals = EQPy_get(L);
      printf("Swift: finals: %s", finals);
    }
    else
    {
      string params[] = split(message, ";");
      string results[];
      foreach p,i in params
      {
        results[i] = task(p);
      }
      result = join(results, ";");
      // printf("swift: result: %s", result);
      EQPy_put(L, result) => c = true;
    }
  }

}

settings_filename = argv("settings");

printf("SWIFT WORKFLOW STARTING...")=>
  EQPy_init_package(L, "algorithm") =>
  handshake(settings_filename) =>
  loop(N) =>
  EQPy_stop(L) =>
  printf("SWIFT WORKFLOW COMPLETE");
