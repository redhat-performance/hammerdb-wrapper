##  Setting the Usercount to 50 if it's not specified as an argument

## Setting up variables for the run and Collecting system information ####
Usercount="50"
whc="500"
benchmark_name="Hammerdb-tpcc"
echo ${benchmark_name} > ${benchmark_run_dir}/user-benchmark-name.txt
hostnm=`hostname -f`
hostip=`hostname -i`
numcpu=`nproc`
totmem=`cat /proc/meminfo |grep "MemTotal:" | awk '{print $2}'`
krel=`uname -r`      ## Kernel

usage()
{
  echo "Usage:
        ./build_pg_tpcc.sh [-h] [-u users] [-w warehouse count] 

        Usage:
        -h help
        -u # of users (Default - 50)
        -w warehouse count (Default - 500)
        
       Examples:
        ./build_pg_tpcc.sh -u "10" -w 50
            Build 50 warehouse tpcc database with 10 users
  "
}

while [ $# -gt 0 ]
do
case $1 in
        -h) usage;
            exit;
            ;;
        -w) whc=$2
            shift 2
            ;;
        -u) Usercount=$2
            shift 2
            ;;
         *) usage;
            exit;
            ;;
esac
done


## Copy postgres config files to the postgres database area after setting the IP address of the host.
#echo "host    all             all             "${hostip}"/32          trust" >> pg_hba.conf
#sed -i "s/^listen_addresses =.*/listen_addresses = \'${hostip}\'/" postgresql.conf

# Change shared_buffer size based on available memory
totmem_MB=`expr $totmem / 1024`
totmem_BP=`expr $totmem_MB / 2`   # Buffer pool is half of physical memory

## IF total memory is more than 128G then bufferpool is set to 64G else set to half of physical memory
if [ ${totmem_BP} -lt 64000 ]
then
   sed -i "s/^shared_buffers =.*/shared_buffers = ${totmem_BP}MB/" postgresql.conf
else
   sed -i "s/^shared_buffers =.*/shared_buffers = 64000MB/" postgresql.conf
fi

## Stop the postgres server if it's running
systemctl stop postgresql


cp pg_hba.conf /var/lib/pgsql/data/pg_hba.conf
cp postgresql.conf /var/lib//pgsql/data/postgresql.conf


### Name the run and set the user counts ####
Testname="HDB_tpcc_pg"

## Start the database instance
systemctl start postgresql
sleep 30

echo "Building ${whc} warehouses with ${Usercount} users"
echo " ..."
sed -i "s/^diset connection pg_host.*/diset connection pg_host ${hostip}/" build_pg.tcl
sed -i "s/^diset tpcc pg_count_ware.*/diset tpcc pg_count_ware ${whc}/" build_pg.tcl
sed -i "s/^diset tpcc pg_num_vu.*/diset tpcc pg_num_vu ${Usercount}/" build_pg.tcl

## Drop the tpcc database if it already exists. This needs to be done otherwise the build and load fails ##

/usr/bin/psql -U postgres -d postgres  <<!
DROP DATABASE tpcc;
DROP ROLE tpcc;
!

./hammerdbcli auto build_pg.tcl >  build_pg_${whc}WH_${Usercount}.out 2>&1

systemctl stop postgresql

