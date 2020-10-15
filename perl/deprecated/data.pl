#!/usr/bin/perl
######### Sorting interesting informations for the matlab files ############
$alcor_dir = "../parallel/Alcor/";
$vega_dir = "../parallel/Vega/";
$timesA = "alcor_times.dat";
$itersA = "alcor_iter.dat";
$timesV = "vega_times.dat";
$itersV = "vega_iter.dat";
### ALCOR ###
opendir( DIR, $alcor_dir ) or die( 'Cannot open directory' . $alcor_dir . '...' );
@filesA = readdir( DIR );
closedir( DIR );
unlink( $timesA );
unlink( $itersA );
open( TIM, ">>" . $timesA );
open( ITER, ">>" . $itersA );
for( $i = 1; $i <= 24; ++$i ) {
	foreach $fileA( @filesA ) {
		if( $fileA =~ m/lap$i-160_ALCOR\.sh\.o/ || $fileA =~ m/L$i-ALCOR\.sh\.o/ ) {
			open( fA, $alcor_dir . $fileA ) or die( 'Sorry, can\'t open ' . $fileA . '...' );
			while( my $in = <fA> ) {
				if( $in =~ m/TOTAL RUNNING TIME/ ) {
					$in =~ s/^.*: *//;
					$in =~ s/ ms.*$//;
					$in =~ s/([0-9]{3})$/\.\1/;
					chomp( $in );
					print TIM $in . " ";
				}
				if( $in =~ m/Done/ ) {
					$in =~ s/^.*Iterations: //;
					$in =~ s/ *Residual.*$//;
					chomp( $in );
					print ITER $in . " ";
				}
			}
			close( fA );
		}
	}
	print TIM "\n";
	print ITER "\n";
}
close( TIM );
close( ITER );

### VEGA ###
opendir( DIR, $vega_dir ) or die( 'Cannot open directory' . $vega_dir . '...' );
@filesV = readdir( DIR );
closedir( DIR );
unlink( $timesV );
unlink( $itersV );
open( TIM, ">>" . $timesV );
open( ITER, ">>" . $itersV );
for( $i = 1; $i <= 24; ++$i ) {
	foreach $fileV( @filesV ) {
		if( $fileV =~ m/lap$i-160_VEGA\.sh\.o/ || $fileV =~ m/L$i-VEGA\.sh\.o/ ) {
			open( fV, $vega_dir . $fileV ) or die( 'Sorry, can\'t open ' . $fileV . '...' );
			while( my $in = <fV> ) {
				if( $in =~ m/TOTAL RUNNING TIME/ ) {
					$in =~ s/^.*: *//;
					$in =~ s/ ms.*$//;
					$in =~ s/([0-9]{3})$/.\1/;
					chomp( $in );
					print TIM $in . " ";
				}
				if( $in =~ m/Done/ ) {
					$in =~ s/^.*Iterations: //;
					$in =~ s/ *Residual.*$//;
					chomp( $in );
					print ITER $in . " ";
				}
			}
			close( fV );
		}
	}
	print TIM "\n";
	print ITER "\n";
}
close( TIM );
close( ITER );

exit 0;

