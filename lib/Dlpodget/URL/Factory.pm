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
		([a-z0-9\-._~%!$&'()*+,;=]+@)?              # User
		([a-z0-9\-._~%]+                            # Named host
		|\[[a-f0-9:.]+\]                            # IPv6 host
		|\[v[a-f0-9][a-z0-9\-._~%!$&'()*+,;=:]+\])  # IPvFuture host
		(:[0-9]+)?                                  # Port
		(\/[a-z0-9\-._~%!$&'()*+,;=:@]+)*\/?        # Path
		(\?[a-z0-9\-._~%!$&'()*+,;=:@\/?]*)?        # Query
		(\#[a-z0-9\-._~%!$&'()*+,;=:@\/?]*)?        # Fragment
	/x) {
		return Dlpodget::Response->new(
			success => 1,
			data    => Dlpodget::URL->new(
				value    => $urlStr,
				scheme   => $1,
				user     => $2,
				host     => $3,
				port     => $4,
				path     => $5,
				query    => $6,
				fragment => $7,
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
