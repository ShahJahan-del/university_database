-- Top 10 of the most wanted courses (by amount of enrollments in each course)

SELECT c.course_id, c.title, d.name AS department, COUNT(e.enrollment_id) AS total_students
FROM courses c
JOIN departments d ON c.department_id = d.department_id
LEFT JOIN enrollments e ON c.course_id = e.course_id
GROUP BY c.course_id, c.title, d.name
ORDER BY total_students DESC
LIMIT 10;

-- Workload for teachers (total numbers of courses taught and students assigned)

SELECT t.teacher_id, t.first_name || ' ' || t.last_name AS teacher_name,
       COUNT(DISTINCT c.course_id) AS courses_taught,
       COUNT(e.enrollment_id) AS total_students_assigned
FROM teachers t
LEFT JOIN courses c ON t.teacher_id = c.teacher_id
LEFT JOIN enrollments e ON c.course_id = e.course_id
GROUP BY t.teacher_id, t.first_name, t.last_name
ORDER BY total_students_assigned DESC;

-- Average score in each department
-- 1/ convert the letters into points
-- 2/ sum the points for each department
-- 3/ convert back into letters
-- 4/ show the 'average letter' for each department

WITH GradePoints AS (
    -- Étape 1 : On associe chaque combinaison de lettres à sa valeur numérique standard
    SELECT 
        c.department_id,
        CASE e.grade
            WHEN 'AA' THEN 4.0  -- Excellent / Excellent
            WHEN 'AB' THEN 3.5  -- Très Bien / Very Good
            WHEN 'BB' THEN 3.0  -- Bien / Good
            WHEN 'BC' THEN 2.5  -- Assez Bien / Above Average
            WHEN 'CC' THEN 2.0  -- Passable / Average
            WHEN 'CD' THEN 1.5  -- Faible / Below Average
            WHEN 'DD' THEN 1.0  -- Insuffisant / Poor
            ELSE 0.0            -- Échec / Fail (FF ou autre)
        END AS points
    FROM enrollments e
    JOIN courses c ON e.course_id = c.course_id
),
DepartmentAverages AS (
    -- Étape 2 : Calcul de la moyenne numérique par département
    SELECT 
        department_id,
        AVG(points) AS average_points
    FROM GradePoints
    GROUP BY department_id
)
-- Étape 3 : Affichage du nom et reconversion dans le système AA, AB...
SELECT 
    d.name AS department_name,
    ROUND(da.average_points, 2) AS average_score_num,
    CASE 
        WHEN da.average_points >= 3.75 THEN 'AA'
        WHEN da.average_points >= 3.25 THEN 'AB'
        WHEN da.average_points >= 2.75 THEN 'BB'
        WHEN da.average_points >= 2.25 THEN 'BC'
        WHEN da.average_points >= 1.75 THEN 'CC'
        WHEN da.average_points >= 1.25 THEN 'CD'
        WHEN da.average_points >= 0.75 THEN 'DD'
        ELSE 'FF'
    END AS dept_average_letter
FROM DepartmentAverages da
JOIN departments d ON da.department_id = d.department_id
ORDER BY average_score_num DESC;


-- Number of students from each age category in every department

SELECT d.name AS department_name, s.age_category, COUNT(DISTINCT s.student_id) AS student_count
FROM enrollments e
JOIN students s ON e.student_id = s.student_id
JOIN courses c ON e.course_id = c.course_id
JOIN departments d ON c.department_id = d.department_id
GROUP BY d.name, s.age_category
ORDER BY department_name, student_count DESC;

-- Succes rate, total amount of credits potentially and actually given in every department (if the student got above average)

SELECT 
    d.name AS department_name,
    -- 1. Crédits potentiels (ancienne version pour comparer)
    SUM(c.credits) AS potential_credits,
    
    -- 2. Crédits réels validés (Seulement les notes >= CC)
    SUM(
        CASE 
            WHEN e.grade IN ('AA', 'AB', 'BB', 'BC', 'CC') THEN c.credits
            ELSE 0 
        END
    ) AS given_credits,

    -- 3. Bonus : Le taux de validation en % pour rendre la requête ultra-analytique
    ROUND(
        100.0 * SUM(CASE WHEN e.grade IN ('AA', 'AB', 'BB', 'BC', 'CC') THEN c.credits ELSE 0 END) 
        / SUM(c.credits), 2
    ) AS success_rate

