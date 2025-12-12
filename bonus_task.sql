CREATE TABLE customers(
    customer_id INT PRIMARY KEY,
    iin CHAR(12) UNIQUE,
    full_name TEXT,
    phone TEXT,
    email TEXT,
    status TEXT NOT NULL DEFAULT 'Active',
    created_at TIMESTAMPTZ,
    daily_limit_kzt NUMERIC(20,2) DEFAULT
);

CREATE TABLE accounts(
    account_id INT PRIMARY KEY,
    customer_id INT REFERENCES customers(customer_id),
    account_number TEXT UNIQUE NOT NULL,
    currency CHAR(3) NOT NULL CHECK (currency IN ('kzt', 'usd', 'rub', 'eur')),
    balance NUMERIC (20,2) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    opened_at TIMESTAMPTZ,
    closed_at TIMESTAMPTZ
);

CREATE TABLE transactions(
    transaction_id INT PRIMARY KEY,
    from_account_id INT REFERENCES accounts(account_id),
    to_account_id INT REFERENCES accounts(account_id),
    amount NUMERIC(20,2),
    currency CHAR(3),
    exchange_rate NUMERIC(30,10),
    amount_kzt  NUMERIC(20,2),
    type TEXT CHECK (type IN ('transfer','deposit','withdrawal')),
    status TEXT CHECK (status IN ('pending','completed','failed','reversed')),
    created_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,
    description TEXT
);

CREATE TABLE exchange_rates(
    rate_id INT PRIMARY KEY,
    from_currency CHAR(3),
    to_currency CHAR(3),
    rate NUMERIC(30,10),
    valid_from TIMESTAMPTZ,
    valid_to TIMESTAMPTZ
);

CREATE TABLE audit_log(
    log_id INT PRIMARY KEY,
    table_name TEXT,
    record_id INT,
    action TEXT CHECK(action in ('INSERT','UPDATE','DELETE')),
    old_values JSONB,
    new_values JSONB,
    changed_by TEXT,
    changed_at TIMESTAMPTZ,
    ip_address TEXT
);

INSERT INTO customers(customer_id, iin, full_name, phone, email, status, created_at, daily_limit_kzt)
VALUES
(1, '870101123456', 'Mergen Nurtaza ', '+77001234567', 'Mergen@example.com', 'active', NOW(), 5000000),
(2, '900202234567', 'Olga Nurtazina', '+77019876543', 'Olga@example.com', 'active', NOW(), 2000000),
(3, '820303345678', 'Aldiyar Nurtaza', '+77001239876', 'Kamilla@example.com', 'blocked', NOW(), 1000000),
(4, '950404456789', 'Kamilla Nurtazina', '+77007778888', 'Aldiyar@example.com', 'active', NOW(), 3000000),
(5, '880505567890', 'Aigul Kakharman', '+77005556666', 'Aigul@example.com', 'frozen', NOW(), 1000000),
(6, '910606678901', 'Meiram Nurtazin', '+77004445555', 'Meiram@example.com', 'active', NOW(), 1500000),
(7, '930707789012', 'Akezhan Nurtazin', '+77003334444', 'Arlan@example.com', 'active', NOW(), 2500000),
(8, '860808890123', 'Arlan Shaimukhamet', '+77002223333', 'Akezhan@example.com', 'active', NOW(), 4000000),
(9, '940909901234', 'Saltanal Dulat', '+77001112222', 'Saltanal@example.com', 'active', NOW(), 3500000),
(10, '980101012345', 'Samat Dulatov', '+77009990000', 'Samat@example.com', 'active', NOW(), 6000000);

