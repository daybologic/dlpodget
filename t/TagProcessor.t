#!/usr/bin/perl
#
# Daybo Logic Podcast downloader
# Copyright (c) 2012-2016, David Duncan Ross Palmer (2E0EOL) and others,
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

use Dlpodget::TagProcessor;
use Test::More 0.96;
use POSIX;
use strict;
use warnings;

sub t_processTags($) {
	my $F = 'processTags';
	my $obj = shift;
	my %testData = (
		'DUMMYA' => '$DUMMYC',
		'DUMMYB' => '/tmp/2',
		'DUMMYC' => '/tmp/3'
	);

	plan tests => keys(%testData) * 2;

	while ( my ( $tag, $subst ) = each(%testData) ) {
		$obj->assoc($tag, $subst);
	}

	while ( my ( $tag, $subst ) = each(%testData) ) {
		is($obj->value($tag), $subst, sprintf('Value of tag %s is %s', $tag, $subst));
	}

	is($obj->result('blah$DUMMYAbleh'), 'blah/tmp/3bleh', "$F: A");
	is($obj->result('blah$DUMMYBgrowl'), 'blah/tmp/2growl', "$F: B");
	is($obj->result('$'), '$', "$F: Illegal variable");
}

sub t_main() {
	plan tests => 3;

	my @methods = qw( assoc value result );
	my $obj = new Dlpodget::TagProcessor;

	isa_ok($obj, 'Dlpodget::TagProcessor');
	can_ok($obj, @methods);

	subtest 'processTags' => sub { t_processTags($obj) };

	return EXIT_SUCCESS;
}

exit(t_main()) unless (caller());
1;
