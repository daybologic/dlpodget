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
use Dlpodget::Errors;

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

sub testFailure {
	my ($self) = @_;
	plan tests => 2;

	Readonly my $DATA => '54a671b4-96c1-4021-aa57-795d19641d1a';

	my $response = Dlpodget::Response->new(
		success => 0,
		data => $DATA,
		error => Dlpodget::Errors->instance->fetchById($Dlpodget::Errors::FILE_NOT_FOUND),
	);

	cmp_deeply($response, all(
		isa('Dlpodget::Response'),
		methods(
			success => bool(0),
			toString => "Failure <$DATA>",
		),
	), 'deep state');

	my $errorMsg = 'Attempt to fetch data for failure response at lib';
	throws_ok { $response->getData() } qr/^$errorMsg/, $errorMsg;

	return EXIT_SUCCESS;
}

package main;
use strict;
exit(ResponseTests->new->run);
