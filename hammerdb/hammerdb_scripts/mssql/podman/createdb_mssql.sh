
# Create database files
/opt/mssql-tools/bin/sqlcmd -U sa -P 100yard- <<! 
drop database tpcc
go
CREATE DATABASE tpcc
ON PRIMARY
(   NAME        = MSSQL_data_1,
    FILENAME    = '/var/opt/mssql/data/MSSQL_tpcc_Data_1.mdf',
    SIZE        = 32768MB,
    FILEGROWTH  = 20)
LOG ON
(   NAME        = MSSQL_tpcc_Log,
    FILENAME    = '/var/opt/mssql/data/tpcc_Log.ldf',
    SIZE        = 20480MB,
    FILEGROWTH  = 500MB,
    MAXSIZE     = 270000MB)
go

ALTER DATABASE tpcc ADD FILE
(    NAME = MSSQL_data_2, FILENAME = '/var/opt/mssql/data/MSSQL_tpcc_Data_2.mdf', SIZE = 32768)
GO

ALTER DATABASE tpcc ADD FILE
(    NAME = MSSQL_data_3, FILENAME = '/var/opt/mssql/data/MSSQL_tpcc_Data_3.mdf', SIZE = 32768)
GO

ALTER DATABASE tpcc ADD FILE
(    NAME = MSSQL_data_4, FILENAME = '/var/opt/mssql/data/MSSQL_tpcc_Data_4.mdf', SIZE = 32768)
GO

exit
!

