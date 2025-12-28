/*
 * MOCK DATA FOR TESTING
 * =====================
 * This file populates the database with sample data for development and testing.
 * 
 * Demonstrates:
 * - Bulk INSERT with multiple values
 * - INSERT ... SELECT pattern
 * - Proper data ordering (categories before products)
 */

-- Insert product categories first (foreign key dependency)
INSERT INTO categories(name) 
VALUES 
  ('Books'), 
  ('Electronics'), 
  ('Home');

-- Insert sample users
INSERT INTO users(email, full_name) 
VALUES
  ('alice@example.com', 'Alice Nguyen'),
  ('bob@example.com',   'Bob Karimov');

-- Insert products (requires categories to exist)
-- Note: unit_price uses numeric(12,2) for precise currency values
INSERT INTO products(category_id, sku, name, description, unit_price) 
VALUES
  (1, 'BK-001', 'SQL Basics', 'Intro book', 29.99),
  (1, 'BK-002', 'Postgres Deep Dive', 'Advanced book', 49.00),
  (2, 'EL-001', 'Noise-Canceling Headphones', 'Over-ear', 199.99),
  (3, 'HM-001', 'French Press', 'Coffee maker', 24.50);

-- Initialize inventory for all products
-- Using INSERT ... SELECT to automatically create inventory records
INSERT INTO inventory(product_id, on_hand)
SELECT product_id, 50 
FROM products;

