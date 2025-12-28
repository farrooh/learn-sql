/*
 * SQL QUICK REFERENCE GUIDE
 * =========================
 * Fast lookup for common SQL patterns
 */

-- ============================================================================
-- BASIC QUERIES
-- ============================================================================

-- Select all columns
SELECT * FROM table_name;

-- Select specific columns
SELECT col1, col2 FROM table_name;

-- Filter rows
SELECT * FROM table_name WHERE condition;

-- Sort results
SELECT * FROM table_name ORDER BY col1 ASC, col2 DESC;

-- Limit results
SELECT * FROM table_name LIMIT 10 OFFSET 20;

-- ============================================================================
-- JOINS
-- ============================================================================

-- INNER JOIN (only matching rows)
SELECT * FROM table1 t1
INNER JOIN table2 t2 ON t1.id = t2.foreign_id;

-- LEFT JOIN (all from left, matching from right)
SELECT * FROM table1 t1
LEFT JOIN table2 t2 ON t1.id = t2.foreign_id;

-- RIGHT JOIN (all from right, matching from left)
SELECT * FROM table1 t1
RIGHT JOIN table2 t2 ON t1.id = t2.foreign_id;

-- FULL OUTER JOIN (all from both)
SELECT * FROM table1 t1
FULL OUTER JOIN table2 t2 ON t1.id = t2.foreign_id;

-- ============================================================================
-- AGGREGATIONS
-- ============================================================================

-- Common aggregate functions
SELECT 
  COUNT(*) AS total_rows,
  COUNT(DISTINCT col1) AS unique_values,
  SUM(col1) AS total,
  AVG(col1) AS average,
  MIN(col1) AS minimum,
  MAX(col1) AS maximum
FROM table_name;

-- GROUP BY
SELECT category, COUNT(*), AVG(price)
FROM products
GROUP BY category;

-- HAVING (filter after grouping)
SELECT category, AVG(price)
FROM products
GROUP BY category
HAVING AVG(price) > 100;

-- ============================================================================
-- WINDOW FUNCTIONS
-- ============================================================================

-- ROW_NUMBER: Sequential numbering
SELECT *, ROW_NUMBER() OVER (PARTITION BY category ORDER BY price) AS row_num
FROM products;

-- RANK: With gaps for ties
SELECT *, RANK() OVER (ORDER BY score DESC) AS rank
FROM scores;

-- DENSE_RANK: No gaps for ties
SELECT *, DENSE_RANK() OVER (ORDER BY score DESC) AS dense_rank
FROM scores;

-- LAG/LEAD: Previous/next row
SELECT *, 
  LAG(value, 1) OVER (ORDER BY date) AS prev_value,
  LEAD(value, 1) OVER (ORDER BY date) AS next_value
FROM time_series;

