/*
 * GROUPING AND AGGREGATION
 * ========================
 * Demonstrates GROUP BY, aggregate functions, and the difference between
 * row-level and aggregated data.
 *
 * Key Concepts:
 * - Aggregate functions: SUM, COUNT, AVG, MIN, MAX
 * - GROUP BY clause
 * - Difference between aggregated and non-aggregated queries
 */

-- ============================================================================
-- NO GROUPING: Row-level detail
-- ============================================================================
/*
 * Shows every individual order item with its line total
 * Each row represents one product in one order
 * No aggregation - just simple calculation per row
 */
SELECT
  o.order_id,
  p.name AS product,
  oi.quantity,
  oi.unit_price,
  oi.quantity * oi.unit_price AS line_total
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
JOIN products p ON p.product_id = oi.product_id
ORDER BY o.order_id, p.name;

-- ============================================================================
-- GROUPING BY ORDER: Aggregate to order level
-- ============================================================================
/*
 * Calculate total amount for each order
 * GROUP BY order_id collapses multiple items into one row per order
 * SUM() aggregates all line items within each group
 */
SELECT
  o.order_id,
  COUNT(oi.product_id) AS item_count,
  SUM(oi.quantity) AS total_items,
  SUM(oi.quantity * oi.unit_price) AS order_total,
  AVG(oi.unit_price) AS avg_item_price
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
GROUP BY o.order_id
ORDER BY order_total DESC;

-- ============================================================================
-- GROUPING BY MULTIPLE COLUMNS: User and Order
-- ============================================================================
/*
 * Group by both user_id and order_id
 * Useful when you want subtotals at different levels
 * Every column in SELECT must be in GROUP BY or be an aggregate function
 */
SELECT
  u.full_name,
  o.user_id,
  o.order_id,
  o.status,
  COUNT(oi.product_id) AS items_in_order,
  SUM(oi.quantity * oi.unit_price) AS order_total
FROM orders o
JOIN users u ON u.user_id = o.user_id
JOIN order_items oi ON oi.order_id = o.order_id
GROUP BY u.full_name, o.user_id, o.order_id, o.status
ORDER BY o.user_id, o.order_id;

-- ============================================================================
-- HAVING: Filter aggregated results
-- ============================================================================
/*
 * HAVING filters groups after aggregation (WHERE filters before)
 * Find orders with total > $100
 */
SELECT
  o.order_id,
  SUM(oi.quantity * oi.unit_price) AS order_total
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
GROUP BY o.order_id
HAVING SUM(oi.quantity * oi.unit_price) > 100
ORDER BY order_total DESC;

-- ============================================================================
-- GROUPING BY CATEGORY: Product analysis
-- ============================================================================
/*
 * Aggregate at category level to see product distribution
 */
SELECT
  c.name AS category,
  COUNT(p.product_id) AS product_count,
  AVG(p.unit_price) AS avg_price,
  MIN(p.unit_price) AS min_price,
  MAX(p.unit_price) AS max_price
FROM categories c
LEFT JOIN products p ON p.category_id = c.category_id AND p.is_active = true
GROUP BY c.category_id, c.name
ORDER BY product_count DESC;

