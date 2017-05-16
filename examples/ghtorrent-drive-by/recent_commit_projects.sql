-- Projects with recent commits

create table driveby.recent_commit_projects AS
  select distinct pr_projects.id
  from driveby.pr_projects
  left join commits
  on commits.project_id = pr_projects.id
  where created_at > '2017-01-01';
