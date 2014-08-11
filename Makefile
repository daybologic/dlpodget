#!/usr/bin/make
#
# Daybo Logic Podcast downloader
# Copyright (c) 2012-2014, David Duncan Ross Palmer (M6KVM), Daybo Logic
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

# TODO: Use GNU Autotools
AUTOMAKE_OPTIONS=subdir-objects
SUBDIRS = lib t
ifdef DLPODGET_DOCS
SUBDIRS += docs
endif


all: subdirs

install:
	uid=`id -u`; \
	if test "$$uid" -eq "0"; then \
		install -m 755 dlpodget $$DESTDIR/usr/bin/; \
	else \
		install -m 755 dlpodget ~/bin/; \
	fi

check : test
test:
	$(SHELL) t/run.sh
	cover
	lynx -dump cover_db/coverage.html | ./bin/cover_check

clean:
	rm -rf cover_db

# nb. we don't presently use Autotools, so we implement AUTOMAKE_OPTIONS ourselves
subdirs:
	for dir in $(SUBDIRS); do \
		cd $$dir; \
		make all; \
		cd ..; \
	done
