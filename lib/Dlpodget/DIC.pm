#
# Daybo Logic Podcast downloader
# Copyright (c) 2012-2018, Duncan Ross Palmer (2E0EOL) and others,
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

package Dlpodget::DIC;

=head1 NAME

Dlpodget::DIC - Dependency Injection Container

=head1 DESCRIPTION

A singleton which contains objects where only one of them needs to exist for a given
application or unit test.

=cut

use Moose;
use Scalar::Util qw(blessed);

my $singleton = undef; # Global one reference.

=head1 ATTRIBUTES

None

=head1 PRIVATE ATTRIBUTES

=over

=item C<__bucket>

Internal bucket for all objects within the DIC.

=cut

has __bucket => (is => 'ro', isa => 'HashRef[Dlpodget::Base]');

=back

=head1 METHODS

=over

=item C<BUILD>

Hook called by L<Moose> when the DIC is created.  This controls a global
reference to the DIC to ensure no more than two are created at the same time
(enforcing the singleton).

Please do not call this method yourself.

=cut

sub BUILD {
	my ($self) = @_;

	if ($singleton) {
		die('Attempt to construct more than one DIC');
	} else {
		$singleton = $self;
	}

	return;
}

=item C<DEMOLISH>

Hook called by L<Moose> when the DIC is destroyed, usually at the end of the application
or the unit test.  This hook clears the global reference to the singleton, so that the
next unit test can re-construct the DIC.

Please do not call this method yourself.

=cut

sub DEMOLISH {
	my ($self) = @_;
	$singleton = undef;
	return;
}

=item C<set($obj)>

Insert an object into the DIC.  You can only do this once per type of object.
If you attempt to do this twice, this is a fatal error.
The setter stores a reference to the object in the bucket, under the name
of the object, minus the 'Dlpodget::' prefix.

Attempting to store ab object which is not derived from L<Dlpodget::Base> is
a fatal error.

This method return a reference to the DIC for chaining several calls together.

=cut

sub set {
	my ($self, $obj) = @_;
	die('No object sent to DIC/set') if (!defined($obj));

	my $type = blessed($obj);
	die('DIC object must be blessed') if (!$type);

	$type =~ s/^Dlpodget:://;
	if ($self->get($type)) {
		die("DIC already contains an object of type $type")
	}

	$self->__bucket->{$type} = $obj;
	return $self;
}

=item C<get($name)>

Fetches the object associated with an name, ie. "Config" will return L<Dlpodget::Config>.
If you have not called L</set($obj)> previously, this will trigger a fatal error

=cut

sub get {
	my ($self, $name) = @_;
	die('No name sent to DIC/get') if (!$name);

	if (my $obj = $self->__bucket->{$type}) {
		return $obj;
	}

	die("DIC object $name was not set, when you attempted to fetch it");
}

=back

=cut

1;
