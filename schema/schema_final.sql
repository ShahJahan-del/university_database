---------- NETTOYAGE ABSOLU ----------

DROP TABLE IF EXISTS enrollments CASCADE;
DROP TABLE IF EXISTS courses CASCADE;
DROP TABLE IF EXISTS students CASCADE;
DROP TABLE IF EXISTS teachers CASCADE;
DROP TABLE IF EXISTS departments CASCADE;


---------- 1. TABLE DEPARTMENTS (Volume cible : 10) ----------

CREATE TABLE departments (
    department_id INT PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL
);


---------- 2. TABLE TEACHERS (Volume cible : 50) ----------

CREATE TABLE teachers (
    teacher_id INT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    department_id INT,
    FOREIGN KEY (department_id) REFERENCES departments(department_id) ON DELETE SET NULL
);


---------- 3. TABLE STUDENTS (Volume cible : 1 000) ----------

CREATE TABLE students (
    student_id INT PRIMARY KEY, -- Ex: 1, 2...
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    age_category VARCHAR(20) NOT NULL,  -- '18-21', '22-25', '26+'
    sex VARCHAR(50) NOT NULL,          -- 'Male', 'Female'
    wsh VARCHAR(50) NOT NULL,          -- Weekly Study Hours: '<5 hours', '6-10 hours'...
    dca VARCHAR(5) NOT NULL            -- Dept Conference Attendance: 'Yes', 'No'
);


---------- 4. TABLE COURSES (Volume cible : 100) ----------

CREATE TABLE courses (
    course_id INT PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    credits INT CHECK (credits > 0),
    department_id INT,
    teacher_id INT,
    FOREIGN KEY (department_id) REFERENCES departments(department_id) ON DELETE CASCADE,
    FOREIGN KEY (teacher_id) REFERENCES teachers(teacher_id) ON DELETE SET NULL
);


-- 5. TABLE ENROLLMENTS (Volume cible : 15 000, 1488 en réalité)

CREATE TABLE enrollments (
    enrollment_id SERIAL PRIMARY KEY,
    student_id INT NOT NULL,
    course_id INT NOT NULL,
    enrollment_date DATE DEFAULT CURRENT_DATE,
    grade VARCHAR(5) NOT NULL,         -- 'AA', 'BA', 'BB', 'CC', 'Fail'...
    FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES courses(course_id) ON DELETE CASCADE
    -- Rappel : Pas de contrainte UNIQUE ici pour absorber le volume Mockaroo sans blocage
);