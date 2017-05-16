-- Projects with recent issues and the number of stars

create table driveby.project_stars AS
  select recent_issue_projects.id as id, count(*) as stars
  from driveby.recent_issue_projects
  left join watchers
  on watchers.repo_id = recent_issue_projects.id
  group by recent_issue_projects.id;
