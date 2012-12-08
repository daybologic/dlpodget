#!/usr/bin/perl -w

package main;
use Test::More tests => 1;
use strict;
use warnings;
use diagnostics;

require 'dlpodget';

sub t_FileFromURI()
{
	my $F = 'FileFromURI';
	is(FileFromURI('test1'), 'test1', "$F test1");
}

sub t_main()
{
	t_FileFromURI();
	return 0;
}

exit(t_main());
