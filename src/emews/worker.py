import sys
import dill
import os
import math


def chunker(vals: list, chunk_size: int):
    # For item i in a range that is a length of l,
    for i in range(0, len(vals), chunk_size):
        # Create an index range for l of n items:
        yield vals[i:i + chunk_size]


def run(chunk_idx: int, total_chunks: int, step: int, data_dir: str):
    args_path = os.path.join(data_dir, 'args_{}.dill'.format(step))
    with open(args_path, 'rb') as f_in:
        args = dill.load(f_in)

    func_path = os.path.join(data_dir, 'func_{}.dill'.format(step))
    with open(func_path, 'rb') as f_in:
        func = dill.load(f_in)

    if total_chunks == 1:
        chunk = args
    else:
        chunk_size = math.ceil(len(args) / total_chunks)
        chunk = list(chunker(args, chunk_size))[chunk_idx]

    result = []
    for arg in chunk:
        result.append(func(arg))

    result_path = os.path.join(data_dir, 'result_{}.dill'.format(chunk_idx))
    with open(result_path, 'wb') as f_out:
        dill.dump(result, f_out)


if __name__ == "__main__":
    chunk_idx, total_chunks, step, data_dir = sys.argv[1:]
    run(int(chunk_idx), int(total_chunks), int(step), data_dir)
