/*
 * DATABASE SCHEMA DEFINITION
 * ==========================
 * This file defines a complete e-commerce database schema with the following tables:
 * - users: Customer accounts
 * - categories: Product categories
 * - products: Product catalog
 * - orders: Customer orders
 * - order_items: Line items within orders
 * - payments: Payment records
 * - shipments: Shipping information
 * - inventory: Current stock levels
 * - inventory_movements: Stock movement history
 *
 * Key Concepts Demonstrated:
 * - Primary keys (SERIAL, UUID)
 * - Foreign keys with referential actions (CASCADE, RESTRICT, SET NULL)
 * - CHECK constraints for data validation
 * - UNIQUE constraints
 * - Default values (now(), gen_random_uuid())
 * - JSONB data type for flexible storage
 * - Proper data types (timestamptz, numeric, text, boolean)
 */

-- Enable UUID generation extension
CREATE EXTENSION IF NOT EXISTS pgcrypto;

/*
 * USERS TABLE
 * Stores customer information with UUID as primary key for better distribution
 * and security (non-sequential IDs)
 */
CREATE TABLE users (
  user_id        uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  email          text NOT NULL UNIQUE,
  full_name      text NOT NULL,
  created_at     timestamptz NOT NULL DEFAULT now()
);

/*
 * CATEGORIES TABLE
 * Simple hierarchical classification for products
 * Uses bigserial for auto-incrementing IDs
 */
CREATE TABLE categories (
  category_id    bigserial PRIMARY KEY,
  name           text NOT NULL UNIQUE,
  created_at     timestamptz NOT NULL DEFAULT now()
);

/*
 * PRODUCTS TABLE
 * Product catalog with pricing and inventory management
 * - ON DELETE RESTRICT: Prevents deleting a category that has products
 * - CHECK constraint: Ensures prices are never negative
 * - is_active: Soft delete pattern for products
 */
CREATE TABLE products (
  product_id     bigserial PRIMARY KEY,
  category_id    bigint NOT NULL REFERENCES categories(category_id) ON DELETE RESTRICT,
  sku            text NOT NULL UNIQUE,
  name           text NOT NULL,
  description    text,
  unit_price     numeric(12,2) NOT NULL CHECK (unit_price >= 0),
  is_active      boolean NOT NULL DEFAULT true,
  created_at     timestamptz NOT NULL DEFAULT now()
);

/*
 * ORDERS TABLE
 * Tracks the lifecycle of customer orders
 * Status flow: cart -> placed -> paid -> shipped -> (cancelled/refunded)
 * - external_ref: For integration with external systems
 * - placed_at: Separate from created_at to track when cart was converted to order
 */
CREATE TABLE orders (
  order_id       bigserial PRIMARY KEY,
  user_id        uuid NOT NULL REFERENCES users(user_id) ON DELETE RESTRICT,
  status         text NOT NULL CHECK (status IN ('cart','placed','paid','shipped','cancelled','refunded')),
  placed_at      timestamptz,
  created_at     timestamptz NOT NULL DEFAULT now(),
  external_ref   text UNIQUE
);

/*
 * ORDER_ITEMS TABLE
 * Line items for each order (many-to-many relationship between orders and products)
 * - Composite primary key: (order_id, product_id)
 * - ON DELETE CASCADE: When an order is deleted, remove its items
 * - Stores unit_price at time of order (historical pricing)
 */
CREATE TABLE order_items (
  order_id       bigint NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
  product_id     bigint NOT NULL REFERENCES products(product_id) ON DELETE RESTRICT,
  quantity       integer NOT NULL CHECK (quantity > 0),
  unit_price     numeric(12,2) NOT NULL CHECK (unit_price >= 0),
  PRIMARY KEY (order_id, product_id)
);

/*
 * PAYMENTS TABLE
 * Payment processing records
 * - One-to-one relationship with orders (UNIQUE constraint on order_id)
 * - provider_txn: External payment gateway transaction ID
 * - JSONB field for flexible metadata storage
 */
CREATE TABLE payments (
  payment_id     bigserial PRIMARY KEY,
  order_id       bigint NOT NULL UNIQUE REFERENCES orders(order_id) ON DELETE CASCADE,
  amount         numeric(12,2) NOT NULL CHECK (amount >= 0),
  provider       text NOT NULL,
  provider_txn   text UNIQUE,
  metadata       JSONB,
  status         text NOT NULL CHECK (status IN ('pending','captured','failed','refunded')),
  created_at     timestamptz NOT NULL DEFAULT now()
);

/*
 * SHIPMENTS TABLE
 * Shipping and delivery tracking
 * - carrier: Shipping company (FedEx, UPS, USPS, etc.)
 * - tracking_no: Carrier-provided tracking number
 */
CREATE TABLE shipments (
  shipment_id    bigserial PRIMARY KEY,
  order_id       bigint NOT NULL UNIQUE REFERENCES orders(order_id) ON DELETE CASCADE,
  carrier        text,
  tracking_no    text UNIQUE,
  shipped_at     timestamptz,
  delivered_at   timestamptz,
  status         text NOT NULL CHECK (status IN ('pending','shipped','delivered','returned')),
  created_at     timestamptz NOT NULL DEFAULT now()
);

/*
 * INVENTORY TABLE
 * Current stock levels for each product
 * - One-to-one with products (primary key is also foreign key)
 * - updated_at: Tracks when inventory was last modified
 */
CREATE TABLE inventory (
  product_id     bigint PRIMARY KEY REFERENCES products(product_id) ON DELETE CASCADE,
  on_hand        integer NOT NULL CHECK (on_hand >= 0),
  updated_at     timestamptz NOT NULL DEFAULT now()
);

/*
 * INVENTORY_MOVEMENTS TABLE
 * Audit trail for all inventory changes
 * - delta: Positive for stock in, negative for stock out
 * - order_id: Optional link to order (NULL for purchases/adjustments)
 * - ON DELETE SET NULL: Keep movement history even if order is deleted
 */
CREATE TABLE inventory_movements (
  movement_id    bigserial PRIMARY KEY,
  product_id     bigint NOT NULL REFERENCES products(product_id) ON DELETE CASCADE,
  order_id       bigint REFERENCES orders(order_id) ON DELETE SET NULL,
  delta          integer NOT NULL, -- +inbound, -outbound
  reason         text NOT NULL CHECK (reason IN ('purchase','sale','adjustment','return')),
  created_at     timestamptz NOT NULL DEFAULT now()
);

