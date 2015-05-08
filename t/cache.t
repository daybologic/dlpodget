#!/usr/bin/perl

package main;
use POSIX qw/EXIT_SUCCESS/;
use Dlpodget::Base;
use Test::More tests => 1;

use strict;
use warnings;

sub main {
	my $obj = new Dlpodget::Base;
	can_ok($obj, qw/cacheKey cacheSet cacheGet/);

	return EXIT_SUCCESS;
}

exit(main());
