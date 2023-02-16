-- ONE-OFF OPTIMIZATION COMMANDS FOR SQL SERVER INSTANCES
ALTER DATABASE [DBNAME]
SET auto_create_statistics ON
ALTER DATABASE SCOPED CONFIGURATION SET MAXDOP = 2
ALTER DATABASE [DBNAME] SET PARAMETERIZATION FORCED

--PERIODIC SCRIPTS TO BE RUN VIA SSMS SQL AGENT JOBS (minimum 12h difference between the jobs, daily jobs)
--early morning job for re-building indexes
https://gist.github.com/jeffjohnson9046/f95f06ec0914eeffce2f14fdfd46ca4f

--late night job for updating statistics
EXEC sp_updatestats;
