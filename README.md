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

When using the *MySQL* or the *PostgreSQL* engine,
the table population timestamps are
automatically propagated from the database to the files that track
the table creation times in the `tables` folder.
This allows multiple users to work together with separate instances
of a `simple-rolap` repository, without requiring the recalculation
of expensive tables.
When the database's information schema is locked (e.g. due to the creation
of new indices) this part of the dependency generation step can block
until the (potentially long) operation finishes.
To avoid this, set the `SKIP_TIMESTAMPING` environment variable,
for example by running `make SKIP_TIMESTAMPING=1`.

The provided functionality is mainly useful in cases where *materialized views*
are unsupported or unusable.
The scripts are written for *MySQL*, *PostgreSQL*, and *SQLite*,
but they should be easy to port to other relational database systems.

For complex relational OLAP queries, *simple-rolap* can be combined particularly
effectively with [RDBUnit](https://github.com/dspinellis/rdbunit).
You can find a complete tutorial on using *simple-rolap* with *RDBUnit*
for mining Git repositories in a
[technical briefing](https://www.spinellis.gr/git-mine-briefing/)
presented at the 2017 International Conference on Software Engineering.
You can cite this work as follows.

Georgios Gousios and Diomidis Spinellis. Mining software engineering data from GitHub. In *Proceedings of the 39th International Conference on Software Engineering Companion, ICSE-C '17*, pages 501–502, Piscataway, NJ, USA, May 2017. IEEE Press. Technical Briefing. [doi:10.1109/ICSE-C.2017.164](https://dx.doi.org/10.1109%2FICSE-C.2017.164)

## Global installation
The *simple-rolap* scripts are used by including the provided `Makefile`.
Consequently, all that is needed is to provide the repository in suitably
accessible location.
Here is an example.
```sh
cd /usr/local/lib
sudo git clone --depth=1 https://github.com/dspinellis/simple-rolap.git
```

Alternatively, you can perform a local install by adding two lines in
the project's `Makefile`. (See below.)

The system where *simple-rolap* is run must have and installation of the
database being used, *GNU make*, *GNU sed*,
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

To work with a local install of *simple-rolap* change the `Makefile`'s
last line into the following.
```Makefile
include simple-rolap/Makefile

simple-rolap/Makefile:
        git clone https://github.com/dspinellis/simple-rolap
```

If some actions need to be performed before running the queries,
you can specify them in a variable named `DEPENDENCIES` and then
add corresponding rules.
Example:
```Makefile
export DEPENDENCIES=rxjs-ghtorrent.db

include simple-rolap/Makefile

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
select projects.id, concat('https://github.com/', substr(url, 30)) as url
from stratsel.popular_projects
left join projects
on projects.id = popular_projects.id;
```

When *make* is run on such a module, the results of the query will
appear in the directory `reports` in a file named after the module's name
with the suffix `.sql` replaced by `.txt`.

To authenticate yourself with the main database, setup suitable
environment variables (e.g. `PGPASSWORD`) or files (e.g. `.my.cnf`
or `.pgpass`).

By default *simple-rolap* will run all SQL queries.
If some additional actions need to be performed in addition
to running the queries, you can specify them in a variable
named `ALL` and then add corresponding rules.
Example:
```Makefile
export ALL=popular.svg

include simple-rolap/Makefile

popular.svg: reports/popular.dot
	dot -Tsvg $? >$@
```


## Goodies
Here are some more things that the provided `Makefile` allows you to do.

* Run `make help` to obtain a list of available targets.
* Run `make graph.png` or `make graph.pdf` to generate a diagram of the
ROLAP queries' dependencies.
  Use `full-graph` rather than `graph` to include the main database tables.
* Run `make test` to run any [RDBUnit](https://github.com/dspinellis/rdbunit)
unit tests you may have written. Pass `UNIT=`*unit-name* to execute
only the specified unit test.
* Run `make clean` to remove all auto-generated files, so that you can
start a new analysis from scratch.
* Run `make sync-timestamps` to update the timestamps of unmodified files
to match those of the committed files.  In collaborative development settings
this will avoid rerunning queries that have already been executed by others.
* Run `make tags` to create a `tags` file that many editors can use
to automatically navigate between the queries.
* Run `make sorted-dependencies` to create a file named `sorted-dependencies`
with the queries listed in the order determined by their dependencies.
* Run `make V=1` to see the commands executed within the Makefile.
* Run `make V=1 TIME=time` to see timing information of executions.
* Run `make V=2` to also see the commands executed within the shell scripts.
* Put SQL statements that you want to precede each query (e.g. *MySQL*
  optimizer tuning `SET` commands), in the file `.config.sql`.

## See also
* [RDBUnit: Unit testing for relational database queries](https://github.com/dspinellis/rdbunit)
* [Oracle: Materialized Views (ROLAP) and Cubes (MOLAP) comparison](http://gerardnico.com/wiki/database/oracle/pre_compute_operations)
* [MySQL Flexviews](https://github.com/greenlion/swanhart-tools) Incrementally refreshable materialized views
* [PostgreSQL Materialized views](https://wiki.postgresql.org/wiki/Materialized_Views)
* [Boa Views: Easy Modularization and Sharing of MSR Analyses](https://www.cs.bgsu.edu/rdyer/papers/msr20.pdf)
