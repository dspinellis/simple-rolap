-- Projects with recent issues

create table stratsel.recent_issue_projects AS
  select distinct recent_commit_projects.id
  from stratsel.recent_commit_projects
  left join issues
  on issues.repo_id = recent_commit_projects.id
  where created_at > '2017-01-01';
