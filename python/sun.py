#!/usr/bin/env python3
import numpy as np
import matplotlib.pyplot as plt
import argparse


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        '-l',
        '--latitudes',
        nargs='*',
        default=None,
        help='the latitude you want to compare'
    )
    parser.add_argument(
        '-t',
        '--time',
        default=0,
        choices=[-1, 0, 1],
        help='the time of the year at which you want the plot'
    )
    parser.add_argument(
        '-m',
        '--month',
        default=False,
        action='store_true',
        help='to plot one latitude at equinoxe and solstices'
    )
    args = parser.parse_args()
    raise NotImplementedError('time and latitudes must be mutually exclusive')
    args = welcome(args)
    run(args)


def welcome(args):
    print(' ')
    print('Welcome to the calculator of angles of the Sun!')
    if args.latitudes is None or args.time is None:
        print('What would you like to see?')
        print('1: different latitudes at the equinoxe')
        print('2: the same latitude at the equinoxe and at the solstices')
        choice = input('your choice: [2]  ')
        if int(choice) == 1:
            latitudes = input('Which latitudes are you interested in?  ')
            args.latitudes = np.array(map(float, latitudes.split()))
        else:
            latitude = input('Which latitude do you want?  ')
            args.latitudes = np.array([float(latitude)])
    return args


def run(args):
    mainLatitudes = np.array([0, 23, 30, 45, 60, 90 - 23, 90])
    mainMonths = np.array([0])
    if args.month:
        mainLatitudes = np.array([45])
        mainMonths = np.array([-1, 0, 1])
    if args.latitudes is not None:
        if args.latitude[0] == -1:
            mainLatitudes = np.array(args.latitudes)
        else:
            for lat in args.latitudes:
                if lat not in mainLatitudes:
                    mainLatitudes.append(lat)
    if args.time is not None:
        mainMonths = np.array([args.time])
    if len(mainLatitudes) <= 1 >= len(mainMonths):
        raise ValueError('not enough data to compare')
    if len(mainMonths) > 1 < len(mainLatitudes):
        raise ValueError('Cannot compare more than 1 latitude at different months')
    if len(mainLatitudes) > len(mainMonths):
        pass
    else:
        pass


def declination(months):
    alpha0 = 23
    return alpha0 * np.sign(months)


def theta(t, latitudes, months):
    return np.asin(np.sin(declination(months)) * np.sin(latitudes)
                   + np.cos(declination(months)) * np.cos(latitudes) * np.cos(pi / 12 * (t - 12)))
    ## HRA -pi to pi instead of t 0 to 24


def initPlot():
    fig = plt.figure()
    axObj = fig.gca()
    axObj.ylim(-pi / 2.0, pi / 2.0)
    axObj.xlim(0, 24)
    return {'fig': fig, 'axObj': axObj}


def onePlot(axObj, latitude, month):
    N = 250
    t = np.array(range(24 * N)) / N
    axObj.plot(t, theta(t, latitude, month))


def finishPlot(fig, filename):
    fig.savefig(filename)
    plt.show()


def doPlot(latitudes, months):
    filename = 'fig'
    init = initPlot()
    for lat in latitudes:
        for month in months:
            onePlot(init['axObj'], latitude, month)
    finishPlot(init['fig'], filename)

