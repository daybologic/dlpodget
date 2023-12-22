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

package main;
use POSIX qw/EXIT_SUCCESS/;
use Cache::MemoryCache;
use Dlpodget::Cache;
use Dlpodget::DIC;
use Dlpodget::Object;
use Readonly;
use Test::More;
use Devel::Cover;

use strict;
use warnings;

Readonly my $TOKEN => '3db6cd60-f5cf-11e4-a93e-feff0000172f';
Readonly my $DATA  => '289f33a1-f637-11e4-a93e-feff0000172f';

my $sut;

sub cacheKey {
	plan tests => 2;

	my $ref = 'Dlpodget::Cache/';

	is($sut->dic->cache->cacheKey($TOKEN), $ref.$TOKEN, 'token -> key');
	is($sut->dic->cache->cacheKey(undef), $ref.'0', 'token undef');

	return;
}

sub cacheGet {
	plan tests => 3;

	is($sut->dic->cache->cacheGet($TOKEN), undef, 'get token not stored');
	$sut->dic->cache->cacheSet($TOKEN, $DATA, 2);
	is($sut->dic->cache->cacheGet($TOKEN), $DATA, 'get token just stored');
	sleep(2);
	is($sut->dic->cache->cacheGet($TOKEN), undef, 'get token expired');

	return;
}

sub xyz {
	plan tests => 5;

	isa_ok($sut, 'Dlpodget::Object');
	isa_ok($sut->dic, 'Dlpodget::DIC');
	isa_ok($sut->dic->cache, 'Dlpodget::Cache');
	isa_ok($sut->dic->cache->cache, 'Cache::Null');

	$sut->dic->cache->cache(Cache::MemoryCache->new());

	isa_ok($sut->dic->cache->cache, 'Cache::MemoryCache');

	return;
}

sub main {
	plan tests => 4;

	$sut = Dlpodget::Object->new({
		dic => Dlpodget::DIC->new(),
	});

	can_ok($sut->dic->cache, qw/cache cacheKey cacheSet cacheGet/);

	subtest 'xyz' => \&xyz;
	subtest 'cacheKey' => \&cacheKey;
	subtest 'cacheGet' => \&cacheGet;

	return EXIT_SUCCESS;
}

exit(main());
