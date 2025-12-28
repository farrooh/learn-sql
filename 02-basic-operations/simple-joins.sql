/*
 * SIMPLE JOIN OPERATIONS
 * ======================
 * Demonstrates different types of joins and their use cases
 */

-- ============================================================================
-- INNER JOIN: Only matching rows from both tables
-- ============================================================================
/*
 * Get all products with their category names
 * INNER JOIN excludes any products without a valid category
 * (shouldn't happen due to foreign key, but demonstrates the concept)
 */
SELECT 
  p.product_id,
  p.name AS product_name,
  p.sku,
  p.unit_price,
  c.name AS category_name
FROM products p
INNER JOIN categories c ON c.category_id = p.category_id
WHERE p.is_active = true
ORDER BY c.name, p.name;

-- ============================================================================
-- LEFT JOIN: All rows from left table, matching rows from right
-- ============================================================================
/*
 * Get all users and their order count (including users with no orders)
 * Users without orders will show 0 due to COALESCE
 */
SELECT 
  u.user_id,
  u.email,
  u.full_name,
  COALESCE(COUNT(o.order_id), 0) AS order_count
FROM users u
LEFT JOIN orders o ON o.user_id = u.user_id
GROUP BY u.user_id, u.email, u.full_name
ORDER BY order_count DESC, u.full_name;

-- ============================================================================
-- MULTIPLE JOINS: Combining multiple tables
-- ============================================================================
/*
 * Get order details with user and product information
 * Chain multiple joins to traverse relationships
 */
SELECT 
  o.order_id,
  u.email AS customer_email,
  u.full_name AS customer_name,
  p.name AS product_name,
  oi.quantity,
  oi.unit_price,
  oi.quantity * oi.unit_price AS line_total
FROM orders o
INNER JOIN users u ON u.user_id = o.user_id
INNER JOIN order_items oi ON oi.order_id = o.order_id
INNER JOIN products p ON p.product_id = oi.product_id
WHERE o.status NOT IN ('cart', 'cancelled')
ORDER BY o.order_id, p.name;

