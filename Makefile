DBUSER=ghtorrent
DBPASSWD=ghtorrent
DB=ghtorrent

QUERIES=$(wildcard *.sql)
RESULTS=$(patsubst %.sql,%.txt,$(QUERIES))

.SUFFIXES:.sql .txt .tex .eps .pdf .gpl

.sql.txt:
	cat lockall.SQL $< unlockall.SQL | \
	mysql -u $(DBUSER) -p"$(DBPASSWD)" $(DB) >$@

all: $(RESULTS)
