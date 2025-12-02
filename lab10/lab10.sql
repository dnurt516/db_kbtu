CREATE TABLE accounts (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    balance DECIMAL(10, 2) DEFAULT 0.00
);

CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    shop VARCHAR(100) NOT NULL,
    product VARCHAR(100) NOT NULL,
    price DECIMAL(10, 2) NOT NULL
);

INSERT INTO accounts (name, balance) VALUES
('Alice', 1000.00),
('Bob', 500.00),
('Wally', 750.00);

INSERT INTO products (shop, product, price) VALUES
('Joe''s Shop', 'Coke', 2.50),
('Joe''s Shop', 'Pepsi', 3.00);

-- 3.2
BEGIN; 

UPDATE accounts SET balance = balance - 100.00
    WHERE name = 'Alice';
UPDATE accounts SET balance = balance + 100.00
    WHERE name = 'Bob';

COMMIT;

-- 1) Alice: 900.00, Bob: 600.00
-- 2) If smth gone wrong, none of the changes gonna be applied
-- 3) Alice's balance gonna decrease, while Bob's might not increase, it causes inconsistent data



 -- 3.3 
BEGIN;

UPDATE accounts SET balance = balance - 500.00
WHERE name = 'Alice';

SELECT * FROM accounts WHERE name = 'Alice';

-- Oops! Wrong amount, let's undo
ROLLBACK;

SELECT * FROM accounts WHERE name = 'Alice';

-- a) 400.00
-- b) 900.00
-- c) Use ROLLBACK when a mistake occurs or condition fails, example: wrong transfer amount

-- 3.4 
BEGIN;

UPDATE accounts SET balance = balance - 100.00
WHERE name = 'Alice';

SAVEPOINT my_savepoint;

UPDATE accounts SET balance = balance + 100.00
WHERE name = 'Bob';

-- Oops, should transfer to Wally instead
ROLLBACK TO my_savepoint;

UPDATE accounts SET balance = balance + 100.00
WHERE name = 'Wally';

COMMIT;

-- a) Alice: 800.00, Bob: 500.00, Wally: 850.00
-- b) Bob was never credited in the final state because the update was rolled back
-- c) SAVEPOINT allows partial rollback without starting a new transaction


-- 3.5 
-- scenario A: READ COMMITTED
-- scenario B: SERIALIZABLE
-- a) scenario A: sees old data first, then new data after commit
-- b) scenario B: sees only old data, must restart if conflict occurs
-- c) READ COMMITTED allows non repeatable reads, SERIALIZABLE prevents them


-- 3.6 
-- a) Terminal 1 doesnt see new product
-- b) Phantom read - a new row appears in repeated query within the same transaction
-- c) SERIALIZABLE isolation level prevents phantom reads

-- 3.7 
-- a) Terminal 1 sees 99.99 temporarily, but it might be rolled back
-- b) Because it is reading uncommitted data from another transaction
-- c) READ UNCOMMITTED should be avoided because it can read inconsistent data


-- 4
BEGIN;

UPDATE accounts SET balance = balance - 200
WHERE name = 'Bob' AND balance >= 200;

UPDATE accounts SET balance = balance + 200
WHERE name = 'Wally' AND EXISTS (
    SELECT 1 FROM accounts WHERE name = 'Bob' AND balance >= 0
);

COMMIT;

-- 2
BEGIN;

INSERT INTO products (shop, product, price)
VALUES ('New Shop', 'Water', 1.50);

SAVEPOINT sp1;

UPDATE products SET price = 2.00 WHERE product = 'Water';

SAVEPOINT sp2;

DELETE FROM products WHERE product = 'Water';

ROLLBACK TO sp1;

COMMIT;
-- Final state: product 'Water' exists with price 2.00

-- 3
-- session 1: BEGIN; SELECT balance; UPDATE balance = balance - amount; COMMIT;
-- session 2: same steps
-- Different isolation levels (READ COMMITTED vs SERIALIZABLE) affect conflicts:
-- SERIALIZABLE prevents overdrawing by blocking conflicting transactions

-- 4: MAX < MIN problem
-- Without transactions:
-- Sally reads MAX(price) before Joe inserts new cheap product, then reads MIN(price)
-- Can get MAX < MIN temporarily
-- Using transactions with proper isolation prevents this inconsistency
