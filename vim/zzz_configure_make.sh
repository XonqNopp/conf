#!/bin/sh

set -eu

echo "Delete cached config"
rm src/auto/config.cache

echo "Clean..."
make distclean

echo "Configure..."
LDFLAGS=-rdynamic ./configure --enable-python3interp=yes --with-python3-command="/usr/local/bin/python3" --enable-gui=none --enable-terminal

echo "Make..."
make

echo "Test..."
PS1='[\$#] $' make test

echo "Install (ROOT)..."
sudo make install

