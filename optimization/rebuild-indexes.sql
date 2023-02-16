----------------------------------------------------
----SCRIPT/SP FOR REBUILD INDEXES AND REORGANIZE
----------------------------------------------------
--Source
--https://gist.github.com/jeffjohnson9046/f95f06ec0914eeffce2f14fdfd46ca4f
----------------------------------------------------

DECLARE
	@fragPercentThreshold decimal(11,2),
	@schemaName nvarchar(128);

-- Determine maximum fragmentation threshold and the schema to operate against
SET @fragPercentThreshold = 5.0;
SET @schemaName = N'dbo';

-- For use in cursor:
DECLARE 
	@tableName nvarchar(500),
	@indexName nvarchar(500),
	@indexType nvarchar(55),
	@percentFragment decimal(11,2);
 
DECLARE FragmentedTableList CURSOR FOR 
	SELECT 
		OBJECT_NAME(ind.OBJECT_ID) AS TableName, 
		ind.name AS IndexName, 
		indexstats.index_type_desc AS IndexType, 
		indexstats.avg_fragmentation_in_percent 
	FROM 
		sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, NULL) indexstats 
	JOIN 
		sys.indexes ind 
		ON ind.object_id = indexstats.object_id 
        AND ind.index_id = indexstats.index_id 
	JOIN
		sys.tables t
		ON ind.object_id = t.object_id
	JOIN
		sys.schemas s
		ON t.schema_id = s.schema_id
	WHERE
		indexstats.avg_fragmentation_in_percent > @fragPercentThreshold
		AND ind.Name IS NOT NULL
		AND s.name = @schemaName
	ORDER BY 
		indexstats.avg_fragmentation_in_percent DESC;

OPEN FragmentedTableList;
FETCH NEXT FROM FragmentedTableList
INTO @tableName, @indexName, @indexType, @percentFragment;
 
WHILE @@FETCH_STATUS = 0 
BEGIN 
    print 'Processing [' + @indexName + '] on table ' + @tableName + ' which is ' + cast(@percentFragment as nvarchar(50)) + ' fragmented';
    IF (@percentFragment<= @fragPercentThreshold) 
    BEGIN 
        EXEC( 'ALTER INDEX [' +  @indexName + '] ON [' + @tableName + '] REBUILD; ') 
    print 'Finished reorganizing [' + @indexName + '] on table ' + @tableName;
    END 
    ELSE 
    BEGIN 
        EXEC( 'ALTER INDEX [' +  @indexName + '] ON [' + @tableName + '] REORGANIZE;') 
    print 'Finished rebuilding [' + @indexName + '] on table ' + @tableName;
    END  
    FETCH NEXT FROM FragmentedTableList  
    INTO @tableName, @indexName, @indexType, @percentFragment; 
END

CLOSE FragmentedTableList;
DEALLOCATE FragmentedTableList;
