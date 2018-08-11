package Dlpodget::URL;
use Moose;
use Moose::Util::TypeConstraints;

enum Scheme => [qw/mailto https http ftp/];
has scheme => (is => 'ro', isa => 'Scheme', default => 'http');

has value => (is => 'ro', isa => 'Str', required => 1);

sub toString {
	my ($self) = @_;
	return join('://', $self->scheme, $self->value);
}

1;
