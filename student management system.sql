-- ============================================================
-- STUDENT MANAGEMENT SYSTEM — FULL SQL PROJECT
-- Compatible with MySQL 8.0+
-- ============================================================

DROP DATABASE IF EXISTS student_management_system;
CREATE DATABASE student_management_system;
USE student_management_system;

-- ============================================================
-- 1. TABLES
-- ============================================================

-- Departments offered by the institution
CREATE TABLE departments (
    dept_id      INT AUTO_INCREMENT PRIMARY KEY,
    dept_name    VARCHAR(100) NOT NULL UNIQUE,
    dept_head    VARCHAR(100)
);

-- Teachers / faculty
CREATE TABLE teachers (
    teacher_id   INT AUTO_INCREMENT PRIMARY KEY,
    first_name   VARCHAR(50) NOT NULL,
    last_name    VARCHAR(50) NOT NULL,
    email        VARCHAR(100) UNIQUE NOT NULL,
    phone        VARCHAR(15),
    dept_id      INT,
    hire_date    DATE DEFAULT (CURRENT_DATE),
    FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
        ON DELETE SET NULL
);

-- Students
CREATE TABLE students (
    student_id   INT AUTO_INCREMENT PRIMARY KEY,
    first_name   VARCHAR(50) NOT NULL,
    last_name    VARCHAR(50) NOT NULL,
    email        VARCHAR(100) UNIQUE NOT NULL,
    phone        VARCHAR(15),
    dob          DATE,
    gender       ENUM('Male', 'Female', 'Other'),
    dept_id      INT,
    admission_date DATE DEFAULT (CURRENT_DATE),
    FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
        ON DELETE SET NULL
);

-- Courses offered
CREATE TABLE courses (
    course_id    INT AUTO_INCREMENT PRIMARY KEY,
    course_name  VARCHAR(100) NOT NULL,
    course_code  VARCHAR(20) UNIQUE NOT NULL,
    credits      INT NOT NULL CHECK (credits BETWEEN 1 AND 6),
    dept_id      INT,
    teacher_id   INT,
    FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
        ON DELETE SET NULL,
    FOREIGN KEY (teacher_id) REFERENCES teachers(teacher_id)
        ON DELETE SET NULL
);

-- Enrollments (many-to-many: students <-> courses)
CREATE TABLE enrollments (
    enrollment_id  INT AUTO_INCREMENT PRIMARY KEY,
    student_id     INT NOT NULL,
    course_id      INT NOT NULL,
    enrolled_on    DATE DEFAULT (CURRENT_DATE),
    UNIQUE KEY uq_student_course (student_id, course_id),
    FOREIGN KEY (student_id) REFERENCES students(student_id)
        ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES courses(course_id)
        ON DELETE CASCADE
);

-- Attendance (one row per student per course per date)
CREATE TABLE attendance (
    attendance_id  INT AUTO_INCREMENT PRIMARY KEY,
    student_id     INT NOT NULL,
    course_id      INT NOT NULL,
    class_date     DATE NOT NULL,
    status         ENUM('Present', 'Absent', 'Late') NOT NULL,
    UNIQUE KEY uq_attendance (student_id, course_id, class_date),
    FOREIGN KEY (student_id) REFERENCES students(student_id)
        ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES courses(course_id)
        ON DELETE CASCADE
);

-- Exams and marks
CREATE TABLE exams (
    exam_id      INT AUTO_INCREMENT PRIMARY KEY,
    course_id    INT NOT NULL,
    exam_name    VARCHAR(50) NOT NULL,   -- e.g. 'Midterm', 'Final'
    exam_date    DATE,
    max_marks    INT NOT NULL DEFAULT 100,
    FOREIGN KEY (course_id) REFERENCES courses(course_id)
        ON DELETE CASCADE
);

CREATE TABLE results (
    result_id    INT AUTO_INCREMENT PRIMARY KEY,
    student_id   INT NOT NULL,
    exam_id      INT NOT NULL,
    marks_obtained DECIMAL(5,2) NOT NULL,
    UNIQUE KEY uq_result (student_id, exam_id),
    FOREIGN KEY (student_id) REFERENCES students(student_id)
        ON DELETE CASCADE,
    FOREIGN KEY (exam_id) REFERENCES exams(exam_id)
        ON DELETE CASCADE
);

-- Fee payments
CREATE TABLE fee_payments (
    payment_id     INT AUTO_INCREMENT PRIMARY KEY,
    student_id     INT NOT NULL,
    amount_paid    DECIMAL(10,2) NOT NULL,
    payment_date   DATE DEFAULT (CURRENT_DATE),
    payment_mode   ENUM('Cash', 'Card', 'UPI', 'Bank Transfer') DEFAULT 'UPI',
    FOREIGN KEY (student_id) REFERENCES students(student_id)
        ON DELETE CASCADE
);

-- ============================================================
-- 2. SAMPLE DATA
-- ============================================================

INSERT INTO departments (dept_name, dept_head) VALUES
('Computer Science', 'Dr. Rao'),
('Electronics', 'Dr. Sharma'),
('Mechanical', 'Dr. Iyer');

INSERT INTO teachers (first_name, last_name, email, phone, dept_id) VALUES
('Anita', 'Verma', 'anita.verma@college.edu', '9000000001', 1),
('Ravi', 'Kumar', 'ravi.kumar@college.edu', '9000000002', 1),
('Sunil', 'Nair', 'sunil.nair@college.edu', '9000000003', 2);

