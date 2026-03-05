
/*
===============================================================================
DDL Script: Create Gold Data Mart
===============================================================================
Script Purpose:
    Creates 'dm_hiring_process' view. 
    Assumes Silver layer is strictly filtered.
===============================================================================
*/

USE dw_gold;

DROP VIEW IF EXISTS dm_hiring_process;

CREATE VIEW dm_hiring_process AS
SELECT 
    a.app_id,
    c.full_name AS candidate_name,
    c.source AS candidate_source,
        DATEDIFF(a.decision_date, a.applied_date) AS time_to_decision_days,
    CASE 
        WHEN a.decision_date IS NULL THEN 'In Progress'
        ELSE 'Decided'
    END AS application_status,    
    COUNT(i.interview_id) AS total_passed_interviews
FROM dw_silver.ats_applications a
LEFT JOIN dw_silver.ats_candidates c 
    ON a.candidate_id = c.candidate_id
LEFT JOIN dw_silver.ats_interviews i 
    ON a.app_id = i.app_id 
    AND i.outcome = 'Passed'
GROUP BY 
    a.app_id,
    c.full_name,
    c.source,
    a.decision_date,
    a.applied_date;