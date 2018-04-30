#!/bin/sh
rm -vf *.zip *.gz *.dist *.vba *.vim
echo " Only authorized file in this directory:"
echo "   GetLatestVimScript.dat and $0"
echo " All others are not back up and have to be removed."
echo " "
ls
