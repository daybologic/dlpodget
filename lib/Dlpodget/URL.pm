package Dlpodget::URL;
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

Dlpodget::URL - URL encapsulation

=head1 DESCRIPTION

Encapsulate a feed's URL

=cut

use Moose;
use Moose::Util::TypeConstraints;

=head1 ATTRIBUTES

=over

=item C<scheme>

The scheme, ie. 'http'.  The following schemes are supported:

=over

=item C<mailto>

=item C<https>

=item C<http>

=item C<ftp>

=back

=cut

enum Scheme => [qw/mailto https http ftp ssh/];
has scheme => (is => 'ro', isa => 'Scheme', required => 1);

=item C<value>

The URL without the scheme.  Should with with a hostname

=cut

has value => (is => 'ro', isa => 'Str', required => 1);

=item C<host>

The hostname of the remote server mentioned in the L</value>

=cut

has host => (is => 'ro', isa => 'Str', required => 1);

=item C<path>

The path which follows the hostname

=cut

has path => (is => 'ro', isa => 'Maybe[Str]');

=item C<port>

The port number in the URI

=cut

has port => (is => 'ro', isa => 'Maybe[Int]');

=item C<user>

Any possible username extracted from the URL

=cut

has user => (is => 'ro', isa => 'Maybe[Str]');

=item C<pass>

Any possible password extracted from the URL

=cut

has pass => (is => 'ro', isa => 'Maybe[Str]');

=item C<query>

Query args

=cut

has query => (is => 'ro', isa => 'Maybe[Str]');

=item C<fragment>

Fragment

=cut

has fragment => (is => 'ro', isa => 'Maybe[Str]');

=back

=head1 METHODS

=over

=item C<toString()>

Returns the complete scehemed URL

=cut

sub toString {
	my ($self) = @_;
	return $self->value;
}

=back

=cut

1;
