-- Une seule structure pour filtrer sur le cours et la note d'un coup
CREATE INDEX idx_enrollments_course_grade ON enrollments(course_id, grade);


-- Séparation des indexes (moins bon)
--CREATE INDEX idx_enrollments_course_id ON enrollments(course_id);
--CREATE INDEX idx_enrollments_grade ON enrollments(grade);