#!/usr/bin/perl

use strict;
BEGIN {
	$|  = 1;
	$^W = 1;
}

use Test::More tests => 10;
use File::Spec;
use t::lib::Test;
require ExtUtils::MakeMaker;

sub _read {
	local *FH;
	if ( $] >= 5.006 ) {
		open( FH, '<', $_[0] ) or die "open($_[0]): $!";
	} else {
		open( FH, "< $_[0]"  ) or die "open($_[0]): $!";
	}
	my $string = do { local $/; <FH> };
	close FH or die "close($_[0]): $!";
	return $string;
}

# Regular build
SCOPE: {
	ok( create_dist('Foo'), 'create_dist' );
	ok( run_makefile_pl('Foo',(run_params=>['PREREQ_PRINT >test'])),  'build_dist'  );
	my $file=File::Spec->catfile(qw(t Foo test));
	ok( -f $file);
	my $content=_read($file);
	ok( $content,'file is not empty');
	ok( $content =~ s/^.*\$PREREQ_PM = \{/\$PREREQ_PM = {/s,'PREREQ_PM found');
	our ($PREREQ_PM, $MIN_PERL_VERSION, $BUILD_REQUIRES);
	eval ($content);
	ok( !$@,'correct content');
	ok( exists $PREREQ_PM->{'File::Spec'});
	if ( eval($ExtUtils::MakeMaker::VERSION) < 6.55_03 ) {
		ok( exists $PREREQ_PM->{'ExtUtils::MakeMaker'});
		ok( !exists $BUILD_REQUIRES->{'ExtUtils::MakeMaker'});
	} else { #best to check both because user can have any version
		ok( exists $BUILD_REQUIRES->{'ExtUtils::MakeMaker'});
		ok( !exists $PREREQ_PM->{'ExtUtils::MakeMaker'});
	}
	ok( kill_dist('Foo'),   'kill_dist'   );
}
