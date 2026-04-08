{{ config(materialized='table') }}

{% set silver_schema = 'silver' %}

SELECT
    q.quiz_id,
    q.quiz_name,
    q.course_id,
    q.max_grade,
    COUNT(DISTINCT a.user_id)                           AS total_attempts,
    ROUND(AVG(CAST(a.sumgrades AS FLOAT)), 2)           AS avg_score,
    MAX(a.sumgrades)                                    AS highest_score,
    ROUND(
        100.0 * SUM(
            CASE 
                WHEN a.sumgrades >= q.max_grade * 0.5
                THEN 1 
                ELSE 0 
            END
        ) / NULLIF(CAST(COUNT(*) AS FLOAT), 0),
        1
    )                                                   AS pass_rate_pct
FROM {{ silver_schema }}.quiz q
LEFT JOIN {{ silver_schema }}.quiz_attempts a
    ON q.quiz_id = a.quiz
GROUP BY
    q.quiz_id, q.quiz_name, q.course_id, q.max_grade