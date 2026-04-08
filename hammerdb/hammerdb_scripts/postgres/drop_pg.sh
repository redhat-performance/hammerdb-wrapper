LD_LIBRARY_PATH=/lib64/mysql:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH

/usr/bin/psql -U postgres -d postgres  <<!
DROP DATABASE tpcc;
DROP ROLE tpcc;
!
