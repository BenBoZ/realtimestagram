#   This file is part of Realtimestagram.
#
#   Realtimestagram is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 2 of the License, or
#   (at your option) any later version.
#
#   Realtimestagram is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with Realtimestagram.  If not, see <http://www.gnu.org/licenses/>.

# 
# To seperate source from build files, export them to the seperate bld folder
TMPDIR=tmp
BLDTMPDIR=bld/tmp
BLDDIR=bld

MKDIR_P = mkdir -p

VIEW_CMD = /usr/bin/gtkwave

.PHONY: all clean directories docs test

all: directories curve_adjust_tb

curve_adjust_tb: 
	@cd src; make

clean:
	@cd doc; make clean
	@cd src; make clean
	@rm -rf $(BLDDIR)/*;echo "Cleared $(BLDDIR)"

directories:
	${MKDIR_P} ${BLDDIR}
	${MKDIR_P} ${BLDTMPDIR}

docs:
	@cd doc; make

test: all
	@echo "Starting TB"
	@$(BLDDIR)/curve_adjust_tb --vcdgz=$(TMPDIR)/curve_adjust_tb.vcdgz

view:
	@gunzip --stdout $(TMPDIR)/curve_adjust_tb.vcdgz | $(VIEW_CMD) --vcd  

