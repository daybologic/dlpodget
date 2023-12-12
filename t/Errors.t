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
use Readonly;

sub setUp {
	my ($self) = @_;

	$self->sut(Dlpodget::Errors->instance);

	#$self->forcePlan();

	return EXIT_SUCCESS;
}

sub tearDown {
	my ($self) = @_;
	$self->clearMocks();
	return EXIT_SUCCESS;
}

sub testFetchAndToString {
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

sub testFetchInvalid {
	my ($self) = @_;
	plan tests => 2;

	my $error = $self->sut->fetchById('03078508-a308-11e8-89e8-f23c9173fe51');
	is($error->toString(), 'No such error', 'NO_SUCH_ERROR');

	$error = $self->sut->fetchById($self->unique);
	is($error->toString(), 'The UUID is corrupt or illegal', 'INVALID_UUID');

	return EXIT_SUCCESS;
}

sub testFetchTheoreticaFail {
	my ($self) = @_;
	plan tests => 1;

	$self->mock('Dlpodget::UUID::Factory', 'create', [
		sub {
			return Dlpodget::Response->new(success => 0);
		}, sub {
			return Dlpodget::Response->new(success => 0);
		}
	]);

	throws_ok {
		$self->sut->fetchById($self->unique);
	} qr/^$Dlpodget::Errors::INTERNAL /, 'Fatal INTERNAL';

	return EXIT_SUCCESS;
}

package main;
use strict;
exit(ErrorsTests->new->run);
