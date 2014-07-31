#!/usr/bin/perl -w
#
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

package Dlpodget::Muadeeb; # Father, the sleeper has awakened!
use Moose;
use strict;
use warnings;

# TODO: Should derive from LocalBase or it's successor.
#extends 'LocalBase';

# TODO: this debug flag should be inherited from LocalBase, or it's successor.
has ['mock','debug']       => (
	'isa'     => 'Bool',
	'is'      => 'ro',
	'default' => 0,
);

#TODO: Rename time, a perioSecs is not /the time/ and that's confusing ;)
# I mean it's not the actual time of date innum?
sub rSleep($$) {
	my ( $self, $time ) = @_;
	return 0 unless ( $time );

	if ( $time =~ m/^(\d+)r$/o ) {
		$time = int(rand($1)) + 1;
	} elsif ( $time !~ m/^\d+$/o ) {
		return -1;
	}

	printf(STDERR "Sleeping %u seconds\n", $time) # TODO: Need logging component
		if ( $self->debug );

	sleep($time) unless( $self->mock );
	return $time;
}

1;
