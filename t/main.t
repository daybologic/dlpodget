#!/usr/bin/perl -w

package main;
use Test::More tests => 8;
use strict;
use warnings;
use diagnostics;

require 'dlpodget';

use constant MIN_FEED_STREAMS => (10);
use constant TEST_FEED        => 'http://xml.nfowars.net/Alex.rss';

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
		_main => { },
		dummy => { }
	);
	my @arr = ReadFeed(\%feeds, TEST_FEED(), 'dummy');
	cmp_ok(scalar(@arr), '>=', MIN_FEED_STREAMS(), sprintf('%s: At least %u feeds', $F, MIN_FEED_STREAMS()));
	foreach my $hashref ( @arr ) {
		my $t = ref($hashref);
		$types{$t} = 1;
		foreach my $k ( keys(%$hashref) ) { $seenKeys{$k} = 1; }
	}
	is(scalar(keys(%types)), 1, "$F: Only one type of return type");
	is_deeply(\%seenKeys, \%expectedKeys, 'Only expected keys returned');
}

sub t_ProcessTags()
{
	my $F = 'ProcessTags';
	my %testData = (
		_main => {
			'dummya' => '$DUMMYC',
			'dummyb' => '/tmp/2',
			'dummyc' => '/tmp/3'
		}
	);
	is(ProcessTags(\%testData, 'blah$DUMMYAbleh'), 'blah/tmp/3bleh', "$F: A");
	is(ProcessTags(\%testData, 'blah$DUMMYBgrowl'), 'blah/tmp/2growl', "$F: B");
}

sub t_main()
{
	t_FileFromURI();
	t_ReadFeed();
	t_ProcessTags();
	return 0;
}

exit(t_main());
