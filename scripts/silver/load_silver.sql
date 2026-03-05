/*
===============================================================================
DML Script: Load Strict Silver Tables (Bronze -> Silver)
===============================================================================
Script Purpose:
    Extracts data from 'dw_bronze', applies safe data type conversions, 
    removes duplicates, and critically: FILTERS OUT all dirty data 
    (orphans, bad logic, future dates, missing mandatory fields).
===============================================================================
*/

USE dw_silver;

-- =======================================================
-- 1. Load Candidates (Strict Mode)
-- =======================================================
TRUNCATE TABLE ats_candidates;

INSERT INTO ats_candidates (candidate_id, full_name, source, profile_created_date)
WITH DedupCandidates AS (
     SELECT 
         candidate_id, full_name, source, profile_created_date,
         ROW_NUMBER() OVER (
             PARTITION BY candidate_id
             ORDER BY CAST(profile_created_date AS DATE) DESC 
         ) as row_num
     FROM dw_bronze.ats_raw_candidates
     WHERE candidate_id IS NOT NULL AND TRIM(candidate_id) <> '' 
),
CleansedCandidates AS (
     SELECT 
         CAST(TRIM(candidate_id) AS CHAR(8)) AS candidate_id,
         CAST(TRIM(full_name) AS CHAR(100)) AS full_name,
         CAST(TRIM(source) AS CHAR(50)) AS source,
         CAST(profile_created_date AS DATE) AS profile_created_date
     FROM DedupCandidates
     WHERE row_num = 1
)
SELECT candidate_id, full_name, source, profile_created_date
FROM CleansedCandidates
WHERE 
    -- Drops candidates with any of the following issues:
    full_name IS NOT NULL AND TRIM(full_name) <> ''
    AND source IN ('LinkedIn', 'Referral', 'Career Page')
    AND profile_created_date IS NOT NULL
    AND profile_created_date <= CURRENT_DATE;


-- =======================================================
-- 2. Load Applications (Strict Mode)
-- =======================================================
TRUNCATE TABLE ats_applications;

INSERT INTO ats_applications (app_id, candidate_id, role_level, applied_date, decision_date, expected_salary)
WITH DedupApplications AS (
    SELECT 
        app_id, candidate_id, role_level, applied_date, decision_date, expected_salary,
        ROW_NUMBER() OVER (
            PARTITION BY app_id 
            ORDER BY 
                CASE WHEN CAST(decision_date AS DATE) IS NOT NULL THEN 1 ELSE 0 END DESC,
                CAST(applied_date AS DATE) DESC
        ) as row_num
    FROM dw_bronze.ats_raw_applications
    WHERE app_id IS NOT NULL AND TRIM(app_id) <> ''
),
CleansedApplications AS (
    SELECT 
        CAST(TRIM(app_id) AS CHAR(8)) AS app_id,
        CAST(TRIM(candidate_id) AS CHAR(8)) AS candidate_id,
        CAST(TRIM(role_level) AS CHAR(50)) AS role_level,
        CAST(applied_date AS DATE) AS applied_date,
        CAST(decision_date AS DATE) AS decision_date,
        CAST(
            REPLACE(REPLACE(expected_salary, '$', ''), ',', '') 
            AS SIGNED
        ) AS expected_salary
    FROM DedupApplications
    WHERE row_num = 1
)
SELECT app_id, candidate_id, role_level, applied_date, decision_date, expected_salary
FROM CleansedApplications
WHERE
    -- Drops applications with any of the following issues:
    role_level IN ('Junior', 'Senior', 'Executive')
    AND applied_date IS NOT NULL
    AND applied_date <= CURRENT_DATE
    AND (decision_date IS NULL OR decision_date >= applied_date)
    AND expected_salary IS NOT NULL
    AND expected_salary >= 0
    AND candidate_id IN (SELECT candidate_id FROM ats_candidates);


-- =======================================================
-- 3. Load Interviews (Strict Mode)
-- =======================================================
TRUNCATE TABLE ats_interviews;

INSERT INTO ats_interviews (interview_id, app_id, interview_date, outcome)
WITH DedupInterviews AS (
    SELECT 
        interview_id, app_id, interview_date, outcome,
        ROW_NUMBER() OVER (
            PARTITION BY app_id, interview_date 
            ORDER BY 
                CASE WHEN outcome IS NOT NULL THEN 1 ELSE 0 END DESC, 
                interview_id DESC 
        ) as row_num
    FROM dw_bronze.ats_raw_interviews
    WHERE app_id IS NOT NULL AND TRIM(app_id) <> ''
),
CleansedInterviews AS (
    SELECT 
        CAST(TRIM(interview_id) AS CHAR(8)) AS interview_id,
        CAST(TRIM(app_id) AS CHAR(8)) AS app_id,
        CAST(interview_date AS DATE) AS interview_date,
        CAST(TRIM(outcome) AS CHAR(50)) AS outcome
    FROM DedupInterviews
    WHERE row_num = 1
)
SELECT interview_id, app_id, interview_date, outcome
FROM CleansedInterviews
WHERE 
    outcome IN ('Passed', 'Rejected', 'No Show')
    AND interview_date IS NOT NULL
    AND interview_date <= CURRENT_DATE
    AND app_id IN (SELECT app_id FROM ats_applications);