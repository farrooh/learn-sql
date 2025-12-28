/*
 * TRANSACTIONS
 * ============
 * Transactions ensure multiple operations complete as a single unit
 * Either ALL operations succeed, or NONE of them do (atomicity)
 *
 * ACID Properties:
 * - Atomicity: All or nothing
 * - Consistency: Database moves from one valid state to another
 * - Isolation: Transactions don't interfere with each other
 * - Durability: Committed changes are permanent
 */

-- ============================================================================
-- BASIC TRANSACTION: Create order with items
-- ============================================================================
/*
 * Fixed version - original had typo: o.order_i instead of o.order_id
 * 
 * Use transactions when multiple operations must succeed together:
 * 1. Create the order
 * 2. Add items to the order
 * If step 2 fails, step 1 is rolled back (order isn't created)
 */
BEGIN;

-- Step 1: Create the order
INSERT INTO orders(user_id, status, placed_at, external_ref)
SELECT user_id, 'placed', now(), 'web-1004'
FROM users
WHERE email='charlie@example.com';

-- Step 2: Add order items
INSERT INTO order_items(order_id, product_id, quantity, unit_price)
SELECT
  o.order_id,          -- FIXED: was o.order_i (typo)
  p.product_id,
  2,                   -- quantity
  p.unit_price
FROM orders o
JOIN products p ON p.sku='BK-002'
WHERE o.external_ref='web-1004';

COMMIT;

-- ============================================================================
-- TRANSACTION WITH ROLLBACK: Error handling
-- ============================================================================
/*
 * Demonstrates explicit rollback
 * In practice, applications catch errors and rollback automatically
 */
BEGIN;

-- Attempt to create order
INSERT INTO orders(user_id, status, placed_at, external_ref)
SELECT user_id, 'placed', now(), 'web-1005'
FROM users
WHERE email='alice@example.com';

-- Oops, product doesn't exist!
-- Manually rollback to undo the order creation
ROLLBACK;

-- ============================================================================
-- COMPLEX TRANSACTION: Order with inventory update
-- ============================================================================
/*
 * Real-world example: Creating an order should reduce inventory
 * Both operations must succeed or fail together
 */
BEGIN;

-- Create the order
INSERT INTO orders(user_id, status, placed_at, external_ref)
VALUES (
  (SELECT user_id FROM users WHERE email='bob@example.com'),
  'placed',
  now(),
  'web-1006'
);

-- Add order item
INSERT INTO order_items(order_id, product_id, quantity, unit_price)
VALUES (
  currval('orders_order_id_seq'),  -- Get the just-inserted order_id
  (SELECT product_id FROM products WHERE sku='EL-001'),
  1,
  (SELECT unit_price FROM products WHERE sku='EL-001')
);

-- Update inventory
UPDATE inventory
SET 
  on_hand = on_hand - 1,
  updated_at = now()
WHERE product_id = (SELECT product_id FROM products WHERE sku='EL-001')
AND on_hand >= 1;  -- Safety check: only decrease if stock available

-- Record inventory movement
INSERT INTO inventory_movements(product_id, order_id, delta, reason)
VALUES (
  (SELECT product_id FROM products WHERE sku='EL-001'),
  currval('orders_order_id_seq'),
  -1,
  'sale'
);

COMMIT;

-- ============================================================================
-- SAVEPOINTS: Partial rollback within a transaction
-- ============================================================================
/*
 * Savepoints allow rolling back to a specific point without losing all work
 */
BEGIN;

-- Create first order
INSERT INTO orders(user_id, status, placed_at, external_ref)
VALUES (
  (SELECT user_id FROM users WHERE email='alice@example.com'),
  'placed',
  now(),
  'web-1007'
);

SAVEPOINT first_order;

-- Try to create second order
INSERT INTO orders(user_id, status, placed_at, external_ref)
VALUES (
  (SELECT user_id FROM users WHERE email='invalid@example.com'),  -- Doesn't exist
  'placed',
  now(),
  'web-1008'
);

-- Rollback only the second order, keep the first
ROLLBACK TO SAVEPOINT first_order;

COMMIT;  -- First order is committed

