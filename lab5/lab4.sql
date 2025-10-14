-- Part 1: CHECK Constraints

CREATE TABLE employees (
    employee_id SERIAL PRIMARY KEY,
    first_name text,
    last_name text,
    age integer CHECK (age BETWEEN 18 AND 65),
    salary numeric CHECK (salary > 0)
);

CREATE TABLE products_catalog (
    product_id SERIAL PRIMARY KEY,
    product_name text,
    regular_price numeric,
    discount_price numeric,
    CONSTRAINT valid_discount CHECK (
        regular_price > 0
        AND discount_price > 0
        AND discount_price < regular_price
    )
);

CREATE TABLE bookings (
    booking_id SERIAL PRIMARY KEY,
    check_in_date date,
    check_out_date date,
    num_guests integer CHECK (num_guests BETWEEN 1 AND 10),
    CHECK (check_out_date > check_in_date)
);

-- Task 1.4: Testing CHECK Constraints
-- Valid data
INSERT INTO employees (first_name, last_name, age, salary) 
    VALUES ('Alice', 'Smith', 30, 45000.00),
        ('Bob', 'Johnson', 45, 60000.50);

-- Invalid employees
-- INSERT INTO employees (first_name, last_name, age, salary) VALUES ('Charlie', 'Young', 16, 30000); -- Violates age CHECK
-- INSERT INTO employees (first_name, last_name, age, salary) VALUES ('Dorothy', 'Oldman', 70, 20000); -- Violates age CHECK
-- INSERT INTO employees (first_name, last_name, age, salary) VALUES ('Eve', 'Negative', 28, 0); -- Violates salary CHECK

-- Valid products
INSERT INTO products_catalog (product_name, regular_price, discount_price) 
    VALUES ('Widget A', 100.00, 80.00),
        ('Gadget B', 50.00, 45.00);

-- Invalid products
-- INSERT INTO products_catalog (product_name, regular_price, discount_price) VALUES ('Bad Price', 0, 0); -- Violates valid_discount
-- INSERT INTO products_catalog (product_name, regular_price, discount_price) VALUES ('No Discount', 30.00, 30.00); -- Violates valid_discount

-- Valid bookings
INSERT INTO bookings (check_in_date, check_out_date, num_guests) 
    VALUES ('2025-06-01', '2025-06-05', 2),
    ('2025-07-10', '2025-07-12', 1);

-- Invalid bookings
-- INSERT INTO bookings (check_in_date, check_out_date, num_guests) VALUES ('2025-08-01', '2025-08-03', 0); -- Violates num_guests CHECK
-- INSERT INTO bookings (check_in_date, check_out_date, num_guests) VALUES ('2025-09-05', '2025-09-04', 2); -- Violates check_out_date > check_in_date

-- Part 2: NOT NULL Constraints
CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    email text NOT NULL,
    phone text,
    registration_date date NOT NULL
);

CREATE TABLE inventory (
    item_id SERIAL PRIMARY KEY,
    item_name text NOT NULL,
    quantity integer NOT NULL CHECK (quantity >= 0),
    unit_price numeric NOT NULL CHECK (unit_price > 0),
    last_updated timestamp NOT NULL
);

INSERT INTO customers (email, phone, registration_date) 
    VALUES ('cust1@example.com', '555-0100', '2024-01-15'),
        ('cust2@example.com', NULL, '2024-02-20'),
        ('cust3@example.com', NULL, '2024-03-05');

-- Test
-- INSERT INTO customers (email, phone, registration_date) VALUES (NULL, '555-0001', '2024-03-02');

INSERT INTO inventory (item_name, quantity, unit_price, last_updated) 
    VALUES ('Screwdriver', 50, 5.99, NOW()),
        ('Hammer', 20, 12.50, NOW());

-- Invalid
-- INSERT INTO inventory (item_name, quantity, unit_price, last_updated) VALUES (NULL, 10, 2.00, NOW()); -- Violates NOT NULL
-- INSERT INTO inventory (item_name, quantity, unit_price, last_updated) VALUES ('Nails', -5, 0.10, NOW()); -- Violates CHECK

-- Part 3: UNIQUE Constraints
CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    username text,
    email text,
    created_at timestamp,
    CONSTRAINT unique_username UNIQUE (username),
    CONSTRAINT unique_email UNIQUE (email)
);

CREATE TABLE course_enrollments (
    enrollment_id SERIAL PRIMARY KEY,
    student_id integer,
    course_code text,
    semester text,
    CONSTRAINT uniq_student_course_semester UNIQUE (student_id, course_code, semester)
);