INSERT INTO students (first_name, last_name, email, phone, dob, gender, dept_id) VALUES
('Akshitha', 'Pappuru', 'akshitha@college.edu', '9346085971', '2005-04-12', 'Female', 1),
('Rahul', 'Reddy', 'rahul@college.edu', '9000000011', '2004-11-02', 'Male', 1),
('Priya', 'Singh', 'priya@college.edu', '9000000012', '2005-01-20', 'Female', 2),
('Arjun', 'Das', 'arjun@college.edu', '9000000013', '2004-07-15', 'Male', 3);

INSERT INTO courses (course_name, course_code, credits, dept_id, teacher_id) VALUES
('Database Management Systems', 'CS301', 4, 1, 1),
('Data Structures', 'CS201', 4, 1, 2),
('Digital Electronics', 'EC201', 3, 2, 3);

INSERT INTO enrollments (student_id, course_id) VALUES
(1, 1), (1, 2),
(2, 1), (2, 2),
(3, 3),
(4, 3);

INSERT INTO attendance (student_id, course_id, class_date, status) VALUES
(1, 1, '2026-07-01', 'Present'),
(1, 1, '2026-07-02', 'Absent'),
(2, 1, '2026-07-01', 'Present'),
(2, 1, '2026-07-02', 'Present');

INSERT INTO exams (course_id, exam_name, exam_date, max_marks) VALUES
(1, 'Midterm', '2026-06-15', 50),
(1, 'Final', '2026-08-10', 100),
(2, 'Midterm', '2026-06-16', 50);

INSERT INTO results (student_id, exam_id, marks_obtained) VALUES
(1, 1, 45),
(2, 1, 38),
(1, 3, 40),
(2, 3, 42);

INSERT INTO fee_payments (student_id, amount_paid, payment_mode) VALUES
(1, 25000.00, 'UPI'),
(2, 25000.00, 'Card'),
(3, 22000.00, 'Cash');

-- ============================================================
-- 3. USEFUL VIEWS
-- ============================================================

-- Student profile with department name
CREATE VIEW student_profile AS
SELECT s.student_id, CONCAT(s.first_name, ' ', s.last_name) AS student_name,
       s.email, s.phone, d.dept_name, s.admission_date
FROM students s
LEFT JOIN departments d ON s.dept_id = d.dept_id;

-- Course roster: which students are in which course
CREATE VIEW course_roster AS
SELECT c.course_name, c.course_code,
       CONCAT(s.first_name, ' ', s.last_name) AS student_name,
       e.enrolled_on
FROM enrollments e
JOIN students s ON e.student_id = s.student_id
JOIN courses c ON e.course_id = c.course_id;

-- Attendance percentage per student per course
CREATE VIEW attendance_summary AS
SELECT student_id, course_id,
       COUNT(*) AS total_classes,
       SUM(status = 'Present') AS classes_present,
       ROUND(SUM(status = 'Present') / COUNT(*) * 100, 2) AS attendance_pct
FROM attendance
GROUP BY student_id, course_id;

-- Overall result summary per student
CREATE VIEW result_summary AS
SELECT r.student_id,
       CONCAT(s.first_name, ' ', s.last_name) AS student_name,
       c.course_name, e.exam_name,
       r.marks_obtained, e.max_marks,
       ROUND(r.marks_obtained / e.max_marks * 100, 2) AS percentage
FROM results r
JOIN exams e ON r.exam_id = e.exam_id
JOIN courses c ON e.course_id = c.course_id
JOIN students s ON r.student_id = s.student_id;

-- ============================================================
-- 4. STORED PROCEDURES
-- ============================================================

DELIMITER $$

-- Enroll a student in a course (avoids duplicate enrollment)
CREATE PROCEDURE enroll_student (
    IN p_student_id INT,
    IN p_course_id INT
)
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM enrollments
        WHERE student_id = p_student_id AND course_id = p_course_id
    ) THEN
        INSERT INTO enrollments (student_id, course_id)
        VALUES (p_student_id, p_course_id);
    END IF;
END$$

-- Get full academic report for one student
CREATE PROCEDURE get_student_report (
    IN p_student_id INT
)
BEGIN
    SELECT * FROM student_profile WHERE student_id = p_student_id;
    SELECT * FROM course_roster WHERE student_name = (
        SELECT CONCAT(first_name, ' ', last_name) FROM students WHERE student_id = p_student_id
    );
    SELECT * FROM result_summary WHERE student_id = p_student_id;
    SELECT * FROM attendance_summary WHERE student_id = p_student_id;
END$$

DELIMITER ;

-- ============================================================
-- 5. TRIGGERS
-- ============================================================

DELIMITER $$

-- Prevent marks greater than the exam's max_marks
CREATE TRIGGER trg_validate_marks
BEFORE INSERT ON results
FOR EACH ROW
BEGIN
    DECLARE v_max INT;
    SELECT max_marks INTO v_max FROM exams WHERE exam_id = NEW.exam_id;
    IF NEW.marks_obtained > v_max THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Marks obtained cannot exceed the maximum marks for this exam.';
    END IF;
END$$

DELIMITER ;

-- ============================================================
-- 6. SAMPLE QUERIES (commented — uncomment to run individually)
-- ============================================================

-- List all students with their department
-- SELECT * FROM student_profile;

-- Roster for a specific course
-- SELECT * FROM course_roster WHERE course_code = 'CS301';

-- Students with attendance below 75%
-- SELECT * FROM attendance_summary WHERE attendance_pct < 75;

-- Top scorer per course
-- SELECT course_name, student_name, MAX(percentage) AS top_score
-- FROM result_summary
-- GROUP BY course_name;

-- Total fees collected
-- SELECT SUM(amount_paid) AS total_collected FROM fee_payments;

-- Call a stored procedure
-- CALL enroll_student(3, 1);
-- CALL get_student_report(1);
