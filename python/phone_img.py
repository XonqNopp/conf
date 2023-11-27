#!/usr/bin/env python3
"""
Rename files (mainly pictures from smartphone) with timestamp.
"""
import os
import shutil
from datetime import datetime
from argparse import ArgumentParser


today = datetime(2023, 11, 20).timestamp()


VID_EXT = ["mov", "mp4", "m4v"]
DEL_EXT = ["aae"]


def rename_files_with_timestamp(directories: list):
    """
    Rename the file.

    Args:
        directories (list): directories to go through
    """
    for directory_path in directories:
        for filename in os.listdir(directory_path):
            file_path = os.path.join(directory_path, filename)

            # Check if the path is a file and not a directory
            if not os.path.isfile(file_path):
                continue

            if len(filename) > 13:
                print(f'Skip, already correct: {file_path}')
                continue

            ext = os.path.splitext(file_path)[1][1:]
            creation_time = os.stat(file_path).st_birthtime

            if ext.lower() in DEL_EXT:
                print(f'Delete {file_path}')
                os.unlink(file_path)
                continue

            prefix = 'IMG'
            if ext.lower() in VID_EXT:
                prefix = 'VID'

            if creation_time > today:
                # Wrong data, do not change
                print(f'Skip {file_path}: wrong data')
                continue

            new_filename = f'{prefix}_'
            new_filename += datetime.fromtimestamp(creation_time).strftime("%Y%m%d_%H%M%S")
            new_filename += f'.{ext.lower()}'

            new_file_path = os.path.join(directory_path, new_filename)

            shutil.move(file_path, new_file_path)
            print(f'Renamed: {filename} -> {new_filename}')


def main():
    """
    Main function used when this file is executed.
    """
    parser = ArgumentParser()
    parser.add_argument(
        '--directory',
        nargs='+',
    )
    args = parser.parse_args()

    rename_files_with_timestamp(args.directory)


if __name__ == "__main__":
    main()
