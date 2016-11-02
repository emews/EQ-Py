
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

# Global settings
num_iter = num_pop = sigma = mate_pb = mutate_pb = None

def i2s(i):
    """ Convert individual to string """
    return "[%0.3f,%0.3f]" % (i[0], i[1])

def obj_func(x):
    """ Dummy function for compatibility with DEAP """
    assert(False)

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
    split_result = result.split(';')
    return [(float(x),) for x in split_result]

def mutate_Gaussian_float(x):
    global sigma
    x += random.gauss(0, sigma)
    return x

# Returns a tuple of one individual
def custom_mutate(individual, indpb):
    old_individual = i2s(individual)
    for i,m in enumerate(individual):
        individual[i] = mutate_Gaussian_float(individual[i])
    print("mutate: %s to: %s" % (old_individual, i2s(individual)))
    return individual,

def read_in_params_csv(csv_file_name):
    return pd.read_csv(csv_file_name)

def cxUniform(ind1, ind2, indpb):
    c1, c2 = tools.cxUniform(ind1, ind2, indpb)
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
    toolbox.register("attr_float", random.random)
    toolbox.register("individual", tools.initRepeat, creator.Individual,
                     toolbox.attr_float, n=2)

    toolbox.register("population", tools.initRepeat, list, toolbox.individual)
    toolbox.register("evaluate", obj_func)
    toolbox.register("mate", cxUniform, indpb=mate_pb)
    toolbox.register("mutate", custom_mutate, indpb=mutate_pb)
    toolbox.register("select", tools.selTournament, tournsize=3)
    toolbox.register("map", queue_map)

    pop = toolbox.population(n=num_pop)
    hof = tools.HallOfFame(2)
    stats = tools.Statistics(lambda ind: ind.fitness.values)
    stats.register("avg", np.mean)
    stats.register("std", np.std)
    stats.register("min", np.min)
    stats.register("max", np.max)

    # num_iter-1 generations since the initial population is evaluated once first
    pop, log = algorithms.eaSimple(pop, toolbox, cxpb=0.5, mutpb=mutate_pb,
                                   ngen=num_iter - 1,
                                   stats=stats, halloffame=hof, verbose=True)

    fitnesses = [str(p.fitness.values[0]) for p in pop]

    eqpy.OUT_put("FINAL")
    # return the final population
    eqpy.OUT_put("{0}\n{1}\n{2}".format(create_list_of_lists_string(pop), ';'.join(fitnesses), log))

def load_settings(settings_filename):
    global num_iter, num_pop, sigma, mate_pb, mutate_pb
    print("Reading settings: '%s'" % settings_filename)
    with open(settings_filename) as fp:
        settings = json.load(fp)
    try:
        seed         = settings["seed"]
        num_iter     = settings["num_iter"]
        num_pop      = settings["num_pop"]
        sigma        = settings["sigma"]
        mate_pb      = settings["mate_pb"]
        mutate_pb    = settings["mutate_pb"]
        crossover_pb = settings["crossover_pb"]
    except KeyError as e:
        print("Settings file (%s) does not contain key: %s" % (settings_filename, str(e)))
        sys.exit(1)
    print "num_iter: ", num_iter
    random.seed(seed)
    print("Settings loaded.")
