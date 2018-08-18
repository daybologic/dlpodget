#!/usr/bin/env perl
package UUIDTests;
use Moose;

extends 'Test::Module::Runnable';

use Cache::MemoryCache;
use English qw(-no_match_vars);
use Dlpodget::UUID;
use Dlpodget::UUID::Factory;
use POSIX qw(EXIT_SUCCESS);
use Test::Deep qw(cmp_deeply all isa methods bool re);
use Test::Exception;
use Test::More 0.96;
use Readonly;
use Data::UUID::LibUUID qw(uuid_to_binary);
use Devel::Cover;

sub setUp {
	my ($self) = @_;

	$self->sut(Dlpodget::UUID::Factory->instance());

	#$self->forcePlan();

	return EXIT_SUCCESS;
}

sub tearDown {
	my ($self) = @_;
	$self->sut->reset();
	return EXIT_SUCCESS;
}

sub testCreateTenAndPop {
	my ($self) = @_;
	my @peeked;
	plan tests => 3;

	Readonly my $COUNT => 10;

	subtest 'pre state' => sub {
		plan tests => 3;

		is($self->sut->top(), undef, 'top returned <undef>');
		is($self->sut->pop(), undef, 'pop returned <undef>');
		is($self->sut->count(), 0, 'count returned zero');
	};

	subtest create => sub {
		plan tests => $COUNT;

		for (my $i = 0; $i < $COUNT; $i++) {
			subtest sprintf('create %d/%d', $i + 1, $COUNT) => sub {
				plan tests => 3;

				my $response = $self->sut->create();
				cmp_deeply($response, all(
					isa('Dlpodget::Response'),
					methods(
						success => bool(1),
						getData => isa('Dlpodget::UUID'),
					),
				), 'create() returns successful response with no data');

				my $data = $response->getData();
				cmp_deeply($data, isa('Dlpodget::UUID'), 'top() returns object of correct type');
				diag($data->toString());
				$peeked[$i] = $data;

				is($self->sut->count(), $i + 1, sprintf('count returns %d', $i + 1));
			};
		}
	};

	subtest pop => sub {
		plan tests => $COUNT + 1; # One extra for the undef at the end

		for (my $i = 0; $i < $COUNT; $i++) {
			subtest sprintf('pop %d/%d', $i + 1, $COUNT) => sub {
				plan tests => 3;

				ok($peeked[$i]->equals($self->sut->top()), 'top() compare successful');
				diag($peeked[$i]->getCanon());
				diag($self->sut->top()->toString());

				my $popped = $self->sut->pop();
				ok($peeked[$i]->equals($popped), 'pop() compare successful');
				diag($popped->toString());

				is($self->sut->count(), ($COUNT - $i) -1, 'count correct');
			};
		}

		ok(!$self->sut->pop(), 'pop returns <undef>');
	};

	return EXIT_SUCCESS;
}

sub testCreateSpecificCompareMatch {
	my ($self) = @_;
	plan tests => 2;

	Readonly my $UUID_A => '7301ed9d-780c-4d0f-ae75-3d78b490c01b';
	Readonly my $UUID_B => '7301ed9d-780c-4d0f-ae75-3d78b490c01b';

	my $response = $self->sut->create($UUID_A);
	BAIL_OUT($response->toString()) unless ($response->success);
	my $a = $self->sut->pop();

	$response = $self->sut->create($UUID_B);
	BAIL_OUT($response->toString()) unless ($response->success);
	my $b = $self->sut->pop();

	ok($a->equals($b), 'compare succeeded');
	isnt($a, $b, 'a is not the b object');

	return EXIT_SUCCESS;
}

sub testCreateSpecificCompareMismatch {
	my ($self) = @_;
	plan tests => 2;

	Readonly my $UUID_A => '435dc643-3226-48c3-a98f-fcb785de0a72';
	Readonly my $UUID_B => '333d36dc-0d8d-49dd-bdf3-cf46f612df89';

	my $response = $self->sut->create($UUID_A);
	BAIL_OUT($response->toString()) unless ($response->success);
	my $a = $self->sut->pop();

	$response = $self->sut->create($UUID_B);
	BAIL_OUT($response->toString()) unless ($response->success);
	my $b = $self->sut->pop();

	ok(!$a->equals($b), 'compare failed');
	isnt($a, $b, 'a is not the b object');

	return EXIT_SUCCESS;
}

sub testCreateSpecific {
	my ($self) = @_;
	plan tests => 1;

	Readonly my $UUID => '1b23f08f-b647-498e-bd1a-bae3bb6a531c';

	my $response = $self->sut->create($UUID);
	BAIL_OUT($response->toString()) unless ($response->success);

	my $uuid = $self->sut->pop();
	cmp_deeply($uuid, all(
		isa('Dlpodget::UUID'),
		methods(
			getCanon => $UUID,
			toString => '{' . $UUID . '}',
			value => uuid_to_binary($UUID),
		),
	), 'deep state of UUID object');

	return EXIT_SUCCESS;
}

sub testVersionDefault {
	my ($self) = @_;
	plan tests => 1;

	my $response = $self->sut->create();
	BAIL_OUT($response->toString()) unless ($response->success);
	my $uuid = $response->getData();
	is($uuid->version(), 1, 'Default UUID creation version is 1');

	return EXIT_SUCCESS;
}

sub testVersion {
	my ($self) = @_;

	Readonly my %UUID_VERSION_MAP => (
		'85502b1e-a272-11e8-89e8-f23c9173fe51' => 1,
		'8ab3060e-2cba-2f23-b74c-b52db3bdfb46' => 2,
		'c87ee674-4ddc-3efe-a74e-dfe25da5d7b3' => 3,
		'750acafd-d343-4e18-911a-923a4a6809d3' => 4,
		'4ebd0208-8328-5d69-8c44-ec50939c0967' => 5,
	);

	plan tests => scalar(keys(%UUID_VERSION_MAP));

	while (my ($uuidStr, $version) = each(%UUID_VERSION_MAP)) {
		my $response = $self->sut->create($uuidStr);
		BAIL_OUT($response->toString()) unless ($response->success);
		my $uuid = $response->getData();
		is(
			$uuid->version(), $version, sprintf(
				'UUID: %s, version: %d',
				$uuid->toString(),
				$version
			)
		);
	}

	return EXIT_SUCCESS;
}

sub testCreateInvalid {
	my ($self) = @_;
	plan tests => 1;

	my $response = $self->sut->create($self->unique);
	cmp_deeply($response, all(
		isa('Dlpodget::Response'),
		methods(
			success => bool(0),
			error   => all(
				isa('Dlpodget::Error'),
				methods(
					value => all(
						isa('Dlpodget::UUID'),
						methods(
							canon => $Dlpodget::Errors::INVALID_UUID,
						),
					),
				),
			),
		),
	), 'INVALID_UUID');

	return EXIT_SUCCESS;
}

package main;
use strict;
use warnings;
exit(UUIDTests->new->run);