INSERT INTO users (username, email, created_at) 
    VALUES ('alice', 'alice@example.com', NOW()), 
        ('bob', 'bob@example.com', NOW());

-- Test
-- INSERT INTO users (username, email, created_at) VALUES ('alice', 'alice2@example.com', NOW()); -- Duplicate username
-- INSERT INTO users (username, email, created_at) VALUES ('charlie', 'alice@example.com', NOW()); -- Duplicate email

INSERT INTO course_enrollments (student_id, course_code, semester) 
    VALUES (200, 'CS101', '2025-S1'),
        (201, 'CS101', '2025-S1');

-- Test
-- INSERT INTO course_enrollments (student_id, course_code, semester) VALUES (200, 'CS101', '2025-S1'); -- Duplicate combination

-- Part 4: PRIMARY KEY Constraints
CREATE TABLE departments (
    dept_id SERIAL PRIMARY KEY,
    dept_name text NOT NULL,
    location text
);

INSERT INTO departments (dept_name, location) 
    VALUES ('Human Resources', 'Building A'),
        ('Engineering', 'Building B'),
        ('Sales', 'Building C');

-- Test
-- INSERT INTO departments (dept_id, dept_name, location) VALUES (1, 'HR Duplicate', 'Building X'); -- Duplicate dept_id
-- INSERT INTO departments (dept_id, dept_name, location) VALUES (NULL, 'No ID Dept', 'Nowhere'); -- NULL dept_id

CREATE TABLE student_courses (
    student_id integer,
    course_id integer,
    enrollment_date date,
    grade text,
    PRIMARY KEY (student_id, course_id)
);

INSERT INTO student_courses (student_id, course_id, enrollment_date, grade) 
    VALUES (1000, 501, '2024-09-01', 'A'),
        (1001, 502, '2024-09-02', 'B');

-- Test
-- INSERT INTO student_courses (student_id, course_id, enrollment_date, grade) VALUES (1000, 501, '2024-12-01', 'A-'); 

-- Part 5: FOREIGN KEY Constraints
CREATE TABLE employees_dept (
    emp_id SERIAL PRIMARY KEY,
    emp_name text NOT NULL,
    dept_id integer REFERENCES departments(dept_id),
    hire_date date
);

INSERT INTO employees_dept (emp_name, dept_id, hire_date) 
    VALUES ('Mary Major', 1, '2022-05-01'),
        ('John Doe', 2, '2023-01-15');

-- Test
-- INSERT INTO employees_dept (emp_name, dept_id, hire_date) VALUES ('Ghost Worker', 1, '2024-01-01'); -- Existent dept_id
-- INSERT INTO employees_dept (emp_name, dept_id, hire_date) VALUES ('Ghost Worker', 99, '2024-01-01'); -- Non-existent dept_id

CREATE TABLE authors (
    author_id SERIAL PRIMARY KEY,
    author_name text NOT NULL,
    country text
);

CREATE TABLE publishers (
    publisher_id SERIAL PRIMARY KEY,
    publisher_name text NOT NULL,
    city text
);

CREATE TABLE books (
    book_id SERIAL PRIMARY KEY,
    title text NOT NULL,
    author_id integer REFERENCES authors(author_id),
    publisher_id integer REFERENCES publishers(publisher_id),
    publication_year integer,
    isbn text UNIQUE
);

INSERT INTO authors (author_name, country) 
    VALUES ('Jane Austen', 'United Kingdom'), 
        ('Gabriel Garcia Marquez', 'Colombia'), 
        ('Haruki Murakami', 'Japan');

INSERT INTO publishers (publisher_name, city) 
    VALUES ('Penguin Books', 'London'), 
        ('HarperCollins', 'New York'), 
        ('Vintage', 'London');

INSERT INTO books (title, author_id, publisher_id, publication_year, isbn) 
    VALUES ('Pride and Prejudice', 1, 1, 1813, 'ISBN-0001'), 
        ('One Hundred Years of Solitude', 2, 2, 1967, 'ISBN-0002'), 
        ('Norwegian Wood', 3, 3, 1987, 'ISBN-0003');

CREATE TABLE categories (
    category_id SERIAL PRIMARY KEY,
    category_name text NOT NULL
);

CREATE TABLE products_fk (
    product_id SERIAL PRIMARY KEY,
    product_name text NOT NULL,
    category_id integer REFERENCES categories(category_id) ON DELETE RESTRICT
);

CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    order_date date NOT NULL
);

CREATE TABLE order_items (
    item_id SERIAL PRIMARY KEY,
    order_id integer REFERENCES orders(order_id) ON DELETE CASCADE,
    product_id integer REFERENCES products_fk(product_id),
    quantity integer CHECK (quantity > 0)
);

