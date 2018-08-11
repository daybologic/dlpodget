#!/usr/bin/perl
package URLTests;
use strict;
use warnings;
use Moose;

extends 'Test::Module::Runnable';

use Cache::MemoryCache;
use Dlpodget::URL;
use English qw(-no_match_vars);
use Dlpodget::DIC;
use POSIX;
use Test::Deep qw(cmp_deeply all isa methods bool re);
use Test::Exception;
use Test::More;
use Readonly;

Readonly my $DEFAULT_SCHEME => 'http';

sub setUp {
	my ($self) = @_;

	$self->sut(Dlpodget::URL->new(
		value => sprintf('x%d.test', $self->unique),
	));

	#$self->forcePlan();

	return EXIT_SUCCESS;
}

sub testDefaultScheme {
	my ($self) = @_;
	plan tests => 1;

	is($self->sut->scheme, $DEFAULT_SCHEME, "default scheme is $DEFAULT_SCHEME");

	return EXIT_SUCCESS;
}

sub testToString {
	my ($self) = @_;
	plan tests => 1;

	is($self->sut->toString(), sprintf('%s://%s', $self->sut->scheme, $self->sut->value), 'toString');

	return EXIT_SUCCESS;
}

package main;
use strict;
exit(URLTests->new->run);
