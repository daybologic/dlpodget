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
