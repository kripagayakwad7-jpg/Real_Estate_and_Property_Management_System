-- ============================================================
--  Real Estate & Property Management System
--  File        : 03_analytical_queries.sql
--  Description : 25 analytical SQL queries grouped by concept
--  Run AFTER   : 01_schema.sql + 02_sample_data.sql
-- ============================================================

USE real_estate_db;

-- ============================================================
-- GROUP A: JOINs
-- ============================================================

-- Q1: Full active lease roster — tenant + property + owner
-- Demonstrates: INNER JOIN across 4 tables
SELECT
    ra.agreement_id,
    t.full_name              AS tenant_name,
    t.phone                  AS tenant_phone,
    p.title                  AS property_title,
    p.city                   AS property_city,
    o.full_name              AS owner_name,
    ra.monthly_rent,
    ra.start_date,
    ra.end_date
FROM Rental_Agreements ra
INNER JOIN Properties p  ON ra.property_id = p.property_id
INNER JOIN Tenants t     ON ra.tenant_id   = t.tenant_id
INNER JOIN Owners o      ON p.owner_id     = o.owner_id
WHERE ra.status = 'active'
ORDER BY p.city, t.full_name;

-- ============================================================

-- Q2: All properties with current tenant or 'VACANT'
-- Demonstrates: LEFT JOIN + COALESCE + CASE
SELECT
    p.property_id,
    p.title,
    p.city,
    p.property_type,
    p.rent_amount,
    COALESCE(t.full_name, 'VACANT')  AS current_tenant,
    COALESCE(t.phone, '—')           AS tenant_phone,
    p.status
FROM Properties p
LEFT JOIN Rental_Agreements ra
    ON p.property_id = ra.property_id AND ra.status = 'active'
LEFT JOIN Tenants t ON ra.tenant_id = t.tenant_id
ORDER BY p.city, p.title;

-- ============================================================

-- Q3: Full payment history — tenant + property + payment details
-- Demonstrates: JOIN across 4 tables + date formatting
SELECT
    rp.payment_id,
    t.full_name              AS tenant_name,
    p.title                  AS property_title,
    p.city,
    rp.amount_due,
    rp.amount_paid,
    rp.due_date,
    rp.payment_date,
    rp.status                AS payment_status,
    rp.payment_mode
FROM Rent_Payments rp
INNER JOIN Rental_Agreements ra ON rp.agreement_id = ra.agreement_id
INNER JOIN Tenants t            ON ra.tenant_id    = t.tenant_id
INNER JOIN Properties p         ON ra.property_id  = p.property_id
ORDER BY rp.due_date DESC;

-- ============================================================

-- Q4: Maintenance requests with property + total repair cost per request
-- Demonstrates: LEFT JOIN + GROUP BY + SUM
SELECT
    mr.request_id,
    p.title                  AS property_title,
    p.city,
    mr.description,
    mr.priority,
    mr.status,
    mr.request_date,
    mr.resolved_date,
    COALESCE(SUM(e.amount), 0)  AS total_repair_cost
FROM Maintenance_Requests mr
INNER JOIN Properties p ON mr.property_id = p.property_id
LEFT JOIN Expenses e    ON mr.request_id  = e.request_id
GROUP BY mr.request_id, p.title, p.city, mr.description, mr.priority,
         mr.status, mr.request_date, mr.resolved_date
ORDER BY total_repair_cost DESC;

-- ============================================================

-- Q5: Owner portfolio summary — total properties + total monthly income
-- Demonstrates: JOIN + GROUP BY aggregation
SELECT
    o.owner_id,
    o.full_name              AS owner_name,
    o.city                   AS owner_city,
    COUNT(p.property_id)     AS total_properties,
    SUM(CASE WHEN p.status = 'occupied' THEN 1 ELSE 0 END) AS occupied_count,
    SUM(CASE WHEN p.status = 'vacant'   THEN 1 ELSE 0 END) AS vacant_count,
    SUM(CASE WHEN p.status = 'occupied' THEN p.rent_amount ELSE 0 END) AS monthly_income
