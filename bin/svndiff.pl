#!/usr/bin/perl
## Script written and mantained by GI
if( $#ARGV == -1 || ( $#ARGV == 0 && $ARGV[0] =~ /--?h(elp)?/ ) ) {
	## Display help, explain usage
	print " This script is intended to be used only through the 'svn diff' command.\n";
	exit 0;
}

$original = $ARGV[5];
$mine = $ARGV[6];

if( $mine eq "" && $original eq "" ) {
	exit 0;
}
if( $original eq "" || $original eq "/tmp/tempfile.tmp" ) {
	$original = "/dev/null";
}

system("vimdiff",$original,$mine);

exit 1;
