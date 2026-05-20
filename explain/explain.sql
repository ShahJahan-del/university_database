--Simple query
EXPLAIN SELECT * FROM film;

--Specific id
EXPLAIN SELECT * FROM film WHERE film_id = 100;


--Supress the cost with Costs option
EXPLAIN (COSTS FALSE) SELECT
    *
FROM
    film
WHERE
    film_id = 100;

--Aggregate function
EXPLAIN SELECT COUNT(*) FROM film;


--Joins
EXPLAIN
SELECT
    f.film_id,
    title,
    name category_name
FROM
    film f
    INNER JOIN film_category fc
        ON fc.film_id = f.film_id
    INNER JOIN category c
        ON c.category_id = fc.category_id
ORDER BY
    title;


--Runtime statistics with Analyze
EXPLAIN ANALYZE
    SELECT
        f.film_id,
        title,
        name category_name
    FROM
        film f
        INNER JOIN film_category fc
            ON fc.film_id = f.film_id
        INNER JOIN category c
            ON c.category_id = fc.category_id
    ORDER BY
        title;