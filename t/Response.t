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

package ResponseTests;
use lib 'externals/libtest-module-runnable-perl/lib';
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
	plan tests => 4;

	Readonly my $DATA => 'e6a01ea4-25c2-4df3-8e85-50eb29d6485c';

	my $response = Dlpodget::Response->new(success => 1, data => $DATA);
	cmp_deeply($response, all(
		isa('Dlpodget::Response'),
		methods(
			success => bool(1),
			getData => $DATA,
			toString => "Success <$DATA>",
		),
	), 'deep state, with data');

	$response = Dlpodget::Response->new(success => 1);
	cmp_deeply($response, all(
		isa('Dlpodget::Response'),
		methods(
			success => bool(1),
			getData => undef,
			toString => "Success <no data>",
		),
	), 'deep state, without data');

	$response = Dlpodget::Response->new(success => 1, data => $self);
	cmp_deeply($response, all(
		isa('Dlpodget::Response'),
		methods(
			success => bool(1),
			getData => $self,
			toString => "Success <ResponseTests>",
		),
	), 'deep state, with blessed data');

	$response = Dlpodget::Response->new(success => 1, data => { });
	cmp_deeply($response, all(
		isa('Dlpodget::Response'),
		methods(
			success => bool(1),
			getData => { },
			toString => "Success <HASH>",
		),
	), 'deep state, with HASH ref data');

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

sub testRO {
	my ($self) = @_;
	plan tests => 2;

	my $response = Dlpodget::Response->new(success => 0);
	throws_ok { $response->__data($self->unique) } qr/read-only/, 'cannot set __data (RO)';
	throws_ok { $response->success(1) } qr/read-only/, 'cannot set success (RO)';

	return EXIT_SUCCESS;
}

package main;
use strict;
exit(ResponseTests->new->run);
