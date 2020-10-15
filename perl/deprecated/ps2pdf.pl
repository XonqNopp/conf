#!/usr/bin/perl
## Script written and mantained by GI
sub ps2pdf()
{
	$pic_dir = shift(@_);
	$pdf_dir = shift(@_);
	my $verbose = 0;
	while( $#_ > -1 ) {
		$this_opt = shift(@_);
		if( $this_opt =~ /^--?v(erbose)?$/ ) {
			$verbose = 1;
		} else {
			die( " Sorry, option $this_opt not recognized..." );
		}
	}
	opendir(PICS,$pic_dir) or die( " Cannot open directory $pic_dir...\n" );
	@pics = readdir(PICS);
	closedir(PICS);
	opendir(PDFS,$pdf_dir) or die( " Cannot open directory $pdf_dir...\n" );
	@pdfs = readdir(PDFS);
	closedir(PDFS);
	my @toconvert = ();
	my @toupdate  = ();
	foreach $ps( @pics ) {
		if( $ps =~ /\.ps$/ && $ps !~ /^\./ ) {
			$pdf_name = $ps;
			$pdf_name =~ s/\.ps$/.pdf/;
			if( !grep( $_ eq $pdf_name, @pdfs ) ) {
				push(@toconvert,$ps);
			} elsif( grep( $_ eq $pdf_name, @pdfs ) && ( ( -M "$pdf_dir/$pdf_name" ) > ( -M "$pic_dir/$ps" ) ) ) {
				push(@toupdate,$ps);
			}
		}
	}
	if( $#toconvert == -1 && $#toupdate == -1 && $verbose ) {
		print " No new picture to convert...\n";
	}
	for( $i_ps = 0; $i_ps <= $#toconvert; $i_ps ++ ) {
		$ps = $toconvert[$i_ps];
		$pdf_name = $ps;
		$pdf_name =~ s/\.ps$/.pdf/;
		print "   + Converting $ps to PDF...";
		if( $verbose ) {
			my $remaining = ( $#toupdate + 1 ) + ( $#toconvert + 1 - $i_ps ) - 1;
			if( $remaining > 0 && ( $remaining % 10 == 0 || $i_ps == 0 ) ) {
				print "        ($remaining remaining)";
			}
		}
		print "\n";
		system("ps2pdf","$pic_dir/$ps","$pdf_dir/$pdf_name");
	}
	for( $i_ps = 0; $i_ps <= $#toupdate; $i_ps ++ ) {
		$ps = $toupdate[$i_ps];
		$pdf_name = $ps;
		$pdf_name =~ s/\.ps$/.pdf/;
		print "   * Updating $ps to PDF...";
		if( $verbose ) {
			my $remaining = ( $#toupdate + 1 - $i_ps ) - 1;
			if( $remaining > 0 && ( $remaining % 10 == 0 || $i_ps == 0 ) ) {
				print "   ($remaining remaining)";
			}
		}
		print "\n";
		system("ps2pdf","$pic_dir/$ps","$pdf_dir/$pdf_name");
	}
}

return 1;

