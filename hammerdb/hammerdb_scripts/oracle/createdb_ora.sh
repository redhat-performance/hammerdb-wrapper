export mnt=/perf1
export logmnt=/perf1

sqlplus '/ as sysdba' <<!
shutdown abort
startup pfile=p_run.ora nomount
create database tpccdb
  controlfile reuse
  maxdatafiles 120
  maxinstances 1
  datafile  '${mnt}/oracle/system_001' size 1600M reuse
  logfile ('${logmnt}/oracle/log_11.1') size 32768M reuse,
  ('${logmnt}/oracle/log_12.1') size 32768M reuse
  undo tablespace undo_sys_ts datafile
  '${mnt}/oracle/undo_sys_ts.dbf' size 16G reuse
sysaux datafile '${mnt}/oracle/aux.df' size 1000M reuse;
set echo off
!

sqlplus '/ as sysdba' <<!
alter user sys identified by oracle;
alter user system identified by oracle;
!

sqlplus '/ as sysdba' <<!
create bigfile tablespace tpcctab 
             datafile '${mnt}/oracle/usertpcctab1' size 64G reuse autoextend on next 16G;
create bigfile tablespace tpcctabol 
             datafile '${mnt}/oracle/tpcctabol1' size 64G reuse autoextend on next 16G;
create temporary tablespace temp tempfile '${mnt}/oracle/tempdb1' size 8G reuse;
!
./createddviews.sh

