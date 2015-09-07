export DBUSER=ghtorrent
export DBPASSWD=ghtorrent
export DB=ghtorrent

QUERIES=$(wildcard *.sql)
TABLES_VIEWS=$(shell sed -rn 's/create (table|or replace view)  *leadership\.([^ ]*).*/tables\/\2/p' *.sql)
RESULTS=$(shell grep -l '^select' *.sql | sed 's/\(.*\)\.sql/reports\/\1.txt/')

.SUFFIXES:.sql .txt .tex .eps .pdf .gpl .table

reports/%.txt: %.sql
	@mkdir -p reports
	cat lockall.SQL $< unlockall.SQL | \
	mysql -u $(DBUSER) -p"$(DBPASSWD)" $(DB) >$@

tables/%: %.sql
	@mkdir -p tables
	cat lockall.SQL $< unlockall.SQL | \
	mysql --local-infile -u $(DBUSER) -p"$(DBPASSWD)" $(DB) >$@

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

clones: reports/project_urls.txt
	mkdir -p clones
	( \
		cd clones ; \
		sed 1d ../reports/project_urls.txt | \
		while read url ; do \
		  git clone $$url ; \
		done \
	)

contribution.txt: clones measure-contribution.sh
	./measure-contribution.sh >$@

growth.txt: clones measure-growth.sh
	./measure-growth.sh >$@

tables/growth: growth.txt

include .depend
