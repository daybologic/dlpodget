package Dlpodget::URL;

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

enum Scheme => [qw/mailto https http ftp/];
has scheme => (is => 'ro', isa => 'Scheme', default => 'http');

=item C<value>

The URL without the scheme.  Should with with a hostname

=cut

has value => (is => 'ro', isa => 'Str', required => 1);

=back

=head1 METHODS

=over

=item C<toString()>

Returns the complete scehemed URL

=cut

sub toString {
	my ($self) = @_;
	return join('://', $self->scheme, $self->value);
}

=back

=cut

1;
