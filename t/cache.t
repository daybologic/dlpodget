#!/usr/bin/perl
# Daybo Logic Podcast downloader
# Copyright (c) 2012-2014, David Duncan Ross Palmer (M6KVM), Daybo Logic
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
use Dlpodget::Base;
use Cache::MemoryCache;
use Test::More tests => 3;

use strict;
use warnings;

use constant TOKEN => '3db6cd60-f5cf-11e4-a93e-feff0000172f';
use constant DATA  => '289f33a1-f637-11e4-a93e-feff0000172f';

my $obj = new Dlpodget::Base;

sub cacheKey {
	my $ref = 'Dlpodget::Base/';
	is($obj->cacheKey(TOKEN), $ref.TOKEN, 'token -> key');
	is($obj->cacheKey(undef), $ref.'0', 'token undef');

	plan tests => 2;
}

sub cacheGet {
	is($obj->cacheGet(TOKEN), undef, 'get token not stored');
	$obj->cacheSet(TOKEN, DATA, 2);
	is($obj->cacheGet(TOKEN), DATA, 'get token just stored');
	sleep(2);
	is($obj->cacheGet(TOKEN), undef, 'get token expired');

	plan tests => 3;
}

sub cacheSet {
}


sub main {
	can_ok($obj, qw/cache cacheKey cacheSet cacheGet/);
	my $cache = new Cache::MemoryCache;

	$obj->cache($cache);
	subtest 'cacheKey' => \&cacheKey;
	subtest 'cacheGet' => \&cacheGet;
	#subtest 'cacheSet' => \&cacheSet;

	return EXIT_SUCCESS;
}

exit(main());
