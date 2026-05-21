---------- 1. NETTOYAGE DES TABLES RÉELLES (Respect de l'ordre des clés étrangères) ----------
TRUNCATE TABLE enrollments, courses, teachers, departments, students RESTART IDENTITY CASCADE;


---------- 2. TRANSFERT DES DÉPARTEMENTS ----------

INSERT INTO departments (department_id, name)
SELECT DISTINCT department_id, name
FROM staging_departments
ORDER BY department_id;


---------- 3. TRANSFERT DES ENSEIGNANTS ----------

INSERT INTO teachers (teacher_id, first_name, last_name, email, department_id)
SELECT DISTINCT teacher_id, first_name, last_name, email, department_id
FROM staging_teachers
ORDER BY teacher_id;


---------- 4. TRANSFERT DES ÉTUDIANTS (100% INT pour les IDs) ----------

INSERT INTO students (student_id, first_name, last_name, email, age_category, sex, wsh, dca)
SELECT DISTINCT student_id, first_name, last_name, email, age_category, sex, wsh, dca
FROM staging_students
ORDER BY student_id;


---------- 5. TRANSFERT DES COURS AVEC REMISE EN COHÉRENCE STRICTE ----------

-- On vide la table au cas où pour éviter les doublons avant de réinsérer
TRUNCATE TABLE enrollments, courses CASCADE;

INSERT INTO courses (course_id, title, credits, department_id, teacher_id)
SELECT 
    sc.course_id,
    sc.title,
    sc.credits,
    -- Étape 1 : On force le vrai ID du département selon le numéro du cours (Blocs de 10)
    CASE 
        WHEN sc.course_id BETWEEN 1 AND 10   THEN 1  -- Literature
        WHEN sc.course_id BETWEEN 11 AND 20  THEN 2  -- Economics
        WHEN sc.course_id BETWEEN 21 AND 30  THEN 3  -- Music
        WHEN sc.course_id BETWEEN 31 AND 40  THEN 4  -- Computer Science
        WHEN sc.course_id BETWEEN 41 AND 50  THEN 5  -- Chemistry
        WHEN sc.course_id BETWEEN 51 AND 60  THEN 6  -- History
        WHEN sc.course_id BETWEEN 61 AND 70  THEN 7  -- Engineering
        WHEN sc.course_id BETWEEN 71 AND 80  THEN 8  -- Physics
        WHEN sc.course_id BETWEEN 81 AND 90  THEN 9  -- Biology
        WHEN sc.course_id BETWEEN 91 AND 100 THEN 10 -- Dance
    END as department_id,
    -- Étape 2 : On va chercher un prof qui appartient VRAIMENT à ce département forcé
    (
        SELECT t.teacher_id 
        FROM teachers t 
        WHERE t.department_id = CASE 
            WHEN sc.course_id BETWEEN 1 AND 10   THEN 1
            WHEN sc.course_id BETWEEN 11 AND 20  THEN 2
            WHEN sc.course_id BETWEEN 21 AND 30  THEN 3
            WHEN sc.course_id BETWEEN 31 AND 40  THEN 4
            WHEN sc.course_id BETWEEN 41 AND 50  THEN 5
            WHEN sc.course_id BETWEEN 51 AND 60  THEN 6
            WHEN sc.course_id BETWEEN 61 AND 70  THEN 7
            WHEN sc.course_id BETWEEN 71 AND 80  THEN 8
            WHEN sc.course_id BETWEEN 81 AND 90  THEN 9
            WHEN sc.course_id BETWEEN 91 AND 100 THEN 10
        END
        ORDER BY random() -- Répartition aléatoire parmi les profs qualifiés
        LIMIT 1
    ) AS teacher_id
FROM staging_courses sc
ORDER BY sc.course_id;


---------- 6. FUSION ET TRANSFERT DES INSCRIPTIONS (Les 3 fichiers de staging) ----------

INSERT INTO enrollments (student_id, course_id, grade, enrollment_date)
SELECT student_id, course_id, grade, TO_DATE(enrollment_date, 'DD-MM-YYYY')
FROM (
    SELECT student_id, course_id, grade, enrollment_date FROM staging_enrollments1
    UNION ALL
    SELECT student_id, course_id, grade, enrollment_date FROM staging_enrollments2
    UNION ALL
    SELECT student_id, course_id, grade, enrollment_date FROM staging_enrollments3
) AS combined_staging
-- Sécurité : On s'assure de ne pas importer une inscription pour un étudiant 
-- ou un cours qui n'existerait pas à cause d'un mauvais tirage Mockaroo
WHERE student_id IN (SELECT student_id FROM students)
  AND course_id IN (SELECT course_id FROM courses);