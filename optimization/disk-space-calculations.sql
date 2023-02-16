--Get space used by a single table (sessions)
sp_spaceused [TABLE NAME]

--Check SQL file size
SELECT DB_NAME() AS DbName,
name AS FileName,
size/128.0 AS CurrentSizeMB,
size/128.0 - CAST(FILEPROPERTY(name, 'SpaceUsed') AS INT)/128.0 AS FreeSpaceMB
FROM sys.database_files;

--Change SQL data or log file size, can use GUI SSMS as well to modify allocated (different from used/free) file size or maximum allowed file size
USE master;
GO
ALTER DATABASE [DBNAME] 
MODIFY FILE
   (NAME =[DBNAME]_log,
   SIZE = 532480MB);
GO
