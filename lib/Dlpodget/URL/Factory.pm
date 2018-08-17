package Dlpodget::URL::Factory;

=head1 NAME

Dlpodget::URL::Factory - URL encapsulation factory

=head1 DESCRIPTION

Generate a L<Dlpodget::URL> object

=cut

use Moose;

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
	die('FIXME');
}

=back

=cut

1;
