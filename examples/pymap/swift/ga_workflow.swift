import files;
import string;
import sys;
import io;
import stats;
import python;
import math;
import location;
import assert;
import R;
import unix;
import EQPy;

import covid_model;

string emews_root = getenv("EMEWS_PROJECT_ROOT");
string turbine_output = getenv("TURBINE_OUTPUT");
string resident_work_ranks = getenv("RESIDENT_WORK_RANKS");
string r_ranks[] = split(resident_work_ranks,",");
int procs_per_run = toint(getenv("PROCS_PER_RUN"));

string stop_at = argv("stop_at");
string default_model_props = argv("model_props");

int trials = toint(argv("trials", "5"));
string chicago_deaths_file = argv("chicago_deaths_file");
string chicago_deaths = join(file_lines(input(chicago_deaths_file)), ",");
printf(chicago_deaths);

string strategy = argv("strategy");
string ga_params = argv("ga_params");
float mut_prob = string2float(argv("mutation_prob", "0.2"));
string init_pop_file = argv("init_pop_file", "");
float init_pop_replacement_fraction = string2float(argv("init_pop_replacement_fraction", "0.0"));

string parse_me_out_template = """
import json

vals = json.loads('%s')
duration_after_d10 = (len([%s]) + 2) * 24
# parameters should be a map of the model parameters
# create parameter format string from that
all_params = ''
for p_map in vals:
  instance = p_map.pop('instance')
  d10 = p_map['d10']
  p_map['goto.school.1'] = "{},0,elementary,middle,high,daycare".format(d10 - 240)
  sah_p = p_map['stay.at.home.probability']
  p_map['stay.at.home.1'] = "{},{}".format(d10 - 144, sah_p)
  sba_p = p_map['stoe.behavioral.adjustment.probability']
  p_map['stoe.behavioral.adjustment.1'] = "{},{}".format(d10 - 144, sba_p)
  p_map['stop.at'] = d10 + duration_after_d10

  params = '{}|{}|{}'.format(instance, d10, json.dumps(p_map))  

  if len(all_params) > 0:
    all_params = '{};{}'.format(all_params, params)
  else:
    all_params = params

ret = '{}'.format(all_params)
""";

string r_obj_template = """
source("%s/R/reff_objective.R")
# counts.file,chicago.data
counts_f <- "%s"
print(counts_f)
obj <- dead.counts.error.d10(counts_f, %d, c(%s))
print(obj)
""";

(string result, string log_string) run_model(string param_line, int ga_iter) {
    //printf("param_line: %s", param_line);
    string items[] = split(param_line, "|");
    string instance = "%s/instance_%d" % (turbine_output, toint(items[0]));
    int d10 = toint(items[1]);
    js_params = items[2];
    float results[];
    mkdir(instance) => {
        foreach r in [0:trials - 1: 1] {
            counts_f = "%s/output/counts_r%d.csv" % (instance, r);
            string add_ons = "\"output.directory\" : \"%s\", \"global.random.seed\" : %d,  \"run\" : %d, "  % 
                (instance, (r + 1), r);
            string prefix = substring(js_params, 0, 1);
            string suffix = substring(js_params, 1, strlen(js_params) - 1);
            string p = "%s %s %s" % (prefix, add_ons, suffix);
            @par=procs_per_run covid_model_run(default_model_props, p) =>
            code = r_obj_template % (emews_root, counts_f, d10, chicago_deaths);
            results[r] = tofloat(R(code, "toString(obj)"));
        }
    }

    result = float2string(avg(results));
    log_string = "%s|%d|%s|%s" % (items[0], ga_iter, result, js_params);
}

(string params[]) parse_param_string(string me_out) {
    // printf("param_line: %s", me_out);
    json_code = parse_me_out_template % (me_out, chicago_deaths);
    string ret = python_persist(json_code, "ret");
    // printf("%s", ret);
    params = split(ret, ";");
}

(void v) loop (location ME, int trials) {
    for (boolean b = true, int i = 1;
       b;
       b=c, i = i + 1)
  {
    // gets the model parameters from the python algorithm
    string params =  EQPy_get(ME);
    printf("Received params");
    boolean c;
    if (params == "DONE")
    {
        string finals =  EQPy_get(ME);
        // TODO if appropriate
        // split finals string and join with "\\n"
        // e.g. finals is a ";" separated string and we want each
        // element on its own line:
        // multi_line_finals = join(split(finals, ";"), "\\n");
        string fname = "%s/final_result" % (turbine_output);
        file results_file <fname> = write(finals) =>
        printf("Writing final result to %s", fname) =>
        // printf("Results: %s", finals) =>
        v = make_void() =>
        c = false;

    } else if (params == "EQPY_ABORT") {
        printf("EQPy Aborted");
        string why = EQPy_get(ME);
        // TODO handle the abort if necessary
        // e.g. write intermediate results ...
        printf("%s", why) =>
        v = propagate() =>
        c = false;

    } else {
        param_array = parse_param_string(params);
        string results[];
        string log[];
        foreach p, j in param_array {
            results[j], log[j] = run_model(p, i);
        }

        string res = join(results, ";");
        string fname = "%s/ga_result_%d.csv" % (turbine_output, i);
        file results_file <fname> = write(join(log, "\n") + "\n");        
        EQPy_put(ME, res) => c = true;

        // string res = join(results, ";");
        // //printf("passing %s", res);
        // string fname = "%s/ga_result_%d.csv" % (turbine_output, i);
        // file results_file <fname> = write(join(log, "\n") + "\n");
        // EQPy_put(ME, res) => c = true;

    }
  }
}

(void o) start (int ME_rank, int num_iter, int pop_size, int trials, int seed) {
  location deap_loc = locationFromRank(ME_rank);
  // num_iter, num_pop, seed, strategy, mut_prob, ga_params_file, param_file
  algo_params = "%d,%d,%d,'%s',%f,'%s', '%s', %f" %  (num_iter, pop_size, seed,
                strategy, mut_prob, ga_params, init_pop_file, init_pop_replacement_fraction);

    EQPy_init_package(deap_loc,"deap_ga") =>
    EQPy_get(deap_loc) =>
    EQPy_put(deap_loc, algo_params) =>
      loop(deap_loc, trials) => {
        EQPy_stop(deap_loc);
        o = propagate();
    }
}

main() {

  int random_seed = toint(argv("seed", "0"));
  int num_iter = toint(argv("ni","100")); // -ni=100
  int num_variations = toint(argv("nv", "5"));
  int num_pop = toint(argv("np","100")); // -np=100;

  printf("NI: %i # num_iter", num_iter);
  printf("NV: %i # num_variations", num_variations);
  printf("NP: %i # num_pop", num_pop);
  printf("MUTPB: %f # mut_prob", mut_prob);

  // PYTHONPATH needs to be set for python code to be run
  assert(strlen(getenv("PYTHONPATH")) > 0, "Set PYTHONPATH!");
  assert(strlen(emews_root) > 0, "Set EMEWS_PROJECT_ROOT!");

  int rank = string2int(r_ranks[0]);
  start(rank, num_iter, num_pop, num_variations, random_seed);
}
