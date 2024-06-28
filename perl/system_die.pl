sub system_return()
{
	## System arguments are within a list:
	@system_cmd = ();
	while( $_[0] ne "zgrlmf" ) {
		push(@system_cmd,shift(@_));
	}
	shift(@_);

	$file_handle = "";
	if( $#_ > 0 ) {
		$file_handle = shift(@_);
	}
	$error_message = shift(@_);
	$error_message = "\n*** $error_message ***\n";


	if( system( @system_cmd ) != 0 ) {
		$bktex_dir = latex_bktex_dir();
		@kept_exts = latex_kept_exts();
		@file_exts = latex_tmp_exts();
		@half_exts = latex_half_exts();

		## Need LaTeX log to check when errors rise
		system("mv", "$filename.log", "$bktex_dir/$filename.log");

		foreach $f( @kept_exts ) {
			if( -f "$filename.$f" ) {
				if( ! -f "$bktex_dir/$filename.$f" ) {
					system("mv","$filename.$f","$bktex_dir/$filename.$f");
				} else {
					system("rm","$filename.$f");
				}
			}
		}
		foreach $f( @file_exts ) {
			if( -f "$filename.$f" ) {
				system("rm","$filename.$f");
			}
		}
		foreach $f( @half_exts ) {
			if( -f "$filename.$f" ) {
				system("rm","$filename.$f");
			}
		}
		if( $file_handle ne "" ) {
			print $file_handle $error_message;
		}
		die( $error_message );
	}
}

return 1;
