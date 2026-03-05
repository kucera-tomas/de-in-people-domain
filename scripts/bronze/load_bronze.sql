/*
===============================================================================
Batch Script: Load Bronze Layer (Source -> Bronze)
===============================================================================
Script Purpose:
    This script loads data into the 'dw_bronze' database from external CSV files.
    It performs the following actions:
    - Creates a temporary log table to track progress and duration.
    - Truncates the bronze tables before loading data.
    - Uses 'LOAD DATA INFILE' to bulk insert data from CSV files.
    - Generates a final summary of rows loaded and execution time.

Parameters:
    None.
      This script uses User-Defined Variables (e.g., @batch_start) and 
      Temporary Tables valid only for the current session.

Usage Example:
    1. Open this script in MySQL Workbench or your SQL Client.
    2. Execute the entire script at once (Run All).
    3. View the final result grid for the execution log.

Notes:
    - Ensure 'local_infile' is enabled if loading from a client machine.
    - Update file paths in the 'LOAD DATA' commands to match your local directory.
===============================================================================
*/

USE dw_bronze;

-- 1. Setup: Create a temporary logging table (Resets every run)
DROP TEMPORARY TABLE IF EXISTS Job_Log;
CREATE TEMPORARY TABLE Job_Log (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    StepName VARCHAR(100),
    Status VARCHAR(50),
    Rows_Affected INT,
    Duration_Seconds DECIMAL(10,2),
    LogTime DATETIME
);

-- Initialize Global Timer
SET @batch_start = NOW();

-- =======================================================
-- Loading source: ATS (Applicant Tracking System)
-- =======================================================

-- 1. ats_raw_candidates
SET @t_start = NOW();
TRUNCATE TABLE ats_raw_candidates;
LOAD DATA INFILE 'C:/sql/source_ats/raw_candidates.csv'
INTO TABLE ats_raw_candidates 
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;
SET @t_end = NOW();
SELECT COUNT(*) INTO @rc FROM ats_raw_candidates;
INSERT INTO Job_Log (StepName, Status, Rows_Affected, Duration_Seconds, LogTime)
VALUES ('ats_raw_candidates', 'Success', @rc, TIMESTAMPDIFF(MICROSECOND, @t_start, @t_end)/1000000, NOW());

-- 2. ats_raw_interviews
SET @t_start = NOW();
TRUNCATE TABLE ats_raw_interviews;
LOAD DATA INFILE 'C:/sql/source_ats/raw_interviews.csv'
INTO TABLE ats_raw_interviews 
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;
SET @t_end = NOW();
SELECT COUNT(*) INTO @rc FROM ats_raw_interviews;
INSERT INTO Job_Log (StepName, Status, Rows_Affected, Duration_Seconds, LogTime)
VALUES ('ats_raw_interviews', 'Success', @rc, TIMESTAMPDIFF(MICROSECOND, @t_start, @t_end)/1000000, NOW());

-- 3. ats_raw_applications
SET @t_start = NOW();
TRUNCATE TABLE ats_raw_applications;
LOAD DATA INFILE 'C:/sql/source_ats/raw_applications.csv'
INTO TABLE ats_raw_applications 
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;
SET @t_end = NOW();
SELECT COUNT(*) INTO @rc FROM ats_raw_applications;
INSERT INTO Job_Log (StepName, Status, Rows_Affected, Duration_Seconds, LogTime)
VALUES ('ats_raw_applications', 'Success', @rc, TIMESTAMPDIFF(MICROSECOND, @t_start, @t_end)/1000000, NOW());


-- =======================================================
-- FINAL SUMMARY
-- =======================================================
SET @batch_end = NOW();
SET @total_duration = TIMESTAMPDIFF(MICROSECOND, @batch_start, @batch_end) / 1000000;

SELECT SUM(Rows_Affected) INTO @total_rows FROM Job_Log;

INSERT INTO Job_Log (StepName, Status, Rows_Affected, Duration_Seconds, LogTime)
VALUES ('=== TOTAL BATCH ===', 'COMPLETE', @total_rows, @total_duration, NOW());

-- Show output logs
SELECT StepName, Status, Rows_Affected, Duration_Seconds FROM Job_Log;