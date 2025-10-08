CREATE TABLE employees(
    employee_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    department VARCHAR(50),
    salary NUMERIC(10,2),
    hire_date DATE,
    manager_id INTEGER,
    email VARCHAR(100)
);

CREATE TABLE projects(
    project_id SERIAL PRIMARY KEY,
    project_name VARCHAR(100),
    budget NUMERIC(12,2),
    start_date DATE,
    end_date DATE,
    status VARCHAR(20)
);

CREATE TABLE assignments(
    assignment_id SERIAL PRIMARY KEY,
    employee_id INTEGER REFERENCES employees(employee_id),
    project_id INTEGER REFERENCES projects(project_id),
    hours_worked NUMERIC(5,1),
    assignment_date DATE
);


INSERT INTO employees (first_name, last_name, department,
salary, hire_date, manager_id, email) VALUES
('John', 'Smith', 'IT', 75000, '2020-01-15', NULL,
'john.smith@company.com'),
('Sarah', 'Johnson', 'IT', 65000, '2020-03-20', 1,
'sarah.j@company.com'),
('Michael', 'Brown', 'Sales', 55000, '2019-06-10', NULL,
'mbrown@company.com'),
('Emily', 'Davis', 'HR', 60000, '2021-02-01', NULL,
'emily.davis@company.com'),
('Robert', 'Wilson', 'IT', 70000, '2020-08-15', 1, NULL),
('Lisa', 'Anderson', 'Sales', 58000, '2021-05-20', 3,
'lisa.a@company.com');

INSERT INTO projects (project_name, budget, start_date,
end_date, status) VALUES
('Website Redesign', 150000, '2024-01-01', '2024-06-30',
'Active'),
('CRM Implementation', 200000, '2024-02-15', '2024-12-31',
'Active'),
('Marketing Campaign', 80000, '2024-03-01', '2024-05-31',
'Completed'),
('Database Migration', 120000, '2024-01-10', NULL, 'Active');

INSERT INTO assignments (employee_id, project_id,
hours_worked, assignment_date) VALUES
(1, 1, 120.5, '2024-01-15'),
(2, 1, 95.0, '2024-01-20'),
(1, 4, 80.0, '2024-02-01'),
(3, 3, 60.0, '2024-03-05'),
(5, 2, 110.0, '2024-02-20'),
(6, 3, 75.5, '2024-03-10');


-- Task 1.1
SELECT
    CONCAT (first_name, ' ', last_name) as full_name,
    department, salary
FROM employees

-- Task 1.2
SELECT DISTINCT department
FROM employees

-- Task 1.3
SELECT
    project_name,
    budget,
    CASE
        WHEN budget > 150000 Then 'Large'
        WHEN budget BETWEEN 1000000 AND 150000 THEN 'Medium'
        ELSE 'Small'
    END AS budget_category
FROM projects

-- Task 1.4
SELECT
    CONCAT(first_name, ' ', last_name) AS full_name,
    COALESCE(email, 'No email provided') AS email
FROM employees;


-- Task 2.1
SELECT * FROM employees
WHERE hire_date > '2020-01-01';

-- Task 2.2
SELECT * FROM employees
WHERE salary BETWEEN 60000 and 70000

-- Task 2.3
SELECT * FROM employees
WHERE last_name LIKE 'J%' OR last_name LIKE 'S%'

-- Task 2.4
SELECT *
FROM employees
WHERE manager_id IS NOT NULL
  AND department = 'IT';

-- Task 3.1
SELECT
    UPPER(CONCAT(first_name, ' ', last_name)) AS full_name_upper,
    LENGTH(last_name) AS last_name_length,
    SUBSTRING(email, 1, 3) AS email_prefix
FROM employees;

-- Task 3.2
SELECT
    CONCAT(first_name, ' ', last_name) AS full_name,
    salary * 12 AS annual_salary,
    ROUND(salary, 2) AS monthly_salary,
    salary * 0.10 AS raise_amount
FROM employees;

-- Task 3.3
SELECT
    ('Project: %s - Budget: $%s - Status: %s', project_name, budget, status) AS project_info
FROM projects;

-- Task 3.4
SELECT
    CURRENT_DATE,
    AGE(CURRENT_DATE, hire_date)
FROM employees;

-- Task 4.1
SELECT
    department,
    AVG(salary) AS average_salary
FROM employees
GROUP BY department;

-- Task 4.2
SELECT
    project_id,
    SUM(hours_worked) AS total_hours
