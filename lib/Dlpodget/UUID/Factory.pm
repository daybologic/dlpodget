package Dlpodget::UUID::Factory;

=head1 NAME

Dlpodget::UUID::Factory - The generator for all UUIDs

=head1 DESCRIPTION

Global singleton which produces L<Dlpodget::UUID> objects.

=cut

use Moose;
use MooseX::Singleton;
use Data::UUID::LibUUID qw(uuid_eq new_uuid_binary uuid_to_binary);
use Dlpodget::UUID;
use Dlpodget::Response;

=head1 PRIVATE ATTRIBUTES

=over

=item C<__pool>

A queue of L<Dlpodget::UUID> objects, which have not yet been popped.

=cut

has __pool => (is => 'ro', isa => 'ArrayRef[Dlpodget::UUID]', default => sub {[]});

=back

=head1 METHODS

=over

=item C<create([$uuid])>

Create a L<Dlpodget::UUID> object, but you'll need to call L</pop()> to fetch it.

=cut

sub create {
	my ($self, $uuid) = @_;
	my $value;

	if ($uuid) {
		$value = uuid_to_binary($uuid);
		unless ($value) {
			return Dlpodget::Response->new(
				success => 0,
				errorNo => $Dlpodget::Errors::INVALID_UUID,
			);
		}
	} else {
		$value = new_uuid_binary(2);
	}

	my $obj = Dlpodget::UUID->new(owner => $self, value => $value);
	push(@{ $self->__pool }, $obj);
	return Dlpodget::Response->new(success => 1, data => $obj);
}

=item C<top()>

Returns the first available UUID, but does not remove it.
Be careful not to use the UUID for anything except stashing away for comparisons
during unit testing.  You really should use L</pop()> instead.

=cut

sub top {
	my ($self) = @_;
	return $self->__pool->[0];
}

=item C<pop()>

Returns the first available UUID and removes it from the internal queue.
Returns C<undef> if nothing is available, in which case, use L</create()> as many
times as you need.

=cut

sub pop {
	my ($self) = @_;
	return undef unless ($self->top());
	return shift(@{ $self->__pool });
}

=item C<count()>

Returns the number of UUIDs currently in the pool.

=cut

sub count {
	my ($self) = @_;
	return scalar(@{ $self->__pool });
}

=item C<equals($a, $b)>

Returns true if objects C<$a> and C<$b> represent the same UUID.

=cut

sub equals {
	my ($self, $a, $b) = @_;

	if ($a && $b) {
		return 1 if ($a eq $b); # Same object
		if ($a->isa('Dlpodget::UUID') && $b->isa('Dlpodget::UUID')) {
			return 1 if (uuid_eq($a->value, $b->value));
		}
	}

	return 0;
}

=item C<reset()>

Resets the internal state of the object.  Throwing away any UUIDs queued in the L</__pool>,
if necessary.

=cut

sub reset {
	my ($self) = @_;
	@{ $self->__pool } = ( );
	return;
}

=back

=cut

1;
