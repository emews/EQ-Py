import eqpy, algorithm, threading
import time, queue

def main():
    eqpy.init("algorithm")

    while (True):
        result = eqpy.output_q_get()
        print(result)
        if (result == "FINAL"):
            break
        eqpy.input_q.put(str(int(result) + 1))

if __name__ == '__main__':
    main()
