#!/bin/sh

set -eu

prefix="/usr"

echo "Clean..."
make distclean

echo "Configure..."
make configure
./configure --prefix=$prefix

echo "Make..."
make prefix=$prefix all doc

echo "Profile (be patient)..."
make prefix=$prefix profile

echo "Install (ROOT)..."
sudo make prefix=$prefix PROFILE=BUILD install install-doc install-html

