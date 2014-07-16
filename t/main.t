#!/usr/bin/perl -w

package main;

use Test::More tests => 6;
use Test::Output;
use Devel::Cover;
use Getopt::Std;

use strict;
use warnings;
use diagnostics;

require 'dlpodget';

use constant MIN_FEED_STREAMS => (10);
use constant TEST_FEED        => 'http://xml.nfowars.net/Alex.rss'; # Requires an internet connection

sub t_child_1() {
	child(
		undef, # DB
		undef, # FeedKey
		undef, # Feeds,
		undef  # Feed
	);
}

sub t_child_2() {
	child(
		undef, # DB
		undef, # FeedKey
		undef, # Feeds,
		{ name => 'Horatio' }
	);
}

sub t_child() {
	plan tests => 2;

	stderr_is(\&t_child_1, "Stream Untitled feed error: \n",'child results with no parameters');
	stderr_is(\&t_child_2, "Stream Horatio error: \n", 'child results with dummy feed name');
}

sub t_rSleep() {
	plan tests => 13;

	my $paul = Muadeeb->new(mock => 1);
	is($paul->rSleep(undef), 0, 'rSleep undef 0');
	is($paul->rSleep(0), 0, 'rSleep 0 0');
	is($paul->rSleep(1), 1, 'rSleep 1 1');
	is($paul->rSleep(-1), -1, 'rSleep -1 -1');
	is($paul->rSleep(-2), -1, 'rSleep -2 -1');
	is($paul->rSleep('blah'), -1, 'rSleep blah -1');
	is($paul->rSleep(10), 10, 'rSleep 10 10');

	# Random tests
	srand(0); # Ensure we always start from a deterministic point
	my @sleepTimes = ( qw/2 8 1 9 6/ );
	is($paul->rSleep('10R'), -1, 'rSleep 10R -1');
	foreach my $v ( @sleepTimes ) {
		is($paul->rSleep('10r'), $v, "rSleep 10r $v");
	}
}

sub t_fileFromURI() {
	plan tests => 3;

	my $F = 'fileFromURI';
	is(fileFromURI('test1'), 'test1', "$F test1");
	is(fileFromURI('http://www.daybologic.co.uk/ddrp/test2.wav'), 'test2.wav', "$F test2");
	is(fileFromURI(undef), undef, "$F test3");
}

sub t_readFeed() {
	plan tests => 3;

	my @arr;
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

	if ( $ENV{TEST_AUTHOR} ) {
		@arr = readFeed(\%feeds, { rss => TEST_FEED(), name => 'dummy' });
		foreach my $hashref ( @arr ) {
			my $t = ref($hashref);
			$types{$t} = 1;
			foreach my $k ( keys(%$hashref) ) { $seenKeys{$k} = 1; }
		}
	}
	SKIP: {
		skip 'Requires internet connection; use TEST_AUTHOR=1 to enable', 3 unless $ENV{TEST_AUTHOR};

		cmp_ok(scalar(@arr), '>=', MIN_FEED_STREAMS(), sprintf('%s: At least %u feeds', $F, MIN_FEED_STREAMS()));
		is(scalar(keys(%types)), 1, "$F: Only one type of return type");
		is_deeply(\%seenKeys, \%expectedKeys, 'Only expected keys returned');
	};
}

sub t_processTags() {
	plan tests => 3;

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

sub t_db() {
	plan tests => 1;

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

sub listTests($) {
	my $testList = shift;
	foreach my $testName ( @$testList ) {
		printf("%s\n", $testName);
	}
}

sub getOpts(%) {
	my %P = @_;
	my $O;
	my $ret = 0;

	return 1 if ( scalar(@_) % 2 );
	die 'assert' unless ( $P{'output'} && $P{'tests'} );
	$O = $P{'output'};
	$ret = getopts('ln:d?h', $O);
	return $ret if ( !$ret );

	$O->{'h'} = 1 if ( $O->{'?'} );

	if ( $O->{'l'} ) {
		listTests($P{'tests'});
		$ret = 0;
		return $ret;
	}

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
	$ret = 1;
	return $ret;
}

sub t_main() {
	my %opts = ( );
	my %tests = (
		'fileFromURI' => \&t_fileFromURI,
		'readFeed'    => \&t_readFeed,
		'processTags' => \&t_processTags,
		'db'          => \&t_db,
		'child'       => \&t_child,
		'rSleep'      => \&t_rSleep,
	);
	return 1 unless ( getOpts(output => \%opts, tests => [ keys(%tests) ]) );
	while ( my ( $name, $func ) = each(%tests) ) {
		next unless ( !$opts{'n'} || $opts{'n'} eq $name );
		subtest $name => $func;
	}
	return 0;
}

exit(t_main());
