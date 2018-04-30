#!/usr/bin/perl

sub BadFilesCheck()
{
	my $check = $_[0];
	return ( 
		$check ne "." &&
		$check ne ".." &&
		$check !~ /^\.DS_Store/ &&
		$check !~ /^\.svn/ &&
		$check !~ /^\.hg$/ &&
		$check !~ /^\..+\.swp$/ &&
		$check !~ /^\.bktex$/ &&
		$check !~ /^\.Spot/ &&
		$check !~ /^\.Trash/ &&
		$check !~ /^\.fseventsd/ &&
		$check !~ /^\._/ &&
		$check !~ /^\.Temporary Items/ &&
		$check ne "Icon\r"
	);
}

return 1;
