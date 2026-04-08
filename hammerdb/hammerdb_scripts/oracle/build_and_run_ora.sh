
## Stop and start the mssql-server and drop and create the database
echo "Stopping Oracle Instance "
./shutdb

echo "Starting MS SQL Server"
./startdb

echo "Waiting 30 seconds for DB to start"
sleep 60

Testname="R8_192G_150WH_64P_HTon_wt0_awt0_3979_TP_xfs_noatime_0403"
Usercount="10 20 30 40 50"

# Define number of warehouses and user count for the build

uc=20
whc=150

echo "Building ${whc} warehouses with ${uc} users"
sed -i "s/^diset tpcc count_ware.*/diset tpcc count_ware ${whc}/" build.tcl
sed -i "s/^diset tpcc mssqls_num_vu.*/diset tpcc mssqls_num_vu ${uc}/" build.tcl

echo "Creating database"
./createdb_ora.sh > crdb_ora_${whc}WH_${uc}.out 2>&1

echo "building the tpcc schema"

./buildora.sh > build_ora_${whc}WH_${uc}.out 2>&1

## Run the database workload with different user count

for uc in ${Usercount}
do

    echo "Run with  ${uc} users"
    sed -i "s/^vuset.*/vuset vu ${uc}/" runtest.tcl
    ./run.sh > test_${Testname}_${uc}.out 2>&1
    grep RESULT test_${Testname}_${uc}.out
done

systemctl stop mssql-server
