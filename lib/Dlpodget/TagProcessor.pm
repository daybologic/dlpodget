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

# TODO Question: Would it have been better to implement this as a tie hash container?
package Dlpodget::TagProcessor;
# TODO: Should derive from LocalBase or it's successor.
use Moose;
use strict;
use warnings;

extends 'Dlpodget::Object';

has 'mappings'    => (
	'isa'     => 'HashRef',
	'is'      => 'ro',
	'default' => sub {{}},
);

sub assoc {
	my ($self, $k, $v) = @_;

	$k = uc($k); # All keys are uppercase
	if ( exists($self->mappings->{$k}) ) {
		my $old = $self->mappings->{$k};
		$old = '(undef)' unless (defined($old));
		warn(sprintf(
			'%s: Key \'%s\' clobered, old value: \'%s\', new value: \'%s\'',
			$self, $k, $old, $v
		));
	}

	$self->mappings->{$k} = $v;
	return $self;
}

sub value {
	my ($self, $k) = @_;

	$k = uc($k); # All keys are uppercase
	if (exists($self->mappings->{$k})) {
		return $self->mappings->{$k};
	}

	$k = '(undef)' unless (defined($k));
	warn(sprintf('%s: No key %s found', $self, $k));
	return;
}

# FIXME: BROKEN PRIORITY Does this need to effectively call assoc() itself?!?!
sub result {
	my ($self, $V) = @_;

	$self->debug(1); # FIXME

	my $tagRx = qr/^\$([A-Z0-9]+)/o;
	my $avoid = 0;

	while ((my $idx = index($V, '$', $avoid)) > -1) { # Find remaining user-variable references
		my $var = substr($V, $idx);
		if ($var =~ $tagRx ) {
			my $v = $self->mappings->{ uc($1) };
			$self->logger->log(0, '%s -> %s', $1, $v || '(undef)')
				if ($self->debug); # TODO: Need a debug call in the logger piece!
			if (!defined($v)) {
				$avoid = $idx+1;
				next;
			}
			substr($V, $idx, length($1)+1, $v);
		} else {
			$avoid++;
		}
	}

	return $V;
}

1;
