export RDBMS?=sqlite
export MAINDB?=rxjs-ghtorrent
export ROLAPDB?=stratsel
export DEPENDENCIES=rxjs-ghtorrent.db

include ../../../Makefile

rxjs-ghtorrent.db:
	wget https://github.com/ghtorrent/tutorial/raw/master/rxjs-ghtorrent.db

tables/project_metrics: data/metrics.csv

data/metrics.csv: reports/project_urls.txt project_metrics.sh
	sh project_metrics.sh
