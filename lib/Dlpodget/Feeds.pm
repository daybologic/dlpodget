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

package Dlpodget::Feeds;
use Moose;

=head1 NAME

Dlpodget::Feeds - Represents all feeds

=head1 DESCRIPTION

Representing all feeds via L</__feeds> private attribute

=cut

use Dlpodget::Feed;

extends 'Dlpodget::Base';

=head1 ATTRIBUTES

=head1 PRIVATE ATTRIBUTES

=over

=item C<__feeds>

=cut

has __feeds => (is => 'ro', isa => 'HashRef[Dlpodget::Feed]', lazy => 1, default => \&__loadsFeeds);

=back

=head1 METHODS

=over

=item C<toString()>

Returns a human-readable summary of the state of the object.

=cut

sub toString {
	my ($self) = @_;
	return sprintf("%s with %d feeds", ref($self), scalar(@{ $self->__feeds }));
}

=back

=head1 PRIVATE METHODS

=over

=item C<__loadFeeds>

TODO: I need to fetch the feeds via a DIC

=cut

sub __loadFeeds {
	my ($self) = @_;
	die('FIXME: Unfinished');
}

=back

=cut

1;