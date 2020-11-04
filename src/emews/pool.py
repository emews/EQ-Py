import dill
import os
import sys

from .eqpy import IN_get, OUT_put


class Pool:

    def __init__(self, tmp_dir: str, rank_type: str="workers", clean_tmp: bool=False):
        self.tmp_dir = tmp_dir
        self.clean_tmp = clean_tmp
        self.step = 1
        self.rank_type = rank_type
        if rank_type not in ['workers', 'leaders']:
            raise ValueError("rank_type must be one of 'workers' or 'leaders'")

        if not os.path.exists(tmp_dir):
            os.makedirs(tmp_dir)

    def __read_result(self, fname):
        r = None
        with open(fname, 'rb') as f_in:
            r = dill.load(f_in)
        return r

    def map(self, func, args: list) -> list:
        try:
            func_f = os.path.join(self.tmp_dir, 'func_{}.dill'.format(self.step))
            with open(func_f, 'wb') as f_out:
                dill.dump(func, f_out)

            args_f = os.path.join(self.tmp_dir, 'args_{}.dill'.format(self.step))
            with open(args_f, 'wb') as f_out:
                dill.dump(args, f_out)

            cmd = 'pymap|{}|{}|{}|{}'.format(self.step, len(args), self.tmp_dir, self.rank_type)
            OUT_put(cmd)

            result = IN_get()
            self.step += 1
            # result is semicolon delimited list of dilled files
            results = result.split(';')
            lists = [self.__read_result(x) for x in results]
            return [y for x in lists for y in x]
        except Exception:
            # exc_type, exc_value, exc_traceback
            exc_info = sys.exc_info()
            # see https://docs.python.org/3.8/library/traceback.html#traceback-examples
            # for how to use the exc_info to create stack trace
            return ["FAILURE", exc_info]

