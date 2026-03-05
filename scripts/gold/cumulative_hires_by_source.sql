SELECT 
    c.full_name,
    c.source,
    a.decision_date,
    COUNT(a.app_id) OVER (
        PARTITION BY c.source
        ORDER BY a.decision_date
    ) AS cumulative_hires
FROM ats_candidates c
INNER JOIN ats_applications a 
    ON c.candidate_id = a.candidate_id
INNER JOIN (
    SELECT DISTINCT app_id 
    FROM ats_interviews 
    WHERE outcome = 'Passed'
) i 
    ON a.app_id = i.app_id
WHERE a.decision_date IS NOT NULL;