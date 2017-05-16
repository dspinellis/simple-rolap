-- Projects with recent issues

create table driveby.recent_issue_projects AS
  select distinct recent_commit_projects.id
  from driveby.recent_commit_projects
  left join issues
  on issues.repo_id = recent_commit_projects.id
  where created_at > '2017-01-01';
