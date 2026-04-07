while [ $# -gt 0 ]
do
case $1 in
        -m) mountpoint=$2
            shift 2
            ;;
esac
done

export mountpoint

# Create database files
/opt/mssql-tools/bin/sqlcmd -U sa -P 100yard- <<! 
drop database tpcc
go
CREATE DATABASE tpcc
ON PRIMARY
(   NAME        = MSSQL_data_1,
    FILENAME    = '${mountpoint}/mssql_data/data/MSSQL_tpcc_Data_1.mdf',
    SIZE        = 32768MB,
    FILEGROWTH  = 20)
LOG ON
(   NAME        = MSSQL_tpcc_Log,
    FILENAME    = '${mountpoint}/mssql_data/data/tpcc_Log.ldf',
    SIZE        = 20480MB,
    FILEGROWTH  = 500MB,
    MAXSIZE     = 270000MB)
go

ALTER DATABASE tpcc ADD FILE
(    NAME = MSSQL_data_2, FILENAME = '${mountpoint}/mssql_data/data/MSSQL_tpcc_Data_2.mdf', SIZE = 32768)
GO

exit
!

