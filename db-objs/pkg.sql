-- vi: foldmethod=marker foldmarker={,}

create or replace package &pfx.dblnk_pkg authid definer as -- {

    procedure create_db_links(connect_to varchar2, identified_by varchar2);
    procedure close_db_links;
    procedure drop_db_links;

    procedure check_connection;

    procedure exec_imm(stmt clob, db_alias varchar2);

    procedure exec_imm_on_db_links(stmt clob, where_ varchar2 := '1=1');
    procedure exec_sel_on_db_links(sel_stmt clob, res_table_name varchar2, alias_for_create_table varchar2, where_ varchar2 := '1=1');

end &pfx.dblnk_pkg; -- }
/

create or replace package body &pfx.dblnk_pkg as -- {

    procedure create_db_links(connect_to varchar2, identified_by varchar2) is -- {
    begin


        for tns in (select * from &pfx.dblnk_server_v order by length(alias), alias) loop -- {
            begin
               execute immediate 'create database link &pfx.dblnk_' || tns.alias || ' connect to ' ||  connect_to || ' identified by ' || identified_by || ' using ''' || tns.connection_string || '''';
            exception when others then
               dbms_output.put_line(tns.alias || ': ' || sqlerrm);
            end;
        end loop; -- }

    end create_db_links; -- }

    procedure close_db_links is -- {
    begin

       for lnk in (select db_link from v$dblink where db_link like upper('&pfx.dblnk_%')) loop
           begin
              dbms_session.close_database_link(lnk.db_link);
           exception when others then
              raise_application_error(-20800, sqlerrm || ' (' || lnk.db_link || ')');
           end;
       end loop;

    end close_db_links; -- }

    procedure drop_db_links is -- {
    begin

       for dbl in (select db_link from user_db_links where db_link like upper('&pfx.dblnk_%')) loop
           begin
              execute immediate 'drop database link ' || dbl.db_link;
           exception when others then
              dbms_output.put_line(dbl.db_link || ': ' || sqlerrm);
           end;
       end loop;

    end drop_db_links; -- }

    procedure check_connection is -- {
       status  varchar2(99);
       cnt     number;
    begin

       for dbl in (select alias from &pfx.dblnk_server where conn_status is null) loop -- {

           begin
              execute immediate 'select count(*) from dual@&pfx.dblnk_' || dbl.alias;
              status := 0;

           exception when others then
              status := -sqlcode;
           end;

           update &pfx.dblnk_server tns set
              tns.conn_status    = status,
              tns.conn_status_dt = sysdate
           where
              tns.alias = dbl.alias;

           commit;

           close_db_links;

       end loop; -- }

    end check_connection; --}

    procedure exec_imm(stmt clob, db_alias varchar2) is -- {
        stmt_ clob;
    begin
        stmt_ := replace(replace(stmt,
                       '%DBLNK%', '&pfx.dblnk_' || db_alias),
                       '%ALIAS%',                  db_alias);

        dbms_output.put_line(stmt_);

        &pfx.hlp.exec_imm(stmt_);

    end exec_imm; -- }

    procedure exec_imm_on_db_links(stmt clob, where_ varchar2 := '1=1') is -- {
        cur   sys_refcursor;
        alias varchar2(6);
    begin

     --
     -- use refcursor because in 19c, it's not possible to loop over a dynamic statement.
     --
        open cur for 'select alias from &pfx.dblnk_server where (' || where_ || ') and conn_status = 0';

        loop -- {
            fetch cur into alias;
            exit when cur%notfound;

            exec_imm(stmt, alias);
            commit;
            &pfx.dblnk_pkg.close_db_links;
        end loop; -- }

    end exec_imm_on_db_links; -- }

    procedure exec_sel_on_db_links(sel_stmt clob, res_table_name varchar2, alias_for_create_table varchar2, where_ varchar2 := '1=1') is -- {
    begin
    --
    -- Create the result table (but drop it first if it exists)
    --
        &pfx.hlp.exec_imm('drop table ' || res_table_name, ignore_errors => ku$_vcnt(942));

        exec_imm(
           stmt => replace(replace(q'[create table %RES_TABLE_NAME% as
select
   cast(null as varchar2(6)) as db_alias,
   x.*
from (
   %SEL_STMT%
) x
where
   1 = 0]',
      '%SEL_STMT%'      , sel_stmt      ),
      '%RES_TABLE_NAME%', res_table_name),
           db_alias => alias_for_create_table
        );

        close_db_links;

        exec_imm_on_db_links(
           stmt   => replace(replace(q'[insert into %RES_TABLE_NAME% select '%ALIAS%', x.* from ( %SEL_STMT%  ) x]',
               '%SEL_STMT%'      , sel_stmt      ),
               '%RES_TABLE_NAME%', res_table_name),
           where_ => where_
        );

   end exec_sel_on_db_links; -- }

end &pfx.dblnk_pkg; -- }
/
