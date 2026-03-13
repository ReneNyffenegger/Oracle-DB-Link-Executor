@ ../_defines
set serveroutput on

begin
   &pfx.dblnk_pkg.close_db_links;
   
   &pfx.dblnk_pkg.exec_sel_on_db_links(
      sel_stmt               => q'[
         select
            ts.tablespace,
            ts.drive,
            count(*) cnt_files
         from (
            select
               tablespace_name         tablespace,
               substr(file_name, 1, 2) drive
            from
               dba_data_files@%DBLNK%
            union all
            select
               tablespace_name         tablespace,
               substr(file_name, 1, 2) drive
            from
               dba_temp_files@%DBLNK%
         ) ts
         group by
            ts.tablespace,
            ts.drive
      ]',
      res_table_name         => '&pfx.dblnk_tablespaces',
      alias_for_create_table => 'GE',
      where_                 => q'[ length(alias) = 2 or alias = 'VI451' ]'
   );
end;
/

-- select ts.* from &pfx.dblnk_tablespaces ts