INSERT INTO accounts(account_id, customer_id, account_number, currency, balance, is_active, opened_at, closed_at)
VALUES
(1, 1, 'ACC100001', 'kzt', 500000.00, TRUE, NOW(), NULL),
(2, 2, 'ACC100002', 'usd', 12000.50, TRUE, NOW(), NULL),
(3, 3, 'ACC100003', 'kzt', 30000.00, FALSE, NOW() - INTERVAL '200 days', NOW() - INTERVAL '10 days'),
(4, 4, 'ACC100004', 'eur', 1500.25, TRUE, NOW(), NULL),
(5, 5, 'ACC100005', 'rub', 90000.00, TRUE, NOW(), NULL),
(6, 6, 'ACC100006', 'kzt', 750000.00, TRUE, NOW(), NULL),
(7, 7, 'ACC100007', 'usd', 3000.00, TRUE, NOW(), NULL),
(8, 8, 'ACC100008', 'eur', 2200.00, TRUE, NOW(), NULL),
(9, 9, 'ACC100009', 'kzt', 180000.00, TRUE, NOW(), NULL),
(10, 10, 'ACC100010', 'rub', 50000.50, TRUE, NOW(), NULL);

INSERT INTO transactions(
    transaction_id, from_account_id, to_account_id, amount, currency,
    exchange_rate, amount_kzt, type, status, created_at, completed_at, description
)
VALUES
(1, 1, 2, 100000.00, 'kzt', 1.0000000000, 100000.00, 'transfer', 'completed', NOW(), NOW(), 'Transfer KZT to USD account'),
(2, NULL, 1, 50000.00, 'kzt', 1.0000000000, 50000.00, 'deposit', 'completed', NOW(), NOW(), 'Cash deposit'),
(3, 2, NULL, 200.00, 'usd', 470.0000000000, 94000.00, 'withdrawal', 'completed', NOW(), NOW(), 'ATM withdrawal'),
(4, 4, 5, 300.00, 'eur', 520.0000000000, 156000.00, 'transfer', 'pending', NOW(), NULL, 'Pending EUR transfer'),
(5, 7, 1, 100.00, 'usd', 470.0000000000, 47000.00, 'transfer', 'completed', NOW(), NOW(), 'USD to KZT'),
(6, NULL, 8, 2000.00, 'eur', 520.0000000000, 1040000.00, 'deposit', 'completed', NOW(), NOW(), 'EUR deposit'),
(7, 3, NULL, 15000.00, 'kzt', 1.0000000000, 15000.00, 'withdrawal', 'failed', NOW(), NULL, 'Insufficient funds'),
(8, 9, 10, 5000.00, 'kzt', 1.0000000000, 5000.00, 'transfer', 'completed', NOW(), NOW(), 'Payment'),
(9, NULL, 6, 300000.00, 'kzt', 1.0000000000, 300000.00, 'deposit', 'completed', NOW(), NOW(), 'Salary'),
(10, 5, 4, 10000.00, 'rub', 6.0000000000, 60000.00, 'transfer', 'reversed', NOW(), NOW(), 'Reversed RUB transfer');

INSERT INTO exchange_rates(rate_id, from_currency, to_currency, rate, valid_from, valid_to)
VALUES
(1, 'usd', 'kzt', 470.0000000000, NOW() - INTERVAL '10 days', NOW() + INTERVAL '20 days'),
(2, 'eur', 'kzt', 520.0000000000, NOW() - INTERVAL '10 days', NOW() + INTERVAL '20 days'),
(3, 'rub', 'kzt', 6.0000000000, NOW() - INTERVAL '10 days', NOW() + INTERVAL '20 days'),
(4, 'kzt', 'usd', 0.0021276596, NOW() - INTERVAL '10 days', NOW() + INTERVAL '20 days'),
(5, 'kzt', 'eur', 0.0019230769, NOW() - INTERVAL '10 days', NOW() + INTERVAL '20 days'),
(6, 'kzt', 'rub', 0.1666666667, NOW() - INTERVAL '10 days', NOW() + INTERVAL '20 days');

