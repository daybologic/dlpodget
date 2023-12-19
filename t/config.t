#!/usr/bin/perl -w
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

package ConfigTests;
use Moose;

use lib 'externals/libtest-module-runnable-perl/lib';
use Dlpodget::Config;
use File::Temp qw(tempfile);
use POSIX qw(EXIT_FAILURE EXIT_SUCCESS);
use Readonly;
use Test::More 0.96;
#use Devel::Cover;

extends 'Test::Module::Runnable';

Readonly my $NON_EXISTENT_FILE => '/tmp/4d687206-9eb1-11ee-98ed-a7fe17edd902';

sub setUp {
	my ($self) = @_;
	$self->sut(Dlpodget::Config->new());
	return EXIT_SUCCESS;
}

sub testType {
	my ($self) = @_;
	plan tests => 1;

	isa_ok($self->sut(Dlpodget::Config->new()), 'Dlpodget::Config', 'new type');

	return EXIT_SUCCESS;
}

sub testLoadNothing {
	my ($self) = @_;
	plan tests => 2;

	is($self->sut->load(), EXIT_SUCCESS, 'success (no-op)');
	is($self->sut->ini, undef, 'ini <undef>');

	return EXIT_SUCCESS;
}

sub testLoadSuccess {
	my ($self) = @_;
	plan tests => 2;

	my ($fh, $filename) = tempfile();
	$self->sut(Dlpodget::Config->new({
		confFiles => [
			$NON_EXISTENT_FILE,
			$filename,
		],
	}));

	print($fh "; Comment\n");
	print($fh "[section]\n");
	print($fh "key = 'value'\n");

	close($fh);

	is($self->sut->load(), EXIT_SUCCESS, 'returned success');
	isa_ok($self->sut->ini, 'Config::IniFiles', 'ini');

	return EXIT_SUCCESS;
}

sub testLoadFailure {
	my ($self) = @_;
	plan tests => 2;

	my ($fh, $filename) = tempfile();
	$self->sut(Dlpodget::Config->new({
		confFiles => [
			$NON_EXISTENT_FILE,
			$filename,
		],
	}));

	is($self->sut->load(), EXIT_FAILURE, 'returned failure');
	is($self->sut->ini, undef, 'ini <undef>');

	return EXIT_SUCCESS;
}

package main;
use strict;
use warnings;

exit(ConfigTests->new()->run());
