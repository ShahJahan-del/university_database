--Query 1 - Show the number of students per course

SELECT
    c.title,
    COUNT(e.student_id) AS total_students
FROM courses c
LEFT JOIN enrollments e ON c.course_id = e.course_id
GROUP BY c.title
ORDER BY total_students DESC;

--Query 2 - Do students who put in a lot of work actually get better grades ?

WITH student_gpa AS (
    SELECT
        student_id,
        AVG(CASE 
            WHEN grade = 'AA' THEN 4.0
            WHEN grade = 'BA' THEN 3.5
            WHEN grade = 'BB' THEN 3.0
            WHEN grade = 'CB' THEN 2.5
            WHEN grade = 'CC' THEN 2.0
            WHEN grade = 'DC' THEN 1.5
            WHEN grade = 'DD' THEN 1.0
            ELSE 0.0 -- Fail
        END) AS avg_score
    FROM enrollments
    GROUP BY student_id
)
SELECT 
    s.student_id,
    s.wsh AS weekly_study_hours,
    ROUND(sg.avg_score, 2) AS avg_score_gpa
FROM student_gpa sg
JOIN students s ON sg.student_id = s.student_id
WHERE sg.avg_score >= 3.0
ORDER BY sg.avg_score DESC;

--Query 3 - Does attending conferences result in better grades ?

SELECT 
    s.dca AS attends_conferences,
    COUNT(DISTINCT e.student_id) AS number_students,
    COUNT(CASE WHEN e.grade = 'Fail' THEN 1 END) AS number_fails,
    ROUND(100.0 * COUNT(CASE WHEN e.grade = 'Fail' THEN 1 END) / COUNT(e.student_id), 2) || '%' AS failure_rate
FROM students s
JOIN enrollments e ON s.student_id = e.student_id
GROUP BY s.dca;