INSERT INTO audit_log(
    log_id, table_name, record_id, action, old_values, new_value, changed_by, changed_at, ip_address
)
VALUES
(1, 'customers', 1, 'INSERT', NULL, '{"full_name": " Saltanat Dulat"}', 'system', NOW(), '192.168.0.10'),
(2, 'accounts', 1, 'INSERT', NULL, '{"balance": 500000.00}', 'system', NOW(), '192.168.0.10'),
(3, 'transactions', 1, 'INSERT', NULL, '{"amount": 100000.00}', 'system', NOW(), '192.168.0.10'),
(4, 'accounts', 3, 'UPDATE', '{"is_active": true}', '{"is_active": false}', 'admin', NOW(), '192.168.0.15'),
(5, 'transactions', 7, 'UPDATE', '{"status": "pending"}', '{"status": "failed"}', 'system', NOW(), '192.168.0.20'),
(6, 'customers', 5, 'UPDATE', '{"status": "active"}', '{"status": "frozen"}', 'admin', NOW(), '192.168.0.30'),
(7, 'accounts', 10, 'INSERT', NULL, '{"currency": "rub"}', 'system', NOW(), '192.168.0.40'),
(8, 'transactions', 4, 'INSERT', NULL, '{"type": "transfer"}', 'system', NOW(), '192.168.0.50'),
(9, 'exchange_rates', 1, 'UPDATE', '{"rate": 465}', '{"rate": 470}', 'admin', NOW(), '192.168.0.60'),
(10, 'customers', 3, 'UPDATE', '{"status": "active"}', '{"status": "blocked"}', 'system', NOW(), '192.168.0.70');

CREATE PROCEDURE process_transfer(
    p_from_account_number TEXT,
    p_to_account_number TEXT,
    p_amount NUMERIC(20,2),
    p_currency CHAR(3),
    p_description TEXT
);
language plpgsql
AS $$
DECLARE 
    v_from_id INT;
    v_to_id   INT;
    v_from_customer INT;
    v_to_customer   INT;
    v_from_balance NUMERIC(20,2);
    v_from_status TEXT;
    v_daily_limit NUMERIC(20,2);
    v_today_total NUMERIC(20,2);
    v_exchange NUMERIC(30,10);
    v_amount_kzt NUMERIC(20,2);
    
BEGIN
    SELECT account_id, customer_id, balance
    INTO v_from_id, v_from_customer, v_from_balance
    FROM accounts
    WHERE account_number = p_from_account_number
    FOR UPDATE;

    IF v_from_id IS NULL THEN
        RAISE EXCEPTION 'Error, Source account not found';
    END IF;

    SELECT account_id, customer_id
    INTO v_to_id, v_to_customer
    FROM accounts WHERE account_number = p_to_account_number
    FOR UPDATE;

    IF v_to_id IS NULL THEN
        RAISE EXCEPTION 'Error, Target account not found';
    END IF;

    SELECT status, daily_limit_kzt
    INTO v_from_status, v_daily_limit
    FROM customers
    WHERE customer_id = v_from_customer;

    IF v_from_status <> 'active' THEN
        RAISE EXCEPTION 'Error, Sender customer is not active (status=%)', v_from_status;
    END IF;

    IF v_from_balance < p_amount THEN
        RAISE EXCEPTION 'Error, Insufficient balance';
    END IF;

    SELECT COALESCE(SUM(amount_kzt), 0)
    INTO v_today_total
    FROM transactions
    WHERE from_account_id = v_from_id
    AND created_at::date = CURRENT_DATE;

    IF p_currency = 'kzt' THEN
        v_amount_kzt := p_amount;
    ELSE
        SELECT rate INTO v_exchange
        FROM exchange_rates
        WHERE from_currency = p_currency AND to_currency = 'kzt'
        ORDER BY valid_from DESC
        LIMIT 1;

        IF v_exchange IS NULL THEN
            RAISE EXCEPTION 'Error, No exchange rate for kzt', p_currency;
        END IF;

        v_amount_kzt := p_amount * v_exchange;
    END IF;

    IF v_today_total + v_amount_kzt > v_daily_limit THEN
        RAISE EXCEPTION 'Error, Daily limit exceeded';
    END IF;

    SAVEPOINT sp_before_updates;

    BEGIN
        UPDATE accounts
        SET balance = balance - p_amount
        WHERE account_id = v_from_id;
        IF p_currency = 'kzt' THEN
            UPDATE accounts SET balance = balance + p_amount WHERE account_id = v_to_id;
        ELSE
            SELECT rate INTO v_exchange
            FROM exchange_rates
            WHERE from_currency = p_currency AND to_currency = (
                SELECT currency FROM accounts WHERE account_id = v_to_id
            )
            LIMIT 1;
            IF v_exchange IS NULL THEN
                RAISE EXCEPTION 'Error, Cannot convert to target currency', p_currency;
            END IF;
            UPDATE accounts
            SET balance = balance + (p_amount * v_exchange)
            WHERE account_id = v_to_id;
        END IF;
    EXCEPTION WHEN OTHERS THEN
        ROLLBACK TO SAVEPOINT sp_before_updates;
        RAISE EXCEPTION 'Error, Failed to update balances';
    END;

    INSERT INTO transactions(
        transaction_id,
        from_account_id,
        to_account_id,
        amount,
        currency,
        exchange_rate,
        amount_kzt,
        type,
        status,
        created_at,
        completed_at,
        description
    )
    VALUES(
        (SELECT COALESCE(MAX(transaction_id),0)+1 FROM transactions),
        v_from_id,
        v_to_id,
        p_amount,
        p_currency,
        COALESCE(v_exchange,1),
        v_amount_kzt,
        'transfer',
        'completed',
        NOW(),
        NOW(),
        p_description
    );

    INSERT INTO audit_log(
        log_id, table_name, record_id, action, old_values, new_value, changed_by, changed_at, ip_address
    )
    VALUES(
        (SELECT COALESCE(MAX(log_id),0)+1 FROM audit_log),
        'transactions',
        (SELECT MAX(transaction_id) FROM transactions),
        'INSERT',
        NULL,
        jsonb_build_object('amount', p_amount, 'from', p_from_account, 'to', p_to_account),
        'procedure',
        NOW(),
        '127.0.0.1'
    );
