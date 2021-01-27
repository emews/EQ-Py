import sys
import dill
import os
import math


def chunker(li, total_chunks):
    item_count = len(li)
    num_chunks = item_count if total_chunks > item_count else total_chunks
    chunk_size = math.floor(item_count / num_chunks)
    remainder = item_count - (chunk_size * num_chunks)
    used_chunk_size = chunk_size + 1
    r = []
    for i in range(num_chunks):
        cs = used_chunk_size - 1 if i >= remainder else used_chunk_size
        offset = remainder if i >= remainder else 0
        start = i * cs + offset
        end = start + cs
        r.append(li[start : end])
    return r


def run(chunk_idx: int, total_chunks: int, step: int, data_dir: str):
    args_path = os.path.join(data_dir, 'args_{}.dill'.format(step))
    with open(args_path, 'rb') as f_in:
        args = dill.load(f_in)

    func_path = os.path.join(data_dir, 'func_{}.dill'.format(step))
    with open(func_path, 'rb') as f_in:
        func = dill.load(f_in)

    # print('chunk_idx: {}, total_chunks: {}, arg length: {}'.format(chunk_idx, total_chunks, len(args)))

    if total_chunks == 1:
        chunk = args
    else:
        chunk = chunker(args, total_chunks)[chunk_idx]

    result = []
    for arg in chunk:
        result.append(func(*arg))

    result_path = os.path.join(data_dir, 'result_{}.dill'.format(chunk_idx))
    with open(result_path, 'wb') as f_out:
        dill.dump(result, f_out)


if __name__ == "__main__":
    chunk_idx, total_chunks, step, data_dir = sys.argv[1:]
    run(int(chunk_idx), int(total_chunks), int(step), data_dir)
