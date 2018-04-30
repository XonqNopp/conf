#!/usr/bin/perl
## Script written and mantained by GI
if( $#ARGV == -1 || ( $#ARGV == 0 && $ARGV[0] =~ /--?h(elp)?/ ) ) {
	## Display help, explain usage
	print " This script is intended to be used only through the 'svn diff' command.\n";
	exit 0;
}

$original = $ARGV[-2];
$mine = $ARGV[-3];
$yours = $ARGV[-1];
$output = $mine;
$output =~ s/\.mine$//;

#$filename     = $ARGV[-1];
#$filename     =~ s/^.*\///;
#$filename     =~ s/\.svn-base$//;
#$ext_original = $ARGV[5];
#$ext_mine     = $ARGV[3];## Should be ".mine"
#$ext_yours    = $ARGV[7];
#$original     = "$filename$ext_original";
#$mine         = "$filename$ext_mine";
#$yours        = "$filename$ext_yours";

## Or should they be the last three args??

if( $original eq "" && $mine eq "" && $yours eq "" ) {
	exit 0;
}
if( $original eq "" || $original eq "/tmp/tempfile.tmp" ) {
	$original = "/dev/null";
}

#print "$original\n$mine\n$yours\n";
system("vimdiff","-c","wincmd J",$output,$original,$mine,$yours);
## Vim warning: output is not to terminal
## svn diff3 commands get file from STDOUT

exit 1;
