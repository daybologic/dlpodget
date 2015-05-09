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

package Dlpodget::Base; # All Moose objects in the script shall be derived from this.

use Cache::Null;
use Moose;

use strict;
use warnings;

has [ 'debug', 'mock' ] => (
	isa     => 'Bool',
	is      => 'rw',
	default => 0,
);

has 'cache' => (
	is => 'rw',
	default => sub { Cache::Null->new(default_expires => '600 sec') }
);

sub cacheKey {
	my ( $self, $token ) = @_;

	$token = 0 if ( !defined($token) );
	return join('/', ref($self), $token);
}

sub cacheGet {
	my ( $self, $token ) = @_;
	my $key = $self->cacheKey($token);
	warn(sprintf("cache->get(%s)\n", $key));
	return $self->cache->get($key);
}

sub cacheSet {
	my ( $self, $token, $data, $ttl ) = @_;

	$ttl = 0 unless ($ttl); # Ensure numeric zero TTL if unspecified
	#TODO: Ensure ttl is a value, make function for that
	#TODO: Warn if ttl is not a value, need a logger for that
	my $key = $self->cacheKey($token);
	my @setArgs = ( $key, $data );
	push(@setArgs, $ttl) if ($ttl);
	warn(sprintf("cache->set(%s)\n", join(', ', @setArgs)));
	$self->cache->set(@setArgs);

	return $data;
}

1;
