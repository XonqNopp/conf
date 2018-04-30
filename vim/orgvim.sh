#!/bin/bash
## Used for SpitVspit at first, now enabling others.
## Used for:
##  - SpitVspit
##  - HgCi
##  - MapComments
##  - FoldImproved
##  - EscapeBchars
if [[ $# -eq 0 ]]; then
	echo "  This script is intended to upload new versions of Vim plugins onto vim.org."
	echo "  The following plugins are shared:"
	echo "   - SpitVspit"
	echo "   - HgCi"
	echo "   - MapComments"
	echo "   - FoldImproved"
	echo "   - EscapeBchars"
else
	plugin_name=${1}
	plugin_version=`head plugin/${plugin_name}.vim | grep -i version | perl -e 'while($i=<>){ $i =~ s/^.*ersion //; $i =~ s/\./_/g; print $i; }'`
	echo "  Preparing plugin ${plugin_name} (version ${plugin_version}) for vim.org upload..."
	echo "    tar:"
	tar cvzf ${plugin_name}_${plugin_version}.tar.gz plugin/${plugin_name}.vim doc/${plugin_name}.txt
	echo "    mv:"
	mv -v ${plugin_name}_${plugin_version}.tar.gz $HOME/Desktop/
fi
