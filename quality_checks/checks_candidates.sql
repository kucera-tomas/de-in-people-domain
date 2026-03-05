-- 1: Duplicate candidate_id
SELECT candidate_id, COUNT(*) 
FROM ats_candidates 
GROUP BY candidate_id 
HAVING COUNT(*) > 1;

-- 2: Missing name or name with trailing whitespace
SELECT candidate_id, full_name 
FROM ats_candidates 
WHERE full_name IS NULL OR TRIM(full_name) != full_name;

-- 3: Invalid or Typo-ridden Source
SELECT candidate_id, source 
FROM ats_candidates 
WHERE source NOT IN ('LinkedIn', 'Referral', 'Career Page') 
   OR source IS NULL;

-- 4: Profile Created in the Future
SELECT candidate_id, profile_created_date 
FROM ats_candidates 
WHERE profile_created_date > CURRENT_DATE;

-- 5: Invalid / Missing Dates
SELECT candidate_id, profile_created_date 
FROM ats_candidates 
WHERE profile_created_date IS NULL;