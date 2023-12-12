package Dlpodget::Feed::Config;
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

use Moose;
use Moose::Util::TypeConstraints;

has attach => (is => 'ro', isa => 'Boolean', default => 0);

has [qw(enable download check)] => (is => 'ro', isa => 'Boolean', default => 1);

has notify => (is => 'ro', isa => 'Boolean|Dlpodget::URL', default => 0);

has [qw(retries maxcount quality)] => (is => 'ro', isa => 'Int', default => 1);

has rss => (is => 'ro', isa => 'Dlpodget::URL');

enum Codec => [qw/default ogg flac mp2/];
has codec => (is => 'ro', isa => 'Codec', default => 'default');

has localpath => (is => 'ro', isa => 'Str');

has maxage => (is => 'ro', isa => 'Dlpodget::Age', default => sub {
	return Dlpodget::Age->new(unlimited => 1);
});

has rsleep => (is => 'ro', isa => 'Dlpodget::RSleep', defaut => sub {
	return Dlpodget::RSleep->new(random => 0, secs => 0);
});

1;
