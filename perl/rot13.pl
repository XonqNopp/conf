#!/usr/bin/perl
use strict;
use warnings;

##### Script written and mantained by GI #####

## Revision history: see version control command svn or hg (mercurial)

my $nArgs = 1;
$nArgs--;

## Help {{{
if( $#ARGV < ${nArgs} || ( $#ARGV == 0 && $ARGV[0] =~ /^--?h(elp)?$/ ) ) {
	## Display help, explain usage
	print " ARGV[0]:\n";
	print "   +/-1: rot-i (enc/dec)\n";
	print "   13:   rot-13\n";
	print "   +/-31: rot-(i*13)\n";
	exit 8;
}
## }}}
## Options {{{
my $debug = 0;
while( $#ARGV > -1 && $ARGV[0] =~ /^-/ ) {
	my $a = shift(@ARGV);
	if( $a =~ /^--?d(ebug(=[0-9])?)?$/i ) {
		if( $a =~ /^--debug=[0-9]$/i ) {
			( $debug = $a ) =~ s/^--debug=//i;
		} else {
			$debug = 1;
		}
	} else {
		die( " Sorry, argument $a not recognized..." );
	}
}
## }}}
## Setting path to script from execution {{{
my $curpath = ".";
if( $0 =~ /\// ) {
	( $curpath = $0 ) =~ s/\/[^\/]*$//;
}
## }}}

## TODO:
## BBOZ DR YNDN
my $start = ord("a");
my $end   = ord("z");
my $mod   = $end - $start + 1;
#print " From $start to $end ($mod)\n";
my $fac = 0;
my $doIndex = 0;
if( $ARGV[0] == 1 ) {
	## Encode rot-i
	$doIndex = 1;
} elsif( $ARGV[0] == -1 ) {
	## Decode rot-i
	$doIndex = -1;
} elsif( $ARGV[0] == 13 ) {
	if( $#ARGV == 0 ) {
		## rot-13
		$fac = 13;
	} else {
		$fac = $ARGV[1];
	}
} elsif( $ARGV[0] == 31 ) {
	## encode rot-(i*13)
	$doIndex = 13;
} elsif( $ARGV[0] == -31 ) {
	## decode rot-(i*13)
	$doIndex = -13;
} else {
	die( "Ni!" );
}

while( my $line = <STDIN> ) {
	print "\n";
	chomp($line);
	$line =~ tr/[A-Z]/[a-z]/;
	my @chars = split( "", $line );
	for( my $i = 0; $i <= $#chars; $i++ ) {
		my $tc = $chars[$i];
		my $oo = ord($tc);
		my $nc = $tc;
		my $no = 0;
		if( $oo >= $start && $oo <= $end ) {
			$no = $oo - $start;
			$no += $fac;
			if( $doIndex ) {
				$no += ( $doIndex * $i );
			}
			$no %= $mod;
			$no += $start;
			$nc = chr($no);
		}
		my $poo = $oo - $start;
		my $pno = $no - $start;
		#print "$i) $tc - $poo -> $pno - $nc\n";
		print $nc;
	}
	print "\n";
	print "\n";
}

exit 0;
