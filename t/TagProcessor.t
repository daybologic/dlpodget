#!/usr/bin/perl -w

use Dlpodget::TagProcessor;
use Test::More tests => 2;
use POSIX;
use strict;
use warnings;

sub t_main() {
	my @methods = qw(
		assoc
		value
		result
	);

	my $obj = new Dlpodget::TagProcessor;

	isa_ok($obj, 'Dlpodget::TagProcessor');
	can_ok($obj, @methods);

	return EXIT_SUCCESS;
}

exit(t_main()) unless (caller());
1;
