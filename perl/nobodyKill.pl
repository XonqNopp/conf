#!/usr/bin/perl
use strict;
use warnings;

##### Script written and mantained by GI #####

## Revision history: see version control command svn or hg (mercurial`;

my $nArgs = 0;
$nArgs--;

## Help {{{
if($#ARGV < ${nArgs} || ($#ARGV == 0 && $ARGV[0] =~ /^--?h(elp)?$/)) {
	## Display help, explain usage
	#&%
	exit 8;
}
## }}}
## Options {{{
my $debug = 0;
while($#ARGV > -1 && $ARGV[0] =~ /^-/) {
	my $a = shift(@ARGV);
	if($a =~ /^--?d(ebug)?$/i) {
		$debug = 1;
	} else {
		die(" Sorry, argument $a not recognized...");
	}
}
## }}}
## Setting path to script from execution {{{
my $curpath = ".";
if($0 =~ /\//) {
	($curpath = $0) =~ s/\/[^\/]*$//;
}
## }}}

## TODO:


## This script should only be ran as user (it uses sudo make me a sandwich)

my $psHeader     = `ps u | head -n 1`;
chomp($psHeader);
my $psZeitgeist  = `ps aux | grep -v grep | grep zeitgeist-datah`;
chomp($psZeitgeist);
if($psZeitgeist ne "") {
	(my $pidZeitgeist = $psZeitgeist) =~ s/^[a-z ]*//;
	$pidZeitgeist =~ s/ .*$//;
	if(system("kill", "-9", "${pidZeitgeist}")) {
		die(" Could not kill ZeitGeist");
	}
	print " KILLED process ${pidZeitgeist}:\n";
	print "${psZeitgeist}\n";
	print "\n";
}
my @psNobodyFind = `ps u -u nobody | grep find`;
if(${debug}) {
	print "${psHeader}\n";
	foreach my $p(@psNobodyFind) {
		print "$p";
	}
}
if($#psNobodyFind > -1) {
	my $cpu = 0;
	my $theMax = -1;
	for(my $i = 0; $i <= $#psNobodyFind; $i++) {
		chomp($psNobodyFind[$i]);
		(my $localCPU = $psNobodyFind[$i]) =~ s/^\s*nobody\s*[0-9]*\s*//;
		$localCPU =~ s/\s.*$//;
		$localCPU += 0;
		if(${localCPU} > ${cpu}) {
			$theMax = $i;
		}
	}
	(my $pid = $psNobodyFind[$theMax]) =~ s/^\s*nobody\s*//;
	$pid =~ s/\s.*$//;
	(my $printLine = $psNobodyFind[$theMax]) =~ s/find.*$/find/;;

	print "  # Killing process ${pid}:\n";
	print " ${psHeader}\n";
	print " ${printLine}\n";
	if(!${debug}) {
		if(system("sudo", "kill", "-9", "${pid}")) {
			die(" Could not kill process ${pid}");
		} else {
			$printLine =~ s/^nobody/*DEAD*/;
			$printLine =~ s/([0-9]{5} | [0-9]{4} |  [0-9]{3} |   [0-9]{2} |    [0-9] )/  +_+ /g;
			$printLine =~ s/[0-9 ][0-9]\.[0-9]/--.-/g;
			$printLine =~ s/(\?    |pts\/[0-9])/+_+  /;
			$printLine =~ s/ [A-Z+][A-Z+ ]{3} / +_+  /;
			#$printLine =~ s/[0-2 ][0-9]:[0-5][0-9]/--:--/g;
			$printLine =~ s/[0-2 ][0-9]:[0-5][0-9]/--:--/;
			## (keeping total CPU time displayed)
			$printLine =~ s/ [a-z\/. ]*$/ 'Bring out your deads!'/;
			print "\n";
			print "    +_+ +_+ +_+ +_+ +_+ +_+    KILLED!!    +_+ +_+ +_+ +_+ +_+ +_+ \n";
			print "\n";
			print " ${psHeader}\n";
			print " ${printLine}\n";
			print "\n";

# USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
# KILL+_+    +_+ --.- --.-    +_+   +_+ +_+      R+   13:13   0:00 /bin/sh ./find

		}
	}
}

exit 0;
