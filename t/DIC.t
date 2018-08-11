#!/usr/bin/env perl
#
# Daybo Logic Podcast downloader
# Copyright (c) 2012-2018, Duncan Ross Palmer (2E0EOL) and others,
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

package DICTests;
use Moose;
extends 'Test::Module::Runnable';

use Cache::MemoryCache;
use Dlpodget::DIC;
use English qw(-no_match_vars);
use POSIX qw(EXIT_SUCCESS);
use Test::Deep qw(cmp_deeply all isa methods bool re);
use Test::Exception;
use Test::Module::Runnable;
use Test::More 0.96;

sub testSingleton {
	my ($self) = @_;
	plan tests => 2;

	isa_ok($self->sut(Dlpodget::DIC->instance()), 'Dlpodget::DIC', 'instance');
	is(Dlpodget::DIC->instance(), $self->sut, 'subsequent instance call returns same object');

	return EXIT_SUCCESS;
}

sub testMisuse {
	my ($self) = @_;
	plan tests => 2;

	isa_ok($self->sut(Dlpodget::DIC->new()), 'Dlpodget::DIC', 'new');

	throws_ok { $self->sut->set(undef) } qr@^No object sent to DIC/set @,
	    'undef passed to set';

	return EXIT_SUCCESS;
}

package main;
use strict;
use warnings;
exit(DICTests->new->run());
