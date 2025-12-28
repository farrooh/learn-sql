/*
 * COMMON TABLE EXPRESSIONS (CTEs)
 * ================================
 * CTEs create temporary named result sets that exist only for the query
 * Benefits:
 * - Improved readability (break complex queries into logical steps)
 * - Reusability (reference the same CTE multiple times)
 * - Recursion (advanced: CTEs can reference themselves)
 *
 * Syntax: WITH cte_name AS (query) SELECT ... FROM cte_name
 */

-- ============================================================================
-- BASIC CTE: Calculate order totals, then join with payments
-- ============================================================================
/*
 * Step 1: Calculate order totals in a CTE
 * Step 2: Join CTE with payments table
 * 
 * Why use CTE here?
 * - Separates calculation logic from join logic
 * - More readable than a subquery
 * - Can be referenced multiple times if needed
 */
WITH order_totals AS (
  SELECT
    o.order_id,
    o.user_id,
    o.status,
    SUM(oi.quantity * oi.unit_price) AS total
  FROM orders o
  JOIN order_items oi ON oi.order_id = o.order_id
  GROUP BY o.order_id, o.user_id, o.status
)
SELECT
  ot.order_id,
  ot.status AS order_status,
  ot.total,
  p.status AS payment_status,
  p.provider
FROM order_totals ot
LEFT JOIN payments p ON p.order_id = ot.order_id
ORDER BY ot.total DESC;

-- ============================================================================
-- MULTIPLE CTEs: Chain multiple steps
-- ============================================================================
/*
 * Calculate user statistics across multiple dimensions
 * Multiple CTEs separated by commas (not multiple WITH keywords)
 */
WITH user_orders AS (
  -- First CTE: Get order counts per user
  SELECT
    user_id,
    COUNT(*) AS order_count,
    MAX(created_at) AS last_order_date
  FROM orders
  WHERE status NOT IN ('cart', 'cancelled')
  GROUP BY user_id
),
user_spending AS (
  -- Second CTE: Calculate total spending per user
  SELECT
    o.user_id,
    SUM(oi.quantity * oi.unit_price) AS total_spent
  FROM orders o
  JOIN order_items oi ON oi.order_id = o.order_id
  WHERE o.status NOT IN ('cart', 'cancelled')
  GROUP BY o.user_id
)
-- Final query combines both CTEs
SELECT
  u.full_name,
  u.email,
  COALESCE(uo.order_count, 0) AS total_orders,
  COALESCE(us.total_spent, 0) AS lifetime_value,
  uo.last_order_date,
  -- Calculate average order value
  CASE 
    WHEN COALESCE(uo.order_count, 0) > 0 
    THEN us.total_spent / uo.order_count 
    ELSE 0 
  END AS avg_order_value
FROM users u
LEFT JOIN user_orders uo ON uo.user_id = u.user_id
LEFT JOIN user_spending us ON us.user_id = u.user_id
ORDER BY lifetime_value DESC;

-- ============================================================================
-- CTE WITH WINDOW FUNCTION: Identify high-value customers
-- ============================================================================
/*
 * Use CTE to calculate metrics, then filter on window function results
 * (You can't use window functions in WHERE, so CTE is necessary)
 */
WITH customer_metrics AS (
  SELECT
    u.user_id,
    u.full_name,
    COUNT(o.order_id) AS order_count,
    SUM(oi.quantity * oi.unit_price) AS total_spent,
    -- Rank customers by spending
    DENSE_RANK() OVER (ORDER BY SUM(oi.quantity * oi.unit_price) DESC) AS spending_rank
  FROM users u
  LEFT JOIN orders o ON o.user_id = u.user_id AND o.status NOT IN ('cart', 'cancelled')
  LEFT JOIN order_items oi ON oi.order_id = o.order_id
  GROUP BY u.user_id, u.full_name
)
-- Filter for top 5 customers
SELECT *
FROM customer_metrics
WHERE spending_rank <= 5
ORDER BY spending_rank;

-- ============================================================================
-- RECURSIVE CTE: Category hierarchy (if categories were hierarchical)
-- ============================================================================
/*
 * Recursive CTEs have two parts:
 * 1. Base case (anchor member)
 * 2. Recursive case (recursive member)
 * They're joined with UNION ALL
 *
 * Example: If categories had parent_id for subcategories
 */
-- This is a conceptual example (would need schema modification)
/*
WITH RECURSIVE category_tree AS (
  -- Base case: top-level categories (no parent)
  SELECT 
    category_id,
    name,
    parent_id,
    1 AS level,
    name AS path
  FROM categories
  WHERE parent_id IS NULL
  
  UNION ALL
  
  -- Recursive case: subcategories
  SELECT 
    c.category_id,
    c.name,
    c.parent_id,
    ct.level + 1,
    ct.path || ' > ' || c.name
  FROM categories c
  JOIN category_tree ct ON c.parent_id = ct.category_id
)
SELECT * FROM category_tree ORDER BY path;
*/

