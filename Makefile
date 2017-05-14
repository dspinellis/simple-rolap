#
# Makefile to automate the relational online analytical processing of complex
# queries
#
# Copyright 2017 Diomidis Spinellis
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

#export RDBMS?=mysql
#export DBUSER?=ghtorrent
#export DBPASSWD?=ghtorrent
#export MAINDB?=ghtorrent2
#export ROLAPDB?=driveby

# Ensure targets are deleted if a command fails
.DELETE_ON_ERROR:

# Directory where the simple-rolap scripts reside
SRD=$(dir $(lastword $(filter-out .depend,$(MAKEFILE_LIST))))
QUERIES=$(wildcard *.sql)
TABLES_VIEWS=$(shell sed -rn 's/create (table|or replace view)  *$(ROLAPDB)\.([^ ]*).*/tables\/\2/p' *.sql)
RESULTS=$(shell grep -l '^select' *.sql | sed 's/\(.*\)\.sql/reports\/\1.txt/')

.SUFFIXES:.sql .txt .pdf

reports/%.txt: %.sql
	mkdir -p reports
	sh $(SRD)/run_sql.sh $< >$@

tables/%: %.sql $(ROLAPDB)
	mkdir -p tables
	sh $(SRD)/run_sql.sh $< >$@

all: $(TABLES_VIEWS) $(RESULTS)

$(ROLAPDB):
	echo $(MAKEFILE_LIST)
	sh $(SRD)/create_db.sh
	touch $@

.PHONY: corrtest

depend: .depend

.depend: $(QUERIES)
	rm -f ./.depend
	sh $(SRD)/mkdep.sh >./.depend

clean:
	rm -rf reports tables .depend

graph.dot: .depend
	$(SRD)/dep2dot.sed $< >$@

sorted-dependencies: .depend
	$(SRD)/dep2tsort.sed $< | tsort >$@

graph.pdf: graph.dot
	dot -Tpdf $< -o $@

test:
	$(SRD)/run_test.sh

tags: $(QUERIES)
	sh mktags.sh $(QUERIES)

include .depend