INSERT INTO categories (category_name) VALUES ('Electronics'), ('Books');
INSERT INTO products_fk (product_name, category_id) VALUES ('Smartphone', 1), ('Novel', 2);
INSERT INTO orders (order_date) VALUES ('2025-01-10');
INSERT INTO order_items (order_id, product_id, quantity) VALUES (1, 1, 2), (1, 2, 1);

-- Tests 
-- DELETE FROM categories WHERE category_id = 1; -- Should fail (RESTRICT)
-- DELETE FROM orders WHERE order_id = 1; -- Should delete order_items (CASCADE)

-- Part 6

CREATE TABLE ecommerce_customers (
    customer_id SERIAL PRIMARY KEY,
    name text NOT NULL,
    email text NOT NULL UNIQUE,
    phone text,
    registration_date date NOT NULL
);

CREATE TABLE ecommerce_products (
    product_id SERIAL PRIMARY KEY,
    name text NOT NULL,
    description text,
    price numeric NOT NULL CHECK (price >= 0),
    stock_quantity integer NOT NULL CHECK (stock_quantity >= 0)
);

CREATE TABLE ecommerce_orders (
    order_id SERIAL PRIMARY KEY,
    customer_id integer REFERENCES ecommerce_customers(customer_id) ON DELETE SET NULL,
    order_date date NOT NULL,
    total_amount numeric NOT NULL CHECK (total_amount >= 0),
    status text NOT NULL CHECK (status IN ('pending','processing','shipped','delivered','cancelled'))
);

CREATE TABLE ecommerce_order_details (
    order_detail_id SERIAL PRIMARY KEY,
    order_id integer REFERENCES ecommerce_orders(order_id) ON DELETE CASCADE,
    product_id integer REFERENCES ecommerce_products(product_id),
    quantity integer NOT NULL CHECK (quantity > 0),
    unit_price numeric NOT NULL CHECK (unit_price >= 0)
);

INSERT INTO ecommerce_customers (name, email, phone, registration_date) 
	VALUES ('Alice Shopper', 'alice.shop@example.com', '555-1000', '2024-04-01'),
		('Bob Buyer', 'bob.buyer@example.com', '555-1001', '2024-04-02'),
		('Carol Consumer', 'carol.cons@example.com', NULL, '2024-04-03'),
		('David Deal', 'david.deal@example.com', '555-1003', '2024-04-04'),
		('Eve Ecom', 'eve.ecom@example.com', '555-1004', '2024-04-05');

INSERT INTO ecommerce_products (name, description, price, stock_quantity) 
	VALUES ('Wireless Mouse', 'Ergonomic wireless mouse', 25.50, 100),
			('Mechanical Keyboard', 'Blue switches keyboard', 75.00, 50),
			('USB-C Cable', '1m cable', 5.00, 500),
			('Monitor 24\"', '24-inch 1080p monitor', 150.00, 30),
			('Webcam HD', '720p webcam', 40.00, 20);

INSERT INTO ecommerce_orders (customer_id, order_date, total_amount, status) 
	VALUES (1, '2025-02-01', 56.50, 'pending'), 
			(2, '2025-02-02', 75.00, 'processing'), 
			(3, '2025-02-03', 150.00, 'shipped'), 
			(4, '2025-02-04', 5.00, 'delivered'), 
			(5, '2025-02-05', 40.00, 'cancelled');

INSERT INTO ecommerce_order_details (order_id, product_id, quantity, unit_price) 
	VALUES (1, 1, 2, 25.50),
			(2, 2, 1, 75.00),
			(3, 4, 1, 150.00),
			(4, 3, 1, 5.00),
			(5, 5, 1, 40.00);

-- Tests 
-- INSERT INTO ecommerce_customers (name, email, phone, registration_date) VALUES ('Fake', 'alice.shop@example.com', '000', '2025-01-01'); 
-- INSERT INTO ecommerce_products (name, description, price, stock_quantity) VALUES ('Broken Price', 'bad', -1, 10); 
-- INSERT INTO ecommerce_products (name, description, price, stock_quantity) VALUES ('Negative Stock', 'bad', 10, -5);
-- INSERT INTO ecommerce_orders (customer_id, order_date, total_amount, status) VALUES (1, '2025-03-01', 10, 'in-transit'); 
-- INSERT INTO ecommerce_order_details (order_id, product_id, quantity, unit_price) VALUES (1, 1, 0, 25.50); 

-- DELETE FROM ecommerce_customers WHERE customer_id = 5; 
-- DELETE FROM ecommerce_orders WHERE order_id = 3;


