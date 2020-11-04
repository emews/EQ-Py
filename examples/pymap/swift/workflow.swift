import io;
import sys;
import files;
import location;
import string;
import EQPy;
import R;
import assert;
import python;
import unix;
import stats;
import PyMap;

string emews_root = getenv("EMEWS_PROJECT_ROOT");
string turbine_output = getenv("TURBINE_OUTPUT");
string resident_work_ranks = getenv("RESIDENT_WORK_RANKS");
string r_ranks[] = split(resident_work_ranks,",");
string algo_params = argv("algo_params");


(void v) loop(location ME) {
    for (boolean b = true, int i = 1;
       b;
       b=c, i = i + 1)
    {
        string payload_str =  EQPy_get(ME);
        // printf(payload_str);
        string payload[] = split(payload_str, "|");
        string payload_type = payload[0];
        boolean c;

        if (payload_type == "DONE") {
            string finals =  EQPy_get(ME);
            // multi_line_finals = join(split(finals, ";"), "\\n");
            //   string fname = "%s/final_result_%i" % (turbine_output, ME_rank);
            //   file results_file <fname> = write(finals) =>
            //   printf("Writing final result to %s", fname) =>
            printf("Results: %s", finals) =>
            v = make_void() =>
            c = false;

        } else if (payload_type == "EQPY_ABORT") {
            printf("EQPy aborted: see output for error") =>
            string why = EQPy_get(ME);
            printf("%s", why) =>
            v = propagate() =>
            c = false;
        } else if (payload_type == "pymap") {
            string pymap_result[] = run_pymap(payload); 
            EQPy_put(ME, join(pymap_result, ";")) => c = true;
        }
    }
}


(void o) start (int ME_rank) {
  location deap_loc = locationFromRank(ME_rank);
    EQPy_init_package(deap_loc,"deap_ga") =>
    EQPy_get(deap_loc) =>
    EQPy_put(deap_loc, algo_params) =>
      loop(deap_loc) => {
        EQPy_stop(deap_loc);
        o = propagate();
    }
}

// deletes the specified directory
app (void o) rm_dir(string dirname) {
    "rm" "-rf" dirname;
}

main() {

    assert(strlen(emews_root) > 0, "Set EMEWS_PROJECT_ROOT!");

    int ME_ranks[];
    foreach r_rank, i in r_ranks {
      ME_ranks[i] = toint(r_rank);
    }

    foreach ME_rank, i in ME_ranks {
    start(ME_rank) =>
        printf("End rank: %d", ME_rank);
    }
}
