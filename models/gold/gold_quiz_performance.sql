{{ config(materialized='table') }}

SELECT
    q.id                                                AS quiz_id,
    q.name                                              AS quiz_name,
    q.course                                            AS course_id,
    q.grade                                             AS max_grade,
    COUNT(DISTINCT a.userid)                            AS total_attempts,
    ROUND(AVG(CAST(a.sumgrades AS FLOAT)), 2)           AS avg_score,
    MAX(a.sumgrades)                                    AS highest_score,
    ROUND(
        100.0 * SUM(
            CASE 
                WHEN a.sumgrades >= q.grade * 0.5
                THEN 1 ELSE 0
            END
        ) / NULLIF(CAST(COUNT(*) AS FLOAT), 0),
        1
    )                                                   AS pass_rate_pct
FROM silver.[silver.quiz] q
LEFT JOIN silver.[silver.quiz_attempts] a
    ON q.id = a.quiz
GROUP BY
    q.id, q.name, q.course, q.grade