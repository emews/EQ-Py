import unittest
import sys
import os
import traceback

sys.path.append("{}/../src".format(os.path.dirname(os.path.abspath(__file__))))

from emews import eqpy, Pool, worker


current_test = None


# proxy for the ME
def run():
    if isinstance(current_test, EQPYTest):
        run1()
    else:
        run2()


def run1():
    eqpy.OUT_put("1")
    msg = eqpy.IN_get()
    current_test.assertEqual("2", msg)
    eqpy.OUT_put("33")
    msg = eqpy.IN_get()
    current_test.assertEqual("34", msg)
    eqpy.OUT_put("FINAL")


def m2(a):
    return a[0] * a[1]


def run2():
    p = Pool("/tmp")
    args = [(2, 4), (10, 7), (12, 3), (1, 10), (0, 5)]
    result = p.map(m2, args)
    expected = [8, 70, 36, 10, 0]
    current_test.assertEqual(expected, result)
    # traceback.print_tb(result[1][2], limit=1, file=sys.stdout)
    eqpy.OUT_put("FINAL")


class EQPYTest(unittest.TestCase):

    def test_eqpy(self):
        global current_test
        current_test = self
        eqpy.init("tests.emews_tests")
        # this is a proxy for the swift-t loop 
        # EQPy_get is eqpy.output_q_get()
        exp = ["1", "33", "FINAL"]
        i = 0
        while True:
            msg = eqpy.output_q_get()
            self.assertEqual(exp[i], msg)
            i += 1
            if msg == "FINAL":
                break
            else:
                eqpy.input_q.put(str(int(msg) + 1))


class PoolTest(unittest.TestCase):

    def test_pool(self):
        global current_test
        current_test = self
        eqpy.init("tests.emews_tests")

        while True:
            msg = eqpy.output_q_get()
            if msg == "FINAL":
                break

            self.assertEqual("pymap|1|5|/tmp", msg)
            vals = msg.split('|')
            step = int(vals[1])
            data_dir = vals[3]
            self.assertTrue(os.path.exists('{}/func_{}.dill'.format(data_dir, step)))
            self.assertTrue(os.path.exists('{}/args_{}.dill'.format(data_dir, step)))

            # run 3 workers
            for i in range(3):
                # chunk_idx: int, total_chunks: int, step: int, data_dir: str
                worker.run(i, 3, step, data_dir)
            
            result = "{}/result_0.dill;{}/result_1.dill;{}/result_2.dill".format(data_dir,
                data_dir, data_dir)

            eqpy.input_q.put(result)
