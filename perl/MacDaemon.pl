#!/usr/bin/perl
use strict;
use warnings;
use Proc::Daemon;

##### Script written and mantained by GI #####

## Revision history: see version control command svn or hg (mercurial)

my $nArgs = 0;
$nArgs--;

## Help {{{
if( $#ARGV < ${nArgs} || ( $#ARGV == 0 && $ARGV[0] =~ /^--?h(elp)?$/ ) ) {
	## Display help, explain usage
	#&%
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

if( ! ${debug} ) {
	Proc::Daemon::Init;
}

my $continue = 1;

$SIG{ TERM } = sub{ $continue = 0; };
$SIG{ INT  } = sub{ $continue = 0; };

my $lockfie = "/tmp/MacDaemonRunsFast.now";

if( ! -f "${lockfile}" ) {
	if( system( "touch", "${lockfile}" ) ) {
		die( " Cannot touch lock file ${lockfile}" );
	}
	my $delay = 60 * 60;
	my $dir = "/Volumes/chalet";
	while( $continue ) {
		## Do the looping stuff
		if( system( "chmod", "-R", "a+rw", "${dir}" ) ) {
			die( " Cannot change access rights to directory ${dir}" );
		}
		sleep( $delay );
	}
	if( system( "rm", "${lockfile}" ) ) {
		die( " Could not remove lock file ${lockfile} on exit" );
	}
} elsif( ${debug} ) {
	print "     Process is already running (or seems so).\n";
}

#( my $logfile = $0 ) =~ s/^(.*\/)?([^\/]*)\.[^.]*$/.$2.log/;
#open( my $LOG, ">", "${logfile}" ) or die( " Cannot write log file ${logfile}..." );

#&%

#close( ${LOG} );

exit 0;
