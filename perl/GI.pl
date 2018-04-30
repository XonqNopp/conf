#!/usr/bin/perl
## Here are some ideas seen on the web

	$comment = "";## Call sub according to user choice
	##
	sub do_I();
	sub do_II();
	sub do_III();
	##
	my %actions = (
		"1" => \&do_I,
		"2" => \&do_II,
		"3" => \&do_III
	);
	##
	print " choose a number: ";
	$n = <>;
	chomp($n);
	$actions{$n} -> ();## if exists!!!
	##
	exit 0;
	##
	sub do_I() {
	}
	$comment = "";##
##
exit 0;
