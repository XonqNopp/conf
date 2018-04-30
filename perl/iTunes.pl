#!/usr/bin/perl
## Script written and mantained by GI

my $OS = `echo \$OSTYPE`;
chomp($OS);
if( $OS !~ /^darwin/i ) {
	print " Sorry, this script is only intended to work on Mac OS X...\n";
	exit 1;
}


sub iTunesHelp();


if( $#ARGV == -1 || ( $#ARGV == 0 && $ARGV[0] =~ /^--?h(elp)?$/ ) ) {
	## Display help, explain usage
	iTunesHelp();
	exit 8;
}

while( $#ARGV > -1 ) {
	$this_arg = shift(@ARGV);
	if( $this_arg eq "prev" ) {
		$this_arg = "previous";
	}
	if( $this_arg eq "stat" || $this_arg eq "st" ) {
		$artist = `osascript -e 'tell application "iTunes" to artist of current track as string'`;
		$album  = `osascript -e 'tell application "iTunes" to album of current track as string'`;
		$track  = `osascript -e 'tell application "iTunes" to name of current track as string'`;
		chomp($artist);
		chomp($album);
		chomp($track);
		print " $track\n   $artist\n     $album\n";
	} elsif( $this_arg eq "pause" ) {
		system( "osascript -e 'tell application \"iTunes\" to pause'" );
		print " iTunes is waiting for you...\n";
	} elsif( $this_arg eq "play" || $this_arg eq "next" || $this_arg eq "previous" ) {
		if( $this_arg eq "play" ) {
			system( "osascript -e 'tell application \"iTunes\" to play'" );
		} else {
			system( "osascript -e 'tell application \"iTunes\" to $this_arg track'" );
		}
		$artist = `osascript -e 'tell application "iTunes" to artist of current track as string'`;
		$track  = `osascript -e 'tell application "iTunes" to name of current track as string'`;
		chomp($artist);
		chomp($track);
		print "    * $artist *\n $track\n";
	} elsif( $this_arg eq "vol" ) {
		$vol = `osascript -e 'tell application "iTunes" to sound volume as integer'`;
		$vol_arg = shift(@ARGV);
		if( $vol_arg eq "up" ) {
			$vol++;
		} elsif( $vol_arg eq "down" ) {
			$vol--;
		} else {
			$vol_arg += 0;
			if( $vol_arg > 0 && $vol_arg < 10 ) {
				$vol = $vol_arg;
			}
		}
		system( "osascript -e 'tell application \"iTunes\" to set sound volume to $vol'" );
	} elsif( $this_arg eq "quit" ) {
		print "Quitting iTunes...\n";
		system( "osascript -e 'tell application \"iTunes\" to quit'" );
	} elsif( $this_arg eq "boring" ) {
		$artist=`osascript -e 'tell application "iTunes" to artist of current track as string'`;
		$track=`osascript -e 'tell application "iTunes" to name of current track as string'`;
		chomp($artist);
		chomp($track);
		system( "say -v Fred '$track from $artist is boring'" );
		system( "osascript -e 'tell app \"iTunes\" to fast forward'" );
	} else {
		iTunesHelp();
		exit 8;
	}
}

sub iTunesHelp()
{
	print "-----------------------------\n";
	print "iTunes Command Line Interface\n";
	print "-----------------------------\n";
	print "Usage: iTunes <option>\n";
	print;
	print "Options:\n";
	print " stat/st     = Shows iTunes' status, current artist and track.\n";
	print " play        = Start playing iTunes.\n";
	print " pause       = Pause iTunes.\n";
	print " next        = Go to the next track.\n";
	print " prev[ious]  = Go to the previous track.\n";
	print " boring      = Go to next track with mocking.\n";
	print " vol up      = Increase iTunes' volume by 10%\n";
	print " vol down    = Increase iTunes' volume by 10%\n";
	print " vol #       = Set iTunes' volume to # [0-100]\n";
	print " quit        = Quit iTunes.\n";
}

exit 0;