FROM assignments
GROUP BY project_id;

-- Task 4.3
SELECT
    department,
    COUNT(*) AS employee_count
FROM employees
GROUP BY department
HAVING COUNT(*) > 1;

-- Task 4.4
SELECT
    MAX(salary) AS max_salary,
    MIN(salary) AS min_salary,
    SUM(salary) AS total_payroll
FROM employees;

-- Task 5.1
SELECT
    employee_id,
    CONCAT(first_name, ' ', last_name) AS full_name,
    salary
FROM employees
WHERE salary > 65000

UNION

SELECT
    employee_id,
    CONCAT(first_name, ' ', last_name) AS full_name,
    salary
FROM employees
WHERE hire_date > '2020-01-01';


-- Task 5.2
SELECT employee_id, first_name, last_name
FROM employees
WHERE department = 'IT'

INTERSECT

SELECT employee_id, first_name, last_name
FROM employees
WHERE salary > 65000;

-- Task 5.3
SELECT employee_id, first_name, last_name
FROM employees

EXCEPT

SELECT employees.employee_id, employees.first_name, employees.last_name
FROM employees
JOIN projects ON employees.employee_id = projects.project_id;

-- Task 6.1
SELECT employee_id, first_name, last_name
FROM employees
WHERE EXISTS (
    SELECT 1
    FROM projects
    WHERE projects.project_id = employees.employee_id
);

-- Task 6.2
SELECT employee_id, first_name, last_name
FROM employees
WHERE employee_id IN (
    SELECT employees.employee_id
    FROM employees
    JOIN projects ON employees.employee_id = projects.project_id
    WHERE projects.status = 'Active'
);

-- Task 6.3
SELECT employee_id, first_name, last_name, salary
FROM employees
WHERE salary > ANY (
    SELECT salary
    FROM employees
    WHERE department = 'Sales'
);


-- Task 7.1
SELECT
    employees.employee_id,
    CONCAT(employees.first_name, ' ', employees.last_name) AS full_name,
    employees.department,
    employees.salary,
    AVG(assignments.hours_worked) AS avg_hours_worked
FROM employees
LEFT JOIN assignments
    ON employees.employee_id = assignments.employee_id
GROUP BY
    employees.employee_id,
    employees.first_name,
    employees.last_name,
    employees.department,
    employees.salary
ORDER BY
    employees.department,
    employees.salary DESC;

-- Task 7.2
SELECT
    p.project_name,
    SUM(a.hours_worked) AS total_hours,
    COUNT(DISTINCT a.employee_id) AS employee_count
FROM projects p
JOIN assignments a ON p.project_id = a.project_id
GROUP BY p.project_name
HAVING SUM(a.hours_worked) > 150;

-- Task 7.3
SELECT
    employees.department,
    COUNT(*) AS total_employees,
    AVG(employees.salary) AS avg_salary,
    MAX(employees.salary) AS highest_salary,
    (SELECT CONCAT(first_name, ' ', last_name)
     FROM employees
     WHERE employees.department = department
     ORDER BY salary DESC
     LIMIT 1) AS highest_paid_employee,
    GREATEST(AVG(employees.salary), MIN(employees.salary)) AS salary_comparison_high,
    LEAST(AVG(employees.salary), MAX(employees.salary)) AS salary_comparison_low
FROM employees
GROUP BY employees.department;







-- TASK
CREATE TABLE flights (
  flight_id SERIAL PRIMARY KEY,
  flight_number VARCHAR(20),
  origin VARCHAR(100),
  destination VARCHAR(100),
  departure_time TIMESTAMP,
  arrival_time TIMESTAMP,
  aircraft_type VARCHAR(50),
  status VARCHAR(20),
  ticket_price NUMERIC(10,2)
);

CREATE TABLE passengers (
  passenger_id SERIAL PRIMARY KEY,
  passenger_name VARCHAR(50),
  nationality VARCHAR(50),
  passport_number VARCHAR(50),
  frequent_flyer_status VARCHAR(20)
);

CREATE TABLE bookings (
  booking_id SERIAL PRIMARY KEY,
  passenger_id INTEGER REFERENCES passengers(passenger_id),
  flight_id INTEGER REFERENCES flights(flight_id),
  booking_date DATE,
  seat_number VARCHAR(10),
  baggage_weight NUMERIC(5,2)
);

