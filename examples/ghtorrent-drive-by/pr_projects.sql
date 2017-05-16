-- Projects that have been forked and have a PR

create table driveby.pr_projects AS
  select distinct forked_projects.id from driveby.forked_projects
  inner join issues on issues.repo_id = forked_projects.id;
