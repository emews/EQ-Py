set -eu

# chunk_idx, total_chunks, step, data_dir
CHUNK_IDX=$1
TOTAL_CHUNKS=$2
STEP=$3
DATA_DIR=$4

EQPY_ROOT=$( cd $( dirname $0 ) ; /bin/pwd )
source $EQPY_ROOT/envs/${SITE}_env.sh

echo "Running pymap worker"

python $EQPY_ROOT/emews/worker.py $CHUNK_IDX $TOTAL_CHUNKS $STEP $DATA_DIR

