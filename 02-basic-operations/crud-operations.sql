/*
 * BASIC CRUD OPERATIONS
 * =====================
 * Demonstrates the four fundamental database operations:
 * CREATE (INSERT), READ (SELECT), UPDATE, DELETE
 */

-- ============================================================================
-- CREATE: Insert new records
-- ============================================================================
/*
 * RETURNING clause returns the inserted row(s)
 * Useful for getting generated IDs or default values
 */
INSERT INTO users(email, full_name)
VALUES ('charlie@example.com', 'Charlie Kim')
RETURNING *;

-- ============================================================================
-- READ: Query existing records
-- ============================================================================
/*
 * Basic SELECT with ORDER BY
 * Always specify columns explicitly for maintainability
 */
SELECT user_id, email, full_name, created_at
FROM users
ORDER BY full_name ASC;

-- ============================================================================
-- UPDATE: Modify existing records
-- ============================================================================
/*
 * Update with calculation: Increase price by 10%
 * RETURNING shows the updated values
 * WHERE clause is CRITICAL to avoid updating all rows
 */
UPDATE products
SET unit_price = unit_price * 1.10
WHERE sku = 'BK-001'
RETURNING product_id, sku, unit_price;

-- ============================================================================
-- DELETE: Remove records
-- ============================================================================
/*
 * WARNING: DELETE is permanent (unless in a transaction)
 * Always use WHERE clause to avoid deleting all rows
 * Consider soft deletes (is_active flag) for important data
 */
DELETE FROM products
WHERE product_id = 4;

-- Alternative: Soft delete (preferred for products with order history)
UPDATE products
SET is_active = false
WHERE product_id = 4
RETURNING product_id, name, is_active;

