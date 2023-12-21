package Dlpodget::DIC;
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

Dlpodget::DIC - Dependency Injection Container

=head1 DESCRIPTION

A singleton which contains objects where only one of them needs to exist for a given
application or unit test.

=cut

use Moose;
use MooseX::Singleton;
use Log::Log4perl;
use Readonly;
use Scalar::Util qw(blessed);

=head1 ATTRIBUTES

=over

=item C<logger>

L<Log::Log4perl::Logger>, automatically initialized on first-access via L</_makeLogger()>.
For the general use of all code.

=cut

has logger => (is => 'rw', isa => 'Log::Log4perl::Logger', lazy => 1, builder => '_makeLogger');

=back

=head1 PRIVATE ATTRIBUTES

=over

=item C<__bucket>

Internal bucket for all objects within the DIC.

=cut

has __bucket => (is => 'ro', isa => 'HashRef[Dlpodget::Base]', default => sub {
	return { };
});

=back

=head1 METHODS

=over

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
	Readonly my $BASE => 'Dlpodget::Base';

	die('No object sent to DIC/set') if (!defined($obj));

	my $type = blessed($obj);
	die('DIC object must be blessed') if (!$type);

	unless ($obj->isa($BASE)) {
		die("$type is not derived from $BASE");
	}

	$type =~ s/^Dlpodget:://;
	if ($self->__get($type)) {
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

	if (my $obj = $self->__get($name)) {
		return $obj;
	}

	die("DIC object $name was not set, when you attempted to fetch it");
}

=back

=head1 PROTECTED METHODS

=over

=item C<_makeLogger()>

=cut

sub _makeLogger {
	Log::Log4perl->init('etc/log4perl.conf');
	return Log::Log4perl->get_logger('dlpodget.general');
}

=back

=head1 PRIVATE METHODS

=over

=item C<__get($name)>

Internal method which returns an object associated with the name,
or return C<undef>, if the object is not set.

=cut

sub __get {
	my ($self, $name) = @_;
	return $self->__bucket->{$name};
}

=back

=cut

1;
