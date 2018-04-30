#!/usr/bin/perl
use strict;
use warnings;
use POSIX;

##### Script written and mantained by Gael Induni #####
## Created      : Mon 09 Dec 2013 02:39:09 PM CET
## Last modified: Mon 09 Dec 2013 03:28:42 PM CET
## Version: 0.01
## Revision history: see revision control command
##
## TODO:
## http://www.rsreese.com/how-to-setup-an-upside-down-ternet/
## https://help.ubuntu.com/community/Upside-Down-TernetHowTo
## http://www.ex-parrot.com/~pete/upside-down-ternet.html
##


## Args: 
my $nArgs = 0;
$nArgs--;

## Help {{{
if($#ARGV < $nArgs || ($#ARGV == 0 && $ARGV[0] =~ /^--?h(elp)?$/)) {
	## Display help, explain usage
	print " Help not done yet...\n";
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

my $mog_flip = "-flip";
my $mog_blur = "-blur 4x3";
my @mog_args = ($mog_flip, $mog_blur);
my $mog_gray = "-colorspace gray";
my $mog_neg  = "-negate";
my @random_arg = ($mog_gray, $mog_neg);
my $HackedDir = "HackedPics";
my $mogrify = "/usr/bin/mogrify";
my $wget = "/usr/bin/wget";
my $timestamp = 0;
my $oldtimer = $timestamp;
my $basedir = "/var/www/$HackedDir";
my $loc_path = "$basedir/$timestamp";
my $DefaultPic = "$basedir/default.png";
my $badstring = "Stealing wifi is bad... Big Brother is watching *YOU*";

if($debug) {
	print " \$mog_flip   = $mog_flip\n";
	print " \$mog_blur   = $mog_blur\n";
	print " \$mog_gray   = $mog_gray\n";
	print " \$mog_neg    = $mog_neg \n";
	print " \$HackedDir  = $HackedDir\n";
	print " \$mogrify    = $mogrify\n";
	print " \$wget       = $wget\n";
	print " \$timestamp  = $timestamp\n";
	print " \$oldtimer   = $oldtimer\n";
	print " \$basedir    = $basedir\n";
	print " \$loc_path   = $loc_path\n";
	print " \$DefaultPic = $DefaultPic\n";
}

$|=1;
my $count = 0;
my $pid = $$;
if($debug) {print " \$pid = $pid\n";}
while (<>) {
	chomp($_);
	if($debug) {print " \$_ = $_\n";}
	$timestamp = strftime("%H", localtime) + 0;
	if($debug) {print " \$timestamp = $timestamp\n";}
	if($timestamp != $oldtimer) {
		if($debug) {print " TOO OLD\n";}
		system("rm", "-rf", "$loc_path");
		$loc_path = "$basedir/$timestamp";
		system("mkdir", "-p", "$loc_path");
		$oldtimer = $timestamp;
	}
	if($_ =~ /(.*\.(jpg|png|gif))/i) {
		if($debug) {print " PIC FOUND\n";}
		my $url = $1;
		my $ext = $2;
		if(system($wget, "-q", "-O", "$loc_path/$pid-$count.$ext", "$url")) {
			$ext = "png";
			system("cp", $DefaultPic, "$loc_path/$pid-$count.$ext");
		}
		system($mogrify, @mog_args, $random_arg[$count % 2], "$loc_path/$pid-$count.$ext");
		print "http://127.0.0.1/$HackedDir/$pid-$count.$ext\n";
		$count++;
	} elsif($_ =~ /<title>/) {
		(my $back = $_) =~ s/<title>/<title>$badstring - /;
		print "$back\n";
	} elsif($_ =~ /<body>/) {
		(my $back = $_) =~ s/<body>/<body><h1 style="color: #f00; position: fixed; top: 50%; left: 50%; text-align: center;">$badstring<\/h1>/;
		print "$back\n";
	} else {
		print "$_\n";
	}
}


exit 0;
