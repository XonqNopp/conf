#!/usr/bin/env python3
"""
LaTeX PAWAAAAAAAAAAAAAAA!!!!

Run LaTeX and check if the .aux file has changed.
Also checks if the .idx file changed.

Possible improvements

* check the log file for warnings, citation undef, for ref, tables...

.. todo::

   * add debug option
   * use strict warnings my
   * Must remove aux file when nothing needs to be done!!!
   * Warning: include (not input) files also generates aux files, must take them in bktex
   * When first time, needs bib
   * Could determine itself which beamer mode it is
   * Add 'my' declarations
   * Look for citation undef in log to rerun bib ONCE
   * Look for sty files in the working directory
   * When adding TOC after the first run, error because of toc file
   * Check the way it checks bibtex needs to be run
   * WARNING: may be more than one bibtex file, separated by commas on inline (l.790 @bibs)
   * (seems to never get to l.570...) (oops, had defined new command with bib :-S)
   * when checking if run needed, stop if true
   * Treat problems from after the latex command differently so I don;t have to redo the run
   * Stop copying the bib file and only check if more recent (all of them)
   * If dead, keep the kept files in bktex as they were
   * If interrupted while doing an eps, rm it
   * Finish option to have dvips muted or not
   * Keep the aux files from before if failed before dvips
   * Check if lapd files also newer than PDF
   * Fix chmod
   * Do it more efficient (if condition found, break the loop)
   * Make sub to help structure this script
   * If found smth that implies a run, stop checking and run!!
   * Should check why it always runs 3-4 times... (rip, bib)
   * Shoud look on class and packages if present in curdir and check for -w (at least)
   * Should save log always?
   * Must handle regexp in file_ext
   * if bktex files exist and ./files too, rm latter and use former
   * check log for: LaTeX Warning: Label(s) may have changed. Rerun to get cross-references right.
   * Must run bibtex only if there is a bib *line*, file present does not mean used (error)
   * if aux in curdir and .texst, use latter since more reliable
   * add option in .lapd for exotic commands to be recognized as includegraphics
   * backinp up kept files is not optimal
   *   Must do one sub for ext to get back and one for ext to move away
   * when dying, check if aux has different select@language. If so, keep new one
"""
import os
import logging
from argparse import ArgumentParser
from subprocess import run
import re
from inspect import currentframe
from collections import OrderedDict


