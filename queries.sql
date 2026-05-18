-- Query 1 - Shows all the students
SELECT * FROM students;

--Query 2 - Student born after January 1 2002 

SELECT *
FROM students
WHERE birth_date > '2002-01-01';

--Query 3 - Students listed in alphabetical order (by last name)

SELECT *
FROM students
ORDER BY last_name ASC;

--Query 4 - Limits the students' number to 2, starting on the first id

SELECT *
FROM students
LIMIT 2;

--Query 5 - Lists all the unique student names

SELECT DISTINCT s.first_name
FROM students s

--Query 6 - 2 queries (getting student grades and getting student courses)

SELECT 
    s.first_name ||' '|| s.last_name student_full_name,
    e.grade
FROM students s
JOIN enrollments e
ON s.student_id = e.student_id;

SELECT
    s.first_name,
    s.last_name,
    c.title
FROM enrollments e
JOIN students s
ON e.student_id = s.student_id
JOIN courses c
ON e.course_id = c.course_id;

--Query 7 - Lists teachers and their department

SELECT
    t.first_name,
    t.last_name,
    d.name AS department
FROM teachers t
JOIN departments d
ON t.department_id = d.department_id;

--Query 8 - Number of students in each course

SELECT
    c.title,
    COUNT(e.student_id) AS total_students
FROM courses c
LEFT JOIN enrollments e
ON c.course_id = e.course_id
GROUP BY c.title;

--Query 9 - Courses having an average score above 15 (out of 20 in the French system)

SELECT
    c.title,
    AVG(e.grade) AS average_grade
FROM courses c
JOIN enrollments e
ON c.course_id = e.course_id
GROUP BY c.title
HAVING AVG(e.grade) > 15;

--Query 10 - Stdents having an average score above 15

WITH student_averages AS (
    SELECT
        student_id,
        AVG(grade) AS avg_grade
    FROM enrollments
    GROUP BY student_id
)
SELECT
    s.first_name,
    s.last_name,
    sa.avg_grade
FROM student_averages sa
JOIN students s
ON sa.student_id = s.student_id
WHERE sa.avg_grade > 15;