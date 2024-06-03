#!/usr/bin/env python3
"""
Compute angles of the sun above the horizon for different latitudes and different seasons.

.. todo::

   * docstrings
   * execute
"""
import venv_autouse.file

from math import pi
import numpy as np
import matplotlib.pyplot as plt
import argparse
import logging


class SunAngles:
    """
    Compute and display angles of the sun.
    """
    XLIM_MIN = 0  # [h]
    XLIM_MAX = 24  # [h]

    XTICK_MAJOR_STEP = 2  # [h]
    XTICK_MINOR_STEP = 1  # [h]

    YLIM_MIN = 0  # [deg]
    YLIM_MAX = 90  # [deg]

    YTICK_MAJOR_STEP = 30  # [deg]
    YTICK_MINOR_STEP = 15  # [deg]

    ALPHA0 = 23  # [deg]

    SINGLE_LATITUDE_DEFAULT = [45]
    MAIN_LATITUDES = [
        0,  # equator
        ALPHA0,  # tropical
        30,
        45,
        60,
        90 - ALPHA0,  # polar circle
        80,  # to show progression to pole
        90  # last
    ]

    MAIN_SEASONS = [-1, 0, 1]
    TEXT_SEASONS = {
        1: 'summer',
        0: 'equinoxe',
        -1: 'winter',
    }

    SINGLE_SEASON = [0]

    ANGLE_BY_HOUR = pi / 12  # 2pi/24

    NUMBER_OF_POINTS = 120  # 5 per hour
    HOURS_A_DAY = 24

    DAWN_ANGLE = -6  # [deg]  -6 civil -12 nautical -18 astronomical

    def __init__(self, args: object):
        self._log = logging.getLogger(self.__class__.__name__)

        self._filename = args.filename
        EXT = '.svg'
        if not self._filename.endswith(EXT):
            self._filename += EXT

        # Prepare figure
        #with plt.xkcd():  # fun but less readable
        self._fig = plt.figure()

        self._axObj = self._fig.gca()

        self._axObj.set_xlim(self.XLIM_MIN, self.XLIM_MAX)
        self._axObj.set_ylim(self.YLIM_MIN, self.YLIM_MAX)

        self._axObj.set_xticks(np.arange(self.XLIM_MIN, self.XLIM_MAX + 1, step=self.XTICK_MAJOR_STEP))
        self._axObj.set_xticks(np.arange(self.XLIM_MIN, self.XLIM_MAX + 1, step=self.XTICK_MINOR_STEP), minor=True)

        self._axObj.set_yticks(np.arange(self.YLIM_MIN, self.YLIM_MAX + 1, step=self.YTICK_MAJOR_STEP))
        self._axObj.set_yticks(np.arange(self.YLIM_MIN, self.YLIM_MAX + 1, step=self.YTICK_MINOR_STEP), minor=True)

        self._axObj.set_xlabel('Hour of the day')
        self._axObj.set_ylabel('Angle above horizon')

        self._axObj.grid(which='both')

        self._colorIndex = 0

        self._latitudes = []
        self._seasons = []

        if args.latitudes is not None:
            for latitude in args.latitudes:
                self._latitudes.append(float(latitude))

        else:
            self._latitudes = self.MAIN_LATITUDES

            if args.doDefaultSeasons:
                self._latitudes = self.SINGLE_LATITUDE_DEFAULT

            if args.appendLatitudes:
                for latitude in args.appendLatitudes:
                    latitude = float(latitude)
                    if latitude not in self._latitudes:
                        self._latitudes.append(latitude)

                self._latitudes.sort()

        if args.seasons is not None:
            for season in args.seasons:
                self._seasons.append(int(season))

        else:
            self._seasons = self.SINGLE_SEASON

            if args.doDefaultSeasons or args.allSeasons:
                self._seasons = self.MAIN_SEASONS

        if len(self._latitudes) < 1 or len(self._seasons) < 1:
            raise ValueError('Not enough data to make a comparison')

        self._log.info('\n\nWelcome to the calculator of angles of the Sun!\n')
        self._log.info('Saving to: {}'.format(self._filename))

        self._log.info('latitudes: {}'.format(self._latitudes))
        self._log.info('seasons: {}'.format(self._seasons))

    def theta(self, t: np.array, latitude: float, season: int) -> np.array:
        """
        Compute angle of the sun with respect to horizon [-90, 90].

        https://uweb.engr.arizona.edu/~ece414a/Sun.pdf

        All inputs and outputs of this method are in [deg].
        """
        noon = 12

        radLatitude = np.deg2rad(latitude)

        declination = np.deg2rad(self.ALPHA0 * np.sign(season))

        hourAngleFromSolarNoon = self.ANGLE_BY_HOUR * (t - noon)

        return np.rad2deg(
            np.arcsin(
                np.sin(declination) * np.sin(radLatitude)
                + np.cos(declination) * np.cos(radLatitude) * np.cos(hourAngleFromSolarNoon)
            )
        )

    def reverseTheta(self, theta: float, latitude: float, season: int) -> float:
        """
        Compute the time with respect to noon at which the sun is at the provided angle.
        """
        radLatitude = np.deg2rad(latitude)

        declination = np.deg2rad(self.ALPHA0 * np.sign(season))

        sinTheta = np.sin(np.deg2rad(theta))

        cosTime = (sinTheta - np.sin(declination) * np.sin(radLatitude)) / (np.cos(declination) * np.cos(radLatitude))

        if abs(cosTime) > 1:
            # No dawn for this case
            return None

        hourFromSolarNoon = np.arccos(cosTime) / self.ANGLE_BY_HOUR

        return hourFromSolarNoon

    def _onePlot(self, latitude: float, season: int) -> None:
        """
        Plot a single dataset.
        """
        legend = '{} @ {}deg'.format(self.TEXT_SEASONS[season], latitude)
        if latitude < 0:
            legend = '{} @ {}deg'.format(self.TEXT_SEASONS[-season], latitude)

        t = np.array(range(self.HOURS_A_DAY * self.NUMBER_OF_POINTS)) / self.NUMBER_OF_POINTS

        self._colorIndex += 1

        self._axObj.plot(t, self.theta(t, latitude, season), 'C{}'.format(self._colorIndex), label=legend)

        # Also plot astronomical dust/dawn
        tDayNight = self.reverseTheta(self.DAWN_ANGLE, latitude, season)

        if tDayNight is None:
            # No dawn for this case
            return

        noon = 12
        displayAngle = 1  # [deg]

        self._axObj.plot(
            [noon - tDayNight, noon + tDayNight],
            [displayAngle] * 2,
            'C{}'.format(self._colorIndex),
            marker='o',
            linestyle='',
        )

    def _finishPlot(self) -> None:
        """
        Save the figure and show it.
        """
        self._axObj.legend(loc='upper left')
        self._fig.savefig(self._filename)
        plt.show()
        plt.close(self._fig)

    def run(self) -> None:
        """
        Plot all the data.
        """
        for season in self._seasons:
            for latitude in self._latitudes:
                self._onePlot(latitude, season)

        self._finishPlot()


def main():
    logging.basicConfig(level=logging.INFO)

    parser = argparse.ArgumentParser()

    parser.add_argument(
        dest='filename',
        help='filename to store the plot into'
    )

    parser.add_argument(
        '-l',
        '--latitudes',
        nargs='*',
        default=None,
        help='the latitude you want to compare'
    )

    parser.add_argument(
        '-s',
        '--seasons',
        nargs='*',
        default=None,
        #choices=SunAngles.MAIN_SEASONS,  # not working smoothly
        help='the season of the year at which you want the plot (0 or +/-1)'
    )

    parser.add_argument(
        '--doDefaultSeasons',
        default=False,
        action='store_true',
        help='to plot one latitude at equinoxe and solstices'
    )

    parser.add_argument(
        '-a',
        '--allSeasons',
        action='store_true',
        default=False,
        help='plot all seasons for the provided latitudes'
    )

    parser.add_argument(
        '--appendLatitudes',
        nargs='*',
        default=None,
        help='latitudes to append to the default list'
    )

    args = parser.parse_args()
    computer = SunAngles(args)
    computer.run()


if __name__ == '__main__':
    main()

