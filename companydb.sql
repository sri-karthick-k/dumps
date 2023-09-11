CREATE TABLE department (
	d_id INT PRIMARY KEY,
	d_name VARCHAR(255) NOT NULL
);

CREATE TABLE employee (
	ssn INT PRIMARY KEY,
	f_name VARCHAR(255) NOT NULL,
	l_name VARCHAR(255) NOT NULL,
	gender CHAR(1) NOT NULL,
	address VARCHAR(255),
	dob DATE NOT NULL,
	salary DECIMAL(10, 2) NOT NULL,
	s_ssn INT,
	dept_id INT,
	FOREIGN KEY (s_ssn) REFERENCES employee(ssn),
	FOREIGN KEY (d_id) REFERENCES department(dept_id)
);

CREATE TABLE manager (
	emp_id INT,
	start_date DATE,
	d_id INT,
	PRIMARY KEY (emp_id, start_date, d_id),
	FOREIGN KEY (emp_id) REFERENCES employee(ssn),
	FOREIGN KEY (d_id) REFERENCES department(d_id)
);

alter table MANAGER ADD COLUMN d_id int;
alter table MANAGER ADD FOREIGN KEY (d_id) REFERENCES department(d_id);

CREATE TABLE location (
	dept_id INT,
	location_name VARCHAR(30),
	PRIMARY KEY (dept_id, location_name),
	FOREIGN KEY (dept_id) REFERENCES department(d_id)
);

-- completely changed table
CREATE TABLE project (
	p_id INT PRIMARY KEY,
	dept_id INT,
	p_name VARCHAR(255) NOT NULL,
	worth DECIMAL(10, 2),
	end_date DATE,
	FOREIGN KEY (d_no) REFERENCES department(d_no)
);

CREATE TABLE project_location (
	p_id INT,
	location VARCHAR(255),
	FOREIGN KEY (p_id) REFERENCES project(p_id)
);

CREATE TABLE works_on (
	ssn INT,
	p_id INT,
	hrs DECIMAL(5, 2) NOT NULL,
	PRIMARY KEY (ssn, p_no),
	FOREIGN KEY (ssn) REFERENCES employee(ssn),
	FOREIGN KEY (p_id) REFERENCES project(p_id)
);

CREATE TABLE dependent (
	ssn INT,
	name VARCHAR(255) NOT NULL,
	sex CHAR(1) NOT NULL,
	dob DATE NOT NULL,
	d_id INT,
	relationship VARCHAR(255),
	primary  key (ssn, name),
	FOREIGN KEY (ssn) REFERENCES employee(ssn),
	FOREIGN KEY (d_id) REFERENCES department(d_id)
);




-- populate

INSERT INTO department (d_no, name) VALUES
	(1, 'Finance'),
	(2, 'R&D'),
	(3, 'Marketing')
;



INSERT INTO employee (ssn, f_name, l_name, gender, address, dob, salary, s_ssn, dept_id) VALUES
(301, 'Rajesh', 'Kumar', 'M', '123 Main St', '1985-07-15', 65000.00, NULL, 1),
(302, 'Priya', 'Sharma', 'F', '456 Elm St', '1987-02-20', 72000.00, NULL, 1),
(303, 'Amit', 'Verma', 'M', '789 Oak St', '1993-09-10', 85000.00, 301, 1),
(304, 'Anjali', 'Patel', 'F', '101 Pine St', '1989-12-30', 63000.00, 301, 2),
(305, 'Suresh', 'Reddy', 'M', '222 Cedar St', '1992-04-25', 76000.00, 301, 2),
(306, 'Smita', 'Gupta', 'F', '333 Maple St', '1996-11-12', 68000.00, 301, 3)
;


INSERT INTO manager (emp_id, start_date, d_id) VALUES
(101, '2023-03-15', 1),
(101, '2023-08-01', 2),
(102, '2023-04-10', 1)
;


INSERT INTO location (d_id, location_name) VALUES
(1, 'Delhi'),
(2, 'Chennai'),
(3, 'Bengaluru')
;


