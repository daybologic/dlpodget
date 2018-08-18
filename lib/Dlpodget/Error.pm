package Dlpodget::Error;
use Moose;

has value => (is => 'ro', isa => 'Dlpodget::UUID', required => 1);

has owner => (is => 'ro', isa => 'Dlpodget::Errors', required => 1);

sub toString {
	my ($self) = @_;
	return $self->owner->toString($self->value);
}

1;
