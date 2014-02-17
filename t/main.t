#!/usr/bin/perl -w

package main;
use Test::More tests => 8;
use Devel::Cover;
use Getopt::Std;
use strict;
use warnings;
use diagnostics;

require 'dlpodget';

use constant MIN_FEED_STREAMS => (10);
use constant TEST_FEED        => 'http://xml.nfowars.net/Alex.rss'; # Requires an internet connection

sub t_FileFromURI()
{
	my $F = 'FileFromURI';
	is(FileFromURI('test1'), 'test1', "$F test1");
	is(FileFromURI('http://www.daybologic.co.uk/ddrp/test2.wav'), 'test2.wav', "$F test2");
	is(FileFromURI(undef), undef, "$F test3");
}

sub t_ReadFeed()
{
	my %types = ( );
	my $F = 'ReadFeed';
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

	my @arr = ReadFeed(\%feeds, { rss => TEST_FEED(), name => 'dummy' });
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

sub t_ProcessTags()
{
	my $F = 'ProcessTags';
	my %testData = (
		main => {
			'DUMMYA' => '$DUMMYC',
			'DUMMYB' => '/tmp/2',
			'DUMMYC' => '/tmp/3'
		}
	);
	is(ProcessTags(\%testData, 'blah$DUMMYAbleh'), 'blah/tmp/3bleh', "$F: A");
	is(ProcessTags(\%testData, 'blah$DUMMYBgrowl'), 'blah/tmp/2growl', "$F: B");
	is(ProcessTags(\%testData, '$'), '$', "$F: Illegal variable");
}

sub t_rsleep() {
	is(rsleep(undef), 0, 'rsleep undef 0');
	is(rsleep(0), 0, 'rsleep 0 0');
	is(rsleep(1), 1, 'rsleep 1 1');
	is(rsleep(-1), -1, 'rsleep -1 -1');
	is(rsleep(-2), -1, 'rsleep -2 -1');
	is(rsleep('blah'), -1, 'rsleep blah -1');
	is(rsleep(10), 10, 'rsleep 10 10');

	# Random tests
	srand(0); # Ensure we always start from a deterministic point
	my @sleepTimes = ( qw/2 8 1 9 6/ );
	is(rsleep('10R'), -1, 'rsleep 10R -1');
	foreach my $v ( @sleepTimes ) {
		is(rsleep('10r'), $v, "rsleep 10r $v");
	}
}

sub t_DB() {
	isa_ok(DB(), 'DBI::db', 'DB; get handle');
}

sub syntax() {
	printf("%s [-n <function> ] -d\n\n", $0);

	print("-d\n");
	print("\tdebug (not implemented)\n\n");

	print("-n <function>\n");
	print("\tOnly unit test this function\n\n");

	return;
}

sub t_codecInfo() {
	is(codecInfo(-1), undef, 'codecInfo -1 is undef');
	is(codecInfo(0), undef, 'codecInfo 0 is undef');
	for ( my $i = CODEC_MIN(); $i <= CODEC_MAX(); $i++ ) {
		isa_ok(codecInfo($i), 'HASH', "codecInfo($i)");
	}
	is(codecInfo(CODEC_MAX()+1), undef, 'codecInfo max+1 is undef');
}

sub t_translationInfo() {
	for ( my $i = CODEC_MIN(); $i <= CODEC_MAX(); $i++ ) {
		for ( my $j = CODEC_MIN(); $j <= CODEC_MAX(); $j++ ) {
			my $expect = undef;
			my $ret = translationInfo($i, $j);
			$ret = ref($ret) if ( $ret && ref($ret) );
			if ( $i == $j ) {
				$expect = CODEC_ERR_REDUNDANT();
			} else {
				$expect = 'HASH';
			}
			is($ret, $expect, 'translationInfo');
		}
	}
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
		syntax();
		$ret = 0;
	}
	return $ret;
}

sub t_validateDirection($) {
	my @invalid = ( 0, '0', undef, 3, 300, -1, 'string' );
	foreach my $inv ( @invalid ) {
		eval {
			validateDirection($inv);
		};
		like(
			$@, qr/^Direction must be encode or decode /o,
			sprintf(
				'Invalid direction: %s',
				(defined($inv)) ? ( $inv ) : ( 'undef' )
			)
		);
	}
}

#
#sub t_validateFilename($) {
#	my $fileName = shift;
#	die 'Must supply filename' if ( !$fileName );
#	die 'File does not exist' unless ( -f $fileName );
#}

#sub t_validateCodec($) {
#	my $codecInfo = codecInfo(shift);
#	return $codecInfo if ( $codecInfo );
#
#	die 'Unknown codec';
#}

sub t_main()
{
	my %opts = ( );
	my %tests = (
		'FileFromURI' => \&t_FileFromURI,
		'ReadFeed'    => \&t_ReadFeed,
		'ProcessTags' => \&t_ProcessTags,
		'rsleep'      => \&t_rsleep,
		'DB'          => \&t_DB,
		'codecInfo'   => \&t_codecInfo,
		'translationInfo' => \&t_translationInfo,
		'validateDirection' => \&t_validateDirection
	);
	return 1 unless ( getOpts(output => \%opts, tests => [ keys(%tests) ]) );
	while ( my ( $name, $func ) = each(%tests) ) {
		next unless ( !$opts{'n'} || $opts{'n'} eq $name );
		subtest $name => $func;
	}
	return 0;
}

exit(t_main());
