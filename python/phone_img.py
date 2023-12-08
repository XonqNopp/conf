#!/usr/bin/env python3
"""
Rename files (mainly pictures from smartphone) with timestamp.
"""
import os
import shutil
from datetime import datetime
from argparse import ArgumentParser
from PIL import Image


today = datetime(2023, 12, 6).timestamp()


VID_EXT = ["mov", "mp4", "m4v"]
DEL_EXT = ["aae"]


def get_creation_date_from_exif(file_path):
    # TODO not fully working
    return os.stat(file_path).st_birthtime

    try:
        with Image.open(file_path) as img:
            # Extract creation date from EXIF data
            exif_info = img._getexif()

        creation_date = exif_info.get(36867)  # 36867 corresponds to the DateTimeOriginal tag

        if creation_date:
            # Convert the creation date to a datetime object
            return datetime.strptime(creation_date, "%Y:%m:%d %H:%M:%S")

    except (AttributeError, KeyError, IndexError, IOError):
        pass
    
    # If not found, use file creation date
    return os.stat(file_path).st_birthtime


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

            if ext.lower() in DEL_EXT:
                print(f'Delete {file_path}')
                os.unlink(file_path)
                continue

            prefix = 'IMG'
            if ext.lower() in VID_EXT:
                prefix = 'VID'

            creation_time = get_creation_date_from_exif(file_path)
            if not isinstance(creation_time, float):
                creation_time = creation_time.timestamp()
            if creation_time > today:
                # Wrong data, do not change
                print(f'Skip {file_path}: wrong data')
                continue

            new_filename = f'{prefix}_'
            new_filename += datetime.fromtimestamp(creation_time).strftime("%Y%m%d_%H%M%S")
            new_filename += f'.{ext.lower()}'

            new_file_path = os.path.join(directory_path, new_filename)

            i = 0
            while os.path.exists(new_file_path):
                i += 1
                new_filename = f'{prefix}_'
                new_filename += datetime.fromtimestamp(creation_time).strftime("%Y%m%d_%H%M%S")
                new_filename += f'_{i}.{ext.lower()}'

                new_file_path = os.path.join(directory_path, new_filename)

            if new_file_path == file_path:
                continue

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
