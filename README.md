# 🏢 Real Estate & Property Management System

A full-stack, database-driven application to manage properties, tenants, rental agreements, rent payments, maintenance requests, and property investment analytics.

---

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| Database | MySQL 8.0+ (InnoDB, Triggers, Stored Procedures, Views) |
| Backend | Java 17 + Spring Boot 3 (Spring Data JPA, Hibernate, JDBC) |
| Frontend | HTML5, CSS3, JavaScript (ES6+), Bootstrap 5, Chart.js |
| Build Tool | Maven |
| Version Control | Git + GitHub |

---

## 🏗️ Architecture

```
[ Frontend: HTML/CSS/JS + Chart.js ]
                │
                │ HTTP REST (JSON)
                ▼
[ Spring Boot Backend: Controller → Service → Repository ]
                │
       ┌────────┴────────┐
       ▼                 ▼
[ JPA Repositories ] [ JDBC Analytics Engine ]
       │                 │
       └────────┬────────┘
                │ JDBC / SQL
                ▼
     [ MySQL 8.0 Database ]
     ├── 9 Normalized Tables
     ├── Stored Procedures (Transactions + Rollback)
     ├── Triggers (JSON Audit Trail)
     └── Advanced Analytical Queries (CTEs, Window Functions)
```

---

## 🗃️ Database Schema — 9 Tables

```
Owners ──< Properties ──< Rental_Agreements ──< Rent_Payments
                │                                    │
                ├──< Maintenance_Requests ──< Expenses│
                │                                    ▼
                ├──< Property_Valuations         Audit_Logs
                │
             Tenants
```

| Table | Description |
|---|---|
| `Owners` | Property owner details |
| `Properties` | Property info, type, rent, availability status |
| `Tenants` | Tenant personal records |
| `Rental_Agreements` | Lease contracts linking tenants to properties |
| `Rent_Payments` | Payment tracking — paid, pending, overdue, partial |
| `Maintenance_Requests` | Repair/service requests with priority and status |
| `Expenses` | Cost tracking per property or maintenance request |
| `Property_Valuations` | Market valuation history for ROI/yield calculations |
| `Audit_Logs` | JSON-based audit trail of all key data changes |

---

## 📂 SQL Files

| File | Description |
|---|---|
| [`sql/01_schema.sql`](sql/01_schema.sql) | All 9 table DDLs with constraints, ENUMs, and indexes |
| [`sql/02_sample_data.sql`](sql/02_sample_data.sql) | Realistic seed data — 5 owners, 15 properties, 12 tenants, 56 payments |
| [`sql/03_analytical_queries.sql`](sql/03_analytical_queries.sql) | 25 analytical queries demonstrating advanced SQL concepts |
| [`sql/04_stored_procedures.sql`](sql/04_stored_procedures.sql) | 3 stored procedures with transactions and rollback |
| [`sql/05_triggers.sql`](sql/05_triggers.sql) | 3 triggers for audit trail and automated vacancy updates |

---

## 🔍 25 Analytical SQL Queries

| # | Query | SQL Concept |
|---|---|---|
| Q1 | Active lease roster — tenant + property + owner | INNER JOIN |
| Q2 | Properties with current tenant or "VACANT" | LEFT JOIN + COALESCE |
| Q3 | Full payment history with tenant + property | JOIN × 4 |
| Q4 | Maintenance requests with total repair cost | JOIN + GROUP BY |
| Q5 | Owner portfolio — total properties + monthly income | JOIN + aggregation |
| Q6 | Top 5 properties by rental income (last 12 months) | GROUP BY + ORDER BY + LIMIT |
| Q7 | Owners with more than 3 properties | GROUP BY + HAVING COUNT |
| Q8 | Properties with avg monthly expense > ₹10,000 | GROUP BY + HAVING AVG |
| Q9 | Tenants who missed more than 2 payments | GROUP BY + HAVING + CASE |
| Q10 | Properties with rent above city average | Correlated Subquery |
| Q11 | Tenants with total paid > 90% of contracted amount | Scalar Subquery |
| Q12 | Maintenance requests costlier than property avg | Subquery in WHERE |
| Q13 | Monthly income + month-over-month % growth | CTE + LAG() |
| Q14 | Overdue payment aging: 0–30, 31–60, 60+ days | CTE + DATEDIFF + CASE |
| Q15 | 6-month rolling revenue per property | CTE + Window Frame |
| Q16 | Tenant churn — leases not renewed within 30 days | CTE + LEFT JOIN |
| Q17 | Rank properties by revenue within each city | RANK() OVER PARTITION BY |
| Q18 | Running total of rent collected per property | SUM() OVER |
| Q19 | Days since last payment per tenant | LAG() OVER PARTITION BY |
| Q20 | Month-over-month revenue % change per property | LAG() arithmetic |
| Q21 | Payment classifier: PAID / PENDING / OVERDUE / PARTIAL | CASE + DATEDIFF |
| Q22 | Property profitability tier: HIGH / MEDIUM / LOW | CASE + net income |
| Q23 | Properties vacant for more than 60 days | DATEDIFF + LEFT JOIN |
| Q24 | Net income per property = rent − expenses | Multi-table aggregation |
| Q25 | Gross rental yield (%) = annual rent ÷ valuation | Subquery + DECIMAL math |

