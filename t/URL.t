#!/usr/bin/perl
#
# Daybo Logic Podcast downloader
# Copyright (C) 2012-2024, Ducan Ross Palmer (M6KVM, 2E0EOL), all rights reserved.
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
#     * Redistributions of source code must retain the above copyright notice,
#       this list of conditions and the following disclaimer.
#
#     * Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in the
#       documentation and/or other materials provided with the distribution.
#
#     * Neither the name of the Daybo Logic nor the names of its contributors
#       may be used to endorse or promote products derived from this software
#       without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.

package URLTests;
use lib 'externals/libtest-module-runnable-perl/lib';
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
use Devel::Cover;

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

	Readonly my @VALID_SCHEMES => (qw(http https ftp mailto ssh));
	plan tests => scalar(@VALID_SCHEMES);

	foreach my $scheme (@VALID_SCHEMES) {
		lives_ok { ref($self)->new(scheme => $scheme) } $scheme;
	}

	return EXIT_SUCCESS;
}

sub testParseSuccess {
	my ($self) = @_;
	plan tests => 6;

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

	$url = 'ftp://username:password@host/path';
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
					user     => 'username',
					pass     => 'password',
					host     => 'host',
					port     => undef,
					path     => '/path',
					query    => undef,
					fragment => undef,
				),
			),
		),
	), $url);

	$url = 'ssh://username@host/path';
	cmp_deeply($self->sut->create($url), all(
		isa('Dlpodget::Response'),
		methods(
			success => bool(1),
			getData => all(
				isa('Dlpodget::URL'),
				methods(
					value    => $url,
					toString => $url,
					scheme   => 'ssh',
					user     => 'username',
					pass     => undef,
					host     => 'host',
					port     => undef,
					path     => '/path',
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
	plan tests => 2;

	Readonly my $PORT => $self->unique;

	my $url = 'invalid_scheme://www.daybologic.co.uk/secret/file';
	cmp_deeply($self->sut->create($url), all(
		isa('Dlpodget::Response'),
		methods(
			success => bool(0),
		),
	), $url);

	$url = sprintf('http://%s:%d/path/dir', $self->uniqueDomain(), $PORT);
	cmp_deeply($self->sut->create($url), all(
		isa('Dlpodget::Response'),
		methods(
			success => bool(1),
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
