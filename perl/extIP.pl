#!/usr/bin/perl
use strict;
use warnings;
use LWP::Simple;

if( $#ARGV > -1 ) {
	# HELP
	print " Usage: extip - yields the exterior IP\n";
	exit 8;
}
my $url = 'http://checkip.dyndns.org';
my @body = split( /\n/, get( $url ) ) or die( "Can't fetch $url..." );
foreach my $l( @body ) {
	$l =~ s/^.*: //;
	$l =~ s/<.*$//;
	print "$l\n";
}

exit 0;
