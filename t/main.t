#!/usr/bin/perl -w

package main;
use Test::More tests => 5;
use Devel::Cover;
use Getopt::Std;
use strict;
use warnings;
use diagnostics;

require 'dlpodget';

use constant MIN_FEED_STREAMS => (10);
use constant TEST_FEED        => 'http://xml.nfowars.net/Alex.rss'; # Requires an internet connection

sub t_fileFromURI() {
	my $F = 'fileFromURI';
	is(fileFromURI('test1'), 'test1', "$F test1");
	is(fileFromURI('http://www.daybologic.co.uk/ddrp/test2.wav'), 'test2.wav', "$F test2");
	is(fileFromURI(undef), undef, "$F test3");
}

sub t_readFeed() {
	my %types = ( );
	my $F = 'readFeed';
	my %seenKeys = ( );
	my %expectedKeys = (
		length => 1,
		filename => 1,
		title => 1,
		type => 1,
		uri => 1
	);
	my %feeds = (
		main => { },
		dummy => { }
	);

	my @arr = readFeed(\%feeds, { rss => TEST_FEED(), name => 'dummy' });
	foreach my $hashref ( @arr ) {
		my $t = ref($hashref);
		$types{$t} = 1;
		foreach my $k ( keys(%$hashref) ) { $seenKeys{$k} = 1; }
	}
	SKIP: {
		skip 'Requires internet connection; use TEST_AUTHOR=1 to enable', 3 unless $ENV{TEST_AUTHOR};

		cmp_ok(scalar(@arr), '>=', MIN_FEED_STREAMS(), sprintf('%s: At least %u feeds', $F, MIN_FEED_STREAMS()));
		is(scalar(keys(%types)), 1, "$F: Only one type of return type");
		is_deeply(\%seenKeys, \%expectedKeys, 'Only expected keys returned');
	};
}

sub t_processTags() {
	my $F = 'processTags';
	my %testData = (
		main => {
			'DUMMYA' => '$DUMMYC',
			'DUMMYB' => '/tmp/2',
			'DUMMYC' => '/tmp/3'
		}
	);
	is(processTags(\%testData, 'blah$DUMMYAbleh'), 'blah/tmp/3bleh', "$F: A");
	is(processTags(\%testData, 'blah$DUMMYBgrowl'), 'blah/tmp/2growl', "$F: B");
	is(processTags(\%testData, '$'), '$', "$F: Illegal variable");
}

sub t_rSleep() {
	is(rSleep(undef), 0, 'rSleep undef 0');
	is(rSleep(0), 0, 'rSleep 0 0');
	is(rSleep(1), 1, 'rSleep 1 1');
	is(rSleep(-1), -1, 'rSleep -1 -1');
	is(rSleep(-2), -1, 'rSleep -2 -1');
	is(rSleep('blah'), -1, 'rSleep blah -1');
	is(rSleep(10), 10, 'rSleep 10 10');

	# Random tests
	srand(0); # Ensure we always start from a deterministic point
	my @sleepTimes = ( qw/2 8 1 9 6/ );
	is(rSleep('10R'), -1, 'rSleep 10R -1');
	foreach my $v ( @sleepTimes ) {
		is(rSleep('10r'), $v, "rSleep 10r $v");
	}
}

sub t_db() {
	isa_ok(db(), 'DBI::db', 'DB; get handle');
}

sub ut_syntax() {
	printf("%s [-n <function> ] -d\n\n", $0);

	print("-d\n");
	print("\tdebug (not implemented)\n\n");

	print("-n <function>\n");
	print("\tOnly unit test this function\n\n");

	return;
}

sub getOpts(%) {
	my %P = @_;
	my $O;
	my $ret;

	return 1 if ( scalar(@_) % 2 );
	die 'assert' unless ( $P{'output'} && $P{'tests'} );
	$O = $P{'output'};
	$ret = getopts('n:d?h', $O);
	return $ret if ( !$ret );

	$O->{'h'} = 1 if ( $O->{'?'} );

	while ( my ( $o, $v ) = each(%$O) ) {
		if ( $o eq 'n' ) {
			unless ( $v ~~ $P{'tests'} ) {
				die(sprintf(
					'Argument %s to -n, is not a known test',
					$v
				));
			}
		}
	}

	if ( $O->{'h'} ) {
		ut_syntax();
		$ret = 0;
	}
	return $ret;
}

sub t_main() {
	my %opts = ( );
	my %tests = (
		'fileFromURI' => \&t_fileFromURI,
		'readFeed'    => \&t_readFeed,
		'processTags' => \&t_processTags,
		'rSleep'      => \&t_rSleep,
		'db'          => \&t_db
	);
	return 1 unless ( getOpts(output => \%opts, tests => [ keys(%tests) ]) );
	while ( my ( $name, $func ) = each(%tests) ) {
		next unless ( !$opts{'n'} || $opts{'n'} eq $name );
		subtest $name => $func;
	}
	return 0;
}

exit(t_main());
