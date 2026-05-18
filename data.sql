INSERT INTO departments (name)
VALUES
('Computer Science'),
('Mathematics'),
('Physics');

INSERT INTO teachers
(first_name, last_name, email, department_id)
VALUES
('John', 'Smith', 'john.smith@uni.com', 1),
('Alice', 'Brown', 'alice.brown@uni.com', 2);

INSERT INTO students
(first_name, last_name, email, birth_date)
VALUES
('Emma', 'Wilson', 'emma@uni.com', '2002-05-10'),
('Liam', 'Taylor', 'liam@uni.com', '2001-08-21');

INSERT INTO courses
(title, credits, department_id, teacher_id)
VALUES
('Database Systems', 4, 1, 1),
('Linear Algebra', 3, 2, 2);

INSERT INTO enrollments
(student_id, course_id, grade)
VALUES
(1, 1, 16.5),
(2, 1, 14.0);

