# Tests the python without swift. This is
# useful for making sure that the eqpy works
# under python 2.7 and 3

from __future__ import print_function

import eqpy, sys

def main():
    print(sys.version)
    eqpy.init("algorithm")

    while True:
        result = eqpy.output_q_get()
        print("test received: {}".format(result))
        if result == "FINAL":
            break
        else:
            eqpy.input_q.put(str(int(result) + 1))

    print("Done")


if __name__ == '__main__':
    main()
