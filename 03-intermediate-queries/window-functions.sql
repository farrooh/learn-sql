/*
 * WINDOW FUNCTIONS
 * ================
 * Window functions perform calculations across rows related to the current row
 * Unlike GROUP BY, they don't collapse rows - each row retains its identity
 *
 * Key Concepts:
 * - PARTITION BY: Divides rows into groups (like GROUP BY but without collapsing)
 * - ORDER BY: Defines order within each partition
 * - Window functions: ROW_NUMBER, RANK, DENSE_RANK, LAG, LEAD, etc.
 */

-- ============================================================================
-- BASIC SELECT: Without window functions (for comparison)
-- ============================================================================
SELECT
  o.user_id,
  o.order_id,
  o.created_at,
  o.status
FROM orders o
WHERE o.status != 'cart'
ORDER BY o.user_id, o.created_at;

-- ============================================================================
-- ROW_NUMBER: Sequential numbering within each partition
-- ============================================================================
/*
 * Number orders per user chronologically
 * Each user's orders are numbered 1, 2, 3...
 * PARTITION BY restarts numbering for each user
 * Useful for: "Show me each customer's first 3 orders"
 */
SELECT
  o.user_id,
  o.order_id,
  o.created_at,
  o.status,
  ROW_NUMBER() OVER (
    PARTITION BY o.user_id
    ORDER BY o.created_at
  ) AS order_sequence
FROM orders o
WHERE o.status != 'cart'
ORDER BY o.user_id, order_sequence;

-- ============================================================================
-- RANK vs DENSE_RANK: Handling ties
-- ============================================================================
/*
 * Rank orders by total amount within each user
 * RANK: Leaves gaps after ties (1, 2, 2, 4)
 * DENSE_RANK: No gaps (1, 2, 2, 3)
 */
SELECT
  o.user_id,
  o.order_id,
  SUM(oi.quantity * oi.unit_price) AS order_total,
  RANK() OVER (
    PARTITION BY o.user_id 
    ORDER BY SUM(oi.quantity * oi.unit_price) DESC
  ) AS rank_with_gaps,
  DENSE_RANK() OVER (
    PARTITION BY o.user_id 
    ORDER BY SUM(oi.quantity * oi.unit_price) DESC
  ) AS dense_rank
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
GROUP BY o.user_id, o.order_id
ORDER BY o.user_id, order_total DESC;

-- ============================================================================
-- LAG and LEAD: Access previous/next rows
-- ============================================================================
/*
 * Compare each order with the previous one
 * LAG: Access previous row's value
 * LEAD: Access next row's value
 * Useful for: "Time between orders", "Growth compared to last period"
 */
SELECT
  o.user_id,
  o.order_id,
  o.created_at,
  LAG(o.created_at) OVER (
    PARTITION BY o.user_id 
    ORDER BY o.created_at
  ) AS previous_order_date,
  o.created_at - LAG(o.created_at) OVER (
    PARTITION BY o.user_id 
    ORDER BY o.created_at
  ) AS time_since_last_order
FROM orders o
WHERE o.status != 'cart'
ORDER BY o.user_id, o.created_at;

-- ============================================================================
-- Running totals with window frames
-- ============================================================================
/*
 * Calculate cumulative order total per user
 * ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW creates a running sum
 */
WITH order_totals AS (
  SELECT
    o.user_id,
    o.order_id,
    o.created_at,
    SUM(oi.quantity * oi.unit_price) AS order_total
  FROM orders o
  JOIN order_items oi ON oi.order_id = o.order_id
  GROUP BY o.user_id, o.order_id, o.created_at
)
SELECT
  user_id,
  order_id,
  order_total,
  SUM(order_total) OVER (
    PARTITION BY user_id 
    ORDER BY created_at
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
  ) AS running_total
FROM order_totals
ORDER BY user_id, created_at;

