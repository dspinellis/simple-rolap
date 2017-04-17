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
The scripts are written for MySQL, but they should be easy to
port to other relational database systems.

## See also
* [RDBUnit: Unit testing for relational database queries](https://github.com/dspinellis/rdbunit)
* [Oracle: Materialized Views (ROLAP) and Cubes (MOLAP) comparison](http://gerardnico.com/wiki/database/oracle/pre_compute_operations)
* [MySQL Flexviews](https://github.com/greenlion/swanhart-tools) Incrementally refreshable materialized views
* [PostgreSQL Materialized views](https://wiki.postgresql.org/wiki/Materialized_Views)
