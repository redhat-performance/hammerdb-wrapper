dbhosts="10.128.2.5"

Usercount="10 20 40 80 100"

for uc in ${Usercount}
do
    echo "Run with  ${uc} users"
    cd /usr/local/HammerDB-3.3
    ctr=1
    for hostnm in ${dbhosts}
      do
        cp runtest_pg.tcl runtest${ctr}_pg.tcl
        sed -i "s/^diset connection pg_host.*/diset connection pg_host ${hostnm}/" runtest${ctr}_pg.tcl
        sed -i "s/^vuset.*/vuset vu ${uc}/" runtest${ctr}_pg.tcl
        nohup ./hammerdbcli auto runtest${ctr}_pg.tcl > test_pg_pod${ctr}_${uc}.out 2>&1 &
        ctr=$((ctr + 1))
      done
    wait
done

