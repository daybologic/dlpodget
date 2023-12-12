package Dlpodget::UUID;
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

use Moose;
use Data::UUID::LibUUID qw(uuid_to_string);

=head1 NAME

Dlpodget::UUID - Container for one UUID.

=head1 DESCRIPTION

Represents one UUID and all comparison, loading, and printing operations.
There is very little error checking because if a UUID is generated or imported via
the factory, then the UUID is valid.  You should not generate this object yourself,
without using the factory.

=head1 ATTRIBUTES

=over

=item C<owner>

The factory which created this UUID.
At the time of writing, this was a singleton, but you should not assume this is still the case.

=cut

has owner => (is => 'ro', isa => 'Dlpodget::UUID::Factory', required => 1);

=item C<value>

The binary UUID value.  You should use L</getCanon()> for the typical 36-character representation.

=cut

has value => (is => 'ro', required => 1);

=item C<canon>

The cache of the canonical representation of the UUID

=cut

has canon => (is => 'ro', lazy => 1, isa => 'Str', builder => 'getCanon');

=back

=head1 METHODS

=over

=item C<getCanon()>

Returns the 36-character representation of the UUID.

=cut

sub getCanon {
	my ($self) = @_;
	return uuid_to_string($self->value);
}

=item C<toString()>

Returns the printable representation, which will look like '{ca5ca873-f950-4243-8752-40d02d167749}'.
If you do not require the braces, you should use L</getCanon()> instead.

=cut

sub toString {
	my ($self) = @_;
	return '{' . $self->canon() . '}';
}

=item C<equals($other)>

Compare a true value if this UUID maches another UUID.  The other UUID
must be a L<Dlpodget/UUID>.  Returns a false value if the UUIDs not match.

=cut

sub equals {
	my ($self, $other) = @_;
	return $self->owner->equals($self, $other);
}

=item C<version()>

Returns the version number of the UUID.

=cut

sub version {
	my ($self) = @_;
	my ($result, @groups, $time_hi_and_version); # time_hi_and_version is defined in RFC 4122

	# We're only interested in the third group - known as 'time_hi_and_version'
	@groups = split(m/-/, $self->canon);
	$time_hi_and_version = hex($groups[2]); # Third group

	return $time_hi_and_version >> 12; # Only interested in MSB 4 bits of remaining 16
}

=back

=cut

1;
