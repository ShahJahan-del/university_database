EXPLAIN ANALYZE
SELECT c.course_id, c.title, d.name AS department, COUNT(e.enrollment_id) AS total_students
FROM courses c
JOIN departments d ON c.department_id = d.department_id
LEFT JOIN enrollments e ON c.course_id = e.course_id
GROUP BY c.course_id, c.title, d.name
ORDER BY total_students DESC
LIMIT 10;


-- Results before Indexation
Limit  (cost=111.56..111.58 rows=10 width=259) (actual time=1.560..1.564 rows=10 loops=1)
  ->  Sort  (cost=111.56..115.28 rows=1488 width=259) (actual time=1.559..1.562 rows=10 loops=1)
        Sort Key: (count(e.enrollment_id)) DESC
        Sort Method: top-N heapsort  Memory: 26kB
        ->  HashAggregate  (cost=64.52..79.40 rows=1488 width=259) (actual time=1.486..1.512 rows=100 loops=1)
              Group Key: c.course_id, d.name
              Batches: 1  Memory Usage: 81kB
              ->  Hash Join  (cost=20.45..53.36 rows=1488 width=255) (actual time=0.149..1.078 rows=1488 loops=1)
                    Hash Cond: (c.department_id = d.department_id)
                    ->  Hash Right Join  (cost=3.25..32.20 rows=1488 width=41) (actual time=0.100..0.745 rows=1488 loops=1)
                          Hash Cond: (e.course_id = c.course_id)
                          ->  Seq Scan on enrollments e  (cost=0.00..24.88 rows=1488 width=8) (actual time=0.024..0.208 rows=1488 loops=1)
                          ->  Hash  (cost=2.00..2.00 rows=100 width=37) (actual time=0.055..0.056 rows=100 loops=1)
                                Buckets: 1024  Batches: 1  Memory Usage: 15kB
                                ->  Seq Scan on courses c  (cost=0.00..2.00 rows=100 width=37) (actual time=0.018..0.030 rows=100 loops=1)
                    ->  Hash  (cost=13.20..13.20 rows=320 width=222) (actual time=0.037..0.038 rows=10 loops=1)
                          Buckets: 1024  Batches: 1  Memory Usage: 9kB
                          ->  Seq Scan on departments d  (cost=0.00..13.20 rows=320 width=222) (actual time=0.032..0.034 rows=10 loops=1)
Planning Time: 3.981 ms
Execution Time: 1.777 ms



-- Results after Indexation
Limit  (cost=111.56..111.58 rows=10 width=259) (actual time=1.356..1.359 rows=10 loops=1)
  ->  Sort  (cost=111.56..115.28 rows=1488 width=259) (actual time=1.355..1.357 rows=10 loops=1)
        Sort Key: (count(e.enrollment_id)) DESC
        Sort Method: top-N heapsort  Memory: 26kB
        ->  HashAggregate  (cost=64.52..79.40 rows=1488 width=259) (actual time=1.287..1.313 rows=100 loops=1)
              Group Key: c.course_id, d.name
              Batches: 1  Memory Usage: 81kB
              ->  Hash Join  (cost=20.45..53.36 rows=1488 width=255) (actual time=0.101..0.869 rows=1488 loops=1)
                    Hash Cond: (c.department_id = d.department_id)
                    ->  Hash Right Join  (cost=3.25..32.20 rows=1488 width=41) (actual time=0.071..0.559 rows=1488 loops=1)
                          Hash Cond: (e.course_id = c.course_id)
                          ->  Seq Scan on enrollments e  (cost=0.00..24.88 rows=1488 width=8) (actual time=0.009..0.129 rows=1488 loops=1)
                          ->  Hash  (cost=2.00..2.00 rows=100 width=37) (actual time=0.051..0.051 rows=100 loops=1)
                                Buckets: 1024  Batches: 1  Memory Usage: 15kB
                                ->  Seq Scan on courses c  (cost=0.00..2.00 rows=100 width=37) (actual time=0.014..0.025 rows=100 loops=1)
                    ->  Hash  (cost=13.20..13.20 rows=320 width=222) (actual time=0.013..0.013 rows=10 loops=1)
                          Buckets: 1024  Batches: 1  Memory Usage: 9kB
                          ->  Seq Scan on departments d  (cost=0.00..13.20 rows=320 width=222) (actual time=0.007..0.009 rows=10 loops=1)
Planning Time: 0.866 ms
Execution Time: 1.527 ms