dbhosts="10.128.2.5"

ctr=1
for hostnm in ${dbhosts}
do
   echo "DROP DATABASE tpcc;" > input
   echo "DROP ROLE tpcc;" >> input
   /usr/bin/psql -U postgres -d postgres -h ${hostnm} -f input
   cp build_pg.tcl build${ctr}_pg.tcl
   sed -i "s/^diset connection pg_host.*/diset connection pg_host ${hostnm}/" build${ctr}_pg.tcl
   nohup ./hammerdbcli auto build${ctr}_pg.tcl > build_pg_pod${ctr}_${uc}.out 2>&1 &
   ctr=$((ctr + 1))
done

