## Collecting system information

hostnm=`hostname -f`
numcpu=`nproc`
totmem=`cat /proc/meminfo |grep "MemTotal:" | awk '{print $2}'`
krel=`uname -r`      ## Kernel

# Define number of warehouses and user count for the build
uc=40
whc=500

echo "Adding files to tempdb"
./update_temp.sh > update_temp_${whc}WH_${uc}.out 2>&1

echo "Building ${whc} warehouses with ${uc} users"
sed -i "s/^diset tpcc mssqls_count_ware.*/diset tpcc mssqls_count_ware ${whc}/" build_mssql.tcl
sed -i "s/^diset tpcc mssqls_num_vu.*/diset tpcc mssqls_num_vu ${uc}/" build_mssql.tcl

echo "Creating database"
./createdb_mssql.sh > crdb_${whc}WH_${uc}.out 2>&1

echo "building the tpcc schema"

./hammerdbcli auto build_mssql.tcl  > build_${whc}WH_${uc}.out 2>&1

