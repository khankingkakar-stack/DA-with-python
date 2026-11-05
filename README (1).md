# Assignment 09 — Joins & GROUP BY

**Author:** Waleed Khan  
**Database:** BikeStores  
**Language:** T-SQL (Microsoft SQL Server)  
**Tool:** SQL Server Management Studio (SSMS)

## Overview

This assignment demonstrates how to retrieve, combine, summarize, and filter relational data using SQL Server. It uses the BikeStores sample database.

## Learning Objectives

- Retrieve related data using `INNER JOIN`, `LEFT JOIN`, `RIGHT JOIN`, and `FULL OUTER JOIN`.
- Join three or more tables using primary-key and foreign-key relationships.
- Identify unmatched records using `NULL`.
- Calculate order-line totals and store revenue.
- Apply aggregate functions: `COUNT`, `MIN`, `MAX`, `AVG`, and `SUM`.
- Summarize data with `GROUP BY`.
- Filter aggregated results with `HAVING`.
- Sort and limit results using `ORDER BY` and `TOP`.

## Assignment Questions

| Question | Topic | Task |
|---|---|---|
| 1 | INNER JOIN | Products with their brand and list price |
| 2 | Multi-table JOIN | Products, brands, and categories priced above 1000 |
| 3 | LEFT JOIN | All customers and orders; customers without orders |
| 4 | RIGHT / FULL OUTER JOIN | Stores and staff; products without stock records |
| 5 | Multi-table JOIN | Detailed order report with discounted line totals |
| 6 | Aggregate functions | Product count and list-price statistics |
| 7 | GROUP BY | Product counts by category; average price by brand and year |
| 8 | GROUP BY with JOINs | Orders per customer; revenue per store |
| 9 | HAVING | Brands with over 20 products; customers with at least 3 orders |
| 10 | Combined challenge | Top 5 products by quantity sold in completed orders |

## Repository Structure

```text
assignment-09-bikestores/
├── README.md
├── Assignment_09_Joins_GroupBy.sql
└── .gitignore
```

## Requirements

- Microsoft SQL Server
- SQL Server Management Studio (SSMS)
- BikeStores sample database

## How to Run

1. Install or configure SQL Server and SSMS.
2. Restore or attach the BikeStores sample database.
3. Open `Assignment_09_Joins_GroupBy.sql` in SSMS.
4. Confirm that the database is named `BikeStores`.
5. Execute the complete script, or select and execute each question separately.
6. Review the result grid after each query.

## Important Notes

- The script uses `USE BikeStores;` and SQL Server-specific syntax such as `TOP`, `GO`, and `CONCAT`.
- Questions 3A and 8A use `LEFT JOIN` so customers with no orders remain in the result.
- Question 7A uses `LEFT JOIN` so categories with no products can also appear with a count of zero.
- Question 8B uses `LEFT JOIN` and `COALESCE` so stores with no sales appear with zero revenue.
- Question 4B uses the requested `FULL OUTER JOIN`, then filters for rows without a matching stock record.
- Question 10 treats `order_status = 4` as completed, as specified in the assignment.

## Revenue Formula

```sql
quantity * list_price * (1 - discount)
```

The discount is applied to each order-item line before the revenue is summed.

## SQL Concepts Quick Reference

| Clause / Function | Purpose |
|---|---|
| `INNER JOIN` | Returns rows with matching values in both tables |
| `LEFT JOIN` | Keeps every row from the left table |
| `RIGHT JOIN` | Keeps every row from the right table |
| `FULL OUTER JOIN` | Keeps matching and non-matching rows from both tables |
| `WHERE` | Filters rows before grouping |
| `GROUP BY` | Creates groups for aggregate calculations |
| `HAVING` | Filters groups after aggregation |
| `COUNT()` | Counts rows or non-NULL values |
| `SUM()` | Calculates a total |
| `AVG()` | Calculates an average |
| `MIN()` / `MAX()` | Finds the minimum / maximum |
| `ORDER BY` | Sorts the result |
| `TOP` | Limits the number of returned rows |

## Author

**Waleed Khan**
