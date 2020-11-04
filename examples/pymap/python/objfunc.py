from math import sin, cos


def objfunc(args):
    x, y = args
    return sin(4 * x) + sin(4 * y) + -2 * x + x**2 - 2 * y + y**2
