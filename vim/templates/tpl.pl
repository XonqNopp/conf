#!/usr/bin/perl
## TODO:
##
my $ScriptVersion = 0.01;

use strict;
use warnings;


## Args: 
my $nArgs = 0;
$nArgs--;

## Help {{{
if($#ARGV < $nArgs || ($#ARGV == 0 && $ARGV[0] =~ /^--?h(elp)?$/)) {
	## Display help, explain usage
	print(" Help not done yet...\n");
	#&%
	exit 8;
}
## }}}
## Options {{{
my $debug = 0;
while($#ARGV > -1 && $ARGV[0] =~ /^-/) {
	my $a = shift(@ARGV);
	if($a =~ /^--?d(ebug(=[0-9])?)?$/i) {
		if($a =~ /^--debug=[0-9]$/i) {
			($debug = $a) =~ s/^--debug=//i;
		} else {
			$debug = 1;
		}
	} else {
		die(" Argument $a not recognized...");
	}
}
## }}}
## Setting path to script from execution {{{
my $curpath = ".";
if($0 =~ /\//) {
	($curpath = $0) =~ s/\/[^\/]*$//;
}
## }}}

#&%

#(my $logfile = $0) =~ s/^(.*\/)?([^\/]*)\.[^.]*$/.$2.log/;
#open(my $LOG, ">", "$logfile") or die(" Cannot write log file $logfile");

#&%

#close($LOG);

exit 0;