SELECT flight_id, LOWER(flight_number) 
    AS flight_number_lower, 
        origin || ' -> ' || destination AS route, 
        aircraft_type || ' Aircraft' AS aircraft_type_label, 
        departure_time, 
        arrival_time,
        status, 
        ticket_price 
    FROM flights ORDER BY flight_id;

SELECT 
    flight_id,
    flight_number,
    origin,
    destination,
    departure_time,
    arrival_time 
    FROM flights 
    WHERE destination LIKE 'New%' OR destination LIKE 'Los%' 
    ORDER BY destination, flight_id;

SELECT 
    passenger_id,
    passenger_name,
    frequent_flyer_status,
    CASE 
        WHEN frequent_flyer_status IN ('Gold','Platinum') THEN 'Elite Member'
        WHEN frequent_flyer_status = 'Silver' THEN 'Regular Member' 
        ELSE 'Standard' END AS passenger_category 
    FROM passengers ORDER BY passenger_id;

SELECT 
    flight_id,
    flight_number, 
    departure_time, 
    arrival_time, 
    EXTRACT(EPOCH FROM (arrival_time - departure_time)) / 3600.0 AS duration_hours 
    FROM flights
    WHERE arrival_time IS NOT NULL AND departure_time IS NOT NULL ORDER BY flight_id;

SELECT 
    booking_id,
    passenger_id,
    flight_id,
    booking_date,
    seat_number,
    baggage_weight 
    FROM bookings 
    WHERE booking_date >= (current_date - INTERVAL '30 days') 
    ORDER BY booking_date DESC;

SELECT 
    flight_id,
    flight_number,
    departure_time,
    EXTRACT(HOUR FROM departure_time) AS depart_hour 
    FROM flights 
    WHERE EXTRACT(HOUR FROM departure_time) < 12 
    ORDER BY departure_time;

SELECT 
    SUM(baggage_weight) AS total_baggage_weight_over_20 
    FROM bookings 
    WHERE baggage_weight > 20;

SELECT DISTINCT 
    p.passenger_id,
    p.passenger_name,
    p.frequent_flyer_status,
    b.baggage_weight,
    b.flight_id 
    FROM passengers p 
    JOIN bookings b ON p.passenger_id = b.passenger_id 
    WHERE b.baggage_weight BETWEEN 15 AND 25 
        AND p.frequent_flyer_status IS NOT NULL 
    ORDER BY p.passenger_id;

SELECT 
    ROUND(ticket_price*1.12, 2) AS ticket_price_with_fee
    FROM flights;

SELECT 
    flight_id,
    origin,
    destination,
    ticket_price
    WHERE ticket_price < 300 
        OR status = 'Delayed';

SELECT flight_id,
    flight_number,
    ticket_price,
    ROUND(ticket_price * 1.12, 2) AS price_with_service_fee
    FROM flights 
    ORDER BY flight_id;

SELECT 
    flight_id,
    flight_number,
    origin,
    destination,
    ticket_price,
    status 
    FROM flights 
    WHERE ticket_price < 300 
        OR status = 'Delayed' 
    ORDER BY status, ticket_price;

SELECT 
    f.flight_id,
    f.flight_number,
    f.origin,
    f.destination,
    COUNT(b.booking_id) AS passenger_count 
    FROM flights f JOIN bookings b ON f.flight_id = b.flight_id
    GROUP BY f.flight_id, f.flight_number, f.origin, f.destination 
    ORDER BY passenger_count DESC, f.flight_id;

SELECT 
    p.nationality,
    ROUND(AVG(b.baggage_weight),
    2) AS avg_baggage_weight,
    COUNT(b.booking_id) AS bookings_count
    FROM passengers p JOIN bookings b ON p.passenger_id = b.passenger_id 
    GROUP BY p.nationality HAVING AVG(b.baggage_weight) > 18 
    ORDER BY avg_baggage_weight DESC;

SELECT 
    aircraft_type,
    MAX(ticket_price) AS max_ticket_price,
    MIN(ticket_price) AS min_ticket_price,
    COUNT(flight_id) AS flights_count
    FROM flights 
    GROUP BY aircraft_type ORDER BY aircraft_type;

SELECT 
    f.destination,
    COUNT(b.booking_id) AS tickets_sold,
    ROUND(SUM(f.ticket_price), 2) AS total_revenue
    FROM bookings b JOIN flights f ON b.flight_id = f.flight_id 
    GROUP BY f.destination 
    ORDER BY total_revenue DESC;
