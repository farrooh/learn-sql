/*
 * PRACTICE EXERCISES
 * ==================
 * Test your SQL skills with these exercises
 * Answers are provided at the bottom (but try first!)
 */

-- ============================================================================
-- BASIC EXERCISES
-- ============================================================================

-- Exercise 1: List all active products with their category names
-- TODO: Write your query here


-- Exercise 2: Find all users who registered in the last 30 days
-- TODO: Write your query here


-- Exercise 3: Count how many products are in each category
-- TODO: Write your query here


-- ============================================================================
-- INTERMEDIATE EXERCISES
-- ============================================================================

-- Exercise 4: Find the top 5 most expensive products
-- TODO: Write your query here


-- Exercise 5: List all orders with their total value, showing only orders over $50
-- TODO: Write your query here


-- Exercise 6: Show each user's total number of orders and total amount spent
-- TODO: Write your query here


-- Exercise 7: Find products that have never been ordered
-- TODO: Write your query here


-- Exercise 8: List the most recent order for each user
-- TODO: Write your query here


-- ============================================================================
-- ADVANCED EXERCISES
-- ============================================================================

-- Exercise 9: Calculate each user's average order value and rank users by it
-- TODO: Write your query here


-- Exercise 10: For each order, show the time difference from the previous order
--              by the same user
-- TODO: Write your query here


-- Exercise 11: Find users whose most recent order was more expensive than their
--              average order value
-- TODO: Write your query here


-- Exercise 12: Create a report showing daily total sales for the last 7 days
-- TODO: Write your query here


-- Exercise 13: Find products that appear in more than 5 orders
-- TODO: Write your query here


-- Exercise 14: Calculate the running total of inventory movements for each product
-- TODO: Write your query here


-- ============================================================================
-- CHALLENGE EXERCISES
-- ============================================================================

-- Exercise 15: Find pairs of products that are frequently bought together
--              (appear in the same order)
-- TODO: Write your query here


-- Exercise 16: Calculate customer retention: users who made their second purchase
--              within 30 days of their first purchase
-- TODO: Write your query here


-- Exercise 17: Identify products whose sales have declined month-over-month
-- TODO: Write your query here


-- Exercise 18: Create a pivot table showing orders by status and month
-- TODO: Write your query here
















-- ============================================================================
-- ANSWERS
-- ============================================================================

-- Answer 1: List all active products with their category names
SELECT p.product_id, p.name, p.sku, p.unit_price, c.name AS category
FROM products p
INNER JOIN categories c ON c.category_id = p.category_id
WHERE p.is_active = true
ORDER BY c.name, p.name;


-- Answer 2: Find all users who registered in the last 30 days
SELECT user_id, email, full_name, created_at
FROM users
WHERE created_at > now() - INTERVAL '30 days'
ORDER BY created_at DESC;


-- Answer 3: Count how many products are in each category
SELECT c.name AS category, COUNT(p.product_id) AS product_count
FROM categories c
LEFT JOIN products p ON p.category_id = c.category_id AND p.is_active = true
GROUP BY c.category_id, c.name
ORDER BY product_count DESC;


-- Answer 4: Find the top 5 most expensive products
SELECT product_id, name, unit_price
FROM products
WHERE is_active = true
ORDER BY unit_price DESC
LIMIT 5;


-- Answer 5: List all orders with their total value, showing only orders over $50
SELECT 
  o.order_id,
  o.user_id,
  o.status,
  SUM(oi.quantity * oi.unit_price) AS order_total
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
GROUP BY o.order_id, o.user_id, o.status
HAVING SUM(oi.quantity * oi.unit_price) > 50
ORDER BY order_total DESC;


-- Answer 6: Show each user's total number of orders and total amount spent
SELECT 
  u.user_id,
  u.full_name,
  COUNT(DISTINCT o.order_id) AS total_orders,
  COALESCE(SUM(oi.quantity * oi.unit_price), 0) AS total_spent
FROM users u
LEFT JOIN orders o ON o.user_id = u.user_id AND o.status NOT IN ('cart', 'cancelled')
LEFT JOIN order_items oi ON oi.order_id = o.order_id
GROUP BY u.user_id, u.full_name
ORDER BY total_spent DESC;


