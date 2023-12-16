package Dlpodget::Errors;
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

Dlpodget::Errors - Global error list

=head1 DESCRIPTION

A singleton which contains all error messages and error message constants.

=cut

use Moose;
use MooseX::Singleton;
use Readonly;
use Scalar::Util qw(blessed);
use Carp qw(confess);
use Dlpodget::Error;
use Dlpodget::UUID::Factory;

=head1 CONSTANTS

=over

=item C<$URL_PARSE>

Could not parse a URL (in L<Dlpodget::URL::Factory>.
Check the scheme is supported and the URI is well-formed.
If you are sure, report a bug to L<mailto:2e0eol@gmail.com>

=cut

Readonly our $URL_PARSE => 'e6077af6-a237-11e8-89e8-f23c9173fe51';

=item C<$INVALID_UUID>

Either the UUID has an invalid version number, or is is not a 36-character
UUID, or the binary representation is invalid, according to the underlying library.

=cut

Readonly our $INVALID_UUID => '473d8f5c-a276-11e8-89e8-f23c9173fe51';

=item C<$INVALID_DIRECTION>

Direction must be encode or decode

=cut

Readonly our $INVALID_DIRECTION => 'd6ac3548-a277-11e8-89e8-f23c9173fe51';

=item C<$MUST_SUPPLY_FILENAME>

Must supply filename

=cut

Readonly our $MUST_SUPPLY_FILENAME => '00c41300-a278-11e8-89e8-f23c9173fe51';


=item C<$FILE_NOT_FOUND>

File does not exist

=cut

Readonly our $FILE_NOT_FOUND => '3f25d458-a278-11e8-89e8-f23c9173fe51';

=item C<$UNKNOWN_CODEC>

Unknown code

=cut

Readonly our $UNKNOWN_CODEC => '7e289fc8-a278-11e8-89e8-f23c9173fe51';

=item C<$ASSERT_FAIL>

Assertion failure

=cut

Readonly our $ASSERT_FAIL => 'cd8f0a5c-a278-11e8-89e8-f23c9173fe51';

=item C<$FORK>

Process fork/spawn failure

=cut

Readonly our $FORK => '08674112-a279-11e8-89e8-f23c9173fe51';

=item C<$INTERNAL>

Internal error

=cut

Readonly our $INTERNAL => '710c0b4e-a279-11e8-89e8-f23c9173fe51';

=item C<$NO_SUCH_ERROR>

No such error

=cut

Readonly our $NO_SUCH_ERROR => 'e2f0bc64-a2ec-11e8-89e8-f23c9173fe51';

=back

=cut

Readonly my %ERR => (
	$URL_PARSE => 'The URL cannot be parsed',
	$INVALID_UUID => 'The UUID is corrupt or illegal',
	$INVALID_DIRECTION => 'Direction must be encode or decode',
	$MUST_SUPPLY_FILENAME => 'Must supply filename',
	$FILE_NOT_FOUND => 'File does not exist',
	$UNKNOWN_CODEC => 'Unknown codec',
	$ASSERT_FAIL => 'Assertion failure',
	$FORK => 'Process fork/spawn failure',
	$INTERNAL => 'Internal error',
	$NO_SUCH_ERROR => 'No such error',
);

=head1 METHODS

=over

=item C<toString()>

Returns the error message associcated with the error identifier.
If such an error cannot be found, the error identifier is used.
Both L</Dlpodget::UUID> and bare strings are supported.

=cut

sub toString {
	my ($self, $error) = @_;

	if (blessed($error) && $error->isa('Dlpodget::UUID')) {
		$error = $error->canon;
	}

	if (my $err = $ERR{$error}) {
		return $err;
	}

	return $error;
}

=item C<fetchById($id)>

Returns a L<Dlpodget::Error> identified by its UUID, which is a string, not an object.
The appropriate, complex object is returned.  If the error does not exist, we will return
$NO_SUCH_ERROR.  If the L<Dlpodget::UUID> cannot be constructed, we will return L<$INVALID_UUID>.

=cut

sub fetchById {
	my ($self, $id) = @_;

	my $uuidResponse = Dlpodget::UUID::Factory->instance->create($id);
	if (!$uuidResponse->success) {
		$uuidResponse = Dlpodget::UUID::Factory->instance->create($INVALID_UUID);
		if (!$uuidResponse->success) {
			confess($INTERNAL); # Can't do anything else
		}
	}
	# $uuidResponse is certainly valid at this point

	my $uuid = Dlpodget::UUID::Factory->instance->pop();
	if ($ERR{ $uuid->canon }) {
		return Dlpodget::Error->new(value => $uuid, owner => $self);
	} else {
		return $self->fetchById($NO_SUCH_ERROR);
	}
}

=back

=cut

1;

