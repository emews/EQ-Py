import files;
import location;
import string;
import python;
import sys;
import io;

int available_ranks = turbine_workers() - size(split(getenv("RESIDENT_WORK_RANKS"), ","));
// printf("available ranks: %d", available_ranks);

location worker_locations[];
foreach rank, i in [0:available_ranks - 1] {
  worker_locations[i] = rank2location(rank);
}

location leader_locations[];
int max_leader_idx = size(hostmapLeaders()) - 1;
foreach rank, i in hostmapLeaders() {
    if (i < max_leader_idx) {
      leader_locations[i] = rank2location(rank);
    }
}

// chunk_idx, total_chunks, step, data_dir
app (file out, file err) app_run_doe_worker(file shfile, int chunk_idx, int total_chunks, int step, string data_dir) {
  "bash" shfile chunk_idx total_chunks step data_dir @stdout=out @stderr=err;
}

app (void o) rmf(string f) {
  "rm" f;
}

(string results[]) dispatch(location locations[], file script_sh, int step, int arg_length, string std_out_dir, string data_dir) {
    int max_node = size(locations);
    int total_chunks = min_integer(max_node, arg_length);
    int max_idx = total_chunks - 1;
    // printf("input_dir: %s", data_dir);
    foreach i in [0:max_idx] {
        string out_fname = "%s/out_%d.txt" % (std_out_dir, i);
        string err_fname = "%s/err_%d.txt" % (std_out_dir, i);
        // printf(out_fname);
        file out <out_fname>;
        file err <err_fname>;
        location l = locations[i];
        string result_f = "%s/result_%d.dill" % (data_dir, i);
        (out,err) = @location=l app_run_doe_worker(script_sh, i, total_chunks, step, data_dir) =>
        results[i] = result_f;
    }
}

(string result[]) run_pymap(string payload[]) {
    // payload: pymap,step,arg_length,rank_type
    file script_sh = input(emews_root + "/ext/eqpy/run_worker.sh");
    string std_out_dir = "%s/pymap" % turbine_output;
    int step = string2int(payload[1]);
    int arg_length = string2int(payload[2]);
    string data_dir = payload[3];
    string rank_type = payload[4];
    if (rank_type == "workers") {
      result = dispatch(worker_locations, script_sh, step, arg_length, std_out_dir, data_dir);
    } else if (rank_type == "leaders") {
      result = dispatch(leader_locations, script_sh, step, arg_length, std_out_dir, data_dir);      
    }
}
