#!/usr/bin/perl
package FeedsTests;
use Moose;

extends 'Test::Module::Runnable';

use Cache::MemoryCache;
use Dlpodget::Feeds;
use English qw(-no_match_vars);
use Dlpodget::DIC;
use POSIX;
use Test::Deep qw(cmp_deeply all isa methods bool re);
use Test::Exception;
use Test::More;
use Devel::Cover;

sub ____setUp {
	my ($self) = @_;

	$self->dic(Dlpodget::DIC->new(
		logger => Dlpodget::Log::Mock->new,
		cache => Cache::MemoryCache->new,
		config => Dlpodget::Config::Mock->new({
			#VOIPDB => Dlpodget::DB::Mock->makeConfig(), # Enable this if you will call an init() to set up DBs
		}),
		#voipdb => Dlpodget::DB::Mock->new, # Enable this if you want to pass a DB directly
	));

	$self->sut(Dlpodget::Feeds->new(
		dic => $self->dic,
		#dicRequire => 1, # Enable this for new libraries which should only use the DIC
	));

	$self->forcePlan();
	$self->dic->logger->warnFatal(1); # disable in specific tests if needed

	return EXIT_SUCCESS;
}

sub testSomething {
	my ($self) = @_;
	plan tests => 1;

	ok('FIXME');

	return EXIT_SUCCESS;
}

package main;
use strict;
use warnings;
exit(FeedsTests->new->run);