END;
$$;

CREATE VIEW customer_balance_summary AS
WITH account_in_kzt AS (
    SELECT 
        a.account_id,
        a.customer_id,
        a.balance,
        a.currency,
        CASE 
            WHEN a.currency = 'kzt' THEN a.balance
            ELSE a.balance * er.rate
        END AS balance_kzt
    FROM accounts a
    LEFT JOIN LATERAL (
        SELECT rate
        FROM exchange_rates
        WHERE from_currency = a.currency AND to_currency = 'kzt'
        ORDER BY valid_from DESC
        LIMIT 1
    ) er ON TRUE
)
SELECT 
    c.customer_id,
    c.full_name,
    a.account_id,
    a.balance,
    a.currency,
    a.balance_kzt,
    c.daily_limit_kzt,
    ROUND(SUM(a.balance_kzt) OVER (PARTITION BY c.customer_id) / c.daily_limit_kzt * 100, 2) AS daily_limit_utilization,
    RANK() OVER (ORDER BY SUM(a.balance_kzt) OVER (PARTITION BY c.customer_id) DESC) AS customer_rank
FROM customers c
JOIN account_in_kzt a ON c.customer_id = a.customer_id;

CREATE VIEW daily_transaction_report AS
WITH daily_stats AS (
    SELECT 
        DATE(created_at) AS tx_date,
        type,
        COUNT(*) AS tx_count,
        SUM(amount_kzt) AS total_amount_kzt,
        AVG(amount_kzt) AS avg_amount_kzt
    FROM transactions
    GROUP BY DATE(created_at), type
)
SELECT 
    tx_date,
    type,
    tx_count,
    total_amount_kzt,
    avg_amount_kzt,
    SUM(total_amount_kzt) OVER (PARTITION BY type ORDER BY tx_date) AS running_total,
    LAG(total_amount_kzt) OVER (PARTITION BY type ORDER BY tx_date) AS prev_total,
    ROUND((total_amount_kzt - LAG(total_amount_kzt) OVER (PARTITION BY type ORDER BY tx_date)) / NULLIF(LAG(total_amount_kzt) OVER (PARTITION BY type ORDER BY tx_date),0) * 100, 2) AS day_over_day_growth_pct
