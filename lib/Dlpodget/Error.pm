package Dlpodget::Error;
use Moose;

has value => (is => 'ro', isa => 'Dlpodget::UUID', required => 1);

1;
