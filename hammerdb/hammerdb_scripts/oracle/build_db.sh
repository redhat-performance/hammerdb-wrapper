/opt/mssql-tools/bin/sqlcmd -U sa -P 100yard- <<EOT 

drop database tpcc
go

CREATE DATABASE tpcc	
ON PRIMARY
(   NAME        = MSSQL_data_1,
    FILENAME    = '/perf1/mssql_data/data/MSSQL_tpcc_Data_1.mdf',
    SIZE        = 87333MB,
    FILEGROWTH  = 20)
LOG ON
(   NAME        = MSSQL_tpcc_Log,
    FILENAME    = '/perf1/mssql_data/data/tpcc_Log.ldf',
    SIZE        = 20480MB,
    FILEGROWTH  = 500MB,
    MAXSIZE     = 270000MB)
go
EOT
