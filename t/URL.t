#!/usr/bin/perl
package URLTests;
use strict;
use warnings;
use Moose;
extends 'Dlpodget::Tester';

use Cache::MemoryCache;
use Dlpodget::URL;
use English qw(-no_match_vars);
use Dlpodget::Config::Mock;
#use Dlpodget::DB::Mock;
use Dlpodget::DIC;
use Dlpodget::Log::Mock 1.4.0;
use POSIX;
use Test::Deep qw(cmp_deeply all isa methods bool re);
use Test::Exception;
use Test::More;

sub setUp {
	my ($self) = @_;

	$self->dic(Dlpodget::DIC->new(
		logger => Dlpodget::Log::Mock->new,
		cache => Cache::MemoryCache->new,
		config => Dlpodget::Config::Mock->new({
			#VOIPDB => Dlpodget::DB::Mock->makeConfig(), # Enable this if you will call an init() to set up DBs
		}),
		#voipdb => Dlpodget::DB::Mock->new, # Enable this if you want to pass a DB directly
	));

	$self->sut(Dlpodget::URL->new(
		dic => $self->dic,
		#dicRequire => 1, # Enable this for new libraries which should only use the DIC
	));

	$self->forcePlan();
	$self->dic->logger->warnFatal(1); # disable in specific tests if needed

	return EXIT_SUCCESS;
}

sub testSomething {
	plan tests => 1;
	fail("You were supposed to remove this (facepalm)");
}

package main;
use strict;
exit(URLTests->new->run);
