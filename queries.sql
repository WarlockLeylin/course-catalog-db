-- queries.sql: queries for the API routes
-- Modifying queries are wrapped in a transaction that rolls back,
-- so the file can be run as many times as you like.

-- 1. GET /courses?is_elective=false&sort=popular&page=1&page_size=3
SELECT id, title, credits, likes
FROM courses
WHERE is_elective = false
ORDER BY likes DESC, id ASC
LIMIT 3 OFFSET 0;

-- 1b. The same, page 2: OFFSET = (2 - 1) * 3 = 3
SELECT id, title, credits, likes
FROM courses
WHERE is_elective = false
ORDER BY likes DESC, id ASC
LIMIT 3 OFFSET 3;

-- 2. GET /courses/{course_id}
SELECT id, title, credits, is_elective, likes
FROM courses
WHERE id = 'api-design';

-- 2b. Non-existent course: 0 rows, API returns 404
SELECT id, title, credits, is_elective, likes
FROM courses
WHERE id = 'no-such-course';

-- 3. POST /courses/{course_id}/like
BEGIN;
-- Increase likes by 1 for 'api-design' and return the updated values
UPDATE courses 
SET likes = likes + 1 
WHERE id = 'api-design' 
RETURNING id, likes;
ROLLBACK;

-- 3b. Non-existent course like: UPDATE 0, API returns 404
BEGIN;
UPDATE courses 
SET likes = likes + 1 
WHERE id = 'no-such-course' 
RETURNING id, likes;
ROLLBACK;

-- 4. POST /enrollments
BEGIN;
-- Enroll student with ID 3 in 'web-security' course
INSERT INTO enrollments (course_id, student_id)
VALUES ('web-security', 3)
RETURNING id, course_id, student_id;
ROLLBACK;

-- 5. GET /enrollments
-- List all enrollments with student names and course titles using JOIN
SELECT e.id, s.name AS student, c.title AS course
FROM enrollments e
JOIN students s ON s.id = e.student_id
JOIN courses c ON c.id = e.course_id
ORDER BY e.id;

-- 6. Statistics: enrollments per course, including courses with none
SELECT c.id, count(e.id) AS enrolled
FROM courses c
LEFT JOIN enrollments e ON e.course_id = c.id
GROUP BY c.id
ORDER BY enrolled DESC, c.id ASC;

-- Query 7: IDs of courses nobody is enrolled in (alphabetical order)
SELECT c.id
FROM courses c
LEFT JOIN enrollments e ON c.id = e.course_id
WHERE e.id IS NULL
ORDER BY c.id;

-- Query 8: Student name and number of courses for students with > 1 course
SELECT s.name, count(e.course_id) AS courses
FROM students s
JOIN enrollments e ON s.id = e.student_id
GROUP BY s.id, s.name
HAVING count(e.course_id) > 1
ORDER BY courses DESC, s.name;