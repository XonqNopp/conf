#!/usr/bin/env python3
"""
Compute angles of the sun above the horizon for different latitudes and different seasons.

.. todo::

   * make classes
   * docstrings
   * execute
"""
from math import pi
import numpy as np
import matplotlib.pyplot as plt
import argparse


class SunAngles:
    """
    Compute and display angles of the sun.
    """
    XLIM_MIN = 0  # [h]
    XLIM_MAX = 24  # [h]

    YLIM_MIN = -pi / 2.0
    YLIM_MAX = pi / 2.0

    ALPHA0 = 23  # [deg]

    def __init__(self, filename: str, latitudes: list = None, season: list = None):
        self._filename = filename

        self._fig = plt.figure()

        self._axObj = self._fig.gca()
        self._axObj.xlim(self.XLIM_MIN, self.XLIM_MAX)
        self._axObj.ylim(self.YLIM_MIN, self.YLIM_MAX)

        self._latitudes = latitudes
        self._season = season

        print(' ')
        print('Welcome to the calculator of angles of the Sun!')

        # FIXME check
        if self._latitudes is None or self._season is None:
            print('What would you like to see?')
            print('1: different latitudes at the equinoxe')
            print('2: the same latitude at the equinoxe and at the solstices')
            choice = input('your choice: [2]  ')
            if int(choice) == 1:
                latitudes = input('Which latitudes are you interested in?  ')
                self._latitudes = np.array(map(float, latitudes.split()))
            else:
                latitude = input('Which latitude do you want?  ')
                self._latitudes = np.array([float(latitude)])

    def _onePlot(self, latitude, month):
        N = 250
        t = np.array(range(24 * N)) / N
        self._axObj.plot(t, self.theta(t, latitude, month))

    def _finishPlot(self):
        self._fig.savefig(self._filename)
        plt.show()

    def plot(self, latitudes, months):
        for latitude in latitudes:
            for month in months:
                self._onePlot(latitude, month)
        self._finishPlot()

    def declination(self, months):
        return self.ALPHA0 * np.sign(months)

    def theta(self, t, latitudes, months):
        ## HRA -pi to pi instead of t 0 to 24
        # FIXME 12=?
        return np.asin(np.sin(self.declination(months)) * np.sin(latitudes)
                       + np.cos(self.declination(months)) * np.cos(latitudes) * np.cos(pi / 12 * (t - 12)))

    def run(self, args):
        mainLatitudes = np.array([0, self.ALPHA0, 30, 45, 60, 90 - self.ALPHA0, 90])
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
    raise NotImplementedError  # FIXME
    computer = SunAngles()
    computer.run()


if __name__ == '__main__':
    main()

