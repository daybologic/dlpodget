package Dlpodget::Response;

=head1 NAME

Dlpodget::Response - Response from factories

=head1 DESCRIPTION

The response from most factories.

=cut

use Moose;
use Carp qw(confess);

=head1 ATTRIBUTES

=over

=item C<success>

Whether the call succeeded.

=cut

has success => (is => 'ro', isa => 'Bool', required => 1);

=item C<errorNo>

Software-specific error message pattern number.
This is looked up via L<Dlpodget::Errors>.
This must be set when L</success> is false, otherwise, it must B<not> be set.

=cut

has errorNo => (is => 'ro', isa => 'Int');

=back

=head1 PRIVATE ATTRIBUTES

=over

=item C<__data>

This is the data for successful calls.  You should access it through L</getData()>.

=cut

has __data => (is => 'ro', init_arg => 'data');

=back

=head1 METHODS

=over

=item C<getData()>

Returns L</__data>, unless L</success> is false, in which case, a fatal error is raised.

=cut

sub getData {
	my ($self) = @_;
	confess('Attempt to fetch data for failure response') unless ($self->success);
	return $self->__data;
}

=item C<toString()>

Returns a human-readable and loggable version of the response.

=cut

sub toString {
	my ($self) = @_;
	my $str = ($self->success) ? 'Success' : 'Failure';
	if (defined($self->data)) {
		$str = sprintf('%s <%s>', $str, (ref($self->data) ? ref($self->data) : $self->data));
	} else {
		$str = sprintf('%s <no data>', $str);
	}
	return $str;
}

=back

=cut

1;
