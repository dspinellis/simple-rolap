create table stratsel.project_metrics (id integer,
  files integer, lines integer);

\copy stratsel.project_metrics from 'data/metrics.csv' with delimiter ',';
