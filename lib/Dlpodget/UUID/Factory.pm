package Dlpodget::UUID::Factory;
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

=head1 NAME

Dlpodget::UUID::Factory - The generator for all UUIDs

=head1 DESCRIPTION

Global singleton which produces L<Dlpodget::UUID> objects.

=cut

use Moose;
use MooseX::Singleton;
use Data::UUID::LibUUID qw(uuid_eq new_uuid_binary uuid_to_binary);
use Dlpodget::Error;
use Dlpodget::Errors;
use Dlpodget::UUID;
use Dlpodget::Response;

=head1 PRIVATE ATTRIBUTES

=over

=item C<__pool>

A queue of L<Dlpodget::UUID> objects, which have not yet been popped.

=cut

has __pool => (is => 'ro', isa => 'ArrayRef[Dlpodget::UUID]', default => sub {[]});

=back

=head1 METHODS

=over

=item C<create([$uuid])>

Create a L<Dlpodget::UUID> object, but you'll need to call L</pop()> to fetch it.

=cut

sub create {
	my ($self, $uuid) = @_;
	my $value;

	if ($uuid) {
		$value = uuid_to_binary($uuid);
		unless ($value) {
			return Dlpodget::Response->new(
				success => 0,
				error   => Dlpodget::Errors->instance->fetchById(
					$Dlpodget::Errors::INVALID_UUID,
				),
			);
		}
	} else {
		$value = new_uuid_binary(2);
	}

	my $obj = Dlpodget::UUID->new(owner => $self, value => $value);
	push(@{ $self->__pool }, $obj);
	return Dlpodget::Response->new(success => 1, data => $obj);
}

=item C<top()>

Returns the first available UUID, but does not remove it.
Be careful not to use the UUID for anything except stashing away for comparisons
during unit testing.  You really should use L</pop()> instead.

=cut

sub top {
	my ($self) = @_;
	return $self->__pool->[0];
}

=item C<pop()>

Returns the first available UUID and removes it from the internal queue.
Returns C<undef> if nothing is available, in which case, use L</create()> as many
times as you need.

=cut

sub pop {
	my ($self) = @_;
	return undef unless ($self->top());
	return shift(@{ $self->__pool });
}

=item C<count()>

Returns the number of UUIDs currently in the pool.

=cut

sub count {
	my ($self) = @_;
	return scalar(@{ $self->__pool });
}

=item C<equals($a, $b)>

Returns true if objects C<$a> and C<$b> represent the same UUID.

=cut

sub equals {
	my ($self, $a, $b) = @_;

	if ($a && $b && blessed($a) && blessed($b)) {
		return 1 if ($a eq $b); # Same object
		if ($a->isa('Dlpodget::UUID') && $b->isa('Dlpodget::UUID')) {
			return 1 if (uuid_eq($a->value, $b->value));
		}
	}

	return 0;
}

=item C<reset()>

Resets the internal state of the object.  Throwing away any UUIDs queued in the L</__pool>,
if necessary.

=cut

sub reset {
	my ($self) = @_;
	@{ $self->__pool } = ( );
	return;
}

=back

=cut

1;