class LaTeXRunner:

    RESTOROUTE = '_RESTORE_THIS_SPACE_'

    LATEX_KEPT_EXTENSIONS = [
        'aux',
        'toc',
        'idx',
        'log',
    ]


    LATEX_TMP_EXTENSIONS = [
        'out',
        'blg',
        'bbl',
        'ilg',
        'ind',
        'snm',
        'nav',
        'tns',
        #'mtc',
        'mtc[0-9]',
        #'stc',
        'stc[0-9]',
        'maf',
        'brf',
        # What is missing???
        # dvi and ps have to be kept for further treatment
    ]


    LATEX_HALF_EXTENSIONS = [
        'dvi',
        'ps',
    ]


    LATEX_BKTEX_DIR = '.textst'
    LOG_EXTENSION = '.plg'


    LATEX_GETBACK_EXTENSIONS = LATEX_KEPT_EXTENSIONS
    LATEX_MOVEAWAY_EXTENSIONS = LATEX_TMP_EXTENSIONS
    LATEX_DELETE_EXTENSIONS = LATEX_HALF_EXTENSIONS

    PREFIX = OrderedDict()
    PREFIX['script'] = '#'
    PREFIX['args'] = '&'
    PREFIX['log'] = '-'
    PREFIX['LaTeX'] = '@'
    PREFIX['shell'] = '$'
    PREFIX['bibtex'] = '%'
    PREFIX['makeindex'] = '%'

    DEBUG_PREFIX = ' -d- '

    DEFAULTS = OrderedDict()
    DEFAULTS['paperFormat'] = 'a4'
    DEFAULTS['pinup'] = 1
    DEFAULTS['noRotate'] = False
    DEFAULTS['cpPath'] = ''
    DEFAULTS['mvPath'] = ''
    DEFAULTS['mustRun'] = False
    DEFAULTS['doOpen'] = True
    DEFAULTS['isNotes'] = False
    DEFAULTS['dvipsMute'] = True
    DEFAULTS['chmod'] = False

    def __init__(self, args):
        self._logger = None
        self._logFilename = None

        CWD = os.getcwd()

        setupBktexDir(self._logger)

        logFilename = os.path.join(self.LATEX_BKTEX_DIR, args.filename + self.LOG_EXTENSION)
        # I WAS HERE

        if os.path.exists(logFilename):
            # Since we always append, we need to clear it before beginning
            os.remove(logFilename)

        def _log(prefix: str, message: str, level: int=logging.INFO, exceptionClass=None):
            """ Shortcut with some args set. """
            _logAll(prefix, message, _logger, logFilename, level, exceptionClass, frameBack=2)

        _log('script', 'Opening log file: {}'.format(logFilename))

        _log(None, 'Prefix table:')
        for prefix in PREFIX:
            _log(prefix, prefix)

        paperFormat = [DEFAULTS['paperFormat']]
        pinup = [DEFAULTS['pinup']]
        noRotate = [DEFAULTS['noRotate']]
        cpPath = [DEFAULTS['cpPath']]
        mvPath = [DEFAULTS['mvPath']]
        mustRun = [DEFAULTS['mustRun']]
        doOpen = [DEFAULTS['doOpen']]
        isNotes = [DEFAULTS['isNotes']]
        dvipsMute = [DEFAULTS['dvipsMute']]
        chmod = [DEFAULTS['chmod']]

        doMany = [False]
        doAmong = False
        iAmong = 0

        # Read latexpawa.lapd
        # Read <filename>.lapd
        # TODO method to read conf file
        # TODO class to have easy access to attributes



    def regex2shellExtensions(self, regex):
        raise NotImplementedError('Keep regex and check file within python')
        #$shex =~ s/(\.|\[[^\]]+\])[\*\?\+]?/*/g;


    def systemReturn(self, cmd, logFile, errorMessage):
        errorMessage = '\n*** {} ***\n'.format(errorMessage)

        if run(cmd):  # ???
            return

        # Failed, clean
        # TODO move LATEX_KEPT_EXTENSIONS to LATEX_BKTEX_DIR
        # TODO delete LATEX_TMP_EXTENSIONS
        # TODO delete LATEX_HALF_EXTENSIONS

        if logFIle is not None:
            # TODO Write error message to log file
            pass

        # TODO print error message
        # TODO die


    def setupBktexDir(self, logger) -> None:
        dirFullName = os.path.abspath(self.LATEX_BKTEX_DIR)
        logger.info('Creating directory: {}'.format(dirFullName))
        os.makedirs(dirFullName, exist_ok=True)


    def _logAll(self, prefix: str, message: str, logger, filename: str=None, level: int=logging.INFO, exceptionClass=None, frameBack: int=1) -> None:
        """
        Log to logger and to file (if provided).
        """
        if level == logging.DEBUG:
            message = self.DEBUG_PREFIX + message

        if prefix is not None:
            message = self.PREFIX[prefix] + ' ' + message

        critical = (exceptionClass is not None)
        if critical:
            level = logging.CRITICAL

        # Prefix FuncName and lineno
        fBack = currentframe().f_back
        frameBack -= 1

        while frameBack > 0:
            fBack = fBack.f_back
            frameBack -= 1

        lineno = fBack.f_lineno
        funcName = fBack.f_code.co_name

        self._logger.log(level, '[{}].{}:{}'.format(lineno, funcName, message))

        if self._logFilename is not None:
            with open(self._logFilename, 'a') as logFile:
                if critical:
                    logFile.write('*' * 42 + '\n')

                logFile.write(message + '\n')

        if not critical:
            return

        # TODO clean files

        raise exceptionClass(message)


def trapKeyboardInterrupt() -> None:
    # TODO
    # List cur dir
    # Delete kept_exts file_exts half_exts
    pass


