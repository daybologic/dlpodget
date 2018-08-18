package Dlpodget::URL::Factory;

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
