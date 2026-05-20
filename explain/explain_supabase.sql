-- Requête d'analyse de performance
EXPLAIN ANALYZE
SELECT 
    s.student_id, 
    s.sex, 
    c.title AS nom_du_cours, 
    e.grade AS note_obtenue
FROM enrollments e
JOIN students s ON e.student_id = s.student_id
JOIN courses c ON e.course_id = c.course_id
WHERE s.sex = 'Female' 
  AND e.grade = 'AA' 
  AND c.course_id = 1;