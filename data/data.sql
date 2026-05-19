-- ====================================================================
-- ÉTAPE 1 : Nettoyage absolu (On vide tout pour éviter les conflits)
-- ====================================================================
TRUNCATE TABLE enrollments, courses, teachers, departments, students CASCADE;

-- ====================================================================
-- ÉTAPE 2 : Remplissage des tables parentes (Données de base créées manuellement)
-- ====================================================================

-- 1. Les Départements
INSERT INTO departments (department_id, name) VALUES
(1, 'Computer Science'),
(2, 'Mathematics'),
(3, 'Physics');

-- 2. Les Enseignants
INSERT INTO teachers (teacher_id, first_name, last_name, email, department_id) VALUES
(1, 'Alan', 'Turing', 'a.turing@uni.com', 1),
(2, 'Grace', 'Hopper', 'g.hopper@uni.com', 1),
(3, 'Ada', 'Lovelace', 'a.lovelace@uni.com', 2),
(4, 'Albert', 'Einstein', 'a.einstein@uni.com', 3);

-- 3. Les 9 Cours (il y a 9 id dans le csv donc on crée 9 cours dans la table courses)
INSERT INTO courses (course_id, title, credits, department_id, teacher_id) VALUES
(1, 'Introduction to SQL', 4, 1, 1),
(2, 'Web Development', 3, 1, 2),
(3, 'Data Structures', 4, 1, 1),
(4, 'Linear Algebra', 3, 2, 3),
(5, 'Calculus I', 4, 2, 3),
(6, 'Discrete Mathematics', 3, 2, 3),
(7, 'Quantum Mechanics', 4, 3, 4),
(8, 'Classical Physics', 4, 3, 4),
(9, 'Relativity Theory', 3, 3, 4);


-- ====================================================================
-- ÉTAPE 3 : Extraction et décodage depuis ton CSV (Staging)
-- ====================================================================

-- 4. Insertion des Étudiants
INSERT INTO students (student_id, first_name, last_name, email, age_category, sex, wsh, dca)
SELECT DISTINCT 
    student_id,
    'Student_FN_' || REPLACE(student_id, 'STUDENT', '') AS first_name, 
    'Student_LN_' || REPLACE(student_id, 'STUDENT', '') AS last_name, 
    LOWER(student_id) || '@university.edu' AS email, 
    CASE 
        WHEN student_age = 1 THEN '18-21' 
        WHEN student_age = 2 THEN '22-25' 
        ELSE '26+' 
    END AS age_category,
    CASE 
        WHEN sex = 1 THEN 'Female' 
        ELSE 'Male' 
    END AS sex,
    CASE
        WHEN weekly_study_hours = 1 THEN 'None' 
        WHEN weekly_study_hours = 2 THEN '<5 hours'
        WHEN weekly_study_hours = 3 THEN '6-10 hours'
        WHEN weekly_study_hours = 4 THEN '11-20 hours' 
        ELSE 'more than 20 hours'
    END AS weekly_study_hours,
    CASE
        WHEN department_conference_attendance = 1 THEN 'Yes' 
        ELSE 'No'
    END AS department_conference_attendance
FROM staging_university_csv
WHERE student_id IS NOT NULL AND student_id != 'STUDENT ID';

-- 5. Insertion des Inscriptions
INSERT INTO enrollments (student_id, course_id, grade)
SELECT 
    student_id,
    course_id::INT, 
    CASE 
        WHEN grade = 0 THEN 'Fail'
        WHEN grade = 1 THEN 'DD'
        WHEN grade = 2 THEN 'DC'
        WHEN grade = 3 THEN 'CC'
        WHEN grade = 4 THEN 'CB'
        WHEN grade = 5 THEN 'BB'
        WHEN grade = 6 THEN 'BA'
        WHEN grade = 7 THEN 'AA'
    END AS grade
FROM staging_university_csv
WHERE student_id IS NOT NULL AND student_id != 'STUDENT ID';