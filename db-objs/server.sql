create table &pfx.dblnk_server (
   alias           varchar2( 8)  not null primary key check (alias = upper(alias) and not alias like '% %'),
   host            varchar2(26)  not null,
   sid             varchar2( 8)  not null,
   port            number  ( 5)  not null,
   conn_status                       null
       references &pfx.ora_err
       check (conn_status in (
              0,
           3150,
          12170,
          12514,
          12541,
          12545
       )),
   conn_status_dt  date
);