FROM Owners o
LEFT JOIN Properties p ON o.owner_id = p.owner_id
GROUP BY o.owner_id, o.full_name, o.city
ORDER BY monthly_income DESC;

-- ============================================================
-- GROUP B: GROUP BY + HAVING
-- ============================================================

-- Q6: Top 5 properties by rental income in last 12 months
-- Demonstrates: GROUP BY + HAVING + ORDER BY + LIMIT
SELECT
    p.property_id,
    p.title,
    p.city,
    p.property_type,
    SUM(rp.amount_paid)      AS total_income_12m,
    COUNT(rp.payment_id)     AS total_payments,
    ROUND(AVG(rp.amount_paid), 2) AS avg_monthly_payment
FROM Rent_Payments rp
INNER JOIN Rental_Agreements ra ON rp.agreement_id = ra.agreement_id
INNER JOIN Properties p         ON ra.property_id  = p.property_id
WHERE rp.payment_date >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH)
  AND rp.status IN ('paid', 'partial')
GROUP BY p.property_id, p.title, p.city, p.property_type
ORDER BY total_income_12m DESC
LIMIT 5;

-- ============================================================

-- Q7: Owners with more than 3 properties
-- Demonstrates: GROUP BY + HAVING COUNT
SELECT
    o.owner_id,
    o.full_name,
    o.city,
    COUNT(p.property_id)  AS property_count
FROM Owners o
INNER JOIN Properties p ON o.owner_id = p.owner_id
GROUP BY o.owner_id, o.full_name, o.city
HAVING COUNT(p.property_id) > 3
ORDER BY property_count DESC;

-- ============================================================

-- Q8: Properties where average monthly expense exceeds ₹10,000
-- Demonstrates: GROUP BY + HAVING AVG
SELECT
    p.property_id,
    p.title,
    p.city,
    COUNT(e.expense_id)          AS total_expenses,
    SUM(e.amount)                AS total_expense_amount,
    ROUND(AVG(e.amount), 2)      AS avg_expense_per_entry,
    ROUND(SUM(e.amount) / 12, 2) AS avg_monthly_expense
FROM Properties p
INNER JOIN Expenses e ON p.property_id = e.property_id
GROUP BY p.property_id, p.title, p.city
HAVING avg_monthly_expense > 10000
ORDER BY avg_monthly_expense DESC;

-- ============================================================

-- Q9: Tenants who missed more than 2 payments in the past year
-- Demonstrates: GROUP BY + HAVING + CASE + date filter
SELECT
    t.tenant_id,
    t.full_name,
    t.email,
    t.phone,
    COUNT(*) AS missed_payments,
    SUM(rp.amount_due) AS total_amount_missed
FROM Tenants t
INNER JOIN Rental_Agreements ra ON t.tenant_id   = ra.tenant_id
INNER JOIN Rent_Payments rp     ON ra.agreement_id = rp.agreement_id
WHERE rp.status IN ('overdue', 'pending')
  AND rp.due_date >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH)
GROUP BY t.tenant_id, t.full_name, t.email, t.phone
HAVING missed_payments > 2
ORDER BY missed_payments DESC;

-- ============================================================
-- GROUP C: SUBQUERIES
-- ============================================================

-- Q10: Properties with rent above the average rent in their city
-- Demonstrates: Correlated subquery in WHERE
SELECT
    p.property_id,
    p.title,
    p.city,
    p.property_type,
    p.rent_amount,
    ROUND((SELECT AVG(p2.rent_amount)
           FROM Properties p2
           WHERE p2.city = p.city), 2) AS city_avg_rent,
    ROUND(p.rent_amount - (SELECT AVG(p2.rent_amount)
                           FROM Properties p2
                           WHERE p2.city = p.city), 2) AS above_avg_by
FROM Properties p
WHERE p.rent_amount > (
    SELECT AVG(p2.rent_amount)
    FROM Properties p2
    WHERE p2.city = p.city
)
ORDER BY p.city, above_avg_by DESC;

-- ============================================================

