#!/usr/bin/perl -w

package main;
use Test::More tests => 1;
use Devel::Cover;
use Getopt::Std;
use strict;
use warnings;

require 'dlpodget';

#use constant BLAH             => (10);

sub t_obj() {
	my $F = 'obj';
	my $o = new OurConfig;
	isa_ok($o, 'OurConfig');
}

sub getOpts(%) {
	my %P = @_;
	my $O;
	my $ret;

	return 1 if ( scalar(@_) % 2 );
	die 'assert' unless ( $P{'output'} && $P{'tests'} );
	$O = $P{'output'};
	$ret = getopts('n:d?h', $O);
	return $ret if ( !$ret );

	$O->{'h'} = 1 if ( $O->{'?'} );

	while ( my ( $o, $v ) = each(%$O) ) {
		if ( $o eq 'n' ) {
			unless ( $v ~~ $P{'tests'} ) {
				die(sprintf(
					'Argument %s to -n, is not a known test',
					$v
				));
			}
		}
	}

	if ( $O->{'h'} ) {
		ut_syntax();
		$ret = 0;
	}
	return $ret;
}

sub t_main() {
	my %opts = ( );
	my %tests = (
		'obj' => \&t_obj,
	);
	return 1 unless ( getOpts(output => \%opts, tests => [ keys(%tests) ]) );
	while ( my ( $name, $func ) = each(%tests) ) {
		next unless ( !$opts{'n'} || $opts{'n'} eq $name );
		subtest $name => $func;
	}
	return 0;
}

exit(t_main());
