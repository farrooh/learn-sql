/*
 * INDEXES FOR PERFORMANCE OPTIMIZATION
 * ====================================
 * Indexes speed up queries by creating data structures for fast lookups
 * Trade-off: Faster reads, slower writes, additional storage
 *
 * When to index:
 * - Foreign key columns (for joins)
 * - Columns in WHERE clauses
 * - Columns in ORDER BY
 * - Columns in GROUP BY
 *
 * When NOT to index:
 * - Tables with few rows
 * - Columns that change frequently
 * - Columns with low cardinality (few distinct values) - except partial indexes
 */

-- ============================================================================
-- COMPOSITE INDEX: Multiple columns together
-- ============================================================================
/*
 * Index column order matters!
 * (user_id, created_at) works for:
 * - WHERE user_id = ? AND created_at = ?
 * - WHERE user_id = ?
 * - ORDER BY user_id, created_at
 *
 * But NOT for: WHERE created_at = ? (without user_id)
 *
 * DESC on created_at for reverse chronological queries
 */
CREATE INDEX idx_orders_user_created_at 
  ON orders(user_id, created_at DESC);

-- ============================================================================
-- SINGLE COLUMN INDEX: For filtering
-- ============================================================================
/*
 * Simple index on status for queries like:
 * WHERE status = 'paid'
 * WHERE status IN ('paid', 'shipped')
 */
CREATE INDEX idx_orders_status 
  ON orders(status);

-- ============================================================================
-- INDEX ON FOREIGN KEY: Essential for joins
-- ============================================================================
/*
 * Speed up: SELECT * FROM products WHERE category_id = ?
 * Also speeds up foreign key constraint checks
 */
CREATE INDEX idx_products_category 
  ON products(category_id);

-- Index on order_items.product_id for reverse lookup
-- "Show me all orders that contain this product"
CREATE INDEX idx_order_items_product 
  ON order_items(product_id);

-- ============================================================================
-- PARTIAL INDEX: Index only relevant rows
-- ============================================================================
/*
 * Only index active products (saves space, faster maintenance)
 * Works for: WHERE is_active = true
 * Much smaller than indexing all products
 */
CREATE INDEX idx_products_active 
  ON products(is_active) 
  WHERE is_active = true;

-- ============================================================================
-- COMPOSITE INDEX FOR ANALYTICS: Product movements over time
-- ============================================================================
/*
 * Optimized for queries like:
 * "Show inventory history for product X in last 30 days"
 */
CREATE INDEX idx_inventory_movements_product_time 
  ON inventory_movements(product_id, created_at DESC);

-- ============================================================================
-- TEXT SEARCH INDEX: Full-text search
-- ============================================================================
/*
 * GIN (Generalized Inverted Index) for text search
 * Enables fast searches like: WHERE name ILIKE '%headphone%'
 * Uses trigrams (3-character sequences)
 */
CREATE EXTENSION IF NOT EXISTS pg_trgm;

CREATE INDEX idx_products_name_trgm 
  ON products 
  USING gin (name gin_trgm_ops);

-- Example query using this index:
-- SELECT * FROM products WHERE name ILIKE '%noise%';

-- ============================================================================
-- UNIQUE INDEX: Enforce uniqueness + performance
-- ============================================================================
/*
 * These are automatically created by UNIQUE constraints
 * But shown here for completeness
 */
-- Already created by UNIQUE constraint:
-- CREATE UNIQUE INDEX idx_users_email ON users(email);
-- CREATE UNIQUE INDEX idx_products_sku ON products(sku);

-- ============================================================================
-- COVERING INDEX: Include extra columns
-- ============================================================================
/*
 * INCLUDE clause (PostgreSQL 11+) adds columns to index without using them for search
 * Allows index-only scans (no table access needed)
 */
CREATE INDEX idx_orders_user_status_covering 
  ON orders(user_id, status) 
  INCLUDE (created_at, placed_at);

-- This query can be satisfied entirely from the index:
-- SELECT user_id, status, created_at FROM orders WHERE user_id = ? AND status = 'paid';

-- ============================================================================
-- INDEX MAINTENANCE TIPS
-- ============================================================================
/*
 * 1. Monitor index usage:
 *    SELECT * FROM pg_stat_user_indexes;
 *
 * 2. Find unused indexes:
 *    SELECT schemaname, tablename, indexname
 *    FROM pg_stat_user_indexes
 *    WHERE idx_scan = 0 AND indexname NOT LIKE 'pg_toast%';
 *
 * 3. Check index size:
 *    SELECT pg_size_pretty(pg_relation_size('index_name'));
 *
 * 4. Rebuild bloated indexes:
 *    REINDEX INDEX index_name;
 *
 * 5. Analyze for query planner statistics:
 *    ANALYZE table_name;
 */

