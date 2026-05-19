DROP TABLE IF EXISTS enrollments CASCADE;
DROP TABLE IF EXISTS courses CASCADE;
DROP TABLE IF EXISTS students CASCADE;
DROP TABLE IF EXISTS teachers CASCADE;
DROP TABLE IF EXISTS departments CASCADE;

CREATE TABLE departments (
    department_id SERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE students (
    student_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    birth_date DATE,
    
    CHECK (birth_date < CURRENT_DATE)
);

CREATE TABLE teachers (
    teacher_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    department_id INT,
    
    FOREIGN KEY (department_id)
    REFERENCES departments(department_id)
    ON DELETE SET NULL
);

CREATE TABLE courses (
    course_id SERIAL PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    credits INT CHECK (credits > 0),
    
    department_id INT,
    teacher_id INT,
    
    FOREIGN KEY (department_id)
    REFERENCES departments(department_id)
    ON DELETE CASCADE,
    
    FOREIGN KEY (teacher_id)
    REFERENCES teachers(teacher_id)
    ON DELETE SET NULL
);

CREATE TABLE enrollments (
    enrollment_id SERIAL PRIMARY KEY,
    
    student_id INT NOT NULL,
    course_id INT NOT NULL,
    
    enrollment_date DATE DEFAULT CURRENT_DATE,
    grade NUMERIC(4,2),
    
    FOREIGN KEY (student_id)
    REFERENCES students(student_id)
    ON DELETE CASCADE,
    
    FOREIGN KEY (course_id)
    REFERENCES courses(course_id)
    ON DELETE CASCADE,
    
    UNIQUE(student_id, course_id)
);