FROM daily_stats
ORDER BY tx_date, type;

CREATE VIEW suspicious_activity_view
WITH (security_barrier = true) AS
WITH flagged_large AS (
    SELECT 
        t.transaction_id,
        t.from_account_id,
        t.amount_kzt,
        t.created_at
    FROM transactions t
    WHERE t.amount_kzt > 5000000
),
frequent_transactions AS (
    SELECT 
        from_account_id,
        DATE_TRUNC('hour', created_at) AS hour_slot,
        COUNT(*) AS tx_count
    FROM transactions
    GROUP BY from_account_id, DATE_TRUNC('hour', created_at)
    HAVING COUNT(*) > 10
),
rapid_sequential AS (
    SELECT 
        t1.from_account_id,
        t1.transaction_id AS first_tx,
        t2.transaction_id AS next_tx,
        EXTRACT(EPOCH FROM (t2.created_at - t1.created_at)) AS seconds_diff
    FROM transactions t1
    JOIN transactions t2 ON t1.from_account_id = t2.from_account_id AND t2.created_at > t1.created_at
)
SELECT 
    fl.transaction_id,
    fl.from_account_id,
    fl.amount_kzt,
    ft.tx_count AS tx_count_in_hour,
    rs.first_tx,
    rs.next_tx,
    rs.seconds_diff
FROM flagged_large fl
LEFT JOIN frequent_transactions ft ON fl.from_account_id = ft.from_account_id
LEFT JOIN rapid_sequential rs ON fl.from_account_id = rs.from_account_id AND rs.seconds_diff < 60;

CREATE INDEX idx_customers_iin ON customers(iin);

CREATE INDEX idx_accounts_number_hash ON accounts USING HASH(account_number);

CREATE INDEX idx_transactions_from_status ON transactions(from_account_id, status);

CREATE INDEX idx_accounts_active ON accounts(account_id) WHERE is_active = TRUE;

CREATE INDEX idx_customers_email_lower ON customers(LOWER(email));

CREATE INDEX idx_audit_log_jsonb ON audit_log USING GIN(new_value);

EXPLAIN ANALYZE SELECT * FROM customers WHERE iin = '870101123456';
EXPLAIN ANALYZE SELECT * FROM accounts WHERE account_number = 'ACC100001';
EXPLAIN ANALYZE SELECT * FROM transactions WHERE from_account_id = 1 AND status='completed';
EXPLAIN ANALYZE SELECT * FROM accounts WHERE is_active = TRUE;
EXPLAIN ANALYZE SELECT * FROM customers WHERE LOWER(email)='Saltanat@example.com';
EXPLAIN ANALYZE SELECT * FROM audit_log WHERE new_value @> '{"amount":100000}';

