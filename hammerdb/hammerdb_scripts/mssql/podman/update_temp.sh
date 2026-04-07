
/opt/mssql-tools/bin/sqlcmd -U sa -P 100yard- <<! 


ALTER DATABASE tempdb REMOVE FILE tempdev2;
GO

ALTER DATABASE tempdb ADD FILE
(    NAME = tempdev2, FILENAME = '/var/opt/mssql/data/tempdb02.mdf', SIZE = 256)
GO

ALTER DATABASE tempdb REMOVE FILE tempdev3;
GO

ALTER DATABASE tempdb ADD FILE
(    NAME = tempdev3, FILENAME = '/var/opt/mssql/data/tempdb03.mdf', SIZE = 256)
GO

ALTER DATABASE tempdb REMOVE FILE tempdev4;
GO

ALTER DATABASE tempdb ADD FILE
(    NAME = tempdev4, FILENAME = '/var/opt/mssql/data/tempdb04.mdf', SIZE = 256)
GO

ALTER DATABASE tempdb REMOVE FILE tempdev5;
GO

ALTER DATABASE tempdb ADD FILE
(    NAME = tempdev5, FILENAME = '/var/opt/mssql/data/tempdb05.mdf', SIZE = 256)
GO

ALTER DATABASE tempdb REMOVE FILE tempdev6;
GO

ALTER DATABASE tempdb ADD FILE
(    NAME = tempdev6, FILENAME = '/var/opt/mssql/data/tempdb06.mdf', SIZE = 256)
GO

ALTER DATABASE tempdb REMOVE FILE tempdev7;
GO

ALTER DATABASE tempdb ADD FILE
(    NAME = tempdev7, FILENAME = '/var/opt/mssql/data/tempdb07.mdf', SIZE = 256)
GO

ALTER DATABASE tempdb REMOVE FILE tempdev8;
GO

ALTER DATABASE tempdb ADD FILE
(    NAME = tempdev8, FILENAME = '/var/opt/mssql/data/tempdb08.mdf', SIZE = 256)
GO

ALTER DATABASE tempdb REMOVE FILE tempdev9;
GO

ALTER DATABASE tempdb ADD FILE
(    NAME = tempdev9, FILENAME = '/var/opt/mssql/data/tempdb09.mdf', SIZE = 256)
GO

ALTER DATABASE tempdb REMOVE FILE tempdev10;
GO

ALTER DATABASE tempdb ADD FILE
(    NAME = tempdev10, FILENAME = '/var/opt/mssql/data/tempdb10.mdf', SIZE = 256)
GO

ALTER DATABASE tempdb REMOVE FILE tempdev11;
GO

ALTER DATABASE tempdb ADD FILE
(    NAME = tempdev11, FILENAME = '/var/opt/mssql/data/tempdb11.mdf', SIZE = 256)
GO

ALTER DATABASE tempdb REMOVE FILE tempdev12;
GO

ALTER DATABASE tempdb ADD FILE
(    NAME = tempdev12, FILENAME = '/var/opt/mssql/data/tempdb12.mdf', SIZE = 256)
GO

ALTER DATABASE tempdb REMOVE FILE tempdev13;
GO

ALTER DATABASE tempdb ADD FILE
(    NAME = tempdev13, FILENAME = '/var/opt/mssql/data/tempdb13.mdf', SIZE = 256)
GO

ALTER DATABASE tempdb REMOVE FILE tempdev14;
GO

ALTER DATABASE tempdb ADD FILE
(    NAME = tempdev14, FILENAME = '/var/opt/mssql/data/tempdb14.mdf', SIZE = 256)
GO

ALTER DATABASE tempdb REMOVE FILE tempdev15;
GO

ALTER DATABASE tempdb ADD FILE
(    NAME = tempdev15, FILENAME = '/var/opt/mssql/data/tempdb15.mdf', SIZE = 256)
GO

ALTER DATABASE tempdb REMOVE FILE tempdev16;
GO

ALTER DATABASE tempdb ADD FILE
(    NAME = tempdev16, FILENAME = '/var/opt/mssql/data/tempdb16.mdf', SIZE = 256)
GO

ALTER DATABASE tempdb REMOVE FILE tempdev17;
GO

ALTER DATABASE tempdb ADD FILE
(    NAME = tempdev17, FILENAME = '/var/opt/mssql/data/tempdb17.mdf', SIZE = 256)
GO

ALTER DATABASE tempdb REMOVE FILE tempdev18;
GO

ALTER DATABASE tempdb ADD FILE
(    NAME = tempdev18, FILENAME = '/var/opt/mssql/data/tempdb18.mdf', SIZE = 256)
GO

ALTER DATABASE tempdb REMOVE FILE tempdev19;
GO

ALTER DATABASE tempdb ADD FILE
(    NAME = tempdev19, FILENAME = '/var/opt/mssql/data/tempdb19.mdf', SIZE = 256)
GO

ALTER DATABASE tempdb REMOVE FILE tempdev20;
GO

ALTER DATABASE tempdb ADD FILE
(    NAME = tempdev20, FILENAME = '/var/opt/mssql/data/tempdb20.mdf', SIZE = 256)
GO

ALTER DATABASE tempdb REMOVE FILE tempdev21;
GO

ALTER DATABASE tempdb ADD FILE
(    NAME = tempdev21, FILENAME = '/var/opt/mssql/data/tempdb21.mdf', SIZE = 256)
GO

ALTER DATABASE tempdb REMOVE FILE tempdev22;
GO

ALTER DATABASE tempdb ADD FILE
(    NAME = tempdev22, FILENAME = '/var/opt/mssql/data/tempdb22.mdf', SIZE = 256)
GO

ALTER DATABASE tempdb REMOVE FILE tempdev23;
GO

ALTER DATABASE tempdb ADD FILE
(    NAME = tempdev23, FILENAME = '/var/opt/mssql/data/tempdb23.mdf', SIZE = 256)
GO

ALTER DATABASE tempdb REMOVE FILE tempdev24;
GO

ALTER DATABASE tempdb ADD FILE
(    NAME = tempdev24, FILENAME = '/var/opt/mssql/data/tempdb24.mdf', SIZE = 256)
GO

exit
!
