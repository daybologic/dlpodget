package Dlpodget::Config;
#
# Daybo Logic Podcast downloader
# Copyright (C) 2012-2024, Ducan Ross Palmer (M6KVM, 2E0EOL), all rights reserved.
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

use strict;
use warnings;

use Moose;
use Config::IniFiles;

extends 'Dlpodget::Base';

has confFiles => (is => 'ro', isa => 'ArrayRef[Str]', default => sub {
	return [];
});

has ini => (is => 'rw', isa => 'Config::IniFiles');

sub initConfigDefaults {
	my ($self, $feeds) = @_;
	my $confmain = $feeds->{main};
	die('Assertion failure') unless $confmain;

	$confmain->{TMPDIR} = '/tmp' unless ($confmain->{TMPDIR});
	$confmain->{HOME} = $confmain->{TMPDIR} unless ($confmain->{HOME});
	$confmain->{LOCALPFX} = $confmain->{HOME} unless ($confmain->{LOCALPFX});

	my %defaults = (
		'enable' => 1,
		'noop'   => 0,
		'debug'  => 0,
	);

	foreach my $opt (keys(%defaults)) {
		next if (defined($confmain->{$opt}) && $confmain->{$opt} =~ m/\d$/);
		$confmain->{$opt} = $defaults{$opt};
	}
}

sub initFeedDefaults {
	my ($self, $feeds, $feed) = @_;
	$feed->{localpath} = $feeds->{main}->{LOCALPFX} unless ($feed->{localpath});
	$feed->{rss} = '' unless ($feed->{rss});
	foreach my $chk ('check', 'download', 'enable') {
		$feed->{$chk} = 1 if ( !$feed->{$chk} || $feed->{$chk} !~ m/\^d$/ );
	}
}

sub load {
	my ($self) = @_;
	foreach my $confFile (@{ $self->confFiles }) {
		next unless (-f $confFile);
		$self->ini(Config::IniFiles->new(-file => $confFile, -commentchar => ';'));
		if (!$self->ini) {
			print(STDERR "Fault with $confFile: " . join(',', @Config::IniFiles::errors) . "\n");
			return 1;
		}
		last;
	}
}

1;
