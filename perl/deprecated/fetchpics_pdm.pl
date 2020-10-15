#!/usr/bin/perl
## Script written and mantained by GI
## Used to write the file containing all the picture filenames needed to be converted from ps to eps for my Master's Thesis
$shot = "40080";
$t0 = "0.8";
#@reports  = ( "pdm_GaelINDUNI_defense.tex" );
@reports = @ARGV;
@picgen = ();
$picpath = "../matlab/pics";
@default_figs = ( 'te', 'LTe', 'ne', 'Lne', 'ti', 'p_e', 'jtot', 'ibsped', 'q', 'shear', 'upl' );
@default_cycle = ( 'te', 'LTe', 'ne', 'Lne', 'ti', 'p_e', 'jtot', 'ibsped', 'q', 'shear', 'upl' );
@default_profs = ( 'te', 'lte', 'ne', 'lne', 'ti', 'p_e', 'itot', 'ibs', 'q', 'shear', 'upl' );

foreach $report( @reports ) {
	print "  Reading $report...\n";
	open( REP, "<", $report ) or die( " Report not openable :-(\n" );
	@rep = <REP>;
	close(REP);
	$repinline = join(' ',@rep);
	$repinline =~ s/  +/ /g;
	$repinline =~ s/\\subfloat\[\\footnotesize[^\]]*\]\{//g;
	chomp( $repinline );
	@repsplit = split( ' ',$repinline );
	foreach $r( @repsplit ) {
		chomp( $r );
		if( $r =~ /^\\/ && $r !~ /\#/ && $r !~ /thisArg/ ) {
			if( $r =~ /includegraphics/ ) {
			# Standard case #
				$r =~ s/^.*includegraphics(\[[^\]]*\])?\{//;
				$r =~ s/\}.*$//;
				$picname = "$r ";
				push( @picgen, $picname );
			} elsif( $r =~ /AllFigs/ && $r !~ /newenvironment/ && $r !~ /Ref/ && $r !~ /Sub/ && $r !~ /\\end/ ) {
			# AllFigs #
				$case = $r;
				$case =~ s/^.*AllFigs\}\{([^}]*)\}.*/\1/;
				$rho = $r;
				$rho =~ s/^.*AllFigs\}(\{[^}]*\}){2}\{([^}]*)\}.*/\2/;
				$candidate = $r;
				$candidate =~ s/^.*AllFigs\}(\{[^}]*\}){5}\{([^}]*)\}.*/\2/;
				if( $candidate =~ /resultsplotO/ ) {
					$candidate = 'results_cycle';
				} elsif( $candidate =~ /resultsplot/ ) {
					$candidate = '_results_'.$case;
				} else {
					$candidate = "rhosOK_$case";
				}
				$r =~ s/^.*AllFigs\}(\{[^}]*\}){3}\{([^}]*)\}.*/\2/;
				@qqs = split( ',', $r );
				foreach $q( @qqs ) {
					if( $candidate =~ /^_results/ ) {
						$picname1 = "$picpath/$shot"."_$t0"."_$q"."_0.754$candidate.eps ";
						$picname2 = "$picpath/$shot"."_$t0"."_$q"."_0.860$candidate.eps ";
						push( @picgen, $picname1 );
						push( @picgen, $picname2 );
					} else {
						$picname = "$picpath/$shot"."_$t0"."_$q"."_$candidate.eps ";
						push( @picgen, $picname );
					}
				}
			}
		}
	}
}

# Print GEN
$filegen = "picgen.mk";
open(GEN,">",$filegen) or die( " picgen cannot be written\n" );
print GEN "PICGEN = ";
foreach $p( @picgen ) {
	print GEN $p;
}
close(GEN);

exit 0;
