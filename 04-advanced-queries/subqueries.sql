/*
 * SUBQUERIES
 * ==========
 * A query nested inside another query
 * Types:
 * - Scalar subquery: Returns single value (can use in SELECT, WHERE)
 * - Row subquery: Returns single row
 * - Table subquery: Returns multiple rows (use with IN, EXISTS, ANY, ALL)
 * - Correlated subquery: References outer query (executes for each row)
 */

-- ============================================================================
-- SCALAR SUBQUERY: Single value in SELECT clause
-- ============================================================================
/*
 * Get each order with the user's total order count
 * Subquery executes once per row (correlated)
 */
SELECT
  o.order_id,
  o.user_id,
  o.status,
  (
    SELECT COUNT(*)
    FROM orders o2
    WHERE o2.user_id = o.user_id
    AND o2.status NOT IN ('cart', 'cancelled')
  ) AS user_total_orders
FROM orders o
WHERE o.status NOT IN ('cart', 'cancelled')
ORDER BY o.user_id, o.order_id;

-- ============================================================================
-- TABLE SUBQUERY with IN: Filter by set membership
-- ============================================================================
/*
 * Find users who have placed orders over $100
 * Subquery returns a set of user_ids
 */
SELECT
  u.user_id,
  u.full_name,
  u.email
FROM users u
WHERE u.user_id IN (
  SELECT o.user_id
  FROM orders o
  JOIN order_items oi ON oi.order_id = o.order_id
  GROUP BY o.user_id, o.order_id
  HAVING SUM(oi.quantity * oi.unit_price) > 100
);

-- ============================================================================
-- CORRELATED SUBQUERY: Orders exceeding user's average
-- ============================================================================
/*
 * Find orders where the order total exceeds that user's average order value
 * Outer query references: o.user_id used in inner query
 * This executes the subquery once per row of outer query
 */
SELECT 
  o.order_id, 
  o.user_id,
  (
    SELECT COALESCE(SUM(oi.quantity * oi.unit_price), 0)
    FROM order_items oi
    WHERE oi.order_id = o.order_id
  ) AS order_total,
  (
    SELECT AVG(order_total)
    FROM (
      SELECT SUM(oi2.quantity * oi2.unit_price) AS order_total
      FROM orders o2
      JOIN order_items oi2 ON oi2.order_id = o2.order_id
      WHERE o2.user_id = o.user_id
        AND o2.status NOT IN ('cart', 'cancelled')
      GROUP BY o2.order_id
    ) t
  ) AS user_avg_order
FROM orders o
WHERE o.status NOT IN ('cart', 'cancelled')
  AND (
    SELECT COALESCE(SUM(oi.quantity * oi.unit_price), 0)
    FROM order_items oi
    WHERE oi.order_id = o.order_id
  ) > (
    SELECT AVG(order_total)
    FROM (
      SELECT SUM(oi2.quantity * oi2.unit_price) AS order_total
      FROM orders o2
      JOIN order_items oi2 ON oi2.order_id = o2.order_id
      WHERE o2.user_id = o.user_id
        AND o2.status NOT IN ('cart', 'cancelled')
      GROUP BY o2.order_id
    ) t
  );

-- ============================================================================
-- EXISTS: Check for existence (usually more efficient than IN)
-- ============================================================================
/*
 * Find users who have at least one completed order
 * EXISTS is often faster than IN because it stops at first match
 */
SELECT
  u.user_id,
  u.full_name,
  u.email
FROM users u
WHERE EXISTS (
  SELECT 1
  FROM orders o
  WHERE o.user_id = u.user_id
    AND o.status IN ('paid', 'shipped')
);

-- NOT EXISTS: Find users with no orders
SELECT
  u.user_id,
  u.full_name,
  u.email
FROM users u
WHERE NOT EXISTS (
  SELECT 1
  FROM orders o
  WHERE o.user_id = u.user_id
    AND o.status NOT IN ('cart', 'cancelled')
);

-- ============================================================================
-- ANY/ALL: Compare with set of values
-- ============================================================================
/*
 * Find products more expensive than ANY book
 * (i.e., more expensive than the cheapest book)
 */
SELECT
  p.product_id,
  p.name,
  p.unit_price
FROM products p
WHERE p.unit_price > ANY (
  SELECT p2.unit_price
  FROM products p2
  JOIN categories c ON c.category_id = p2.category_id
  WHERE c.name = 'Books'
);

-- Find products more expensive than ALL books
-- (i.e., more expensive than the most expensive book)
SELECT
  p.product_id,
  p.name,
  p.unit_price
FROM products p
WHERE p.unit_price > ALL (
  SELECT p2.unit_price
  FROM products p2
  JOIN categories c ON c.category_id = p2.category_id
  WHERE c.name = 'Books'
);

-- ============================================================================
-- SUBQUERY IN FROM: Inline view
-- ============================================================================
/*
 * Calculate aggregates, then aggregate again
 * Find the average order total across all orders
 */
SELECT
  COUNT(*) AS total_orders,
  AVG(order_total) AS avg_order_value,
  MIN(order_total) AS smallest_order,
  MAX(order_total) AS largest_order
FROM (
  SELECT
    o.order_id,
    SUM(oi.quantity * oi.unit_price) AS order_total
  FROM orders o
  JOIN order_items oi ON oi.order_id = o.order_id
  WHERE o.status NOT IN ('cart', 'cancelled')
  GROUP BY o.order_id
) AS order_totals;

