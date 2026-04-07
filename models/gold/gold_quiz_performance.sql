{{ config(materialized='table') }}

SELECT
    q.quiz_id,
    q.quiz_name,
    q.course_id,
    q.max_grade,
    COUNT(DISTINCT a.user_id) AS total_attempts,
    ROUND(AVG(a.sumgrades), 2) AS avg_score,
    MAX(a.sumgrades) AS highest_score,
    ROUND(
        100.0 * SUM(
            CASE WHEN a.sumgrades >= q.max_grade * 0.5
                 THEN 1 ELSE 0 END
        ) / NULLIF(COUNT(*),0), 1
    ) AS pass_rate_pct
FROM silver.quiz q
LEFT JOIN silver.quiz_attempts a
    ON q.quiz_id = a.quiz
GROUP BY
    q.quiz_id, q.quiz_name, q.course_id, q.max_grade