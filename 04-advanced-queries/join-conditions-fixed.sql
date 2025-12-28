/*
 * JOIN CONDITIONS AND COMMON MISTAKES
 * ===================================
 * Demonstrates proper JOIN syntax and fixes common errors
 */

-- ============================================================================
-- INCORRECT: Filtering in JOIN condition (from recent-customer-orders-with-totals.sql)
-- ============================================================================
/*
 * PROBLEM in original query:
 * LEFT OUTER JOIN users u ON u.user_id = o.user_id AND u.full_name IS NULL
 * 
 * This join condition is wrong because:
 * 1. It filters users where full_name IS NULL in the JOIN condition
 * 2. This causes the LEFT JOIN to not match any users (they all have names)
 * 3. Result: All user columns show NULL even though users exist
 * 
 * RULE: Join conditions should specify HOW tables relate (foreign keys)
 *       Filtering should be in WHERE clause (or the SELECT itself)
 */

-- WRONG VERSION (from original file):
SELECT
  o.order_id,
  u.email,          -- Will be NULL because join condition filters users
  u.full_name,      -- Will be NULL because join condition filters users
  o.status,
  o.created_at,
  SUM(oi.quantity * oi.unit_price) AS order_total
FROM orders o
LEFT OUTER JOIN users u ON u.user_id = o.user_id AND u.full_name IS NULL  -- WRONG!
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.status IN ('placed','paid','shipped')
GROUP BY o.order_id, u.email, u.full_name, o.status, o.created_at
ORDER BY o.created_at DESC
LIMIT 20;

-- ============================================================================
-- CORRECT VERSION: Proper join with user information
-- ============================================================================
/*
 * FIXED: Join condition only specifies the relationship
 * Any filtering goes in WHERE clause
 */
SELECT
  o.order_id,
  u.email,
  u.full_name,
  o.status,
  o.created_at,
  SUM(oi.quantity * oi.unit_price) AS order_total
FROM orders o
INNER JOIN users u ON u.user_id = o.user_id  -- CORRECT: Only join condition
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.status IN ('placed','paid','shipped')
  -- If you wanted to filter users with no name (unusual): AND u.full_name IS NOT NULL
GROUP BY o.order_id, u.email, u.full_name, o.status, o.created_at
ORDER BY o.created_at DESC
LIMIT 20;

-- ============================================================================
-- JOIN vs WHERE: Understanding the difference
-- ============================================================================

-- Example 1: Additional condition in JOIN (with LEFT JOIN)
/*
 * Get all orders, but only show payment info for captured payments
 * The condition in JOIN affects which payments are joined (not which orders)
 */
SELECT
  o.order_id,
  o.status AS order_status,
  p.status AS payment_status,
  p.amount
FROM orders o
LEFT JOIN payments p 
  ON p.order_id = o.order_id 
  AND p.status = 'captured'  -- This filters payments, not orders
ORDER BY o.order_id;

-- Example 2: Same condition in WHERE (changes meaning!)
/*
 * This filters the RESULT to only show orders with captured payments
 * Orders without captured payments are excluded entirely
 */
SELECT
  o.order_id,
  o.status AS order_status,
  p.status AS payment_status,
  p.amount
FROM orders o
LEFT JOIN payments p ON p.order_id = o.order_id
WHERE p.status = 'captured'  -- This filters the result set
ORDER BY o.order_id;

-- ============================================================================
-- KEY TAKEAWAYS
-- ============================================================================
/*
 * 1. JOIN conditions should describe the RELATIONSHIP between tables
 *    Usually: foreign_key = primary_key
 *
 * 2. WHERE clause filters the RESULT SET
 *
 * 3. With LEFT JOIN:
 *    - Additional conditions in ON affect what gets joined from right table
 *    - Conditions in WHERE filter final results (can turn LEFT JOIN into INNER)
 *
 * 4. With INNER JOIN:
 *    - Additional conditions in ON or WHERE have similar effect
 *    - But ON is clearer for relationships, WHERE for filtering
 */

