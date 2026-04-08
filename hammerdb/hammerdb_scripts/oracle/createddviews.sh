# Call some DATABASE admin SQL

sqlplus '/ as sysdba' << !

spool createddviews.log


REM
REM In an ade/nde view we might need to run standard.sql and dbmsstdx manually
REM catalog and catproc suppose to take care of it
REM

@$ORACLE_HOME/rdbms/admin/standard
@$ORACLE_HOME/rdbms/admin/dbmsstdx

rem dbms_registry
rem @$ORACLE_HOME/rdbms/admin/catr
@$ORACLE_HOME/rdbms/admin/catalog
@$ORACLE_HOME/rdbms/admin/catproc

REM
REM In an ade/nde view we might need to run pupbld manually 
REM catalog and catproc suppose to take care of it
REM

connect system/manager
@$ORACLE_HOME/sqlplus/admin/pupbld

REM
REM Oracle 
REM

REM to create Real Application Cluster-related views and tables
REM @$ORACLE_HOME/rdbms/admin/catclust

spool off
!