CREATE OR REPLACE PROCEDURE process_salary_batch(
    IN p_company_account_number TEXT,
    IN p_payments JSONB,
    OUT successful_count INT,
    OUT failed_count INT,
    OUT failed_details JSONB
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_company_account_id INT;
    v_company_balance NUMERIC(20,2);
    v_total NUMERIC(20,2) := 0;
    v_elem JSONB;
    v_iin TEXT;
    v_amount NUMERIC(20,2);
    v_desc TEXT;
    v_cust_id INT;
    v_target_account_id INT;
    v_batch_id UUID := uuid_generate_v4();
BEGIN
    successful_count := 0;
    failed_count := 0;
    failed_details := '[]'::jsonb;

    PERFORM pg_advisory_xact_lock(hashtext(p_company_account_number));

    SELECT account_id, balance
    INTO v_company_account_id, v_company_balance
    FROM accounts
    WHERE account_number = p_company_account_number
    FOR UPDATE;

    FOR v_elem IN SELECT * FROM jsonb_array_elements(p_payments) LOOP
        v_total := v_total + ((v_elem->>'amount')::numeric);
    END LOOP;

    IF v_company_balance < v_total THEN
        failed_details := jsonb_build_array(
            jsonb_build_object('reason','insufficient_company_funds','needed',v_total,'available',v_company_balance)
        );
        failed_count := jsonb_array_length(failed_details);
        RETURN;
    END IF;

    CREATE TEMP TABLE tmp_batch_changes(account_id INT PRIMARY KEY, amount NUMERIC(20,2));
    CREATE TEMP TABLE tmp_batch_payments(account_id INT, amount NUMERIC(20,2), description TEXT, iin TEXT);

    FOR v_elem IN SELECT * FROM jsonb_array_elements(p_payments) LOOP
        v_iin := v_elem->>'iin';
        v_amount := (v_elem->>'amount')::numeric;
        v_desc := COALESCE(v_elem->>'description','salary');

        SAVEPOINT sp;

        BEGIN
            SELECT customer_id INTO v_cust_id FROM customers WHERE iin = v_iin;
            SELECT account_id
            INTO v_target_account_id
            FROM accounts
            WHERE customer_id = v_cust_id AND currency = 'KZT' AND is_active = true
            LIMIT 1
            FOR UPDATE;

            IF v_target_account_id IS NULL THEN
                SELECT account_id
                INTO v_target_account_id
                FROM accounts
                WHERE customer_id = v_cust_id AND is_active = true
                LIMIT 1
                FOR UPDATE;
            END IF;

            INSERT INTO tmp_batch_changes(account_id, amount)
            VALUES (v_target_account_id, v_amount)
            ON CONFLICT (account_id)
            DO UPDATE SET amount = tmp_batch_changes.amount + EXCLUDED.amount;

            INSERT INTO tmp_batch_payments(account_id, amount, description, iin)
            VALUES (v_target_account_id, v_amount, v_desc, v_iin);

            successful_count := successful_count + 1;
            RELEASE SAVEPOINT sp;

        EXCEPTION WHEN OTHERS THEN
            ROLLBACK TO SAVEPOINT sp;
            failed_details := failed_details || jsonb_build_object(
                'iin', v_iin,
                'amount', v_amount,
                'reason', SQLERRM
            );
            failed_count := failed_count + 1;
        END;
    END LOOP;

    UPDATE accounts
    SET balance = balance - v_total
    WHERE account_id = v_company_account_id;
    UPDATE accounts a
    SET balance = a.balance + c.amount
    FROM tmp_batch_changes c
    WHERE a.account_id = c.account_id;

    INSERT INTO salary_batch_runs(
        batch_id, company_account_id, company_account_number,
        total_amount, successful_count, failed_count, failed_details, created_at
    )
    VALUES (
        v_batch_id, v_company_account_id, p_company_account_number,
        v_total, successful_count, failed_count, failed_details, now()
    );
END;
$$;


--ALL TEST CASES

-- Success on transfer
CALL process_transfer('ACC100002','ACC100004',10000,'kzt','Test');

-- Fail on transfer 
CALL process_transfer('ACC100011','ACC100013',999999999,'kzt','Fail test');

-- salart batch Successful
CALL process_salary_batch('ACC100003', '[{"iin":"870101123456","amount":100000}]');

-- salary batch  Failure
CALL process_salary_batch('ACC1000010', '[{"iin":"wrong","amount":50000}]');

--  design (decisions):

--  hash index on account_number to speed up exact-match lookups
--  partial index on active accounts to accelerate frequent filtering
--  GIN index on the JSONB column audit_log for efficient @> queries
--  materialized view for salary reports since the data is large and rarely refreshed
--  advisory locks in salary batch processing to avoid concurrent batch payments

/*
concurrent transactions example:
session 1:
BEGIN;
SELECT balance FROM accounts WHERE account_id = 1 FOR UPDATE;
-- session holds lock on the row

session 2:
BEGIN;
SELECT balance FROM accounts WHERE account_id = 1 FOR UPDATE;
-- session 2 waits for the lock to be released by

session 1:
UPDATE accounts SET balance = balance - 10000 WHERE account_id = 1;
COMMIT;

session 2:
-- now session 2 can proceed
SELECT balance;
COMMIT;
*/
