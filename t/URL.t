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
		value => $self->uniqueDomain(),
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

sub testRO {
	my ($self) = @_;
	plan tests => 2;

	throws_ok { $self->sut->scheme($self->sut->scheme) } qr/read-only/, 'scheme cannot be changed';
	throws_ok { $self->sut->value($self->sut->value) } qr/read-only/, 'value cannot be changed';

	return EXIT_SUCCESS;
}

sub testSchemeUnacceptable {
	my ($self) = @_;
	plan tests => 1;

	throws_ok { ref($self->sut)->new(value => $self->uniqueDomain(), scheme => $self->unique) } qr/constraint/,
	    'Constraint fail';

	return EXIT_SUCCESS;
}

sub testSchemeAcceptable {
	my ($self) = @_;

	Readonly my @VALID_SCHEMES => (qw(http https ftp mailto));
	plan tests => scalar(@VALID_SCHEMES);

	foreach my $scheme (@VALID_SCHEMES) {
		lives_ok { ref($self)->new(scheme => $scheme) } $scheme;
	}

	return EXIT_SUCCESS;
}

sub uniqueDomain {
	my ($self) = @_;
	return sprintf('x%d.test', $self->unique);
}

package main;
use strict;
exit(URLTests->new->run);
