#!/usr/bin/perl
package ErrorsTests;
use strict;
use warnings;
use Moose;
extends 'Test::Module::Runnable';

use Cache::MemoryCache;
use Dlpodget::Errors;
use English qw(-no_match_vars);
use POSIX;
use Test::Deep qw(cmp_deeply all isa methods bool re);
use Test::Exception;
use Test::More 0.96;

sub setUp {
	my ($self) = @_;

	$self->sut(Dlpodget::Errors->instance);

	#$self->forcePlan();

	return EXIT_SUCCESS;
}

sub testSomething {
	my ($self) = @_;
	plan tests => 10;

	my $error = $self->sut->fetchById($Dlpodget::Errors::URL_PARSE);
	is($error->toString(), 'The URL cannot be parsed', 'URL_PARSE');

	$error = $self->sut->fetchById($Dlpodget::Errors::INVALID_UUID);
	is($error->toString(), 'The UUID is corrupt or illegal', 'INVALID_UUID');

	$error = $self->sut->fetchById($Dlpodget::Errors::INVALID_DIRECTION);
	is($error->toString(), 'Direction must be encode or decode', 'INVALID_DIRECTION');

	$error = $self->sut->fetchById($Dlpodget::Errors::MUST_SUPPLY_FILENAME);
	is($error->toString(), 'Must supply filename', 'MUST_SUPPLY_FILENAME');

	$error = $self->sut->fetchById($Dlpodget::Errors::FILE_NOT_FOUND);
	is($error->toString(), 'File does not exist', 'FILE_NOT_FOUND');

	$error = $self->sut->fetchById($Dlpodget::Errors::UNKNOWN_CODEC);
	is($error->toString(), 'Unknown codec', 'UNKNOWN_CODEC');

	$error = $self->sut->fetchById($Dlpodget::Errors::ASSERT_FAIL);
	is($error->toString(), 'Assertion failure', 'ASSERT_FAIL');

	$error = $self->sut->fetchById($Dlpodget::Errors::FORK);
	is($error->toString(), 'Process fork/spawn failure', 'FORK');

	$error = $self->sut->fetchById($Dlpodget::Errors::INTERNAL);
	is($error->toString(), 'Internal error', 'INTERNAL');

	$error = $self->sut->fetchById($Dlpodget::Errors::NO_SUCH_ERROR);
	is($error->toString(), 'No such error', 'NO_SUCH_ERROR');

	return EXIT_SUCCESS;
}

package main;
use strict;
exit(ErrorsTests->new->run);