-- Q11: Tenants whose total paid rent is greater than 90% of contracted amount
-- Demonstrates: Scalar subquery in HAVING
SELECT
    t.tenant_id,
    t.full_name,
    SUM(rp.amount_paid)         AS total_paid,
    SUM(rp.amount_due)          AS total_due,
    ROUND(SUM(rp.amount_paid) / SUM(rp.amount_due) * 100, 1) AS payment_percent
FROM Tenants t
INNER JOIN Rental_Agreements ra ON t.tenant_id    = ra.tenant_id
INNER JOIN Rent_Payments rp     ON ra.agreement_id = rp.agreement_id
GROUP BY t.tenant_id, t.full_name
HAVING payment_percent > 90
ORDER BY payment_percent DESC;

-- ============================================================

-- Q12: Maintenance requests costing more than that property's average repair cost
-- Demonstrates: Correlated subquery in WHERE clause
SELECT
    mr.request_id,
    p.title               AS property_title,
    mr.description,
    e.amount              AS this_request_cost,
    ROUND((SELECT AVG(e2.amount)
           FROM Expenses e2
           WHERE e2.property_id = p.property_id), 2) AS property_avg_cost
FROM Maintenance_Requests mr
INNER JOIN Properties p ON mr.property_id = p.property_id
INNER JOIN Expenses e   ON mr.request_id  = e.request_id
WHERE e.amount > (
    SELECT AVG(e2.amount)
    FROM Expenses e2
    WHERE e2.property_id = p.property_id
)
ORDER BY this_request_cost DESC;

-- ============================================================
-- GROUP D: CTEs
-- ============================================================

-- Q13: Monthly rental income + month-over-month % growth
-- Demonstrates: CTE + LAG() window function
WITH MonthlyIncome AS (
    SELECT
        DATE_FORMAT(payment_date, '%Y-%m')  AS payment_month,
        SUM(amount_paid)                    AS monthly_total
    FROM Rent_Payments
    WHERE status IN ('paid', 'partial')
      AND payment_date IS NOT NULL
    GROUP BY DATE_FORMAT(payment_date, '%Y-%m')
)
SELECT
    payment_month,
    monthly_total,
    LAG(monthly_total) OVER (ORDER BY payment_month) AS prev_month_total,
    ROUND(
        (monthly_total - LAG(monthly_total) OVER (ORDER BY payment_month))
        / LAG(monthly_total) OVER (ORDER BY payment_month) * 100,
    1) AS mom_growth_pct
FROM MonthlyIncome
ORDER BY payment_month;

-- ============================================================

-- Q14: Overdue payment aging buckets — 0–30, 31–60, 60+ days
-- Demonstrates: CTE + DATEDIFF + CASE for aging analysis
WITH OverduePayments AS (
    SELECT
        t.full_name             AS tenant_name,
        p.title                 AS property_title,
        rp.amount_due,
        rp.amount_paid,
        (rp.amount_due - rp.amount_paid) AS balance_due,
        rp.due_date,
        DATEDIFF(CURDATE(), rp.due_date) AS days_overdue
    FROM Rent_Payments rp
    INNER JOIN Rental_Agreements ra ON rp.agreement_id = ra.agreement_id
    INNER JOIN Tenants t            ON ra.tenant_id    = t.tenant_id
    INNER JOIN Properties p         ON ra.property_id  = p.property_id
    WHERE rp.status IN ('overdue', 'partial')
)
SELECT
    tenant_name,
    property_title,
    balance_due,
    due_date,
    days_overdue,
    CASE
        WHEN days_overdue BETWEEN 0  AND 30 THEN '0–30 days'
        WHEN days_overdue BETWEEN 31 AND 60 THEN '31–60 days'
        ELSE '60+ days'
    END AS aging_bucket
FROM OverduePayments
ORDER BY days_overdue DESC;

-- ============================================================

