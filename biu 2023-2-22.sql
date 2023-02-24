
/*
Create a table that shows the following data:
CourseName, TeacherName, NumberOfStudents, AverageGrades (for each course)
Use 2 ways: 1) Join 2) subquery.
Create a view that will always show the above table updated.
*/

USE College;

SELECT * FROM Classrooms; -- CourseId
SELECT * FROM Courses; -- CourseId, TeacherId
SELECT * FROM Teachers; --TeacherId


--JOIN method

SELECT t1.*, t2.CourseName, t3.FirstName, t3.LastName INTO dsuser29.avgCourse
    FROM Classrooms as t1
    INNER JOIN Courses as t2
    ON t1.CourseId = t2.CourseId
    INNER JOIN Teachers as t3
    ON t2.TeacherId = t3.TeacherId

SELECT t4.CourseName, CONCAT(t4.FirstName ,' ', t4.LastName) as TeacherName, COUNT(t4.StudentId) as NumberOfStudents, AVG(t4.Grades) as AverageGrades
    FROM dsuser29.avgCourse as t4 GROUP BY FirstName, LastName, CourseName;

--End join method
-- Subquery method:

SELECT  Courses.CourseName,
    (SELECT CONCAT(FirstName, ' ' , LastName) FROM Teachers WHERE Teachers.TeacherId = Courses.TeacherId) as TeacherName,
    (SELECT COUNT(StudentId) FROM Classrooms WHERE Classrooms.CourseId = Courses.CourseId) as NumberOfStudents,
    (select AVG(Grades) from Classrooms WHERE Classrooms.CourseId = Courses.CourseId) as AverageGrades
    FROM Courses;
--End subquery

--View (Virtual table)
CREATE VIEW CoursesMeans AS 
SELECT  Courses.CourseName,
    (SELECT CONCAT(FirstName, ' ' , LastName) FROM Teachers WHERE Teachers.TeacherId = Courses.TeacherId) as TeacherName,
    (SELECT COUNT(StudentId) FROM Classrooms WHERE Classrooms.CourseId = Courses.CourseId) as NumberOfStudents,
    (select AVG(Grades) from Classrooms WHERE Classrooms.CourseId = Courses.CourseId) as AverageGrades
    FROM Courses;

SELECT * FROM CoursesMeans