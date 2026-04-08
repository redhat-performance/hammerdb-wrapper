usage()
{
  echo " HOST NAME or IP REQUIRED!! - see usage below
        Usage:
        ./multi_vm_driver.sh [-h] [-H Host names] 

        Usage:
        -h help
        -H <Host names sepearted by space>

       Examples:
        ./multi_vm_driver.sh -H "dhcp31-32 dhcp31-33" 
        ./multi_vm_driver.sh -H "10.16.31.32 10.16.31.33" 
  "
}
if [ $# -eq 0 ]
then
    usage;
    exit;
fi

while [ $# -gt 0 ]
do
case $1 in
        -h) usage;
            exit;
            ;;
        -H) dbhosts=$2
            shift 2
            ;;
         *) usage;
            exit;
            ;;
esac
done
ctr=1
export ctr
for hostnm in ${dbhosts}
do
   export hostnm
   ssh root@${hostnm} "systemctl restart postgresql"
   sleep 15
   ssh root@${hostnm} "echo 'DROP DATABASE tpcc;' > input"
   ssh root@${hostnm} "echo 'DROP ROLE tpcc;' >> input"
   ssh root@${hostnm} "/usr/bin/psql -U postgres -d postgres -h ${hostnm} -f input"
   ssh root@${hostnm} "cd /usr/local/HammerDB-3.3; cp build_pg.tcl build${ctr}_pg.tcl"
   ssh root@${hostnm} "cd /usr/local/HammerDB-3.3; sed -i 's/^diset connection pg_host.*/diset connection pg_host ${hostnm}/' build${ctr}_pg.tcl"
   ssh root@${hostnm} "cd /usr/local/HammerDB-3.3; nohup ./hammerdbcli auto build${ctr}_pg.tcl > build_pg${ctr}.out 2>&1 " &
   ctr=$((ctr + 1))
done
wait
echo "Build done"