-- Q15: 6-month rolling revenue per property
-- Demonstrates: CTE + SUM OVER with window frame
WITH MonthlyPropertyRevenue AS (
    SELECT
        p.property_id,
        p.title,
        DATE_FORMAT(rp.payment_date, '%Y-%m') AS pay_month,
        SUM(rp.amount_paid) AS monthly_revenue
    FROM Rent_Payments rp
    INNER JOIN Rental_Agreements ra ON rp.agreement_id = ra.agreement_id
    INNER JOIN Properties p         ON ra.property_id  = p.property_id
    WHERE rp.payment_date IS NOT NULL
    GROUP BY p.property_id, p.title, pay_month
)
SELECT
    property_id,
    title,
    pay_month,
    monthly_revenue,
    ROUND(AVG(monthly_revenue) OVER (
        PARTITION BY property_id
        ORDER BY pay_month
        ROWS BETWEEN 5 PRECEDING AND CURRENT ROW
    ), 2) AS rolling_6m_avg
FROM MonthlyPropertyRevenue
ORDER BY property_id, pay_month;

-- ============================================================

-- Q16: Tenant churn — leases expired and NOT renewed within 30 days
-- Demonstrates: CTE + LEFT JOIN to detect missing renewals
WITH ExpiredLeases AS (
    SELECT
        ra.agreement_id,
        ra.property_id,
        ra.tenant_id,
        ra.end_date,
        t.full_name  AS tenant_name,
        p.title      AS property_title
    FROM Rental_Agreements ra
    INNER JOIN Tenants t    ON ra.tenant_id    = t.tenant_id
    INNER JOIN Properties p ON ra.property_id  = p.property_id
    WHERE ra.status = 'expired'
)
SELECT
    el.tenant_name,
    el.property_title,
    el.end_date            AS lease_ended,
    new_ra.start_date      AS renewed_on,
    CASE
        WHEN new_ra.agreement_id IS NULL THEN 'CHURNED'
        WHEN DATEDIFF(new_ra.start_date, el.end_date) > 30 THEN 'DELAYED RENEWAL'
        ELSE 'RENEWED'
    END AS renewal_status
FROM ExpiredLeases el
LEFT JOIN Rental_Agreements new_ra
    ON el.property_id = new_ra.property_id
    AND new_ra.start_date > el.end_date
ORDER BY el.end_date DESC;

-- ============================================================
-- GROUP E: WINDOW FUNCTIONS
-- ============================================================

-- Q17: Rank properties by total revenue within each city
-- Demonstrates: RANK() OVER (PARTITION BY city ORDER BY revenue)
SELECT
    p.property_id,
    p.title,
    p.city,
    p.property_type,
    SUM(rp.amount_paid)  AS total_revenue,
    RANK() OVER (PARTITION BY p.city ORDER BY SUM(rp.amount_paid) DESC) AS city_rank
FROM Properties p
INNER JOIN Rental_Agreements ra ON p.property_id  = ra.property_id
INNER JOIN Rent_Payments rp     ON ra.agreement_id = rp.agreement_id
WHERE rp.status IN ('paid', 'partial')
GROUP BY p.property_id, p.title, p.city, p.property_type
ORDER BY p.city, city_rank;

-- ============================================================

-- Q18: Running total of rent collected per property per year
-- Demonstrates: SUM() OVER (PARTITION BY ORDER BY month)
SELECT
    p.property_id,
    p.title,
    DATE_FORMAT(rp.payment_date, '%Y-%m')  AS pay_month,
    SUM(rp.amount_paid)                    AS monthly_collected,
    SUM(SUM(rp.amount_paid)) OVER (
        PARTITION BY p.property_id
        ORDER BY DATE_FORMAT(rp.payment_date, '%Y-%m')
    ) AS running_total
FROM Rent_Payments rp
INNER JOIN Rental_Agreements ra ON rp.agreement_id = ra.agreement_id
INNER JOIN Properties p         ON ra.property_id  = p.property_id
WHERE rp.payment_date IS NOT NULL
  AND rp.status IN ('paid', 'partial')
GROUP BY p.property_id, p.title, pay_month
ORDER BY p.property_id, pay_month;

-- ============================================================

-- Q19: Days since last payment per tenant (detect at-risk tenants)
-- Demonstrates: LAG() to find gap between successive payments
SELECT
    t.tenant_id,
    t.full_name,
    rp.due_date,
    rp.payment_date,
    rp.status,
    LAG(rp.payment_date) OVER (
        PARTITION BY ra.tenant_id
        ORDER BY rp.due_date
    ) AS prev_payment_date,
    DATEDIFF(
        COALESCE(rp.payment_date, CURDATE()),
        LAG(rp.payment_date) OVER (
            PARTITION BY ra.tenant_id
            ORDER BY rp.due_date
        )
    ) AS days_since_prev_payment
