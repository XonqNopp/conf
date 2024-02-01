#!/usr/bin/env python3
"""
Rename files (mainly pictures from smartphone) with timestamp.
"""
# pylint: disable=[logging-fstring-interpolation]
import os
import shutil
import logging
from datetime import datetime
from argparse import ArgumentParser
from pathlib import Path
from PIL import Image  # pylint: disable=[import-error]


today = datetime(2023, 12, 6).timestamp()


VID_EXT = ["mov", "mp4", "m4v"]
DEL_EXT = ["aae"]


def get_creation_date_from_exif(file_path: Path):
    """
    Get creation date of the picture from the EXIF data if possible.
    """
    # TODO not fully working
    return os.stat(file_path).st_birthtime

    try:
        with Image.open(file_path) as img:
            # Extract creation date from EXIF data
            exif_info = img._getexif()  # pylint: disable=[protected-access]

        creation_date = exif_info.get(36867)  # 36867 corresponds to the DateTimeOriginal tag

        if creation_date:
            # Convert the creation date to a datetime object
            return datetime.strptime(creation_date, "%Y:%m:%d %H:%M:%S")

    except (AttributeError, KeyError, IndexError, IOError):
        pass

    # If not found, use file creation date
    return os.stat(file_path).st_birthtime


def rename_files_with_timestamp(verbose: int, dryrun: bool, directories: list, subdirs: bool):
    """
    Rename the file.

    Args:
        directories (list): directories to go through
    """
    for directory_path in directories:
        directory = Path(directory_path)
        logging.debug(f'{directory=}')

        for file_path in directory.iterdir():
            logging.debug(f'{file_path=}')
            filename = file_path.name

            # Check if the path is a file and not a directory
            if not file_path.is_file():
                logging.debug(f'Skipping directory {file_path}')
                continue

            if len(filename) > 13:  # TODO regex
                logging.warning(f'Skip, already correct: {file_path}')
                continue

            ext = file_path.suffix[1:]  # remove dot

            if ext.lower() in DEL_EXT:
                logging.warning(f'Delete {file_path}')
                file_path.unlink()
                continue

            prefix = 'IMG'
            if ext.lower() in VID_EXT:
                prefix = 'VID'

            creation_time = get_creation_date_from_exif(file_path)
            if not isinstance(creation_time, float):
                creation_time = creation_time.timestamp()

            if creation_time > today:
                logging.warning(f'Skip {file_path}: wrong data')
                continue

            timestamp = datetime.fromtimestamp(creation_time).strftime('%Y%m%d_%H%M%S')
            new_filename = f'{prefix}_{timestamp}.{ext.lower()}'
            new_file_path = directory / new_filename

            i = 0
            while new_file_path.exists():
                i += 1
                new_filename = f'{prefix}_{timestamp}_{i}.{ext.lower()}'
                new_file_path = directory / new_filename

            if new_file_path == file_path:
                logging.debug(f'Already the correct filename, skip {file_path}')
                continue

            if subdirs:
                year = datetime.fromtimestamp(creation_time).strftime('%Y')
                month = datetime.fromtimestamp(creation_time).strftime('%m')

                subdir = directory / year / month
                subdir.mkdir(parents=True, exist_ok=True)

                new_file_path = subdir / new_filename

            file_path.rename(new_file_path)
            logging.warning(f'Renamed: {filename} -> {new_filename}')


def main():
    """
    Main function used when this file is executed.
    """
    parser = ArgumentParser()

    parser.add_argument(
        '-v',
        '--verbose',
        action='count',
        default=0,
    )

    parser.add_argument(
        '-d',
        '--dryrun',
        action='store_true',
        default=False,
    )

    parser.add_argument(
        dest='directory',
        nargs='+',
        help='Directories to go through',
    )

    parser.add_argument(
        '-s',
        '--subdirs',
        action='store_true',
        default=False,
        help='Move files in subdirectories sorted by months',
    )

    args = parser.parse_args()

    rename_files_with_timestamp(args.verbose, args.dryrun, args.directory, args.subdirs)


if __name__ == "__main__":
    main()
