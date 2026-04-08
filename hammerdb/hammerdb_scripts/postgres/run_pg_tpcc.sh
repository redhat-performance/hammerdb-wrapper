#!/bin/sh
export PATH=$PATH:.:
## Set variables for the run
## Set variables for the run
storagetype="Storage not specified"
Usercount="10 20 40 80 100"
whc="500"
benchmark_results_dir=`pwd`"/results"
DBRESTARTUP="n"
Testname="HDB_tpcc_postgres"

usage()
{
  echo "Usage:
        run_pg_tpcc.sh [-h] [-u users] [-t runlength] [-w warehouse count] [-s storage type]

        Usage:
        -h help
        -u # of users (Default - "10 20 40 80 100")
        -t runlength in minutes (Default - 15 minutes)
        -w warehouse count (Default - 500 warehouses - MAKE SURE THIS MATCHES BUILD WAREHOUSE COUNT)
        -s storage type ( Default - "Storage no specified")
        -n name for the run (Default - "HDB_tpcc_postgres")

       Examples:
        ./run_pg_tpcc.sh -u "10 20 30"
            Do runs with 10, 20 and 30 users
        ./run_pg_tpcc.sh -s "nvme"
            Do a 10 user, 500 warehouse, 15 minute run with storage type as "nvme"
        ./run_pg_tpcc.sh -w 1000 -u "10 20 40 80 100" -s "iscsi"
            Do a 1000 warehouse run with 10 20 40 80 and 100 users and storage type specified as iscsi
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
        -s) storagetype=$2
            shift 2
            ;;
        -t) RUNLENGTH=$2
            shift 2
            ;;
        -n) Testname=$2
            shift 2
            ;;
         *) usage;
            exit;
            ;;
esac
done

mkdir -p results

if [ -z "${benchmark_results_dir}" ]
then
benchmark_results_dir=`pwd`"/results"
fi

if [ -z "${benchmark_run_dir}" ]
then
benchmark_run_dir=`pwd`"/results"
fi

echo ${storagetype}
echo ${benchmark_results_dir}

## Collecting system information

benchmark_name="Hammerdb-tpcc"
echo ${benchmark_name} > ${benchmark_run_dir}/user-benchmark-name.txt
hostnm=`hostname -f`
hostip=`hostname -i`
numcpu=`nproc`
totmem=`cat /proc/meminfo |grep "MemTotal:" | awk '{print $2}'`
krel=`uname -r`      ## Kernel


# Name the run and set the user counts

Testname="HDB_tpcc_pg"

# Set Host IP and Warehouse Count in the tcl file
sed -i "s/^diset connection pg_host.*/diset connection pg_host ${hostip}/" runtest_pg.tcl
sed -i "s/^diset tpcc pg_count_ware.*/diset tpcc pg_count_ware ${whc}/" runtest_pg.tcl

echo "StartTime,EndTime,Hostname,Kernel,Database,DBVer,Cpus,Memory,StorageType,Users,Tpm" > Run_mariadb_tpm.csv
pgver=`psql --version |awk '{print $3}'`

## Run the database workload with different user count

for uc in ${Usercount}
do
    echo " Restarting database before each user count run"
    systemctl restart postgresql
    sleep 30
    starttime=`date +%Y.%m.%d.%T`
    echo "Run with  ${uc} users"
    sed -i "s/^diset tpcc pg_count_ware.*/diset tpcc pg_count_ware ${whc}/" runtest_pg.tcl
    sed -i "s/^vuset.*/vuset vu ${uc}/" runtest_pg.tcl
    ./hammerdbcli auto runtest_pg.tcl > test_pg_${Testname}_${uc}.out 2>&1
    endtime=`date +%Y.%m.%d.%T`
    grep RESULT test_pg_${Testname}_${uc}.out
    tpm=`grep TPM test_pg_${Testname}_${uc}.out | awk '{print $7}'`
    echo "\"${starttime}\",\"${endtime}\",\"${hostnm}\",\"${krel}\",\"Postgres\",\"${pgver}\",\"${numcpu}\",\"${totmem}\",\"${storagetype}\",\"${uc}\",\"${tpm}\"" >> user-benchmark-result.csv
    cp user-benchmark-result.csv $benchmark_results_dir
    cp /etc/my.cnf $benchmark_results_dir
    cp test_pg_${Testname}_${uc}.out $benchmark_results_dir
done

systemctl stop postgresql

