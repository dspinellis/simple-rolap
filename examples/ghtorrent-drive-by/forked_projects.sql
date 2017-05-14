-- Projects that have been forked

create table driveby.forked_projects AS
  select distinct forked_from as id from projects
  where forked_from is not null;