INSERT INTO project (p_id, dept_id, p_name, worth, end_date) VALUES
(501, 2, 'Product Development', 200000.00, '2024-03-31'),
(502, 1, 'Sales Expansion', 160000.00, '2024-05-30'),
(503, 3, 'Customer Satisfaction Survey', 75000.00, '2023-09-30'),
(504, 2, 'Market Research', 130000.00, '2024-04-15');


INSERT INTO project_location (p_id, location) VALUES
(501, 'Delhi'),
(502, 'Chennai'),
(503, 'Kolkata'),
(504, 'Bengaluru');


INSERT INTO works_on (ssn, p_id, hrs) VALUES
(301, 501, 40.00),
(302, 502, 35.00),
(303, 503, 42.00),
(304, 504, 30.00),
(301, 503, 38.00);


INSERT INTO dependent (ssn, name, sex, dob, d_id, relationship) VALUES
(301, 'Emma', 'F', '2010-03-10', 1, 'Child'),
(301, 'Oliver', 'M', '2015-07-20', 1, 'Child'),
(303, 'Sophia', 'F', '2009-05-05', 2, 'Child'),
(304, 'Ethan', 'M', '2013-12-15', 2, 'Child'),
(305, 'Ava', 'F', '2018-02-28', 3, 'Child');




-- Queries

-- 1
SELECT e.f_name, e.l_name, 
(SELECT d_name FROM department WHERE d_id = e.dept_id) AS dept_Name
	FROM employee e
	WHERE e.salary > (
		SELECT AVG(salary)
		FROM employee
		WHERE d_id = 1
	);


-- 2

insert into project values(505,2, 'IOT', 1000001.00, '2023-12-31');
insert into works_on values(105,505,40.00);
insert into project values(506,2, 'livestock', 1000002.00, '2023-12-31');
insert into project values(506,2, 'livestock', 1000002.00, '2023-12-31');

SELECT e.f_name, e.l_name, d.name AS dept_Name
	FROM employee e, works_on w, project p, department d
	WHERE e.ssn = w.ssn
	AND w.p_id = p.p_id
	AND p.dept_id = d.d_id
	AND d.d_name = 'R&D'
	GROUP BY e.ssn, e.f_name, e.l_name, d.d_name
	HAVING COUNT(w.p_id) >= 2;


-- 3


SELECT d.d_name AS dept_Name, p.p_name AS project_name
	FROM department d, project p
	WHERE d.d_id = p.dept_id
	AND (p.end_date > CURDATE() OR p.end_date IS NULL);


-- 4

SELECT DISTINCT s.ssn AS supervisor_ssn, s.f_name AS supervisor_f_name, s.l_name AS supervisor_l_name
	FROM employee s
	WHERE s.ssn IN (
		SELECT s_ssn
		FROM employee e
		WHERE e.ssn IN (SELECT DISTINCT ssn FROM works_on)
		GROUP BY s_ssn
		HAVING COUNT(*) > 3
	);


-- 5


update project set worth=1000000 where p_no=503;

SELECT d.d_name AS dept_Name, e.f_name AS employee_f_name, e.l_name AS employee_l_name, d2.name AS dependent_name
	FROM employee e, works_on w, project p, department d, dependent d2
	WHERE e.ssn = w.ssn
	AND w.p_id = p.p_id
	AND e.dept_id = d.d_id
	AND e.ssn = d2.ssn
	AND p.worth >= 1000000;


--- 6

INSERT INTO project_location (p_id, location) VALUES (501, 'Chicago');

SELECT d.d_name AS dept_Name, e.f_name, e.l_name, p.p_name
	FROM employee e, project p, department d
	WHERE e.ssn IN (
		SELECT ssn
		FROM works_on w
		WHERE w.p_id IN (
			SELECT p_id
			FROM project_location
			GROUP BY p_id
			HAVING COUNT(DISTINCT location) > 1
		)
	)
	AND e.dept_id = d.d_id
	AND p.p_id = (
		SELECT DISTINCT p_id
		FROM project_location
		GROUP BY p_id
		HAVING COUNT(DISTINCT location) > 1
	);
