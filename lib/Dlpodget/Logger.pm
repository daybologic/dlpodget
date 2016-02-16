#!/usr/bin/perl -w
#
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

package Dlpodget::Logger;
use Moose;
use strict;
use warnings;

extends 'Dlpodget::Base';

use constant LOGLEVEL_FATAL => (9);
use constant LOGLEVEL_CRIT  => (8);
use constant LOGLEVEL_ERROR => (7);
use constant LOGLEVEL_WARN  => (6);
use constant LOGLEVEL_INFO  => (5);

sub log($$$@) {
	my ( $self, $level, $format, @args ) = @_;
	my $ret;

	# TODO: Ignore the log level for now.
	if ( $self->mock ) {
		$ret = scalar(@args);
	} else {
		$ret = printf($format, @args);
	}

	return $ret;
}

1;
