@ _defines.sql

begin
   &pfx.dblnk_pkg.close_db_links;
   &pfx.dblnk_pkg.drop_db_links;
end;
/

drop package &pfx.dblnk_pkg;
drop view    &pfx.dblnk_server_v;
drop table   &pfx.dblnk_server;
