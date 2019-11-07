#
# Makefile to automate the relational online analytical processing of complex
# queries
#
# Copyright 2017-2019 Diomidis Spinellis
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
#export DBPASSWD?=ghtorrent
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
	@mkdir -p reports
	@sh $(SRD)/run_sql.sh $< >$@

tables/%: %.sql $(ROLAPDB) $(DEPENDENCIES)
	@echo "[Create table from $<]"
	@mkdir -p tables
	@sh $(SRD)/run_sql.sh $< >$@

all: .depend .gitignore $(TABLES_VIEWS) $(RESULTS)

$(ROLAPDB):
	@echo "[Create database $(ROLAPDB)]"
	@sh $(SRD)/create_db.sh
	@touch $@

.gitignore: $(ROLAPDB)
	@echo "[Create / update .gitignore]"
	@touch $@
	@( cat $@ ; \
	  echo .depend ; \
	  echo reports ; \
	  echo tables ; \
	  echo simple-rolap ; \
	  echo $(ROLAPDB) ; \
	) | \
	sort -u >$@.new
	@mv $@.new $@

.PHONY: .depend corrtest

.depend:
	@echo "[Create/update dependencies]"
	@sh $(SRD)/mkdep.sh >./.depend

clean:
	@echo '[Remove tables, reports; drop database $(ROLAPDB)]'
	@rm -rf reports tables .depend $(ROLAPDB)
	@sh $(SRD)/drop_db.sh

graph.dot: .depend
	$(SRD)/dep2dot.sed $< >$@

sorted-dependencies: .depend
	$(SRD)/dep2tsort.sed $< | tsort >$@

graph.pdf: graph.dot
	dot -Tpdf $< -o $@

graph.png: graph.dot
	dot -Tpng $< -o $@

test:
	$(SRD)/run_test.sh

tags: $(QUERIES)
	sh mktags.sh $(QUERIES)

# Include dependencies if they exist
ifneq ("$(wildcard .depend)","")
include .depend
endif
