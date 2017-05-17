-- Projects that have been forked and have a PR

create table stratsel.pr_projects AS
  select distinct forked_projects.id from stratsel.forked_projects
  inner join pull_requests on pull_requests.base_repo_id = forked_projects.id;