-- Running total
SELECT *, 
  SUM(amount) OVER (ORDER BY date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total
FROM transactions;

-- ============================================================================
-- SUBQUERIES
-- ============================================================================

-- Scalar subquery (single value)
SELECT *, (SELECT MAX(price) FROM products) AS max_price
FROM products;

-- IN subquery
SELECT * FROM users
WHERE user_id IN (SELECT user_id FROM orders WHERE status = 'paid');

-- EXISTS subquery
SELECT * FROM users u
WHERE EXISTS (SELECT 1 FROM orders o WHERE o.user_id = u.user_id);

-- ============================================================================
-- CTEs (Common Table Expressions)
-- ============================================================================

-- Single CTE
WITH high_value AS (
  SELECT * FROM orders WHERE total > 1000
)
SELECT * FROM high_value WHERE status = 'paid';

-- Multiple CTEs
WITH 
  cte1 AS (SELECT ...),
  cte2 AS (SELECT ...)
SELECT * FROM cte1 JOIN cte2 ON ...;

-- ============================================================================
-- INSERT
-- ============================================================================

-- Insert single row
INSERT INTO table_name (col1, col2) VALUES (val1, val2);

-- Insert multiple rows
INSERT INTO table_name (col1, col2) VALUES 
  (val1, val2),
  (val3, val4);

-- Insert from SELECT
INSERT INTO table_name (col1, col2)
SELECT col1, col2 FROM other_table WHERE condition;

-- Insert with RETURNING
INSERT INTO table_name (col1) VALUES (val1) RETURNING *;

-- ============================================================================
-- UPDATE
-- ============================================================================

-- Basic update
UPDATE table_name SET col1 = val1 WHERE condition;

-- Update with calculation
UPDATE products SET price = price * 1.1 WHERE category = 'Electronics';

-- Update from another table
UPDATE table1 t1
SET col1 = t2.col2
FROM table2 t2
WHERE t1.id = t2.foreign_id;

-- Update with RETURNING
UPDATE table_name SET col1 = val1 WHERE condition RETURNING *;

-- ============================================================================
-- DELETE
-- ============================================================================

-- Delete rows
DELETE FROM table_name WHERE condition;

-- Delete with RETURNING
DELETE FROM table_name WHERE condition RETURNING *;

-- Soft delete (preferred)
UPDATE table_name SET is_active = false WHERE condition;

-- ============================================================================
-- TRANSACTIONS
-- ============================================================================

-- Basic transaction
BEGIN;
  -- your queries here
COMMIT;

-- Transaction with rollback
BEGIN;
  -- queries
  -- if error:
ROLLBACK;

-- Savepoints
BEGIN;
  INSERT INTO ...;
  SAVEPOINT my_savepoint;
  UPDATE ...;
  ROLLBACK TO SAVEPOINT my_savepoint;
COMMIT;

-- ============================================================================
-- INDEXES
-- ============================================================================

-- Simple index
CREATE INDEX idx_name ON table_name(column_name);

-- Composite index
CREATE INDEX idx_name ON table_name(col1, col2);

-- Unique index
CREATE UNIQUE INDEX idx_name ON table_name(column_name);

-- Partial index
CREATE INDEX idx_name ON table_name(column_name) WHERE condition;

-- Drop index
DROP INDEX idx_name;

-- ============================================================================
-- USEFUL FUNCTIONS
-- ============================================================================

-- String functions
CONCAT(str1, str2)
UPPER(str), LOWER(str)
LENGTH(str)
SUBSTRING(str, start, length)
TRIM(str), LTRIM(str), RTRIM(str)

-- Date functions
NOW(), CURRENT_DATE, CURRENT_TIMESTAMP
DATE_TRUNC('day', timestamp)
EXTRACT(YEAR FROM date)
AGE(timestamp1, timestamp2)
date + INTERVAL '1 day'

-- Numeric functions
ROUND(num, decimals)
CEIL(num), FLOOR(num)
ABS(num)
RANDOM()

-- Conditional
CASE 
  WHEN condition1 THEN result1
  WHEN condition2 THEN result2
  ELSE default_result
END

COALESCE(val1, val2, val3)  -- First non-null value
NULLIF(val1, val2)           -- NULL if equal

-- ============================================================================
-- CONSTRAINTS
-- ============================================================================

-- Primary key
CREATE TABLE table_name (
  id SERIAL PRIMARY KEY
);

-- Foreign key
CREATE TABLE orders (
  user_id INTEGER REFERENCES users(id) ON DELETE CASCADE
);

-- Unique constraint
CREATE TABLE users (
  email TEXT UNIQUE
);

-- Check constraint
CREATE TABLE products (
  price NUMERIC CHECK (price >= 0)
);

-- Not null
CREATE TABLE users (
  email TEXT NOT NULL
);

-- ============================================================================
-- PERFORMANCE
-- ============================================================================

-- Analyze query performance
EXPLAIN ANALYZE SELECT ...;

-- Update statistics
ANALYZE table_name;

-- Vacuum (cleanup)
VACUUM table_name;

-- ============================================================================
-- USEFUL QUERIES
-- ============================================================================

-- Find duplicate rows
SELECT col1, COUNT(*)
FROM table_name
GROUP BY col1
HAVING COUNT(*) > 1;

-- Top N per group
WITH ranked AS (
  SELECT *, ROW_NUMBER() OVER (PARTITION BY category ORDER BY price DESC) AS rn
  FROM products
)
SELECT * FROM ranked WHERE rn <= 3;

-- Running difference
SELECT *,
  value - LAG(value) OVER (ORDER BY date) AS change
FROM metrics;

-- Cumulative percentage
SELECT *,
  SUM(amount) OVER (ORDER BY date) / SUM(amount) OVER () * 100 AS cumulative_pct
FROM sales;

