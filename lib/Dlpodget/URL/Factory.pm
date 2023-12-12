package Dlpodget::URL::Factory;
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

Dlpodget::URL::Factory - URL encapsulation factory

=head1 DESCRIPTION

Generate a L<Dlpodget::URL> object

=cut

use Moose;
use MooseX::Singleton;
use Dlpodget::Response;
use Dlpodget::URL;

=head1 ATTRIBUTES

None

=head1 METHODS

=over

=item C<create($url)>

Returns a L<Dlpodget::URL> object based on a string, wrapped in a Dlpodget::Response
object.

=cut

sub create {
	my ($self, $urlStr) = @_;

	if ($urlStr =~ m/
		^(mailto)\:                                 # Scheme
		(\w+)@                                      # User
		(.*)$                                       # Host
	/x) {
		return Dlpodget::Response->new(
			success => 1,
			data    => Dlpodget::URL->new(
				value  => $urlStr,
				scheme => $1,
				user   => $2,
				host   => $3,
			),
		);
	} elsif ($urlStr =~ m/
		^([a-z][a-z0-9+\-.]*):\/\/                  # Scheme
		([a-z0-9\-._~%!$&'()*+,;:=]+@)?             # User and pass
		([a-z0-9\-._~%]+                            # Named host
		|\[[a-f0-9:.]+\]                            # IPv6 host
		|\[v[a-f0-9][a-z0-9\-._~%!$&'()*+,;=:]+\])  # IPvFuture host
		(:[0-9]+)?                                  # Port
		(\/[a-z0-9\-._~%!$&'()*+,;=:@]+)*\/?        # Path
		(\?[a-z0-9\-._~%!$&'()*+,;=:@\/?]*)?        # Query
		(\#[a-z0-9\-._~%!$&'()*+,;=:@\/?]*)?        # Fragment
	/x) {
		my $scheme   = $1;
		my $userPass = $2;
		my $host     = $3;
		my $port     = $4;
		my $path     = $5;
		my $query    = $6;
		my $fragment = $7;

		$port = substr($port, 1) if ($port); # Strip ':' prefix

		my ($user, $pass);
		if ($userPass) {
			($user, $pass) = split(m/\:/, $userPass);

			# Strip trailing '@'
			if ($pass) {
				chop($pass);
			} else {
				chop($user);
			}
		}

		return Dlpodget::Response->new(
			success => 1,
			data    => Dlpodget::URL->new(
				value    => $urlStr,
				scheme   => $scheme,
				user     => $user,
				pass     => $pass,
				host     => $host,
				port     => $port,
				path     => $path,
				query    => $query,
				fragment => $fragment,
			),
		);
	} else {
		return Dlpodget::Response->new(
			success => 0,
		);
	}
}

=back

=cut

1;
