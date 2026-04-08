

SELECT
    c.course_id,
    c.course_name,
    c.course_code,
    c.start_date,
    c.end_date,
    COUNT(DISTINCT e.user_id) AS total_enrolled,
    COUNT(DISTINCT cp.user_id) AS total_completed,
    ROUND(100.0 * COUNT(DISTINCT cp.user_id)
        / NULLIF(COUNT(DISTINCT e.user_id), 0), 1) AS completion_rate_pct
FROM silver.course c
LEFT JOIN silver.enrolments e
    ON c.course_id = e.course_id
LEFT JOIN silver.completions cp
    ON c.course_id = cp.course_id
    AND cp.is_complete = 1
GROUP BY
    c.course_id, c.course_name, c.course_code,
    c.start_date, c.end_date