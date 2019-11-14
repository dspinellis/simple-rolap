-- Projects with recent issues

create table stratsel.popular_projects AS
  select recent_issue_projects.id
  from stratsel.recent_issue_projects
  left join stratsel.project_stars
  on project_stars.id = recent_issue_projects.id
  where stars > 100;
