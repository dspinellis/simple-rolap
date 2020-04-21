#
# Makefile to automate the relational online analytical processing of complex
# queries
#
# Copyright 2017-2020 Diomidis Spinellis
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Change the following four variables to match your environment
# or set them before invoking make(1)
export RDBMS?=sqlite
export MAINDB?=rxjs-ghtorrent
export ROLAPDB?=driveby
export DBHOST=127.0.0.1

#export RDBMS?=mysql
#export DBUSER?=ghtorrent
#export MAINDB?=ghtorrent2
#export ROLAPDB?=driveby

# Ensure targets are deleted if a command fails
.DELETE_ON_ERROR:

# Directory where the simple-rolap scripts reside
SRD=$(dir $(lastword $(filter-out .depend,$(MAKEFILE_LIST))))
export ROLAP_DIR=$(SRD)

QUERIES=$(wildcard *.sql)
TABLES_VIEWS=$(shell sed -rn 's/create (table|or replace view)  *$(ROLAPDB)\.([^ ]*).*/tables\/\2/pi' *.sql)
RESULTS=$(shell grep -li '^select' *.sql | sed 's/\(.*\)\.sql/reports\/\1.txt/')

.SUFFIXES:.sql .txt .pdf

reports/%.txt: %.sql $(ROLAPDB) $(DEPENDENCIES)
	@echo "[Create report from $<]"
	mkdir -p reports
	$(SRD)/run_sql.sh $< >$@

tables/%: %.sql $(ROLAPDB) $(DEPENDENCIES)
	@echo "[Create table from $<]"
	mkdir -p tables
	$(SRD)/run_sql.sh $< >$@

all: .depend .gitignore $(TABLES_VIEWS) $(RESULTS) $(ALL) # Help: Run all queries and reports
	@echo '[All tables and reports are up to date]'

$(ROLAPDB):
	@echo "[Create database $(ROLAPDB)]"
	$(SRD)/create_db.sh
	touch $@

.gitignore: $(ROLAPDB)
	@echo "[Create / update .gitignore]"
	touch $@
	( cat $@ ; \
	  echo .depend ; \
	  echo reports ; \
	  echo tables ; \
	  echo simple-rolap ; \
	  echo $(ROLAPDB) ; \
	) | \
	sort -u >$@.new
	mv $@.new $@

.PHONY: corrtest

.depend .depend.all: $(ROLAPDB) $(wildcard *.sql)
	@echo "[Create/update dependencies]"
	-$(SRD)/mkdep.sh | tee .depend.all | grep -v maindb/ >.depend

clean:	# Help: Drop database and remove generated files
	@echo '[Remove tables, reports; drop database $(ROLAPDB)]'
	rm -rf reports tables .depend $(ROLAPDB)
	$(SRD)/drop_db.sh

graph.dot: .depend	# Help: Create GraphViz file with ROLAP dependencies
	$(SRD)/dep2dot.sed $< >$@

full-graph.dot: .depend.all	# Help: Create GraphViz file with all dependencies
	$(SRD)/dep2dot.sed $< >$@

sorted-dependencies: .depend	# Help: Create text file with ROLAP dependencies
	$(SRD)/dep2tsort.sed $< | tsort >$@

graph.pdf: graph.dot	# Help: Create PDF chart with dependencies
	dot -Tpdf $< -o $@

graph.png: graph.dot	# Help: Create PNG chart with dependencies
	dot -Tpng $< -o $@

test:	# Help: Run RDBUnit tests
# Help: Pass SCRIPT=script-name to execute only a single test script
	$(SRD)/run_test.sh

tags: $(QUERIES)	# Help: Create tags file
	$(SRD)/mktags.sh $(QUERIES)

sync-timestamps:	# Help: Synchronize query timestamps to their commit time
	$(SRD)/sync_timestamps.sh

help: # Help: Show this help message
	@echo 'The following make targets are available.'
	@sed -n 's/^\([^:]*:\).*# [H]elp: \(.*\)/printf "%-20s %s\\n" "\1" "\2"/p' $(SRD)/Makefile | sh | sort
	@echo
	@echo 'You can modify the operation of make with the following assignments.'
	@sed -n 's/^# [H]elp: \(.*\)/\1/p' $(SRD)/Makefile

# Include dependencies; no error if they don't exist
-include .depend

# Help: Pass V=1 (verbose) to disable silent operation
# http://make.mad-scientist.net/managing-recipe-echoing/
$(V).SILENT:

# Help: Pass V=2 to trace the underlying shell scripts
