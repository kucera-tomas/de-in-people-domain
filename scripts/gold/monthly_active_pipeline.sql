USE dw_silver;

WITH RECURSIVE Calendar AS (
    SELECT DATE_FORMAT(MIN(applied_date), '%Y-%m-01') AS report_month
    FROM ats_applications

    UNION ALL

    SELECT DATE_ADD(report_month, INTERVAL 1 MONTH)
    FROM Calendar
    WHERE report_month < CAST(DATE_FORMAT(CURRENT_DATE, '%Y-%m-01') AS DATE)
)

SELECT 
    c.report_month, 
    COUNT(a.app_id) AS active_applications
FROM Calendar c
LEFT JOIN ats_applications a
    ON a.applied_date < DATE_ADD(c.report_month, INTERVAL 1 MONTH)
    AND (a.decision_date >= c.report_month OR a.decision_date IS NULL)
WHERE c.report_month <= CURRENT_DATE 
GROUP BY c.report_month
ORDER BY c.report_month;