# SQL Sample Queries - Educational Resource

A comprehensive collection of PostgreSQL queries organized by topic and complexity level. Perfect for learning SQL from basics to advanced concepts.

## 📁 Repository Structure

```
SQL-sample-queries/
├── 01-schema/              # Database setup
├── 02-basic-operations/    # Fundamental SQL operations
├── 03-intermediate-queries/# Grouping, windows, transactions
├── 04-advanced-queries/    # CTEs, subqueries, complex joins
└── 05-performance/         # Optimization and indexing
```

## 🗂️ Contents by Folder

### 01-schema/ - Database Foundation
- **database-schema.sql**: Complete e-commerce schema with comprehensive comments
  - Tables: users, products, orders, payments, shipments, inventory
  - Demonstrates: primary keys, foreign keys, constraints, data types
- **insert-mock-data.sql**: Sample data for testing and learning

### 02-basic-operations/ - SQL Fundamentals
- **crud-operations.sql**: Create, Read, Update, Delete operations
  - INSERT with RETURNING
  - SELECT with ORDER BY
  - UPDATE with calculations
  - DELETE vs soft delete patterns
- **simple-joins.sql**: Introduction to JOIN operations
  - INNER JOIN
  - LEFT JOIN
  - Multiple table joins

### 03-intermediate-queries/ - Building Complexity
- **grouping-and-aggregation.sql**: Working with GROUP BY
  - SUM, COUNT, AVG, MIN, MAX
  - GROUP BY vs row-level queries
  - HAVING clause
  - Multi-level grouping
- **window-functions.sql**: Analytical queries without collapsing rows
  - ROW_NUMBER, RANK, DENSE_RANK
  - LAG and LEAD for time-series analysis
  - PARTITION BY
  - Running totals
- **transactions.sql**: ACID properties in practice
  - BEGIN/COMMIT/ROLLBACK
  - Multi-step operations
  - Savepoints
  - Inventory management example

### 04-advanced-queries/ - Expert Level
- **common-table-expressions.sql**: CTEs for readable complex queries
  - Basic CTEs (WITH clause)
  - Multiple CTEs
  - Recursive CTEs (with example)
- **subqueries.sql**: Nested query patterns
  - Scalar subqueries
  - Correlated subqueries
  - EXISTS vs IN
  - ANY/ALL operators
- **join-conditions-fixed.sql**: Common JOIN mistakes and fixes
  - Proper JOIN syntax
  - JOIN ON vs WHERE
  - Explanation of a real bug from original code

### 05-performance/ - Optimization
- **indexes.sql**: Speed up your queries
  - Single and composite indexes
  - Partial indexes
  - Text search with GIN indexes
  - Index maintenance tips
- **query-optimization-tips.sql**: Best practices
  - EXPLAIN ANALYZE usage
  - Avoiding common pitfalls
  - Efficient query patterns

## 🚀 Getting Started

### 1. Set up the database
```sql
-- Create a new database
CREATE DATABASE sql_learning;

-- Connect to it
\c sql_learning

-- Run the schema
\i 01-schema/database-schema.sql

-- Load sample data
\i 01-schema/insert-mock-data.sql
```

### 2. Follow the learning path
Start with folder `01-schema` and progress through each folder in order. Each file contains:
- Detailed comments explaining concepts
- Working examples you can run
- Common pitfalls and best practices

### 3. Experiment
- Modify queries to see different results
- Try breaking things to understand errors
- Use EXPLAIN ANALYZE to see query performance

## 📚 Key Learning Concepts

### Beginner Topics
- CRUD operations
- Basic JOINs (INNER, LEFT, RIGHT)
- WHERE clauses and filtering
- ORDER BY and LIMIT

### Intermediate Topics
- GROUP BY and aggregations
- Window functions (ROW_NUMBER, RANK, etc.)
- Transactions and ACID
- Subqueries

### Advanced Topics
- Common Table Expressions (CTEs)
- Recursive queries
- Complex join conditions
- Query optimization
- Index strategies

## 🔧 Requirements

- PostgreSQL 12+ (some features like INCLUDE in indexes require 11+)
- psql client or any PostgreSQL IDE (pgAdmin, DBeaver, DataGrip)

## 📝 Notes

- All queries use PostgreSQL syntax
- Some features (like `gen_random_uuid()`) require extensions
- Comments explain WHY, not just WHAT
- Real-world examples from e-commerce domain

## 🐛 Issues Fixed

This repository includes fixes for common SQL mistakes found in the original queries:

1. **transaction-create-order-with-items.sql**: Fixed typo `o.order_i` → `o.order_id`
2. **recent-customer-orders-with-totals.sql**: Fixed incorrect JOIN condition with filtering in ON clause
3. **database-schema.sql**: Fixed JSONB column name (`test` → `metadata`)

## 🎯 Use Cases

- **Learning**: Step-by-step progression from basics to advanced
- **Reference**: Quick lookup for SQL patterns
- **Teaching**: Use as course material with detailed explanations
- **Interview Prep**: Common SQL patterns asked in interviews
- **Debugging**: Compare your queries with working examples

## 📖 Additional Resources

- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Use The Index, Luke!](https://use-the-index-luke.com/) - Index optimization guide
- [Explain.depesz.com](https://explain.depesz.com/) - EXPLAIN plan visualizer

## 🤝 Contributing

Feel free to:
- Add more examples
- Improve explanations
- Fix errors
- Suggest new topics

---

**Happy Learning! 🎓**

