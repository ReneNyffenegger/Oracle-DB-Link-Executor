@ ../_defines

set serveroutput on

begin
   &pfx.dblnk_pkg.close_db_links;
   
   &pfx.dblnk_pkg.exec_sel_on_db_links(
      sel_stmt               => q'[ select '%ALIAS%', name, value, isdefault from v$parameter@%DBLNK% ]',
      res_table_name         => '&pfx.dblnk_param',
      alias_for_create_table => 'GE',
      where_                 => q'[ length(alias) = 2 or alias = 'VI451' ]'
   );
end;
/

-- select * from &pfx.dblnk_param;
