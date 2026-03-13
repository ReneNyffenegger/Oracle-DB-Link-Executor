create or replace view &pfx.dblnk_server_v as
select
   dbs.alias,
   lower('&pfx.dblnk_' || dbs.alias)  dblnk,
   err.msg                            conn_status_,
   dbs.conn_status_dt,
   dbs.host,
   dbs.sid,
   dbs.port,
   count(*) over (partition by dbs.host) cnt_same_host,
   count(*) over (partition by dbs.sid ) cnt_same_sid,
   dbs.conn_status,
  '(description=' ||
   '(address=' ||
      '(protocol=tcp)(host=' || rpad(host, 15) || ')' ||
      '(port=' || to_char(port, 'fm99999') || '))' ||
   '(connect_data=' ||
      '(service_name=' || rpad(sid, 8) || ')))'  connection_string
from
   &pfx.dblnk_server   dbs                                     left join
   &pfx.ora_err        err on dbs.conn_status = err.num;