-- Answer 7: Find products that have never been ordered
SELECT p.product_id, p.name, p.sku, p.unit_price
FROM products p
WHERE NOT EXISTS (
  SELECT 1
  FROM order_items oi
  WHERE oi.product_id = p.product_id
)
AND p.is_active = true
ORDER BY p.name;


-- Answer 8: List the most recent order for each user
WITH ranked_orders AS (
  SELECT 
    o.*,
    ROW_NUMBER() OVER (PARTITION BY o.user_id ORDER BY o.created_at DESC) AS rn
  FROM orders o
  WHERE o.status NOT IN ('cart', 'cancelled')
)
SELECT 
  ro.user_id,
  u.full_name,
  ro.order_id,
  ro.status,
  ro.created_at
FROM ranked_orders ro
JOIN users u ON u.user_id = ro.user_id
WHERE ro.rn = 1
ORDER BY ro.created_at DESC;


-- Answer 9: Calculate each user's average order value and rank users by it
WITH user_stats AS (
  SELECT 
    u.user_id,
    u.full_name,
    AVG(oi.quantity * oi.unit_price) AS avg_order_value,
    COUNT(DISTINCT o.order_id) AS order_count
  FROM users u
  JOIN orders o ON o.user_id = u.user_id AND o.status NOT IN ('cart', 'cancelled')
  JOIN order_items oi ON oi.order_id = o.order_id
  GROUP BY u.user_id, u.full_name
)
SELECT 
  *,
  RANK() OVER (ORDER BY avg_order_value DESC) AS value_rank
FROM user_stats
ORDER BY value_rank;


-- Answer 10: For each order, show the time difference from the previous order
SELECT 
  o.order_id,
  o.user_id,
  o.created_at,
  LAG(o.created_at) OVER (PARTITION BY o.user_id ORDER BY o.created_at) AS prev_order_date,
  o.created_at - LAG(o.created_at) OVER (PARTITION BY o.user_id ORDER BY o.created_at) AS time_since_last_order
FROM orders o
WHERE o.status NOT IN ('cart', 'cancelled')
ORDER BY o.user_id, o.created_at;


-- Answer 11: Find users whose most recent order was more expensive than their average
WITH user_order_totals AS (
  SELECT 
    o.user_id,
    o.order_id,
    o.created_at,
    SUM(oi.quantity * oi.unit_price) AS order_total
  FROM orders o
  JOIN order_items oi ON oi.order_id = o.order_id
  WHERE o.status NOT IN ('cart', 'cancelled')
  GROUP BY o.user_id, o.order_id, o.created_at
),
user_stats AS (
  SELECT 
    user_id,
    AVG(order_total) AS avg_order_value
  FROM user_order_totals
  GROUP BY user_id
),
most_recent AS (
  SELECT DISTINCT ON (user_id)
    user_id,
    order_id,
    order_total
  FROM user_order_totals
  ORDER BY user_id, created_at DESC
)
SELECT 
  u.full_name,
  mr.order_id AS latest_order,
  mr.order_total AS latest_order_value,
  us.avg_order_value,
  mr.order_total - us.avg_order_value AS difference
FROM most_recent mr
JOIN user_stats us ON us.user_id = mr.user_id
JOIN users u ON u.user_id = mr.user_id
WHERE mr.order_total > us.avg_order_value
ORDER BY difference DESC;


-- Answer 12: Create a report showing daily total sales for the last 7 days
SELECT 
  DATE(o.created_at) AS sale_date,
  COUNT(DISTINCT o.order_id) AS order_count,
  SUM(oi.quantity) AS items_sold,
  SUM(oi.quantity * oi.unit_price) AS daily_revenue
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.status NOT IN ('cart', 'cancelled')
  AND o.created_at > now() - INTERVAL '7 days'
GROUP BY DATE(o.created_at)
ORDER BY sale_date DESC;


-- Answer 13: Find products that appear in more than 5 orders
SELECT 
  p.product_id,
  p.name,
  p.sku,
  COUNT(DISTINCT oi.order_id) AS order_count,
  SUM(oi.quantity) AS total_quantity_sold
