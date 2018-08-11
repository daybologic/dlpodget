package Dlpodget::Feed::Config;
use Moose;
use Moose::Util::TypeConstraints;

has attach => (is => 'ro', isa => 'Boolean', default => 0);

has [qw(enable download check)] => (is => 'ro', isa => 'Boolean', default => 1);

has notify => (is => 'ro', isa => 'Boolean|Dlpodget::URL', default => 0);

has [qw(retries maxcount quality)] => (is => 'ro', isa => 'Int', default => 1);

has rss => (is => 'ro', isa => 'Dlpodget::URL');

enum Codec => [qw/default ogg flac mp2/];
has codec => (is => 'ro', isa => 'Codec', default => 'default');

has localpath => (is => 'ro', isa => 'Str');

has maxage => (is => 'ro', isa => 'Dlpodget::Age', default => sub {
	return Dlpodget::Age->new(unlimited => 1);
});

has rsleep => (is => 'ro', isa => 'Dlpodget::RSleep', defaut => sub {
	return Dlpodget::RSleep->new(random => 0, secs => 0);
});

1;