FROM Rent_Payments rp
INNER JOIN Rental_Agreements ra ON rp.agreement_id = ra.agreement_id
INNER JOIN Tenants t            ON ra.tenant_id    = t.tenant_id
ORDER BY t.full_name, rp.due_date;

-- ============================================================

-- Q20: Month-over-month revenue % change per property
-- Demonstrates: LAG() over partitioned time series
WITH PropMonthly AS (
    SELECT
        p.property_id,
        p.title,
        DATE_FORMAT(rp.payment_date, '%Y-%m')  AS pay_month,
        SUM(rp.amount_paid)                    AS revenue
    FROM Rent_Payments rp
    INNER JOIN Rental_Agreements ra ON rp.agreement_id = ra.agreement_id
    INNER JOIN Properties p         ON ra.property_id  = p.property_id
    WHERE rp.payment_date IS NOT NULL
    GROUP BY p.property_id, p.title, pay_month
)
SELECT
    property_id,
    title,
    pay_month,
    revenue,
    LAG(revenue) OVER (PARTITION BY property_id ORDER BY pay_month) AS prev_revenue,
    ROUND(
        (revenue - LAG(revenue) OVER (PARTITION BY property_id ORDER BY pay_month))
        / NULLIF(LAG(revenue) OVER (PARTITION BY property_id ORDER BY pay_month), 0) * 100,
    1) AS mom_change_pct
FROM PropMonthly
ORDER BY property_id, pay_month;

-- ============================================================
-- GROUP F: CASE EXPRESSIONS
-- ============================================================

-- Q21: Payment status classifier — PAID / PENDING / OVERDUE / PARTIALLY PAID
-- Demonstrates: CASE + DATEDIFF + arithmetic
SELECT
    t.full_name              AS tenant_name,
    p.title                  AS property_title,
    rp.amount_due,
    rp.amount_paid,
    (rp.amount_due - rp.amount_paid) AS balance,
    rp.due_date,
    rp.payment_date,
    CASE
        WHEN rp.amount_paid >= rp.amount_due THEN 'PAID'
        WHEN rp.amount_paid > 0 AND rp.amount_paid < rp.amount_due THEN 'PARTIALLY PAID'
        WHEN rp.payment_date IS NULL AND rp.due_date < CURDATE() THEN
            CONCAT('OVERDUE — ', DATEDIFF(CURDATE(), rp.due_date), ' days')
        ELSE 'PENDING'
    END AS payment_classification
FROM Rent_Payments rp
INNER JOIN Rental_Agreements ra ON rp.agreement_id = ra.agreement_id
INNER JOIN Tenants t            ON ra.tenant_id    = t.tenant_id
INNER JOIN Properties p         ON ra.property_id  = p.property_id
ORDER BY rp.due_date DESC;

-- ============================================================

-- Q22: Property profitability tier — HIGH / MEDIUM / LOW
-- Demonstrates: CASE on computed net income
WITH PropertyNetIncome AS (
    SELECT
        p.property_id,
        p.title,
        p.city,
        COALESCE(SUM(rp.amount_paid), 0)  AS total_collected,
        COALESCE(SUM(e.amount), 0)         AS total_expenses,
        COALESCE(SUM(rp.amount_paid), 0) - COALESCE(SUM(e.amount), 0) AS net_income
    FROM Properties p
    LEFT JOIN Rental_Agreements ra ON p.property_id  = ra.property_id
    LEFT JOIN Rent_Payments rp     ON ra.agreement_id = rp.agreement_id
                                   AND rp.status IN ('paid', 'partial')
    LEFT JOIN Expenses e           ON p.property_id  = e.property_id
    GROUP BY p.property_id, p.title, p.city
)
SELECT
    property_id,
    title,
    city,
    total_collected,
    total_expenses,
    net_income,
    CASE
        WHEN net_income > 200000 THEN 'HIGH'
        WHEN net_income BETWEEN 50000 AND 200000 THEN 'MEDIUM'
        ELSE 'LOW'
    END AS profitability_tier
