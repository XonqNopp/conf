#!/bin/sh
perl -pe 'y/A-Za-z/N-ZA-Mn-za-m/' $1
