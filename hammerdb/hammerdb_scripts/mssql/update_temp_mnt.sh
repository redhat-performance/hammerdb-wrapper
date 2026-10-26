#!/bin/bash

#
# If a command fails, exit the script with that error code.
#
set -e

while [ $# -gt 0 ]
do
case $1 in
        -m) mountpoint=$2
            shift 2
            ;;
esac
done

export mountpoint

numcpu=`nproc`

if [ ${numcpu} -le 8 ]
then
numcpu=8
fi
ctr=1
echo " " > input
while [ ${ctr} -le ${numcpu} ]
do
     echo "ALTER DATABASE tempdb REMOVE FILE tempdev${ctr};" >> input
     echo "GO" >> input
     echo " " >> input
     echo "ALTER DATABASE tempdb ADD FILE" >> input
     echo "(    NAME = tempdev${ctr}, FILENAME = '${mountpoint}/mssql_data/data/tempdb${ctr}.mdf', SIZE = 8)" >> input
     echo "GO" >> input
     echo " " >> input
     ctr=$(( ${ctr} + 1 ))
done
/opt/mssql-tools/bin/sqlcmd -U sa -P A2!bcdefgh < input
