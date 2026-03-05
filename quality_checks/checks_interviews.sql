-- 1: Orphaned app_id
SELECT i.interview_id, i.app_id 
FROM ats_interviews i
LEFT JOIN ats_applications a ON i.app_id = a.app_id
WHERE a.app_id IS NULL;

-- 2: Invalid outcome
SELECT interview_id, outcome 
FROM ats_interviews 
WHERE outcome NOT IN ('Passed', 'Rejected', 'No Show') 
   OR outcome IS NULL;

-- 3: Interview Date in the Future
SELECT interview_id, interview_date 
FROM ats_interviews 
WHERE interview_date > CURRENT_DATE;

-- 4: Missing Date
SELECT interview_id, interview_date, outcome 
FROM ats_interviews 
WHERE interview_date IS NULL;