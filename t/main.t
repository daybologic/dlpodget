#!/usr/bin/perl -w

package main;
use Test::More tests => 4;
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
	my $F = 'ReadFeed';
	my %feeds = (
		_main => { },
		dummy => { }
	);
	my @arr = ReadFeed(\%feeds, TEST_FEED(), 'dummy');
	cmp_ok(scalar(@arr), '>=', MIN_FEED_STREAMS(), sprintf('%s: At least %u feeds', $F, MIN_FEED_STREAMS()));
}

sub t_main()
{
	t_FileFromURI();
	t_ReadFeed();
	return 0;
}

exit(t_main());