def parseArgs():
    """
    Prepare parsing of input arguments.

    Returns:
        parsed args
    """
    description = """This script will cleverly print the PDF from a given tex file.'
It will redo a LaTeX compilation if needed, compile bib and index, do the needed pictures in eps."""

    epilog = """These arguments can also be set in a configuration file.
See latexpawa --helpConfig"""  # TODO

    parser = ArgumentParser(description=description, epilog=epilog)

    parser.add_argument(
        '-d',
        '--debug',
        action='store_true',
        default=False,
    )

    parser.add_argument(
        '-v',
        '--verbose',
        action='store_true',
        default=False,
    )

    parser.add_argument(
        '-f',
        '--force',
        action='store_true',
        default=False,
        help='Force run even if script would skip running.'
    )

    parser.add_argument(
        '--helpConfig',
        action='store_true',
        default=False,
        help='Show help about config file.'
    )

    PAPER_FORMATS = [
        # psnup output paper format
        'a0',
        'a1',
        'a2',
        'a3',
        'a4',
        'a5',
        'a6',
        'a7',
        'a8',
        'a9',
        'b0',
        'b1',
        'b2',
        'b3',
        'b4',
        'b5',
        'b6',
        'b7',
        'b8',
        'b9',
        'letter',
        'legal',
        'tabloid',
        'statement',
        'executive',
        'folio',
        'quarto',
        '10x14',
    ]
    # NOTE: was -N before
    parser.add_argument(
        '-pf',
        '--paperFormat',
        choices=PAPER_FORMATS,
        default=PAPER_FORMATS[0],
        help='Desired output paper format'
    )

    parser.add_argument(
        '-ps',
        '--pagePerSheet',
        type=int,
        help='Number of pages per sheet'
    )

    parser.add_argument(
        '--slides',
        action='store_true',
        default=False,
        help='Output slides format (only for beamer presentation)'
    )

    parser.add_argument(
        '--handout',
        action='store_true',
        default=False,
        help='Output handout format (only for beamer presentation)'
    )

    parser.add_argument(
        '--notes',
        action='store_true',
        default=False,
        help='Output notes format (only for beamer presentation)'
    )

    parser.add_argument(
        '--no-rotate',
        dest='rotate',
        action='store_false',
        default=True,
        help='Do not rotate what???'  # TODO
    )

    parser.add_argument(
        '--no-open',
        dest='open',
        action='store_false',
        default=True,
        help='Do not open output file after run'
    )

    parser.add_argument(
        '--cp',  # TODO
        help='Path to copy to'
    )

    parser.add_argument(
        '--mv',  # TODO
        help='Path to move to'
    )

    parser.add_argument(
        '--chmod',  # TODO
        help='chmod output file'
    )

    # Positional args
    parser.add_argument(
        dest='filename',
        #required=True,
        help='LaTeX input filename'
    )

    parser.add_argument(
        dest='outputFilename',
        nargs='?',
        help='Filename for the output if different than the input'
    )

    # Parse
    args = parser.parse_args()

    if args.helpConfig:
        # TODO update doc
        print("""
        To set global arguments for all the files of the directory,
          write them in the file 'latexpawa.lapd'.
        To set arguments specific to each file, set them in 'filename.lapd'.

        For arguments requiring a value, write the argument name followed by
          a semi-colon and the value.
        Arguments that are logical should be set only as 'arg'. If
          the default is true and you want to set it to false, you
          can write 'arg: 0'.
        The arguments must be on separated lines.
        Commented lines (beginning with #) are ignored.

        The arguments that are recognized are the following:
          - 'pf' = (a|b)[0-9] or letter, legal, tavloid, statement, executive,
                   folio, quarto, 10x14 (psnup output paper format)
          - 'N' = x
          - 'slides'  for slides mode when writing a beamer document
          - 'handout' idem
          - 'notes'   idem
          - 'no_rotate' to prevent ps2pdf to automatically rotate your pages
                        (useful when working with graphs containing 90deg text)
          - 'cp' = cp path
          - 'mv' = mv path. Be careful: since the PDF won't be at its original
                   location anymore, the script will always rerun the latex command.
          - 'chmod' to do chmod u+w before cp/mv and chmod a-w after
          - 'force-run' to force latex to run again
            (this should not be let permanently in a conf file)
          - 'open' = (true|false) to open the PDF when ready

        You can also provide different arguments for the same file with
          different output filenames.
        You specify each time the output filename (PDF) except for the
          default case (must be present) which will be the input filename:
          case file1.pdf
             arg1: blabla1
             arg2: blabla2
             arg3
          break
          case file2.pdf
             arg1: blabla4
             arg3
          break
          default
             arg1: blabla1
             arg2: blabla5
          break
        """)
        return None

    # post-processing to check options which are mutually exclusive
    if not args.filename.endswith('.tex'):
        raise ValueError('No tex filename provided: {}'.format(args.filename))

    args.filename = re.sub('\.tex$', '', args.filename)

    if args.outputFilename is None:
        args.outputFilename = args.filename + '.pdf'
    # TODO

    return args


def main():
    """
    What is called when this file gets executed.
    """
    args = parseArgs()

    if args is None:
        # Means to not run
        return

    logLevel = logging.INFO
    if args.debug:
        logLevel = logging.DEBUG

    logFormat = '%(asctime)s:%(levelname)s:%(module)s%(message)s'
    logging.basicConfig(level=logLevel, format=logFormat)
    _logger = logging.getLogger('LaTeX PaWaAa')

    # TODO need to know platform for "open" cmd

    trapKeyboardInterrupt()

    logging.info("\n   ***** You are currently running LaTeX PaWaAa !! *****\n")

    latexRunner = LaTeXRunner(args)


if __name__ == "__main__":
    main()

