#!/usr/bin/perl -w
# Daybo Logic Podcast downloader
# Copyright (c) 2012-2015, David Duncan Ross Palmer (2E0EOL), Daybo Logic
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

use Test::More tests => 2;
use Test::Output;
use Devel::Cover;
use Dlpodget::Logger;

use strict;
use warnings;
use diagnostics;

my $Debug = 0; # TODO Need shared getopts() handling!

sub logWrapper($$$@) {
	my ( $expectOutput, $expectRet, $logger, $level, $format, @args ) = @_;
	my $ret = undef;

	my $logCall = sub {
		$ret = $logger->log($level, $format, @args);
	};

	stdout_is(sub { $logCall->() }, $expectOutput, 'Output as expected');
	is($ret, $expectRet, 'Return from printf is as expected');
}

sub t_log() {
	my $logger = new Dlpodget::Logger;
	my ( $format, @args );

	srand(0); # Not so random!
	( $format, @args ) = ( 'Test message %d', int(rand()*9999) );
	logWrapper('Test message 1708', scalar(@args), $logger, 0, $format, @args);

	return 0;
}

exit(t_log()) unless ( caller() );
1;