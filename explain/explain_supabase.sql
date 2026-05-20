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


--Results before indexation :

Nested Loop  (cost=5.68..34.21 rows=8 width=236) (actual time=0.323..0.443 rows=7 loops=1)
  ->  Index Scan using courses_pkey on courses c  (cost=0.15..2.37 rows=1 width=222) (actual time=0.069..0.070 rows=1 loops=1)
        Index Cond: (course_id = 1)
  ->  Hash Join  (cost=5.54..31.77 rows=8 width=22) (actual time=0.252..0.370 rows=7 loops=1)
        Hash Cond: ((e.student_id)::text = (s.student_id)::text)
        ->  Seq Scan on enrollments e  (cost=0.00..26.18 rows=21 width=17) (actual time=0.063..0.283 rows=18 loops=1)
              Filter: ((course_id = 1) AND ((grade)::text = 'AA'::text))
              Rows Removed by Filter: 1127
        ->  Hash  (cost=4.81..4.81 rows=58 width=15) (actual time=0.068..0.069 rows=58 loops=1)
              Buckets: 1024  Batches: 1  Memory Usage: 11kB
              ->  Seq Scan on students s  (cost=0.00..4.81 rows=58 width=15) (actual time=0.009..0.050 rows=58 loops=1)
                    Filter: ((sex)::text = 'Female'::text)
                    Rows Removed by Filter: 87
Planning Time: 2.844 ms
Execution Time: 0.532 ms

--Results after indexation :

Nested Loop  (cost=7.28..18.95 rows=8 width=236) (actual time=0.174..0.186 rows=7 loops=1)
  ->  Index Scan using courses_pkey on courses c  (cost=0.15..2.37 rows=1 width=222) (actual time=0.031..0.032 rows=1 loops=1)
  