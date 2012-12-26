#!/usr/bin/perl -w

package main;
use Test::More tests => 3;
use strict;
use warnings;
use diagnostics;

require 'dlpodget';

sub t_FileFromURI()
{
	my $F = 'FileFromURI';
	is(FileFromURI('test1'), 'test1', "$F test1");
	is(FileFromURI('http://www.daybologic.co.uk/ddrp/test2.wav'), 'test2.wav', "$F test2");
	is(FileFromURI(undef), undef, "$F test3");
}

sub t_ReadFeed()
{
	my %feeds = (
		_main => { },
		dummy => { }
	);
	ReadFeed(\%feeds, 'http://blah', 'dummy');
}

sub t_main()
{
	t_FileFromURI();
	t_ReadFeed();
	return 0;
}

exit(t_main());
