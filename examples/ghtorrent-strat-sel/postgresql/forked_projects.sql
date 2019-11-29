-- Projects that have been forked

create table stratsel.forked_projects AS
  select distinct forked_from as id from (
    select * from projects limit 1000
  ) AS a
  where forked_from is not null limit 100;
