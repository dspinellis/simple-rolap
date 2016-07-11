export DBUSER=ghtorrent
export DBPASSWD=ghtorrent
export DB=ghtorrent2

# Ensure targets are deleted if a command fails
.DELETE_ON_ERROR:

QUERIES=$(wildcard *.sql)
TABLES_VIEWS=$(shell sed -rn 's/create (table|or replace view)  *leadership\.([^ ]*).*/tables\/\2/p' *.sql)
RESULTS=$(shell grep -l '^select' *.sql | sed 's/\(.*\)\.sql/reports\/\1.txt/')

.SUFFIXES:.sql .txt .tex .eps .pdf .gpl .table

reports/%.txt: %.sql
	@mkdir -p reports
	sh run_sql.sh $< >$@

tables/%: %.sql leadership
	@mkdir -p tables
	sh run_sql.sh $< >$@

all: $(TABLES_VIEWS) $(RESULTS)
	-beep

leadership:
	( \
	echo 'create database leadership;' ; \
	echo "GRANT ALL PRIVILEGES ON leadership.* to ghtorrent@'localhost';" ; \
	echo 'flush privileges;' \
	) | \
	mysql -u root -p && \
	touch $@

results.txt: corrtest.R reports/performance_report.txt
	./corrtest.R >$@

# Copy the corrtest results for pasting into the spreadsheet
corrtest:
	./corrtest.R | winclip -cm

.PHONY: corrtest

depend: .depend

.depend: $(QUERIES)
	rm -f ./.depend
	sh mkdep.sh >./.depend

clean:
	rm -rf reports tables clones contribution growth

graph.dot: .depend
	./dep2dot.sed $< >$@

graph.pdf: graph.dot
	dot -Tpdf $< -o $@

code_contribution.txt: measure-contribution.sh reports/project_urls.txt
	sh measure-contribution.sh >$@

# The code_contribution.txt file is a dependency in order
# to ensure that the projects are cloned
growth.txt: code_contribution.txt measure-growth.sh
	sh measure-growth.sh >$@

tables/project_lines: growth.txt

tables/code_contribution: code_contribution.txt

test: $(TABLES_VIEWS)
	@sh runtest.sh

tags: $(QUERIES)
	sh make-tags.sh $(QUERIES)

# Sync over the reports
rsync:
	rsync -av stereo:leadership-performance/reports/ reports/

# Put correlations to clipboard for spreadsheet copying
correlations:
	./corrtest.R | winclip -cm

include .depend
