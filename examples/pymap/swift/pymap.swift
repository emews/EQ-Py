import files;
import location;
import string;
import python;
import sys;
import io;


location node_locations[];
foreach rank, i in hostmapLeaders() {
    // printf("hostmap leader rank: %d", rank);
    node_locations[i] = rank2location(rank);
}

// TODO replace this with swift json calls
string doe_input_template = 
"""
import json
vals = json.loads('%s')
print(vals, flush=True)
out_directory = vals['out_d'][0]
""";

app (file out, file err) app_run_doe_worker(file shfile, string input_dir, string output_dir, int num_workers, int worker_id) {
  "bash" shfile input_dir output_dir num_workers worker_id @stdout=out @stderr=err;
}

app (void o) rmf(string f) {
  "rm" f;
}

(string result[]) run_do_emews(string payload[]) {
    file script_sh = input(emews_root + "/ext/doEMEWS/run_worker.sh");
    string std_out_dir = "%s/do_emews" % turbine_output;
    int num_iter = string2int(payload[1]);
    string code = doe_input_template % (payload[2]);
    string worker_input_dir = python_persist(code, "out_directory");
    int max_node = size(node_locations) - 1;
    int max_idx = min_integer(max_node, num_iter);
    // printf("input_dir: %s", worker_input_dir);
    printf("max idx: %d", max_idx);
    foreach i in [1:max_idx] {
        string out_fname = "%s/do_emews_out_%d.txt" % (std_out_dir, i);
        string err_fname = "%s/do_emews_err_%d.txt" % (std_out_dir, i);
        // printf(out_fname);
        file out <out_fname>;
        file err <err_fname>;
        location l = node_locations[i];
        string doe_result_f = "%s/out_%d.rds" % (worker_input_dir, i);
        (out,err) = @location=l app_run_doe_worker(script_sh, worker_input_dir, doe_result_f, max_idx, i) =>
        result[i - 1] = doe_result_f;
    }
}
