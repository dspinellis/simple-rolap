create table stratsel.project_metrics (id integer,
  files integer, lines integer);

.separator ","

.import data/metrics.csv project_metrics
