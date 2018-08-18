#!/usr/bin/perl
#
# Daybo Logic Podcast downloader
# Copyright (c) 2012-2016, David Duncan Ross Palmer (2E0EOL) and others,
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
#     * Redistributions of source code must retain the above copyright notice,
#       this list of conditions and the following disclaimer.
#
#     * Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in the
#       documentation and/or other materials provided with the distribution.
#
#     * Neither the name of the Daybo Logic nor the names of its contributors
#       may be used to endorse or promote products derived from this software
#       without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.

package main;

use Test::More tests => 6;
use Test::Output;
use Devel::Cover;
use Getopt::Std;

use strict;
use warnings;

require 'dlpodget';

use constant MIN_FEED_STREAMS => (10);
use constant TEST_FEED        => 'http://xml.nfowars.net/Alex.rss'; # Requires an internet connection

my $Debug = 0;

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

sub t_db() {
	plan tests => 1;

	isa_ok(db(), 'DBI::db', 'DB; get handle');
}

sub ut_syntax() {
	printf("%s [-n <function> ] -d\n\n", $0);

	print("-d\n");
	print("\tdebug\n\n");

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
			unless ( listHasMember($v, @{ $P{'tests'} }) ) {
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
sub t_listHasMember() {
	is(listHasMember('one', 'one', 'two', 'three'), 1, 'List contains one');
	is(listHasMember('two', 'one', 'two', 'three'), 1, 'List contains two');
	is(listHasMember('four', 'one', 'two', 'three'), 0, 'List does not contain four');
	is(listHasMember(undef, undef, undef), 1, 'undef contained');
	is(listHasMember(undef, 1234, 4321), 0, 'undef not contained');
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


sub t_main() {
#
#	die 'Unknown codec';
#}

	my %opts = ( );
	my %tests = (
		'fileFromURI' => \&t_fileFromURI,
		'readFeed'    => \&t_readFeed,
		'processTags' => \&t_processTags,
		'db'          => \&t_db,
		'child'       => \&t_child,
		'listHasMember' => \&t_listHasMember,
		'DB'          => \&t_DB,
		'codecInfo'   => \&t_codecInfo,
		'translationInfo' => \&t_translationInfo,
		'validateDirection' => \&t_validateDirection
	);
	return 1 unless ( getOpts(output => \%opts, tests => [ keys(%tests) ]) );
	$Debug = $opts{'d'};

	while ( my ( $name, $func ) = each(%tests) ) {
		next unless ( !$opts{'n'} || $opts{'n'} eq $name );
		subtest $name => $func;
	}
	return 0;
}

exit(t_main());
