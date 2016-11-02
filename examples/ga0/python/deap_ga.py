
# GA0 DEAP_GA

import json
import math
import numpy as np
import random
import sys
import threading
import time

from deap import base
from deap import creator
from deap import tools
from deap import algorithms

import eqpy

df_params = None

def obj_func(x):
    return 0

def create_list_of_lists_string(list_of_lists, super_delim=";", sub_delim=","):
    # super list elements separated by ;
    res = []
    for x in list_of_lists:
        res.append(sub_delim.join(str(n) for n in x))
    return (super_delim.join(res))

def create_fitnesses(params_string):
    """return equivalent length tuple list
    :type params_string: str
    """
    params = params_string.split(";")
    # get length
    res = [(i,) for i in range(len(params))]
    return (res)

def queue_map(obj_func, pops):
    # Note that the obj_func is not used
    # sending data that looks like:
    # [[a,b,c,d],[e,f,g,h],...]
    if not pops:
        return []
    eqpy.OUT_put(create_list_of_lists_string(pops))
    result = eqpy.IN_get()
    split_result = result.split(',')
    return [(float(x),) for x in split_result]

def make_random_params():
    """Iterate through df_params dataframe and return uniform
    draws from lo_val to hi_val for each parameter"""
    global df_params
    while True:
        l = []
        d = {"int":random.randint,"float":random.uniform}
        for ix, i in df_params.iterrows():
            if i['p_type'] == 'log':
                l.append(math.pow(10, random.uniform(i['lo_val'], i['hi_val'])))
            else:
                l.append(d[i['p_type']](i['lo_val'], i['hi_val']))
        if l[1] * l[2] * l[3] < 5000:
            break

    return l

def mutGaussian_int(x, mu, sigma, mi, mx, indpb):
    if random.random() < indpb:
        x += random.gauss(mu, sigma)
        x = int(max(mi, min(mx, round(x))))
    return x

def mutGaussian_float(x, mu, sigma, mi, mx, indpb):
    if random.random() < indpb:
        x += random.gauss(mu, sigma)
        x = max(mi, min(mx, x))
    return x

def mutGaussian_log(x, mu, sigma, mi, mx, indpb):
    if random.random() < indpb:
        logx = math.log10(x)
        logx += random.gauss(mu, sigma)
        logx = max(mi, min(mx, logx))
        x = math.pow(10, logx)
    return x

# Returns a tuple of one individual
def custom_mutate(individual, indpb):
    global df_params
    tmp_list = list(individual)
    while True:
        for i, m in enumerate(individual):
            row = df_params.iloc[i]
            mi = row.lo_val
            mx = row.hi_val
            sigma = row.sigma
            if row.p_type == 'int':
                f = mutGaussian_int
            elif row.p_type == 'float':
                f = mutGaussian_float
            else:
                f = mutGaussian_log
            individual[i] = f(tmp_list[i], mu=0, sigma=sigma, mi=mi, mx=mx, indpb=indpb)

        if  individual[1] * individual[2] * individual[3] < 5000:
            break
    return individual,

def read_in_params_csv(csv_file_name):
    return pd.read_csv(csv_file_name)

def cxUniform(ind1, ind2, indpb):
    c1 = c2 = None
    while True:
        c1, c2 = tools.cxUniform(ind1, ind2, indpb)
        if c1[1] * c1[2] * c1[3] < 5000 and c2[1] * c2[2] * c2[3] < 5000:
            break

    return (c1, c2)

def run():
    """
    :param num_iter: number of generations
    :param num_pop: size of population
    :param seed: random seed
    :param csv_file_name: csv file name (e.g., "params_for_deap.csv")
    """

    eqpy.OUT_put("Settings")
    settings_filename = eqpy.IN_get()
    load_settings(settings_filename)

    # parse settings # num_iter, num_pop, seed,


    creator.create("FitnessMin", base.Fitness, weights=(-1.0,))
    creator.create("Individual", list, fitness=creator.FitnessMin)
    toolbox = base.Toolbox()
    toolbox.register("individual", tools.initIterate, creator.Individual,
                     make_random_params)

    toolbox.register("population", tools.initRepeat, list, toolbox.individual)
    toolbox.register("evaluate", obj_func)
    toolbox.register("mate", cxUniform, indpb=0.5)
    toolbox.register("mutate", custom_mutate, indpb=0.5)
    toolbox.register("select", tools.selTournament, tournsize=3)
    toolbox.register("map", queue_map)

    pop = toolbox.population(n=num_pop)
    hof = tools.HallOfFame(1)
    stats = tools.Statistics(lambda ind: ind.fitness.values)
    stats.register("avg", np.mean)
    stats.register("std", np.std)
    stats.register("min", np.min)
    stats.register("max", np.max)

    # num_iter-1 generations since the initial population is evaluated once first
    pop, log = algorithms.eaSimple(pop, toolbox, cxpb=0.5, mutpb=0.2, ngen=num_iter - 1,
                                   stats=stats, halloffame=hof, verbose=True)

    fitnesses = [str(p.fitness.values[0]) for p in pop]

    eqpy.OUT_put("FINAL")
    # return the final population
    eqpy.OUT_put("{0}\n{1}\n{2}".format(create_list_of_lists_string(pop), ';'.join(fitnesses), log))

def load_settings(settings_filename):
    global num_iter, num_pop
    print("Reading settings: '%s'" % settings_filename)
    with open(settings_filename) as fp:
        settings = json.load(fp)
    try:
        seed     = settings["seed"]
        num_iter = settings["num_iter"]
        num_pop  = settings["num_pop"]
    except KeyError as e:
        print("Settings file (%s) does not contain key: %s" % (settings_filename, str(e)))
        sys.exit(1)
    random.seed(seed)
    print("Settings loaded.")
