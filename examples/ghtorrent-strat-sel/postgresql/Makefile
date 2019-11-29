export RDBMS?=postgresql
export MAINDB?=ghtorrent
export DBUSER?=ght
export ROLAPDB?=stratsel

include ../../../Makefile

tables/project_metrics: data/metrics.csv

data/metrics.csv: reports/project_urls.txt project_metrics.sh
	sh project_metrics.sh
