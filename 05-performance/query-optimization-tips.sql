/*
 * QUERY OPTIMIZATION TIPS
 * =======================
 * Best practices for writing efficient SQL queries
 */

-- ============================================================================
-- 1. Use EXPLAIN ANALYZE to understand query performance
-- ============================================================================
/*
 * Shows actual execution plan and timing
 * Look for:
 * - Seq Scan (table scan) - might need an index
 * - High cost values
 * - Rows estimate vs actual (if very different, run ANALYZE)
 */
EXPLAIN ANALYZE
SELECT o.order_id, u.full_name, SUM(oi.quantity * oi.unit_price) AS total
FROM orders o
JOIN users u ON u.user_id = o.user_id
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.status = 'paid'
GROUP BY o.order_id, u.full_name
ORDER BY total DESC
LIMIT 10;

-- ============================================================================
-- 2. Select only needed columns (not SELECT *)
-- ============================================================================

-- BAD: Fetches all columns, more data transfer
SELECT *
FROM products;

-- GOOD: Explicit columns, only what you need
SELECT product_id, name, unit_price
FROM products;

-- ============================================================================
-- 3. Avoid functions on indexed columns in WHERE
-- ============================================================================

-- BAD: Function on indexed column prevents index use
SELECT *
FROM orders
WHERE EXTRACT(YEAR FROM created_at) = 2024;

-- GOOD: Rewrite to allow index use
SELECT *
FROM orders
WHERE created_at >= '2024-01-01' AND created_at < '2025-01-01';

-- ============================================================================
-- 4. Use EXISTS instead of IN for large subqueries
-- ============================================================================

-- LESS EFFICIENT: IN with subquery
SELECT u.*
FROM users u
WHERE u.user_id IN (
  SELECT DISTINCT o.user_id
  FROM orders o
  WHERE o.status = 'paid'
);

-- MORE EFFICIENT: EXISTS (stops at first match)
SELECT u.*
FROM users u
WHERE EXISTS (
  SELECT 1
  FROM orders o
  WHERE o.user_id = u.user_id AND o.status = 'paid'
);

-- ============================================================================
-- 5. Use LIMIT to restrict results
-- ============================================================================
/*
 * Always use LIMIT for pagination or when you only need a few results
 * Especially important with ORDER BY (can stop sorting early)
 */
SELECT o.order_id, o.created_at
FROM orders o
ORDER BY o.created_at DESC
LIMIT 20;

-- ============================================================================
-- 6. CTEs vs Subqueries: Choose wisely
-- ============================================================================
/*
 * CTEs (WITH clauses):
 * - Better readability
 * - Can be referenced multiple times
 * - In PostgreSQL 12+, optimizer can inline them
 * 
 * Subqueries:
 * - Simpler for one-time use
 * - Sometimes better optimized
 */

-- CTE version (readable, reusable)
WITH high_value_orders AS (
  SELECT order_id, SUM(quantity * unit_price) AS total
  FROM order_items
  GROUP BY order_id
  HAVING SUM(quantity * unit_price) > 100
)
SELECT o.*, h.total
FROM orders o
JOIN high_value_orders h ON h.order_id = o.order_id;

-- ============================================================================
-- 7. Avoid correlated subqueries when possible
-- ============================================================================

-- SLOW: Correlated subquery (runs for each row)
SELECT p.product_id, p.name,
  (SELECT COUNT(*) FROM order_items oi WHERE oi.product_id = p.product_id) AS order_count
FROM products p;

-- FAST: Join with aggregate
SELECT p.product_id, p.name, COALESCE(COUNT(oi.order_id), 0) AS order_count
FROM products p
LEFT JOIN order_items oi ON oi.product_id = p.product_id
GROUP BY p.product_id, p.name;

-- ============================================================================
-- 8. Use appropriate JOIN types
-- ============================================================================

-- If you know all orders have users (foreign key enforced), use INNER JOIN
SELECT o.*, u.full_name
FROM orders o
INNER JOIN users u ON u.user_id = o.user_id;

-- Use LEFT JOIN only when you need to preserve left table rows
SELECT u.*, COUNT(o.order_id) AS order_count
FROM users u
LEFT JOIN orders o ON o.user_id = u.user_id
GROUP BY u.user_id;

-- ============================================================================
-- 9. Filter as early as possible
-- ============================================================================

-- LESS EFFICIENT: Filter after joining everything
SELECT o.order_id, u.full_name
FROM orders o
JOIN users u ON u.user_id = o.user_id
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.status = 'paid' AND o.created_at > now() - interval '7 days';

-- MORE EFFICIENT: Filter orders first (reduces join size)
WITH recent_paid_orders AS (
  SELECT order_id, user_id
  FROM orders
  WHERE status = 'paid' 
    AND created_at > now() - interval '7 days'
)
SELECT o.order_id, u.full_name
FROM recent_paid_orders o
JOIN users u ON u.user_id = o.user_id
JOIN order_items oi ON oi.order_id = o.order_id;

-- ============================================================================
-- 10. Use connection pooling for applications
-- ============================================================================
/*
 * Not a SQL query tip, but critical for performance:
 * - Reuse database connections
 * - Use tools like PgBouncer
 * - Configure appropriate pool size (not too large!)
 */

-- ============================================================================
-- 11. Regular maintenance
-- ============================================================================
/*
 * Keep statistics updated for query planner
 */
ANALYZE orders;
ANALYZE order_items;

-- Check for bloat and rebuild if needed
-- VACUUM FULL orders;  -- Locks table, use with caution
-- Or use pg_repack extension for zero-downtime maintenance

