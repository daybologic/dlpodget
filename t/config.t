#!/usr/bin/perl -w

package ConfigTests;
use Moose;
use Test::More 0.96;
#use Devel::Cover;
use Getopt::Std;
use Dlpodget::Config;
use POSIX qw(EXIT_SUCCESS);

extends 'Test::Module::Runnable';

sub test {
	my ($self) = @_;
	isa_ok($self->sut(Dlpodget::Config->new()), 'Dlpodget::Config', 'new type');
	return EXIT_SUCCESS;
}

package main;
use strict;
use warnings;

exit(ConfigTests->new()->run());
