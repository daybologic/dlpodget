package Dlpodget::Response;
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

Dlpodget::Response - Response from factories

=head1 DESCRIPTION

The response from most factories.

=cut

use Moose;
use Carp qw(confess);

=head1 ATTRIBUTES

=over

=item C<success>

Whether the call succeeded.

=cut

has success => (is => 'ro', isa => 'Bool', required => 1);

=item C<error>

Software-specific error message pattern number.
This is a L<Dlpodget::Error>.

This must be set when L</success> is false, otherwise, it must B<not> be set.

=cut

has error => (is => 'ro', isa => 'Dlpodget::Error');

=back

=head1 PRIVATE ATTRIBUTES

=over

=item C<__data>

This is the data for successful calls.  You should access it through L</getData()>.

=cut

has __data => (is => 'ro', init_arg => 'data');

=back

=head1 METHODS

=over

=item C<getData()>

Returns L</__data>, unless L</success> is false, in which case, a fatal error is raised.

=cut

sub getData {
	my ($self) = @_;
	confess('Attempt to fetch data for failure response') unless ($self->success);
	return $self->__data;
}

=item C<toString()>

Returns a human-readable and loggable version of the response.

=cut

sub toString {
	my ($self) = @_;
	my $str = ($self->success) ? 'Success' : 'Failure';
	if (defined($self->__data)) {
		$str = sprintf('%s <%s>', $str, (ref($self->__data) ? ref($self->__data) : $self->__data));
	} else {
		$str = sprintf('%s <no data>', $str);
	}
	return $str;
}

=back

=cut

1;