---

## ⚙️ Stored Procedures

| Procedure | Purpose |
|---|---|
| `record_rent_payment(agreement_id, amount, date, mode)` | Records payment with TRANSACTION + ROLLBACK safety |
| `close_lease(agreement_id, end_date)` | Closes lease and marks property vacant atomically |
| `get_monthly_report(year, month)` | Returns income, expenses, and net profit per property |

---

## ⚡ Triggers

| Trigger | Fires On | Action |
|---|---|---|
| `trg_after_payment_insert` | AFTER INSERT on `Rent_Payments` | Logs new payment to `Audit_Logs` (JSON) |
| `trg_after_payment_update` | AFTER UPDATE on `Rent_Payments` | Logs status/amount changes to `Audit_Logs` |
| `trg_after_agreement_update` | AFTER UPDATE on `Rental_Agreements` | Auto-sets property to vacant when lease ends |

---

## 🌐 REST API Endpoints

### Analytics & Reports (Powered by Direct SQL Queries)
- `GET /api/analytics/occupancy` — Overall occupancy metrics & rates
- `GET /api/analytics/monthly-income` — Monthly rent totals & MoM % growth (CTE + LAG)
- `GET /api/analytics/top-properties` — Top 5 revenue properties
- `GET /api/analytics/overdue-aging` — Overdue rent aging buckets (0–30, 31–60, 60+ days)
- `GET /api/analytics/net-income` — Net income per property (rent collected − expenses)
- `GET /api/analytics/yield` — Gross rental yield % against market valuations
- `GET /api/analytics/vacant-properties` — Long-term vacant properties (> 60 days)
- `GET /api/analytics/expense-breakdown` — Expenses categorized
- `GET /api/analytics/owner-portfolios` — Owner property count and income summary
- `POST /api/analytics/close-lease` — Calls `close_lease` stored procedure
- `GET /api/analytics/monthly-report` — Calls `get_monthly_report` stored procedure

### Entity Operations
- `GET /api/properties` — List/filter properties by status or city
- `GET /api/tenants` — List tenants
- `GET /api/payments` — List payment transactions
- `POST /api/payments/record` — Records a payment (calls `record_rent_payment` stored procedure)
- `GET /api/maintenance` — List maintenance requests

---

## 🚀 How to Run Locally

### 1. Database Setup
```bash
# Clone the repository
git clone https://github.com/kripagayakwad7-jpg/Real_Estate_and_Property_Management_System.git
cd Real_Estate_and_Property_Management_System

# In MySQL Workbench or CLI, run in order:
mysql -u root -p < sql/01_schema.sql
mysql -u root -p < sql/02_sample_data.sql
mysql -u root -p < sql/04_stored_procedures.sql
mysql -u root -p < sql/05_triggers.sql
```

### 2. Configure Spring Boot
Create or update `backend/src/main/resources/application.yml` (template provided in `application-sample.yml`):
```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/real_estate_db?useSSL=false&serverTimezone=UTC
    username: root
    password: YOUR_PASSWORD
```

### 3. Run Backend & Frontend
```bash
cd backend
mvn spring-boot:run
```

Once started:
- **Interactive Dashboard:** [http://localhost:8080/index.html](http://localhost:8080/index.html)
- **Properties Directory:** [http://localhost:8080/properties.html](http://localhost:8080/properties.html)
- **Payment Manager:** [http://localhost:8080/payments.html](http://localhost:8080/payments.html)

---

## 👤 Author

**Kripa Gayakwad**  
GitHub: [@kripagayakwad7-jpg](https://github.com/kripagayakwad7-jpg)
