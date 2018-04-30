#!/usr/bin/perl
## Script written and mantained by GI
if( $#ARGV == 0 && $ARGV[0] =~ /^--?h(elp)?$/ ) {
	## Display help, explain usage
	print " perl filenamesOK.pl [mvflag] dir1 [dir2... not done yet]\n";
	print " Corrects the filenames that need to be fixed (spaces, accents...) in the current or given directory recursively.\n";
	print " mvflag can be --interactive (default) or --not-overwrite\n";
	exit 8;
}

use Encode;

$mvflag = "-i";
if( $#ARGV > -1 && $ARGV[0] =~ /^--/ ) {
	$flag_argv = shift(@ARGV);
	if( $flag_argv =~ /^--not-overwrite$/ ) {
		$mvflag = "-n";
	}
}

$HSH = `echo \$HSH`;
chomp( $HSH );
require "$HSH/.wash/perl/readrec.pl";
$dir = ".";
if( $#ARGV > -1 ) {
	$dir = $ARGV[0];
}## Must enable more than one argument

@dd = readdirs($dir);
foreach $file( @dd ) {
	$newname = decode("utf-8",$file);
	#$newname = $file;
	$newname =~ s/[ \t',]/_/g;
	$newname =~ s/[()]//g;
	$newname =~ s/\x{0026}/et/g;
	$newname =~ s/[\x{0021}-\x{002c}]//g;
	$newname =~ s/[\x{003a}-\x{003f}]//g;
	$newname =~ s/\x{0040}/a/g;
	## a's
	$newname =~ s/[\x{00e0}-\x{00e5}]/a/g;
	## ae
	$newname =~ s/\x{00e6}/ae/g;
	## c
	$newname =~ s/\x{00e7}/c/g;
	## e's
	$newname =~ s/[\x{00e8}-\x{00eb}]/e/g;
	## i's
	$newname =~ s/[\x{00ec}-\x{00ef}]/i/g;
	## n
	$newname =~ s/\x{00f1}/n/g;
	## o's
	$newname =~ s/[\x{00f0}-\x{00f6}]/o/g;
	$newname =~ s/\x{00f8}/o/g;
	## u's
	$newname =~ s/[\x{00f9}-\x{00fc}]/u/g;
	## y's
	$newname =~ s/\x{00fd}/y/g;
	$newname =~ s/\x{00ff}/y/g;
	## A's
	$newname =~ s/[\x{00c0}-\x{00c5}]/A/g;
	## AE
	$newname =~ s/\x{00c6}/AE/g;
	## C
	$newname =~ s/\x{00c7}/C/g;
	## E's
	$newname =~ s/[\x{00c8}-\x{00cb}]/E/g;
	## I's
	$newname =~ s/[\x{00cc}-\x{00cf}]/I/g;
	## N
	$newname =~ s/\x{00d1}/N/g;
	## O's
	$newname =~ s/[\x{00d2}-\x{00d6}]/O/g;
	$newname =~ s/\x{00d8}/O/g;
	## U's
	$newname =~ s/[\x{00d9}-\x{00dc}]/U/g;
	## Y's
	$newname =~ s/\x{00dd}/Y/g;
	## Others new age:
	$newname =~ s/[\x{00de}-\x{ffff}]//g;
	if( $newname ne $file ) {
		if( $newname ne "" ) {
			print " $file -> $newname\n";
			system("mv",$mvflag,"$file","$newname");
		} else {
			print "   ### New name empty for $file\n";
		}
	}
}

exit 0;
