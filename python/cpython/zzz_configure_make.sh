#!/bin/sh

set -eu

echo "Configure..."
./configure --with-openssl=/usr/local --with-openssl-rpath=auto

#echo "Clean..."
#make clean

echo "Make..."
make

echo "Test..."
make test

echo "Install (ROOT)..."
sudo make install

