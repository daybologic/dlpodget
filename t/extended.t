#!/usr/bin/perl -w

package main;
use Test::More tests => 1;
use Devel::Cover;
use strict;
use warnings;
use diagnostics;

require 'dlpodget';

sub t_rSleep() {
	plan tests => 13;

	my $paul = Muadeeb->new(mock => 1);
	is($paul->rSleep(undef), 0, 'rSleep undef 0');
	is($paul->rSleep(0), 0, 'rSleep 0 0');
	is($paul->rSleep(1), 1, 'rSleep 1 1');
	is($paul->rSleep(-1), -1, 'rSleep -1 -1');
	is($paul->rSleep(-2), -1, 'rSleep -2 -1');
	is($paul->rSleep('blah'), -1, 'rSleep blah -1');
	is($paul->rSleep(10), 10, 'rSleep 10 10');

	# Random tests
	srand(0); # Ensure we always start from a deterministic point
	my @sleepTimes = ( qw/2 8 1 9 6/ );
	is($paul->rSleep('10R'), -1, 'rSleep 10R -1');
	foreach my $v ( @sleepTimes ) {
		is($paul->rSleep('10r'), $v, "rSleep 10r $v");
	}
}

sub t_main() {
	my %opts = ( );
	my %tests = (
		'rSleep'      => \&t_rSleep,
	);
	while ( my ( $name, $func ) = each(%tests) ) {
		next unless ( !$opts{'n'} || $opts{'n'} eq $name );
		subtest $name => $func;
	}
	return 0;
}

exit(t_main());
