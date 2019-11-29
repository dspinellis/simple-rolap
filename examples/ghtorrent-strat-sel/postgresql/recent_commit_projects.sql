-- Projects with recent commits

create table stratsel.recent_commit_projects AS
  select distinct pr_projects.id
  from stratsel.pr_projects
  left join (
    select * from commits where created_at > '2017-01-01' limit 10000) as C
  on C.project_id = pr_projects.id;
