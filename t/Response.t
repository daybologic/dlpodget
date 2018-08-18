#!/usr/bin/perl
package ResponseTests;
use Moose;

extends 'Test::Module::Runnable';

use Dlpodget::Response;
use English qw(-no_match_vars);
use POSIX;
use Test::Deep qw(cmp_deeply all isa methods bool re);
use Test::Exception;
use Test::More;
use Readonly;

sub testSuccess {
	my ($self) = @_;
	plan tests => 1;

	Readonly my $DATA => 'e6a01ea4-25c2-4df3-8e85-50eb29d6485c';

	my $response = Dlpodget::Response->new(success => 1, data => $DATA);
	cmp_deeply($response, all(
		isa('Dlpodget::Response'),
		methods(
			success => bool(1),
			getData => $DATA,
			toString => "Success <$DATA>",
		),
	), 'deep state');

	return EXIT_SUCCESS;
}

package main;
use strict;
exit(ResponseTests->new->run);
