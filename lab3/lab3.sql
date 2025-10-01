CREATE TABLE employees(
    employee_id SERIAL PRIMARY KEY,
    first_name VARCHAR(30),
    last_name VARCHAR(30),
    salary INT NOT NULL,
    hire_date DATE,
    status VARCHAR(30) default 'Active'
);

CREATE TABLE departments(
    dept_id SERIAL PRIMARY KEY,
    dept_name VARCHAR(50),
    budget INT,
    manager_id INT
);

CREATE TABLE projects(
    project_id SERIAL PRIMARY KEY,
    project_name VARCHAR(50),
    dept_id INT,
    start_date DATE,
    end_date DATE,
    budget INT
);

ALTER TABLE employees ADD COLUMN department varchar(50);

INSERT INTO employees(first_name, last_name, department)
values ('Nursultan', 'Erbatyr','IT' );

INSERT INTO employees(first_name, last_name, salary, hire_date, status, department)
VALUES
    ('Daniyal', 'Nurtaza', 40000, '2025-05-29', 'Active', 'Finance'),
    ('Asset', 'Abdirakhman', 10000, '2025-01-22', 'Active', 'Finance'),
    ('Abdik', 'Nurzhan', 32000, '2025-04-21', 'Active', 'IT')

INSERT INTO employees(first_name, last_name, salary, hire_date, status, department)
VALUES ('Alice', 'Green', 50000 * 1.1, CURRENT_DATE, 'Active', 'HR')

CREATE TEMP TABLE temp_employees AS
SELECT * FROM employees WHERE department = 'IT';

UPDATE employees
SET salary = salary * 1.1;

UPDATE employees
SET status = 'Senior'
WHERE salary > 60000 AND hire_date < '2020-01-01';

UPDATE employees
SET department = CASE
    WHEN salary > 80000 THEN 'Management'
    WHEN salary BETWEEN 50000 AND 80000 THEN 'Senior'
    ELSE 'Junior'
END;

UPDATE employees
SET department = DEFAULT
WHERE status = 'Inactive';


UPDATE departments
SET budget = (
    SELECT AVG(employees.salary) * 1.2
    FROM employees
    WHERE employees.department = departments.dept_name
);

UPDATE employees
SET salary = salary * 1.15,
    status = 'Promoted'
WHERE department = 'Sales';

DELETE FROM employees
WHERE status = 'Terminated';

DELETE FROM departments
WHERE dept_name NOT IN (
    SELECT DISTINCT department
    FROM employees
    WHERE department IS NOT NULL
);

DELETE FROM projects
WHERE end_date < '2023-01-01'
RETURNING *;


INSERT INTO employees (first_name, last_name, salary, department)
VALUES ('Null', 'Example', NULL, NULL);


UPDATE employees
SET department = 'Unassigned'
WHERE department IS NULL;

DELETE FROM employees
WHERE salary IS NULL OR department IS NULL;


INSERT INTO employees (first_name, last_name, salary, hire_date, department)
VALUES ('Chris', 'Evans', 70000, CURRENT_DATE, 'IT')
RETURNING employee_id, first_name || ' ' || last_name AS full_name;

UPDATE employees
SET salary = salary + 5000
WHERE department = 'IT'
RETURNING employee_id, salary - 5000 AS old_salary, salary AS new_salary;


DELETE FROM employees
WHERE hire_date < '2020-01-01'
RETURNING *;


INSERT INTO employees (first_name, last_name, salary, hire_date, department)
SELECT 'Daniyal', 'Nurtaza', 200000, CURRENT_DATE, 'Management'
WHERE NOT EXISTS (
    SELECT 1 FROM employees
    WHERE first_name = 'Daniyal' AND last_name = 'Nurtaza'
);


UPDATE employees
SET salary = salary * CASE
    WHEN (SELECT budget 
          FROM departments 
          WHERE departments.dept_name = employees.department) > 100000
    THEN 1.10
    ELSE 1.05
END;


INSERT INTO employees (first_name, last_name, salary, hire_date, department)
VALUES
    ('John', 'Doe', 40000, CURRENT_DATE, 'Sales'),
    ('Jane', 'Doe', 42000, CURRENT_DATE, 'Sales'),
    ('Mike', 'Smith', 45000, CURRENT_DATE, 'Sales'),
    ('Emily', 'Davis', 46000, CURRENT_DATE, 'Sales'),
    ('Robert', 'Brown', 47000, CURRENT_DATE, 'Sales');


UPDATE employees
SET salary = salary * 1.1
WHERE department = 'Sales'
  AND hire_date = CURRENT_DATE;


CREATE TABLE employee_archive AS
TABLE employees WITH NO DATA;

INSERT INTO employee_archive
SELECT * FROM employees WHERE status = 'Inactive';

DELETE FROM employees WHERE status = 'Inactive';


UPDATE projects
SET end_date = end_date + INTERVAL '30 days'
WHERE budget > 50000
  AND (
        SELECT COUNT(*)
        FROM employees
        JOIN departments ON employees.department = departments.dept_name
        WHERE departments.dept_id = projects.dept_id
      ) > 3;
