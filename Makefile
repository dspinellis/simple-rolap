DBUSER=ghtorrent
DBPASSWD=ghtorrent
DB=ghtorrent

QUERIES=$(wildcard *.sql)
TABLES_VIEWS=$(shell sed -rn 's/create (table|or replace view)  *leadership\.([^ ]*).*/tables\/\2/p' *.sql)
RESULTS=$(shell grep -l '^select' *.sql | sed 's/\(.*\)\.sql/results\/\1.txt/')

.SUFFIXES:.sql .txt .tex .eps .pdf .gpl .table

results/%.txt: %.sql
	cat lockall.SQL $< unlockall.SQL | \
	mysql -u $(DBUSER) -p"$(DBPASSWD)" $(DB) >$@

tables/%: %.sql
	cat lockall.SQL $< unlockall.SQL | \
	mysql -u $(DBUSER) -p"$(DBPASSWD)" $(DB) >$@

all: $(TABLES_VIEWS) $(RESULTS)
	-beep

depend: .depend

.depend: $(QUERIES)
	rm -f ./.depend
	sh mkdep.sh >./.depend

include .depend
