#
# Makefile to automate the relational online analytical processing of complex
# queries
#
export DBUSER=ghtorrent
export DBPASSWD=ghtorrent
export MAINDB=ghtorrent2
ROLAPDB=rolapdb

# Ensure targets are deleted if a command fails
.DELETE_ON_ERROR:

QUERIES=$(wildcard *.sql)
TABLES_VIEWS=$(shell sed -rn 's/create (table|or replace view)  *$ROLAPDB\.([^ ]*).*/tables\/\2/p' *.sql)
RESULTS=$(shell grep -l '^select' *.sql | sed 's/\(.*\)\.sql/reports\/\1.txt/')

.SUFFIXES:.sql .txt .pdf

reports/%.txt: %.sql
	@mkdir -p reports
	sh run_sql.sh $< >$@

tables/%: %.sql $(ROLAPDB)
	@mkdir -p tables
	sh run_sql.sh $< >$@

all: $(TABLES_VIEWS) $(RESULTS)

$(ROLAPDB):
	( \
	echo 'create database $(ROLAPDB);' ; \
	echo "GRANT ALL PRIVILEGES ON $(ROLAPDB).* to ghtorrent@'localhost';" ; \
	echo 'flush privileges;' \
	) | \
	mysql -u root -p && \
	touch $@

.PHONY: corrtest

depend: .depend

.depend: $(QUERIES)
	rm -f ./.depend
	sh mkdep.sh >./.depend

clean:
	rm -rf reports tables clones contribution growth

graph.dot: .depend
	./dep2dot.sed $< >$@

sorted-dependencies: .depend
	./dep2tsort.sed $< | tsort >$@

graph.pdf: graph.dot
	dot -Tpdf $< -o $@

test: $(TABLES_VIEWS)
	@sh runtest.sh

tags: $(QUERIES)
	sh make-tags.sh $(QUERIES)

include .depend
