#!/usr/bin/perl
package URLTests;
use strict;
use warnings;
use Moose;

extends 'Test::Module::Runnable';

use Cache::MemoryCache;
use Dlpodget::URL;
use Dlpodget::URL::Factory;
use English qw(-no_match_vars);
use Dlpodget::DIC;
use POSIX;
use Test::Deep qw(cmp_deeply all isa methods bool re);
use Test::Exception;
use Test::More;
use Readonly;

sub setUp {
	my ($self) = @_;

	$self->sut(Dlpodget::URL::Factory->instance());

	#$self->forcePlan();

	return EXIT_SUCCESS;
}

sub testRO {
	my ($self) = @_;
	plan tests => 2;

	my $response = $self->sut->create('https://' . $self->uniqueDomain());
	BAIL_OUT($response->toString()) unless ($response->success);

	my $url = $response->getData();
	throws_ok { $url->scheme($url->scheme) } qr/read-only/, 'scheme cannot be changed';
	throws_ok { $url->value($url->value) } qr/read-only/, 'value cannot be changed';

	return EXIT_SUCCESS;
}

sub testSchemeUnacceptable {
	my ($self) = @_;
	plan tests => 1;

	throws_ok {
		Dlpodget::URL->new(value => 'http://' . $self->uniqueDomain(), host => $self->uniqueDomain, scheme => $self->unique);
	} qr/constraint/, 'Constraint fail';

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

sub testParseSuccess {
	my ($self) = @_;
	plan tests => 4;

	my $url = 'https://www.forbes.com/sites/timworstall/2013/04/29/the-possibility-of-peak-facebook/#67380a786d64';
	cmp_deeply($self->sut->create($url), all(
		isa('Dlpodget::Response'),
		methods(
			success => bool(1),
			getData => all(
				isa('Dlpodget::URL'),
				methods(
					value    => $url,
					toString => $url,
					scheme   => 'https',
					user     => undef,
					pass     => undef,
					host     => 'www.forbes.com',
					port     => undef,
					path     => '/the-possibility-of-peak-facebook',
					query    => undef,
					fragment => '#67380a786d64',
				),
			),
		),
	), $url);

	$url = 'http://thehill.com/policy/technology/technology/402063-fcc-shuts-down-pirate-radio-station-alex-jones';
	cmp_deeply($self->sut->create($url), all(
		isa('Dlpodget::Response'),
		methods(
			success => bool(1),
			getData => all(
				isa('Dlpodget::URL'),
				methods(
					value    => $url,
					toString => $url,
					scheme   => 'http',
					user     => undef,
					pass     => undef,
					host     => 'thehill.com',
					port     => undef,
					path     => '/402063-fcc-shuts-down-pirate-radio-station-alex-jones',
					query    => undef,
					fragment => undef,
				),
			),
		),
	), $url);

	$url = 'mailto:palmer@overchat.org';
	cmp_deeply($self->sut->create($url), all(
		isa('Dlpodget::Response'),
		methods(
			success => bool(1),
			getData => all(
				isa('Dlpodget::URL'),
				methods(
					value    => $url,
					toString => $url,
					scheme   => 'mailto',
					user     => 'palmer',
					pass     => undef,
					host     => 'overchat.org',
					port     => undef,
					path     => undef,
					query    => undef,
					fragment => undef,
				),
			),
		),
	), $url);

	$url = 'ftp://ftp.freebsd.org/pub/FreeBSD/README.TXT',
	cmp_deeply($self->sut->create($url), all(
		isa('Dlpodget::Response'),
		methods(
			success => bool(1),
			getData => all(
				isa('Dlpodget::URL'),
				methods(
					value    => $url,
					toString => $url,
					scheme   => 'ftp',
					user     => undef,
					pass     => undef,
					host     => 'ftp.freebsd.org',
					port     => undef,
					path     => '/pub',
					query    => undef,
					fragment => undef,
				),
			),
		),
	), $url);

	return EXIT_SUCCESS;
}

sub testParseFailure {
	my ($self) = @_;
	plan tests => 1;

	my $url = 'invalid_scheme://www.daybologic.co.uk/secret/file';
	cmp_deeply($self->sut->create($url), all(
		isa('Dlpodget::Response'),
		methods(
			success => bool(0),
		),
	), $url);

	return EXIT_SUCCESS;
}

sub uniqueDomain {
	my ($self) = @_;
	return sprintf('x%d.test', $self->unique);
}

package main;
use strict;
exit(URLTests->new->run);