FROM enrollments e
JOIN courses c ON e.course_id = c.course_id
JOIN departments d ON c.department_id = d.department_id
GROUP BY d.name
ORDER BY given_credits DESC;


-- Count the number of enrollments each month

SELECT DATE_TRUNC('month', enrollment_date) AS enrollment_month, COUNT(*) AS registrations
FROM enrollments
GROUP BY enrollment_month
ORDER BY enrollment_month;

-- Workload for students (number of courses, weekly study hours)

WITH StudentEnrollmentCount AS (
    -- 1. On compte le nombre de cours par étudiant
    SELECT student_id, COUNT(course_id) AS total_courses
    FROM enrollments
    GROUP BY student_id
),
WSHNumeric AS (
    -- 2. On calcule le score de tri numérique pour CHAQUE étudiant
    SELECT 
        student_id,
        wsh AS wsh_texte_original, -- On garde le texte pour l'affichage
        CASE wsh
            WHEN 'None'               THEN 0
            WHEN '<5 hours'           THEN 1
            WHEN '6-10 hours'         THEN 2
            WHEN '11-20 hours'        THEN 3
            WHEN 'more than 20 hours' THEN 4
            ELSE -1 -- Sécurité au cas où
        END AS wsh_score_tri
    FROM students
)
-- 3. Requête finale qui affiche le texte mais trie par le score
SELECT 
    s.student_id, 
    s.first_name || ' ' || s.last_name AS full_name, 
    wn.wsh_texte_original AS weekly_study_hours, -- Le texte s'affiche ici proprement !
    COALESCE(sec.total_courses, 0) AS number_of_courses
FROM students s
JOIN WSHNumeric wn ON s.student_id = wn.student_id
LEFT JOIN StudentEnrollmentCount sec ON s.student_id = sec.student_id
ORDER BY wn.wsh_score_tri DESC, number_of_courses DESC;


--Most popular teachers in each department (by the number of enrollments in their course)

WITH TeacherEnrollmentStats AS (
    SELECT 
        c.department_id, 
        c.teacher_id, 
        COUNT(e.enrollment_id) AS total_students,
        -- RANK() attribue la place n°1 au prof qui a le plus d'étudiants dans son département
        RANK() OVER(PARTITION BY c.department_id ORDER BY COUNT(e.enrollment_id) DESC) as teacher_rank
    FROM courses c
    JOIN enrollments e ON c.course_id = e.course_id
    GROUP BY c.department_id, c.teacher_id
)
SELECT 
    d.name AS department_name, 
    t.first_name || ' ' || t.last_name AS top_teacher, 
    tes.total_students AS total_enrollments
FROM TeacherEnrollmentStats tes
JOIN teachers t ON tes.teacher_id = t.teacher_id
JOIN departments d ON tes.department_id = d.department_id
WHERE tes.teacher_rank = 1
ORDER BY total_enrollments DESC;

-- Courses having less enrollments than the university average

SELECT 
    c.course_id, 
    c.title AS course_title, 
    d.name AS department,
    COUNT(e.enrollment_id) AS total_enrollments
FROM courses c
LEFT JOIN enrollments e ON c.course_id = e.course_id
JOIN departments d ON c.department_id = d.department_id
GROUP BY c.course_id, c.title, d.name
-- Le HAVING filtre en comparant le score du cours avec la moyenne théorique globale
HAVING COUNT(e.enrollment_id) < (
    SELECT COUNT(*)::float / COUNT(DISTINCT course_id) FROM enrollments
)
ORDER BY total_enrollments ASC;

-- Parité par département

SELECT 
    d.name AS department_name,
    SUM(CASE WHEN s.sex IN ('Male', 'M') THEN 1 ELSE 0 END) AS men,
    SUM(CASE WHEN s.sex IN ('Female', 'F') THEN 1 ELSE 0 END) AS women,
    -- Prise en compte des autres genres générés par Mockaroo
    SUM(CASE WHEN s.sex NOT IN ('Male', 'M', 'Female', 'F') THEN 1 ELSE 0 END) AS other,
    COUNT(e.enrollment_id) AS total_enrollments_department
FROM enrollments e
JOIN students s ON e.student_id = s.student_id
JOIN courses c ON e.course_id = c.course_id
JOIN departments d ON c.department_id = d.department_id
GROUP BY d.name
ORDER BY total_enrollments_department DESC;