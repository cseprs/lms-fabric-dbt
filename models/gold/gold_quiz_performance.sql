{{ config(materialized='table') }}

SELECT
    q.id                                                        AS quiz_id,
    q.name                                                      AS quiz_name,
    q.course                                                    AS course_id,
    CAST(q.grade AS FLOAT)                                      AS max_grade,
    COUNT(DISTINCT a.userid)                                    AS total_attempts,
    ROUND(AVG(CAST(a.sumgrades AS FLOAT)), 2)                   AS avg_score,
    MAX(CAST(a.sumgrades AS FLOAT))                             AS highest_score,
    ROUND(
        100.0 * SUM(
            CASE 
                WHEN TRY_CAST(a.sumgrades AS FLOAT) >= TRY_CAST(q.grade AS FLOAT) * 0.5
                THEN 1 ELSE 0
            END
        ) / NULLIF(CAST(COUNT(*) AS FLOAT), 0),
        1
    )                                                           AS pass_rate_pct
FROM silver.[silver.quiz] q
LEFT JOIN silver.[silver.quiz_attempts] a
    ON q.id = a.quiz
GROUP BY
    q.id, q.name, q.course, q.grade