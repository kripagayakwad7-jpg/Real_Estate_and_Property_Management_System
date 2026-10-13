package com.realestate.repository;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;

@Repository
public class AnalyticsRepository {

    private final JdbcTemplate jdbcTemplate;

    public AnalyticsRepository(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    /**
     * Q6: Top 5 revenue-generating properties in last 12 months
     */
    public List<Map<String, Object>> getTopRevenueProperties() {
        String sql = """
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
            WHERE rp.status IN ('paid', 'partial')
            GROUP BY p.property_id, p.title, p.city, p.property_type
            ORDER BY total_income_12m DESC
            LIMIT 5;
        """;
        return jdbcTemplate.queryForList(sql);
    }

    /**
     * Q13: Monthly rental income with month-over-month growth (CTE + LAG)
     */
    public List<Map<String, Object>> getMonthlyIncomeGrowth() {
        String sql = """
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
        """;
        return jdbcTemplate.queryForList(sql);
    }

    /**
     * Q14: Overdue payment aging buckets (0-30, 31-60, 60+ days)
     */
    public List<Map<String, Object>> getOverdueAgingReport() {
        String sql = """
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
        """;
        return jdbcTemplate.queryForList(sql);
    }

    /**
     * Q23: Properties vacant for more than 60 days
     */
    public List<Map<String, Object>> getLongTermVacantProperties() {
        String sql = """
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
        """;
        return jdbcTemplate.queryForList(sql);
    }

    /**
     * Q24: Net income per property = rent collected - expenses
     */
    public List<Map<String, Object>> getPropertyNetIncome() {
        String sql = """
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
        """;
        return jdbcTemplate.queryForList(sql);
    }

    /**
     * Q25: Gross rental yield (%) = (annual rent / valuation) * 100
     */
    public List<Map<String, Object>> getPropertyGrossYield() {
        String sql = """
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
        """;
        return jdbcTemplate.queryForList(sql);
    }

    /**
     * Q5: Owner portfolio summary
     */
    public List<Map<String, Object>> getOwnerPortfolioSummary() {
        String sql = """
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
        """;
        return jdbcTemplate.queryForList(sql);
    }

    /**
     * Expense breakdown by category for charts
     */
    public List<Map<String, Object>> getExpenseCategoryBreakdown() {
        String sql = """
            SELECT
                category,
                COUNT(expense_id) AS total_count,
                SUM(amount)       AS total_amount
            FROM Expenses
            GROUP BY category
            ORDER BY total_amount DESC;
        """;
        return jdbcTemplate.queryForList(sql);
    }

    /**
     * Occupancy stats
     */
    public Map<String, Object> getOccupancyStats() {
        String sql = """
            SELECT
                COUNT(*) AS total_properties,
                SUM(CASE WHEN status = 'occupied' THEN 1 ELSE 0 END) AS occupied,
                SUM(CASE WHEN status = 'vacant' THEN 1 ELSE 0 END) AS vacant,
                SUM(CASE WHEN status = 'under_maintenance' THEN 1 ELSE 0 END) AS under_maintenance,
                ROUND(SUM(CASE WHEN status = 'occupied' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) AS occupancy_rate
            FROM Properties;
        """;
        return jdbcTemplate.queryForMap(sql);
    }

    /**
     * Stored Procedure: record_rent_payment
     */
    public Map<String, Object> callRecordRentPaymentProcedure(Integer agreementId, BigDecimal amount, LocalDate date, String mode) {
        String sql = "CALL record_rent_payment(?, ?, ?, ?)";
        return jdbcTemplate.queryForMap(sql, agreementId, amount, date, mode);
    }

    /**
     * Stored Procedure: close_lease
     */
    public Map<String, Object> callCloseLeaseProcedure(Integer agreementId, LocalDate endDate) {
        String sql = "CALL close_lease(?, ?)";
        return jdbcTemplate.queryForMap(sql, agreementId, endDate);
    }

    /**
     * Stored Procedure: get_monthly_report
     */
    public List<Map<String, Object>> callGetMonthlyReportProcedure(int year, int month) {
        String sql = "CALL get_monthly_report(?, ?)";
        return jdbcTemplate.queryForList(sql, year, month);
    }
}
