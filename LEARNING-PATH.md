# 🎓 Learning Path Guide

## Quick Start

### Step 1: Setup (5 minutes)
```bash
# Create database
createdb sql_learning

# Connect
psql sql_learning

# Load schema
\i 01-schema/database-schema.sql

# Load sample data
\i 01-schema/insert-mock-data.sql
```

### Step 2: Choose Your Path

#### 🟢 Beginner (Never used SQL)
**Estimated Time**: 4-6 hours

1. Read: `README.md` (overview)
2. Study: `01-schema/database-schema.sql` (understand the data)
3. Practice: `02-basic-operations/crud-operations.sql`
   - Run each query
   - Modify values
   - Understand CRUD
4. Practice: `02-basic-operations/simple-joins.sql`
   - Learn INNER vs LEFT JOIN
   - Practice combining tables
5. Exercise: Try exercises 1-3 in `PRACTICE-EXERCISES.sql`
6. Reference: Keep `QUICK-REFERENCE.sql` open for syntax

**You're ready for intermediate when you can:**
- Write SELECT with WHERE and ORDER BY
- Understand INNER JOIN vs LEFT JOIN
- Use basic aggregate functions (COUNT, SUM, AVG)

---

#### 🟡 Intermediate (Know basic SELECT and JOIN)
**Estimated Time**: 6-8 hours

1. Study: `03-intermediate-queries/grouping-and-aggregation.sql`
   - GROUP BY fundamentals
   - When to use HAVING vs WHERE
2. Study: `03-intermediate-queries/window-functions.sql`
   - ROW_NUMBER for sequences
   - RANK for leaderboards
   - LAG/LEAD for comparisons
3. Study: `03-intermediate-queries/transactions.sql`
   - When to use transactions
   - COMMIT vs ROLLBACK
4. Exercise: Try exercises 4-8 in `PRACTICE-EXERCISES.sql`
5. Review: Common mistakes in `04-advanced-queries/join-conditions-fixed.sql`

**You're ready for advanced when you can:**
- Group data and filter with HAVING
- Use window functions for rankings
- Write and understand transactions
- Debug JOIN conditions

---

#### 🔴 Advanced (Comfortable with GROUP BY and window functions)
**Estimated Time**: 8-10 hours

1. Study: `04-advanced-queries/common-table-expressions.sql`
   - Break complex queries into steps
   - Chain multiple CTEs
   - When to use CTE vs subquery
2. Study: `04-advanced-queries/subqueries.sql`
   - Correlated vs uncorrelated
   - EXISTS vs IN performance
   - ANY/ALL operators
3. Study: `05-performance/indexes.sql`
   - When to create indexes
   - Composite vs single-column
   - Partial indexes
4. Study: `05-performance/query-optimization-tips.sql`
   - Read EXPLAIN ANALYZE
   - Optimize slow queries
5. Exercise: Try exercises 9-18 in `PRACTICE-EXERCISES.sql`

**You're an expert when you can:**
- Write complex multi-CTE queries
- Understand query execution plans
- Design appropriate indexes
- Optimize slow queries

---

## 📚 Topic-Based Learning

### Want to learn a specific topic?

| Topic | Files | Difficulty |
|-------|-------|-----------|
| **Basic queries** | `02-basic-operations/crud-operations.sql` | 🟢 Beginner |
| **Joins** | `02-basic-operations/simple-joins.sql`<br>`04-advanced-queries/join-conditions-fixed.sql` | 🟢🟡 |
| **Aggregation** | `03-intermediate-queries/grouping-and-aggregation.sql` | 🟡 Intermediate |
| **Window functions** | `03-intermediate-queries/window-functions.sql` | 🟡 Intermediate |
| **Transactions** | `03-intermediate-queries/transactions.sql` | 🟡 Intermediate |
| **CTEs** | `04-advanced-queries/common-table-expressions.sql` | 🔴 Advanced |
| **Subqueries** | `04-advanced-queries/subqueries.sql` | 🔴 Advanced |
| **Performance** | `05-performance/indexes.sql`<br>`05-performance/query-optimization-tips.sql` | 🔴 Advanced |

---

## 🎯 Project-Based Learning

### Project 1: Analytics Dashboard (Beginner)
**Goal**: Create a simple sales report

1. Count total orders by status
2. Calculate revenue per category
3. Find top 5 customers by spending
4. Show daily sales for last week

