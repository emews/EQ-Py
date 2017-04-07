import threading
import sys
import importlib, traceback

EQPY_ABORT = "EQPY_ABORT"

try:
    import queue as q
except ImportError:
    # queue is Queue in python 2
    import Queue as q

input_q = q.Queue()
output_q = q.Queue()

p = None

class ThreadRunner(threading.Thread):

    def __init__(self, runnable):
        threading.Thread.__init__(self)
        self.runnable = runnable
        self.status = None

    def run(self):
        try:
            self.runnable.run()
        except BaseException:
            # tuple of type, value and traceback
            self.status = traceback.format_exc()

def init(pkg):
    global p
    imported_pkg = importlib.import_module(pkg)
    p = ThreadRunner(imported_pkg)
    p.start()

def output_q_get():
    global output_q
    while p.isAlive():
        try:
            result = output_q.get(True, 60)
            break
        except q.Empty:
            pass
    else:
        #lines = traceback.format_exception(p.status[0], p.status[1], p.status[0])
        result = "{}\n{}".format(EQPY_ABORT, p.status)

    return result

def OUT_put(string_params):
    output_q.put(string_params)

def IN_get():
    global input_q
    result = input_q.get()
    return result
