{{ config(materialized='table') }}

WITH quiz_clean AS (
    SELECT
        id,
        name,
        course,
        TRY_CAST(grade AS FLOAT)        AS grade
    FROM silver.[silver.quiz]
),

attempts_clean AS (
    SELECT
        quiz,
        userid,
        TRY_CAST(sumgrades AS FLOAT)    AS sumgrades
    FROM silver.[silver.quiz_attempts]
)

SELECT
    q.id                                                        AS quiz_id,
    q.name                                                      AS quiz_name,
    q.course                                                    AS course_id,
    q.grade                                                     AS max_grade,
    COUNT(DISTINCT a.userid)                                    AS total_attempts,
    ROUND(AVG(a.sumgrades), 2)                                  AS avg_score,
    MAX(a.sumgrades)                                            AS highest_score,
    ROUND(
        100.0 * SUM(
            CASE 
                WHEN a.sumgrades >= q.grade * 0.5
                THEN 1 ELSE 0
            END
        ) / NULLIF(CAST(COUNT(*) AS FLOAT), 0),
        1
    )                                                           AS pass_rate_pct
FROM quiz_clean q
LEFT JOIN attempts_clean a
    ON q.id = a.quiz
GROUP BY
    q.id, q.name, q.course, q.grade