@ ../_defines

begin

   delete from &pfx.dblnk_server;

   insert into &pfx.dblnk_server (alias, host, port, sid) values ('AB', '10.72.68.10', 1521, 'srvab');
   insert into &pfx.dblnk_server (alias, host, port, sid) values ('DE', '10.72.68.11', 1521, 'srvde');
   insert into &pfx.dblnk_server (alias, host, port, sid) values ('FG', '10.72.68.12', 1521, 'srvfg');
   insert into &pfx.dblnk_server (alias, host, port, sid) values ('HI', '10.72.68.13', 1521, 'srvhi');

   commit;

   &pfx.dblnk_pkg.create_db_links(connect_to => 'rene', identified_by => 'the-secret-password');
   &pfx.dblnk_pkg.check_connection;
end;
/
