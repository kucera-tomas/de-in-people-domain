-- 1: Duplicate app_id
SELECT app_id, COUNT(*) 
FROM ats_applications 
GROUP BY app_id 
HAVING COUNT(*) > 1;

-- 2: Orphaned candidate_id
SELECT a.app_id, a.candidate_id 
FROM ats_applications a
LEFT JOIN ats_candidates c ON a.candidate_id = c.candidate_id
WHERE c.candidate_id IS NULL;

-- 3: Invalid Role Level
SELECT app_id, role_level 
FROM ats_applications 
WHERE role_level NOT IN ('Junior', 'Senior', 'Executive') 
   OR role_level IS NULL;

-- 4: Decision Date before Applied Date
SELECT app_id, applied_date, decision_date 
FROM ats_applications 
WHERE decision_date < applied_date;

-- 5: Applied Date in the Future
SELECT app_id, applied_date 
FROM ats_applications 
WHERE applied_date > CURRENT_DATE;

-- 6: Missing or applied Date
SELECT app_id, applied_date 
FROM ats_applications 
WHERE applied_date IS NULL;

-- 7: Negative or missing salary
SELECT app_id, expected_salary 
FROM ats_applications 
WHERE expected_salary < 0 
   OR expected_salary IS NULL;