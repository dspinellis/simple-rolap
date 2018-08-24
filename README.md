# simple-rolap: Simple relational online analytical processing

This collection of scripts allows maintainable and time-efficient
[relational online analytical processing](https://en.wikipedia.org/wiki/Online_analytical_processing#Relational_OLAP_.28ROLAP.29) through the
specification of small, modular SQL queries.
It is mainly suited for querying a rarely modified data set,
such as that of [GHTorrent](http://ghtorrent.org/).
The result of each SQL query is saved in corresponding table,
which can then be used by subsequent queries.
As a result, each query can be independently developed and tested.
Automatic dependency analysis of the queries ensures that
new queries can use already calculated results and that every
time a query is changed all tables that depend on it (and only those)
are automatically repopulated.

The provided functionality is mainly useful in cases where *materialized views*
are unsupported or unusable.
The scripts are written for *MySQL* and *SQLite*,
but they should be easy to port to other relational database systems.

For complex relational OLAP queries, *simple-rolap* can be combined particularly
effectively with [RDBUnit](https://github.com/dspinellis/rdbunit).
You can find a complete tutorial on using *simple-rolap* with *RDBUnit*
for mining Git repositories in a
[technical briefing](https://www.spinellis.gr/git-mine-briefing/)
presented at the 2017 International Conference on Software Engineering.
You can cite this work as follows.

Georgios Gousios and Diomidis Spinellis. Mining software engineering data from GitHub. In *Proceedings of the 39th International Conference on Software Engineering Companion, ICSE-C '17*, pages 501–502, Piscataway, NJ, USA, May 2017. IEEE Press. Technical Briefing. [doi:10.1109/ICSE-C.2017.164](https://dx.doi.org/10.1109%2FICSE-C.2017.164)

## Installation
The *simple-rolap* scripts are used by including the provided *Makefile*.
Consequently, all that is needed is to provide the repository in suitably
accessible location.
Here is an example.
```sh
cd /usr/local/lib
sudo git clone --depth=1 https://github.com/dspinellis/simple-rolap.git
```

The system where *simple-rolap* is run must have and installation of the
database unit beend tested, *GNU make*,
and (if you want to visualize the associated dependency graphs)
[GraphViz](http://graphviz.org/).

## Use
To start using *simple-rolap*, create a `Makefile` that
a) specifies the project's configuration by defining a few variables,
and b) includes the *simple-rolap* `Makefile`.
Consider the following self-explanatory example.
```Makefile
# Database engine to use (One of sqlite or mysql)
export RDBMS?=sqlite
# The (default) database containing the data you want to query
export MAINDB?=rxjs-ghtorrent
# The (explicitly specified) database that will contain your queries' results
export ROLAPDB?=stratsel

include /usr/local/src/simple-rolap/Makefile
```

If some actions need to be performed before running the queries,
you can specify them in a variable named `DEPENDENCIES` and then
add corresponding rules.
Example:
```Makefile
export DEPENDENCIES=rxjs-ghtorrent.db

rxjs-ghtorrent.db:
	wget https://github.com/ghtorrent/tutorial/raw/master/rxjs-ghtorrent.db
```

Then comes the specification of SQL statements that will analyze the data.
The *simple-rolap* system supports two types of modules:
those that create tables and those that run queries to create a report.
Below is a table creation module.

```sql
-- Projects that have been forked

create table stratsel.forked_projects as
  select distinct forked_from as id from projects
  where forked_from is not null;
```

The SQL statement creates a table in the result database by using tables
from the data and the result database.
The module must reside in a file named after the table it creates,
with the suffix `.sql`, e.g. `forked_projects.sql` in the preceding example.

By typing `make` the module will be run, if and only if its results have never
been produced, or if they are older than the result tables on which they
depend.
This is accomplished by creating a timestamped file for each module
execution in a directory named `tables`.

Each module can contain database engine-specific extensions and also SQL
statements that create indices, as shown in the following example.
```sql
-- Projects in our candidate set that have their URL blacklisted

create table leadership.blacklisted_projects ENGINE=MyISAM as
  select projects.id
  from leadership.blacklisted_urls
  left join projects
  on blacklisted_urls.url = projects.url;

alter table leadership.blacklisted_projects add index(id);
```

A query module is a simple SQL `SELECT` query, such as the following.
```sql
-- URLs of popular projects
select projects.id, 'https://github.com/' || substr(url, 30) as url
from stratsel.popular_projects
left join projects
on projects.id = popular_projects.id;
```

When *make* is run on such a module, the results of the query will
appear in the directory `reports` in a file named after the module's name
with the suffix `.sql` replaced by `.txt`.

## Goodies
Here are some more things that the provided `Makefile` allows you to do.

* Run `make graph.png` or `make graph.pdf` to generate a diagram of the
queries' dependencies.
* Run `make test` to run any [RDBUnit](https://github.com/dspinellis/rdbunit)
unit tests you may have written.
* Run `make clean` to remove all auto-generated files, so that you can
start a new analysis from scratch.
* Run `make tags` to create a `tags` file that many editors can use
to automatically navigate between the queries.
* Run `make sorted-dependencies` to create a file named `sorted-dependencies`
with the queries listed in the order determined by their dependencies.

## See also
* [RDBUnit: Unit testing for relational database queries](https://github.com/dspinellis/rdbunit)
* [Oracle: Materialized Views (ROLAP) and Cubes (MOLAP) comparison](http://gerardnico.com/wiki/database/oracle/pre_compute_operations)
* [MySQL Flexviews](https://github.com/greenlion/swanhart-tools) Incrementally refreshable materialized views
* [PostgreSQL Materialized views](https://wiki.postgresql.org/wiki/Materialized_Views)
