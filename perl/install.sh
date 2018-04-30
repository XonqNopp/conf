#!/bin/bash
# cpan == perl -MCPAN shell
sudo perl -MCPAN -e "install $1"
o conf init