FROM PropertyNetIncome
ORDER BY net_income DESC;

-- ============================================================
-- GROUP G: ADVANCED ANALYTICS
-- ============================================================

-- Q23: Properties vacant for more than 60 days
-- Demonstrates: DATEDIFF + LEFT JOIN to find vacancies
SELECT
    p.property_id,
    p.title,
    p.city,
    p.property_type,
    p.rent_amount,
    MAX(ra.end_date)                         AS last_lease_ended,
    DATEDIFF(CURDATE(), MAX(ra.end_date))    AS days_vacant,
    ROUND(p.rent_amount * (DATEDIFF(CURDATE(), MAX(ra.end_date)) / 30), 0) AS estimated_lost_income
FROM Properties p
LEFT JOIN Rental_Agreements ra
    ON p.property_id = ra.property_id
    AND ra.status IN ('expired', 'terminated')
WHERE p.status = 'vacant'
GROUP BY p.property_id, p.title, p.city, p.property_type, p.rent_amount
HAVING days_vacant > 60 OR days_vacant IS NULL
ORDER BY days_vacant DESC;

-- ============================================================

-- Q24: Net income per property = total rent collected − total expenses
-- Demonstrates: Multi-table aggregation with LEFT JOINs
SELECT
    p.property_id,
    p.title,
    p.city,
    p.property_type,
    o.full_name                                           AS owner_name,
    COALESCE(SUM(DISTINCT_rent.total_rent), 0)            AS total_rent_collected,
    COALESCE(exp_data.total_expenses, 0)                  AS total_expenses,
    COALESCE(SUM(DISTINCT_rent.total_rent), 0)
        - COALESCE(exp_data.total_expenses, 0)            AS net_income
FROM Properties p
INNER JOIN Owners o ON p.owner_id = o.owner_id
LEFT JOIN (
    SELECT ra.property_id, SUM(rp.amount_paid) AS total_rent
    FROM Rental_Agreements ra
    INNER JOIN Rent_Payments rp ON ra.agreement_id = rp.agreement_id
    WHERE rp.status IN ('paid', 'partial')
    GROUP BY ra.property_id
) AS DISTINCT_rent ON p.property_id = DISTINCT_rent.property_id
LEFT JOIN (
    SELECT property_id, SUM(amount) AS total_expenses
    FROM Expenses
    GROUP BY property_id
) AS exp_data ON p.property_id = exp_data.property_id
GROUP BY p.property_id, p.title, p.city, p.property_type, o.full_name, exp_data.total_expenses
ORDER BY net_income DESC;

-- ============================================================

-- Q25: Gross rental yield = (annual rent ÷ latest market valuation) × 100
-- Demonstrates: Subquery for latest valuation + DECIMAL math
SELECT
    p.property_id,
    p.title,
    p.city,
    p.rent_amount,
    (p.rent_amount * 12)                       AS annual_rent,
    latest_val.market_value                    AS latest_valuation,
    latest_val.valuation_date,
    ROUND(
        (p.rent_amount * 12) / latest_val.market_value * 100,
    2)                                         AS gross_yield_pct,
    CASE
        WHEN (p.rent_amount * 12) / latest_val.market_value * 100 >= 6 THEN 'Excellent'
        WHEN (p.rent_amount * 12) / latest_val.market_value * 100 >= 4 THEN 'Good'
        WHEN (p.rent_amount * 12) / latest_val.market_value * 100 >= 2 THEN 'Average'
        ELSE 'Poor'
    END AS yield_rating
FROM Properties p
INNER JOIN (
    SELECT pv1.property_id, pv1.market_value, pv1.valuation_date
    FROM Property_Valuations pv1
    WHERE pv1.valuation_date = (
        SELECT MAX(pv2.valuation_date)
        FROM Property_Valuations pv2
        WHERE pv2.property_id = pv1.property_id
    )
) AS latest_val ON p.property_id = latest_val.property_id
ORDER BY gross_yield_pct DESC;
