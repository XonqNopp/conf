#!/usr/bin/perl
use strict;
use warnings;

##### Script written and mantained by GI #####

## Revision history: see version control command svn or hg (mercurial)

my $nArgs = 0;
$nArgs--;

## Help {{{
if($#ARGV == -1 || $ARGV[0] =~ /^help$/) {
	## Display help, explain usage
	print " This script is used as an alias on hg.\n";
	print " It helps doing pull/push.\n";
	print " Below is the help of the real hg.\n";
	print "\n";
	my $hgarg = "";
	my @hghelp = ();
	if($#ARGV > 0) {
		$hgarg = $ARGV[1];
		if($hgarg !~ /^help$/i) {
			@hghelp = `hg help $hgarg`;
		} else {
			@hghelp = `hg help`;
		}
	} else {
		@hghelp = `hg`;
	}
	foreach my $hgl(@hghelp) {
		chomp($hgl);
		print "$hgl\n";
	}
	exit 8;
}
## }}}
## Options {{{
my $debug = 0;
my $internal = 0;
while($#ARGV > -1 && $ARGV[0] =~ /^-/) {
	my $a = shift(@ARGV);
	if($a =~ /^--?d(ebug(=[0-9])?)?$/i) {
		if($a =~ /^--debug=[0-9]$/i) {
			($debug = $a) =~ s/^--debug=//i;
		} else {
			$debug = 1;
		}
	} elsif($a =~ /^--internal$/) {
		$internal = 1;
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

## TODO:
## Discuss if reading hgrc is better than execute `hg paths`
## Discuss if warning or prevent commit when no pull is done
## Integrate all the perl hg scripts (serve,...)
## If a problem occurs, prevent doint the special things
## Improve management of the log (not using args from user now)
## Make aa llUPdate command allowed by hGrc
## If no connection, do not die on unpush
## .hgoutdated when pulled but not updated
## read aliases in ~/.hgrc to match if push, ci...
##
## without/with connection:
## 12:24:54 gaelinduni@McGuy: .vash $ ifconfig 
## lo0: flags=8049<UP,LOOPBACK,RUNNING,MULTICAST> mtu 16384
## options=3<RXCSUM,TXCSUM>
## inet6 fe80::1%lo0 prefixlen 64 scopeid 0x1 
## inet 127.0.0.1 netmask 0xff000000 
## inet6 ::1 prefixlen 128 
## gif0: flags=8010<POINTOPOINT,MULTICAST> mtu 1280
## stf0: flags=0<> mtu 1280
## en0: flags=8823<UP,BROADCAST,SMART,SIMPLEX,MULTICAST> mtu 1500
## ether 14:10:9f:f0:25:28 
## media: autoselect (<unknown type>)
## status: inactive
## p2p0: flags=8802<BROADCAST,SIMPLEX,MULTICAST> mtu 2304
## ether 06:10:9f:f0:25:28 
## media: autoselect
## status: inactive
## 12:25:35 gaelinduni@McGuy: .vash $ ifconfig 
## lo0: flags=8049<UP,LOOPBACK,RUNNING,MULTICAST> mtu 16384
## options=3<RXCSUM,TXCSUM>
## inet6 fe80::1%lo0 prefixlen 64 scopeid 0x1 
## inet 127.0.0.1 netmask 0xff000000 
## inet6 ::1 prefixlen 128 
## gif0: flags=8010<POINTOPOINT,MULTICAST> mtu 1280
## stf0: flags=0<> mtu 1280
## en0: flags=8863<UP,BROADCAST,SMART,RUNNING,SIMPLEX,MULTICAST> mtu 1500
## ether 14:10:9f:f0:25:28 
## inet6 fe80::1610:9fff:fef0:2528%en0 prefixlen 64 scopeid 0x4 
## inet 192.168.0.100 netmask 0xffffff00 broadcast 192.168.0.255
## media: autoselect
## status: active
## p2p0: flags=8843<UP,BROADCAST,RUNNING,SIMPLEX,MULTICAST> mtu 2304
## ether 06:10:9f:f0:25:28 
## media: autoselect
## status: inactive
## 12:25:52 gaelinduni@McGuy: .vash $

my $pwd = $ENV{"PWD"};
my $rootdir = $pwd;
while(! -d "$rootdir/.hg" && $rootdir ne "/") {
	$rootdir =~ s/\/[^\/]*$//;
}
if(! -d "$rootdir/.hg") {
	die(" Sorry, could not find the .hg directory in $pwd");
}

my $warnPull   = 0;
my $warnPush   = 0;
my $unpull0warn1die = 0;
my $allowPU    = 0;
my $defPath    = "";
my $hgdir      = "$rootdir/.hg";
my $hgrc       = "$hgdir/hgrc";
my $myrc       = "$rootdir/.hGrc";
my $hgignore   = "$rootdir/.hgignore";
my $hgunpushed = "$hgdir/unpushed";
my $port = 8000;
my %TrueFalse = ("true" => 1, "false" => 0);

## Check that we are not in an ignored path with $pwd {{{
if(-f "$hgignore") {
	if($debug) {
		print " Ignored paths:\n";
	}
	open(my $IIG, "<", "$hgignore") or die(" Cannot read $hgignore");
	while(my $l = <$IIG>) {
		chomp($l);
		if($l =~ /^$/){
			next;
		}
		if($l =~ /^\^/) {
			#$l =~ s/^\^//;
		} else {
			$l =~ s/^/^.*/;
		}
		#$l =~ s/\$$//;
		my $ipath = "$rootdir/$l";
		if($debug) {
			print "   # $ipath\n";
		}
		if($pwd =~ /${ipath}/) {
			print " Here is an ignored path, aborting...\n";
			exit 0;
		}
	}
	close($IIG);
	if($debug) {
		print "\n";
	}
}
## }}}
## Read hGrc {{{
## die_on_not_pulled
## llUPdate
if(-f "$myrc") {
	open(my $RC, "<", "$myrc") or die(" Cannot read myrc file $myrc");
	while(my $line = <$RC>) {
		chomp($line);
		if($line =~ /^#/) {
			## We do not treat commented lines
			next;
		}
		if($line =~ /^die_on_not_pulled:?/i) {
			if($line =~ /^die_on_not_pulled$/i) {
				$unpull0warn1die = 1;
			} else {
				$line =~ s/^die_on_not_pulled: *//i;
				$line =~ s/(.)/\l$1/g;
				#print " Die on not pulled not ready\n";
				$unpull0warn1die = $TrueFalse{ $line } // 0;
				#$unpull0warn1die = exists($TrueFalse{ $line }) ? $TrueFalse{ $line } : 0;
			}
		} elsif($line =~ /^llUPdate:?/i) {
			if($line =~ /^llUPdate$/i) {
				$allowPU = 1;
			} else {
				$line =~ s/^llUPdate: *//i;
				$line =~ s/(.)/\l$1/g;
				$allowPU = $TrueFalse{ $line } // 0;
			}
		} else {
			die(" Unrecognized option: $line");
		}
	}
	close($RC);
}
## }}}
## Check if default path to ssh; if not, no need to proceed, get to hg directly {{{
if(-f "$hgrc") {
	if($debug) {
		print " Reading local hgrc file $hgrc\n";
	}
	open(my $IRC, "<", "$hgrc") or die(" Cannot read $hgrc");
	my $which = "";
	while(my $l = <$IRC>) {
		chomp($l);
		if($l =~ /^\s*\[[a-zA-Z]*\]\s*$/) {
			($which = $l) =~ s/^\s*\[([a-zA-Z]*)\]\s*$/$1/;
			if($debug) {
				print " which is now #$which#\n";
			}
		}
		if($which =~ /^paths$/i && $l =~ /^\s*default\s*=/) {
			$warnPull = 1;
			$warnPush = 1;
			($defPath = $l) =~ s/^\s*default\s*=\s*//;
			$defPath =~ s/\s*$//;
			if($debug) {
				print "  Found default path: $defPath\n";
			}
		} elsif($which =~ /^web$/i) {
			if($l =~ /^\s*port\s*=\s*[0-9]{4}\s*/i) {
				($port = $l) =~ s/^\s*port\s*=\s*//i;
				$port =~ s/\s*//g;
				$port += 0;
				if($debug) {
					print "  Found port: $port\n";
				}
			}
		}
	}
	close($IRC);
}
## }}}
## Init tmp files {{{
(my $tmpfile = $rootdir) =~ s/^.*\///;
(my $tmptmp = $defPath) =~ s/^.*\///;
$tmpfile = "${tmpfile}_$tmptmp";
$tmpfile = "/tmp/$tmpfile";
my $pullfile   = "${tmpfile}_pulled";
if($debug) {
	print " \$hgunpushed = $hgunpushed\n";
	print " \$pullfile   = $pullfile\n";
}
## }}}
##

my $hgarg = shift(@ARGV);
my @hgopt = @ARGV;
if($debug) {
	print " hg\n";
	print "  #$hgarg#\n";
	foreach my $h(@hgopt) {
		print "   #$h#\n";
	}
	print "\n";
}

## Print warnings if needed {{{
if($warnPull && $hgarg !~ /^pull$/ && $hgarg !~ /^llUPdate$/) {
	if(! -f "$pullfile") {
		if($unpull0warn1die) {
			die(" hG-Error: no pull have been done today...\n");
		}
	}
}
## }}}

## Execute command (only if not serve)
if($hgarg !~ /^(serve|log|llUPdate)$/i) {
	my $exec = "hg $hgarg";
	foreach my $h(@hgopt) {
		if($h =~ / /) {
			$h = "\"$h\"";
		}
		$exec = "$exec $h";
	}
	$exec = "$exec 2>&1";
	if($hgarg !~ /^(push|pull|update|llUPdate|clone|(vim)?diff|merge)$/i) {
		## Store the output to check
		my @out = `$exec`;
		foreach my $o(@out) {
			chomp($o);
			print "$o\n";
		}
		if($?) {
			if($#out == -1) {
				die(" No information");
			}
			if($out[0] =~ /^nothing changed$/ || $out[0] =~ /^abort: .*: no match under directory!$/) {
				## Nothing changed, no commit
				$hgarg = "abort"
			} elsif($out[$#out] =~ /hg help/) {
				## wrong command, no problem
			} else {
				die(" Problem running the hg command ($?)");
			}
		}
	} else {
		## Live output
		if(system("hg", "$hgarg", @hgopt)) {
			die(" Problem running hg $hgarg");
		}
	}
}

## Special treatment {{{
## Commit/tag {{{
if($hgarg =~ /^(c(omm)?it?|tag|init)$/) {
	$warnPush = 0;
	if($debug) {
		print " Committing changes or creating tag...\n";
	}
	## create unpush file
	if(-f "$hgunpushed") {
		my $UPFcount = 0;
		open(my $UPF, "<", "$hgunpushed") or die(" Cannot read the unpushed file $hgunpushed");
		$UPFcount = <$UPF>;
		chomp($UPFcount);
		$UPFcount += 1;
		close($UPF);
		open($UPF, ">", "$hgunpushed") or die(" Cannot write the unpushed file $hgunpushed");
		print $UPF "$UPFcount";
		close($UPF);
	} else {
		open(my $UPF, ">", "$hgunpushed") or die(" Cannot write the unpushed file $hgunpushed");
		print $UPF "1";
		close($UPF);
	}
## }}}
## Push {{{
} elsif($hgarg =~ /^push$/) {
	$warnPush = 0;
	if($debug) {
		print " Pushing committed changes...\n";
	}
	## erase unpush file
	if(system("rm", "-f", "$hgunpushed")) {
		die(" Could not do rm -f $hgunpushed");
	}
## }}}
## Pull {{{
} elsif($hgarg =~ /^pull$/) {
	$warnPull = 0;
	if($debug) {
		print " Pulling changes...\n";
	}
	## create pull file
	if(system("touch", "$pullfile")) {
		die(" Problem touching the pull file $pullfile");
	}
## }}}
## Serve {{{
} elsif($hgarg =~ /^serve$/) {
	if($debug) {
		print " Starting/stoping server mode...\n";
	}
	my $PIDfile = "/tmp/hg.$port.pid";
	my $doStart = -1;
	if($#hgopt > -1) {
		if($hgopt[0] =~ /^start$/i) {
			$doStart = 1;
		} elsif($hgopt[0] =~ /^stop$/i) {
			$doStart = 0;
		} else {
			warn(" Cannot run hg serve $hgopt[0]");
		}
	}
	if($doStart < 0) {
		if(-f "$PIDfile") {
			$doStart = 0;
		} else {
			$doStart = 1;
		}
	}
	if($doStart) {
		if(-f "$PIDfile") {
			die(" Sorry, it seems there already is a mercurial process running on port $port...");
		}
		print " Starting mercurial server on port $port...\n";
		if(system("hg", "serve", "-d", "--pid-file", "$PIDfile")) {
			die(" Sorry, could not start mercurial server on port $port...");
		}
		open(my $PF, "<", "$PIDfile") or die(" Cannot read PID file $PIDfile");
		my $PID = <$PF>;
		close($PF);
		chomp($PID);
		$PID += 0;
		print "     (PID=$PID)\n";
	} else {
		if(-f "$PIDfile") {
			open(my $PF, "<", "$PIDfile") or die(" Cannot read PID file $PIDfile");
			my $PID = <$PF>;
			close($PF);
			chomp($PID);
			$PID += 0;
			if($PID > 1) {
				if(system("kill", "-TERM", "$PID")) {
					die(" Sorry, could not kill process $PID...");
				}
				print " Stopped the mercruial server on port $port (PID=$PID)\n";
				if(system("rm", "-f", "$PIDfile")) {
					die(" Problem while removing the PID fie $PIDfile");
				}
			} else {
				die(" Bad PID for mercurial on port $port: \"$PID\"");
			}
		} else {
			print " No PID file recorder for mercurial port $port...\n";
		}
	}
## }}}
## log {{{
} elsif($hgarg =~ /^log$/i) {
	if(-f "$hgunpushed") {
		## Get UP count
		my $UPFcount = 0;
		open(my $UPF, "<", "$hgunpushed") or die(" Cannot read the unpushed file $hgunpushed");
		$UPFcount = <$UPF>;
		chomp($UPFcount);
		$UPFcount += 0;
		close($UPF);
		my $withS = "";
		my $isORare = "is";
		my $hasORhave = "has";
		if($UPFcount > 1) {
			$withS = "s";
			$isORare = "are";
			$hasORhave = "have";
		}
		## Get tip rev number
		my @tmplog = `hg log -r tip`;
		my $tip = $tmplog[0];
		chomp($tip);
		$tip =~ s/^changeset: *//;
		$tip =~ s/:[0-9a-fA-F]* *$//;
		$tip += 0;
		my $lastPushed = $tip - $UPFcount;
		my $firstUnpushed = $lastPushed + 1;
		## Print that there are unpushed changes
		#print " hG-Warning: there $isORare $UPFcount commited change$withS that $hasORhave not been pushed yet...\n";
		print "\n###------------- <unpushed revision$withS> -------------###\n\n";
		## print log till unpushed
		if(system("hg", "log", "-r", "$tip:$firstUnpushed")) {
			die(" Problem running hg log for all unpushed");
		}
		## print unpushed stop here
		print "###------------- </unpushed revision$withS> -------------###\n\n";
		## print remaining
		if(system("hg", "log", "-r", "$lastPushed")) {
			die(" Problem running hg log for the last pushed");
		}
	} else {
		if(system("hg", "$hgarg", @hgopt)) {
			die(" Problem running hg $hgarg");
		}
	}
## }}}
## llUPdate (if allowed) {{{
} elsif($hgarg =~ /^llUPdate$/) {
	if(!$allowPU) {
		die(" You are not allow to run llUPdate for this repository");
	}
	if(system("perl", "$curpath/hG.pl", "--internal", "pull")) {
		die(" Problem pulling...");
	}
	if(system("perl", "$curpath/hG.pl", "--internal", "update")) {
		die(" Problem updating...");
	}
## }}}
}
##
## Print warnings if needed {{{
if($warnPull && !$internal) {
	if(! -f "$pullfile") {
		if(! $unpull0warn1die) {
			print " hG-Warning: no pull have been done today...\n";
		}
	}
}
if($warnPush && !$internal) {
	if(-f "$hgunpushed") {
		my $UPFcount = 0;
		open(my $UPF, "<", "$hgunpushed") or die(" Cannot read the unpushed file $hgunpushed");
		$UPFcount = <$UPF>;
		chomp($UPFcount);
		$UPFcount += 0;
		close($UPF);
		my $withS = "";
		my $isORare = "is";
		my $hasORhave = "has";
		if($UPFcount > 1) {
			$withS = "s";
			$isORare = "are";
			$hasORhave = "have";
		}
		print " hG-Warning: there $isORare $UPFcount commited change$withS that $hasORhave not been pushed yet...\n";
	}
}
## }}}
## }}}


exit 0;
