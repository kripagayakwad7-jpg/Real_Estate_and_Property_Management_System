-- ============================================================
--  Real Estate & Property Management System
--  File        : 04_stored_procedures.sql
--  Description : 3 stored procedures with transactions
--  Run AFTER   : 01_schema.sql + 02_sample_data.sql
-- ============================================================

USE real_estate_db;

DELIMITER $$

-- ============================================================
-- PROCEDURE 1: record_rent_payment
-- Purpose    : Insert a rent payment inside a transaction.
--              Automatically marks the record PAID, PARTIAL,
--              or keeps it OVERDUE. Rolls back on any error.
-- Usage      : CALL record_rent_payment(1, 28000.00, '2024-12-05', 'upi');
-- ============================================================
DROP PROCEDURE IF EXISTS record_rent_payment$$

CREATE PROCEDURE record_rent_payment (
    IN p_agreement_id   INT,
    IN p_amount         DECIMAL(12,2),
    IN p_payment_date   DATE,
    IN p_payment_mode   ENUM('cash','bank_transfer','upi','cheque')
)
BEGIN
    DECLARE v_amount_due     DECIMAL(12,2);
    DECLARE v_amount_paid    DECIMAL(12,2);
    DECLARE v_payment_id     INT;
    DECLARE v_new_status     ENUM('paid','pending','overdue','partial');
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Error recording payment — transaction rolled back.';
    END;

    START TRANSACTION;

    -- Find the most recent pending/overdue payment for this agreement
    SELECT payment_id, amount_due, amount_paid
    INTO v_payment_id, v_amount_due, v_amount_paid
    FROM Rent_Payments
    WHERE agreement_id = p_agreement_id
      AND status IN ('pending', 'overdue', 'partial')
    ORDER BY due_date ASC
    LIMIT 1;

    IF v_payment_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'No pending or overdue payment found for this agreement.';
    END IF;

    -- Determine new status based on amount paid
    SET v_amount_paid = v_amount_paid + p_amount;
    IF v_amount_paid >= v_amount_due THEN
        SET v_new_status = 'paid';
    ELSE
        SET v_new_status = 'partial';
    END IF;

    -- Update the payment record
    UPDATE Rent_Payments
    SET amount_paid    = v_amount_paid,
        payment_date   = p_payment_date,
        payment_mode   = p_payment_mode,
        status         = v_new_status,
        updated_at     = CURRENT_TIMESTAMP
    WHERE payment_id = v_payment_id;

    COMMIT;

    -- Return result
    SELECT
        v_payment_id     AS payment_id,
        v_amount_due     AS amount_due,
        v_amount_paid    AS amount_paid,
        v_new_status     AS new_status,
        'Payment recorded successfully' AS message;
END$$

-- ============================================================
-- PROCEDURE 2: close_lease
-- Purpose    : Mark a rental agreement as 'expired' and
--              automatically set the property status to 'vacant'.
--              Both updates are wrapped in a single transaction.
-- Usage      : CALL close_lease(1, '2025-12-31');
-- ============================================================
DROP PROCEDURE IF EXISTS close_lease$$

CREATE PROCEDURE close_lease (
    IN p_agreement_id   INT,
    IN p_end_date       DATE
)
BEGIN
    DECLARE v_property_id   INT;
    DECLARE v_tenant_name   VARCHAR(100);
    DECLARE v_property_title VARCHAR(150);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Error closing lease — transaction rolled back.';
    END;

    START TRANSACTION;

    -- Get the property_id for this agreement
    SELECT ra.property_id, t.full_name, p.title
    INTO v_property_id, v_tenant_name, v_property_title
    FROM Rental_Agreements ra
    INNER JOIN Tenants t    ON ra.tenant_id    = t.tenant_id
    INNER JOIN Properties p ON ra.property_id  = p.property_id
    WHERE ra.agreement_id = p_agreement_id
      AND ra.status = 'active';

    IF v_property_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'No active agreement found with given agreement_id.';
    END IF;

    -- Close the lease
    UPDATE Rental_Agreements
    SET status     = 'expired',
        end_date   = p_end_date,
        updated_at = CURRENT_TIMESTAMP
    WHERE agreement_id = p_agreement_id;

    -- Mark property as vacant
    UPDATE Properties
    SET status     = 'vacant',
        updated_at = CURRENT_TIMESTAMP
    WHERE property_id = v_property_id;

    COMMIT;

    SELECT
        p_agreement_id      AS agreement_id,
        v_property_title    AS property_title,
        v_tenant_name       AS former_tenant,
        p_end_date          AS closed_on,
        'Lease closed and property marked vacant' AS message;
END$$

-- ============================================================
-- PROCEDURE 3: get_monthly_report
-- Purpose    : Returns income, expenses, and net profit for
--              all properties in a given year-month.
-- Usage      : CALL get_monthly_report(2024, 10);
-- ============================================================
DROP PROCEDURE IF EXISTS get_monthly_report$$

CREATE PROCEDURE get_monthly_report (
    IN p_year   INT,
    IN p_month  INT
)
BEGIN
    SELECT
        p.property_id,
        p.title                                   AS property_title,
        p.city,
        o.full_name                               AS owner_name,
        COALESCE(income.total_collected, 0)       AS rent_collected,
        COALESCE(expenses.total_expenses, 0)      AS total_expenses,
        COALESCE(income.total_collected, 0)
            - COALESCE(expenses.total_expenses, 0) AS net_income,
        COALESCE(income.payment_count, 0)         AS payments_received
    FROM Properties p
    INNER JOIN Owners o ON p.owner_id = o.owner_id
    LEFT JOIN (
        SELECT ra.property_id,
               SUM(rp.amount_paid)  AS total_collected,
               COUNT(rp.payment_id) AS payment_count
        FROM Rent_Payments rp
        INNER JOIN Rental_Agreements ra ON rp.agreement_id = ra.agreement_id
        WHERE YEAR(rp.payment_date) = p_year
          AND MONTH(rp.payment_date) = p_month
          AND rp.status IN ('paid', 'partial')
        GROUP BY ra.property_id
    ) AS income ON p.property_id = income.property_id
    LEFT JOIN (
        SELECT property_id, SUM(amount) AS total_expenses
        FROM Expenses
        WHERE YEAR(expense_date) = p_year
          AND MONTH(expense_date) = p_month
        GROUP BY property_id
    ) AS expenses ON p.property_id = expenses.property_id
    ORDER BY net_income DESC;
END$$

DELIMITER ;

-- ============================================================
-- Test the procedures
-- ============================================================
-- CALL record_rent_payment(1, 28000.00, '2024-12-05', 'upi');
-- CALL close_lease(2, '2025-02-28');
-- CALL get_monthly_report(2024, 10);
