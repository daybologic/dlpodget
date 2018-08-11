#
# Daybo Logic Podcast downloader
# Copyright (c) 2012-2018, Duncan Ross Palmer (2E0EOL) and others,
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

package Dlpodget::DIC;
use Moose;
use Scalar::Util qw(blessed);

has __bucket => (is => 'ro', isa => 'HashRef[Dlpodget::Base]');

sub set {
	my ($self, $obj) = @_;
	die('No object sent to DIC/set') if (!defined($obj));

	my $type = blessed($obj);
	die('DIC object must be blessed') if (!$type);

	$type =~ s/^Dlpodget:://;
	if ($self->get($type)) {
		die("DIC already contains an object of type $type")
	}

	$self->__bucket->{$type} = $obj;
	return $self;
}

sub get {
	my ($self, $name) = @_;
	die('No name sent to DIC/get') if (!$name);

	if (my $obj = $self->__bucket->{$type}) {
		return $obj;
	}

	die("DIC object $name was not set, when you attempted to fetch it");
}

1;