FROM products p
JOIN order_items oi ON oi.product_id = p.product_id
JOIN orders o ON o.order_id = oi.order_id AND o.status NOT IN ('cart', 'cancelled')
GROUP BY p.product_id, p.name, p.sku
HAVING COUNT(DISTINCT oi.order_id) > 5
ORDER BY order_count DESC;


-- Answer 14: Calculate the running total of inventory movements for each product
SELECT 
  im.product_id,
  p.name AS product_name,
  im.movement_id,
  im.delta,
  im.reason,
  im.created_at,
  SUM(im.delta) OVER (
    PARTITION BY im.product_id 
    ORDER BY im.created_at, im.movement_id
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
  ) AS running_total
FROM inventory_movements im
JOIN products p ON p.product_id = im.product_id
ORDER BY im.product_id, im.created_at;


-- Answer 15: Find pairs of products that are frequently bought together
SELECT 
  p1.name AS product1,
  p2.name AS product2,
  COUNT(DISTINCT oi1.order_id) AS times_bought_together
FROM order_items oi1
JOIN order_items oi2 ON oi1.order_id = oi2.order_id AND oi1.product_id < oi2.product_id
JOIN products p1 ON p1.product_id = oi1.product_id
JOIN products p2 ON p2.product_id = oi2.product_id
JOIN orders o ON o.order_id = oi1.order_id AND o.status NOT IN ('cart', 'cancelled')
GROUP BY p1.product_id, p1.name, p2.product_id, p2.name
HAVING COUNT(DISTINCT oi1.order_id) >= 2
ORDER BY times_bought_together DESC;


-- Answer 16: Calculate customer retention (second purchase within 30 days)
WITH user_orders AS (
  SELECT 
    user_id,
    order_id,
    created_at,
    ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY created_at) AS order_num
  FROM orders
  WHERE status NOT IN ('cart', 'cancelled')
),
first_orders AS (
  SELECT * FROM user_orders WHERE order_num = 1
),
second_orders AS (
  SELECT * FROM user_orders WHERE order_num = 2
)
SELECT 
  u.user_id,
  u.full_name,
  fo.created_at AS first_order_date,
  so.created_at AS second_order_date,
  so.created_at - fo.created_at AS time_to_second_order
FROM users u
JOIN first_orders fo ON fo.user_id = u.user_id
LEFT JOIN second_orders so ON so.user_id = u.user_id
WHERE so.created_at - fo.created_at <= INTERVAL '30 days'
ORDER BY time_to_second_order;


-- Answer 17: Identify products whose sales have declined month-over-month
WITH monthly_sales AS (
  SELECT 
    p.product_id,
    p.name,
    DATE_TRUNC('month', o.created_at) AS month,
    SUM(oi.quantity) AS quantity_sold
  FROM products p
  JOIN order_items oi ON oi.product_id = p.product_id
  JOIN orders o ON o.order_id = oi.order_id AND o.status NOT IN ('cart', 'cancelled')
  GROUP BY p.product_id, p.name, DATE_TRUNC('month', o.created_at)
)
SELECT 
  product_id,
  name,
  month,
  quantity_sold AS current_month_sales,
  LAG(quantity_sold) OVER (PARTITION BY product_id ORDER BY month) AS prev_month_sales,
  quantity_sold - LAG(quantity_sold) OVER (PARTITION BY product_id ORDER BY month) AS change
FROM monthly_sales
WHERE LAG(quantity_sold) OVER (PARTITION BY product_id ORDER BY month) IS NOT NULL
  AND quantity_sold < LAG(quantity_sold) OVER (PARTITION BY product_id ORDER BY month)
ORDER BY month DESC, change;


-- Answer 18: Create a pivot table showing orders by status and month
SELECT 
  DATE_TRUNC('month', created_at) AS month,
  COUNT(*) FILTER (WHERE status = 'placed') AS placed,
  COUNT(*) FILTER (WHERE status = 'paid') AS paid,
  COUNT(*) FILTER (WHERE status = 'shipped') AS shipped,
  COUNT(*) FILTER (WHERE status = 'cancelled') AS cancelled,
  COUNT(*) AS total
FROM orders
WHERE created_at > now() - INTERVAL '6 months'
GROUP BY DATE_TRUNC('month', created_at)
ORDER BY month DESC;

