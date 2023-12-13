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

package FeedsTests;
use lib 'externals/libtest-module-runnable-perl/lib';
use Moose;

extends 'Test::Module::Runnable';

use Cache::MemoryCache;
use Dlpodget::Feeds;
use English qw(-no_match_vars);
use Dlpodget::DIC;
use POSIX;
use Test::Deep qw(cmp_deeply all isa methods bool re);
use Test::Exception;
use Test::More;
use Devel::Cover;

sub ____setUp {
	my ($self) = @_;

	$self->dic(Dlpodget::DIC->new(
		logger => Dlpodget::Log::Mock->new,
		cache => Cache::MemoryCache->new,
		config => Dlpodget::Config::Mock->new({
			#VOIPDB => Dlpodget::DB::Mock->makeConfig(), # Enable this if you will call an init() to set up DBs
		}),
		#voipdb => Dlpodget::DB::Mock->new, # Enable this if you want to pass a DB directly
	));

	$self->sut(Dlpodget::Feeds->new(
		dic => $self->dic,
		#dicRequire => 1, # Enable this for new libraries which should only use the DIC
	));

	$self->forcePlan();
	$self->dic->logger->warnFatal(1); # disable in specific tests if needed

	return EXIT_SUCCESS;
}

sub testSomething {
	my ($self) = @_;
	plan tests => 1;

	ok('FIXME');

	return EXIT_SUCCESS;
}

package main;
use strict;
use warnings;
exit(FeedsTests->new->run);
