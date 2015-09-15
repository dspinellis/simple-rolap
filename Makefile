export DBUSER=ghtorrent
export DBPASSWD=ghtorrent
export DB=ghtorrent

# Ensure targets are deleted if a command fails
.DELETE_ON_ERROR:

QUERIES=$(wildcard *.sql)
TABLES_VIEWS=$(shell sed -rn 's/create (table|or replace view)  *leadership\.([^ ]*).*/tables\/\2/p' *.sql)
RESULTS=$(shell grep -l '^select' *.sql | sed 's/\(.*\)\.sql/reports\/\1.txt/')

.SUFFIXES:.sql .txt .tex .eps .pdf .gpl .table

reports/%.txt: %.sql
	@mkdir -p reports
	sh run_sql.sh $< >$@

tables/%: %.sql
	@mkdir -p tables
	sh run_sql.sh $< >$@

all: $(TABLES_VIEWS) $(RESULTS) clones
	-beep

depend: .depend

.depend: $(QUERIES)
	rm -f ./.depend
	sh mkdep.sh >./.depend

clean:
	rm -rf reports tables clones

graph.dot: .depend
	./dep2dot.sed $< >$@

graph.pdf: graph.dot
	dot -Tpdf $< -o $@

clones: reports/project_urls.txt
	sh clone.sh

code_contribution.txt: clones measure-contribution.sh
	sh measure-contribution.sh >$@

growth.txt: clones measure-growth.sh
	sh measure-growth.sh >$@

tables/growth: growth.txt

test: $(TABLES_VIEWS)
	@sh runtest.sh

tags: $(QUERIES)
	sh make-tags.sh $(QUERIES)

# Sync over the reports
rsync:
	rsync -av stereo:leadership-performance/reports/ reports/

include .depend