**Files needed**: `02-basic-operations/`, `03-intermediate-queries/grouping-and-aggregation.sql`

---

### Project 2: Customer Analysis (Intermediate)
**Goal**: Understand customer behavior

1. Calculate customer lifetime value
2. Find repeat customers (2+ orders)
3. Identify customers at risk (no order in 30 days)
4. Calculate average time between orders

**Files needed**: `03-intermediate-queries/window-functions.sql`, `04-advanced-queries/common-table-expressions.sql`

---

### Project 3: Performance Optimization (Advanced)
**Goal**: Speed up slow queries

1. Use EXPLAIN ANALYZE on complex queries
2. Identify missing indexes
3. Rewrite correlated subqueries as JOINs
4. Create appropriate indexes

**Files needed**: `05-performance/`

---

## 💡 Tips for Success

### 1. Run Every Query
Don't just read - execute each query and examine results.

```sql
-- Example: Play with this query
SELECT * FROM products WHERE unit_price > 30;

-- Change the price: What happens?
SELECT * FROM products WHERE unit_price > 100;

-- Add ORDER BY: How does it change?
SELECT * FROM products WHERE unit_price > 30 ORDER BY unit_price DESC;
```

### 2. Break Things
Try to make queries fail - you'll learn more!

```sql
-- This will fail - why?
SELECT name, COUNT(*) FROM products;

-- Fix: Add GROUP BY
SELECT name, COUNT(*) FROM products GROUP BY name;
```

### 3. Use EXPLAIN
Understand what the database is doing:

```sql
EXPLAIN ANALYZE
SELECT * FROM orders WHERE status = 'paid';
```

### 4. Keep Notes
Document your "aha!" moments:
- What was confusing?
- What clicked?
- What would you explain differently?

### 5. Practice Daily
Even 15 minutes a day > 2 hours once a week

---

## 🔄 Review Cycle

### Week 1-2: Basics
- [ ] Understand schema
- [ ] Master CRUD
- [ ] Practice JOINs
- [ ] Complete exercises 1-3

### Week 3-4: Intermediate
- [ ] GROUP BY fluency
- [ ] Window functions
- [ ] Transactions
- [ ] Complete exercises 4-8

### Week 5-6: Advanced
- [ ] CTEs for complex queries
- [ ] Subquery patterns
- [ ] Complete exercises 9-14

### Week 7-8: Expert
- [ ] Performance tuning
- [ ] Index strategies
- [ ] Complete exercises 15-18
- [ ] Build a project

---

## 📞 Common Questions

**Q: Do I need to memorize all this?**
A: No! Keep `QUICK-REFERENCE.sql` handy. Focus on understanding concepts.

**Q: How long to become proficient?**
A: With daily practice:
- Beginner → Intermediate: 2-3 weeks
- Intermediate → Advanced: 1-2 months
- Advanced → Expert: 3-6 months

**Q: What if I get stuck?**
A: 
1. Re-read the comments in the SQL file
2. Check `QUICK-REFERENCE.sql`
3. Try simplifying the query (remove parts until it works)
4. Look at similar examples in other files

**Q: Should I use CTEs or subqueries?**
A: Generally prefer CTEs for readability. See `04-advanced-queries/common-table-expressions.sql` for detailed comparison.

**Q: When should I add an index?**
A: When queries are slow! See `05-performance/indexes.sql` for guidelines.

---

## 🎯 Success Metrics

You're making progress when you can:

**Week 1**: Write basic SELECT queries without looking at references
**Week 2**: Explain the difference between INNER and LEFT JOIN
**Week 3**: Use GROUP BY and understand HAVING
**Week 4**: Write window functions for ranking/sequences
**Week 5**: Break complex queries into CTEs
**Week 6**: Understand EXPLAIN output
**Week 7**: Design database indexes
**Week 8**: Optimize slow queries

---

## 🚀 Next Steps After Completion

1. **Apply to real projects**: Use in your work or side projects
2. **Explore advanced topics**: 
   - Recursive CTEs
   - Full-text search
   - JSONB operations
   - Materialized views
3. **Learn optimization**: 
   - Query planning internals
   - Partitioning strategies
   - Replication
4. **Try other databases**: 
   - MySQL (differs in syntax)
   - SQLite (embedded)
   - SQL Server (T-SQL)

---

**Remember**: Everyone starts somewhere. Be patient with yourself and celebrate small wins! 🎉

