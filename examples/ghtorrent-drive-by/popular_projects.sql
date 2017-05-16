-- Projects with recent issues

create table driveby.popular_projects AS
  select recent_issue_projects.id
  from driveby.recent_issue_projects
  left join driveby.project_stars
  on project_stars.id = recent_issue_projects.id
  where stars > 100;
