# Execute queries on multiple databases using DB links

Execute SQL statements across multiple databases over DB links.

## Installation

Define a prefix for the created database objects in `_defines.sql` and run `_install.sql` in SQL*Plus/SQLcd or SQL Developer.

## Dependencies

- [Oracle SYS Views Plus](https://github.com/ReneNyffenegger/Oracle-SYS-views-plus):
  - [`tq84_ora_err`](https://github.com/ReneNyffenegger/Oracle-SYS-views-plus/blob/master/ora_err.sql) — referenced for error/status lookup in `tq84_dblnk_server`
  - [`tq84_hlp`](https://github.com/ReneNyffenegger/Oracle-SYS-views-plus/blob/master/hlp.sql) — helper used by `tq84_dblnk_pkg` for executing dynamic SQL
