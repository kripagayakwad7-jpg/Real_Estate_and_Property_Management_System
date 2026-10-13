-- ============================================================
--  Real Estate & Property Management System
--  File        : 05_triggers.sql
--  Description : 3 triggers for audit trail and automation
--  Run AFTER   : 01_schema.sql + 02_sample_data.sql
-- ============================================================

USE real_estate_db;

DELIMITER $$

-- ============================================================
-- TRIGGER 1: trg_after_payment_insert
-- Fires  : AFTER INSERT on Rent_Payments
-- Action : Writes a log entry to Audit_Logs with the new
--          payment details as JSON.
-- ============================================================
DROP TRIGGER IF EXISTS trg_after_payment_insert$$

CREATE TRIGGER trg_after_payment_insert
AFTER INSERT ON Rent_Payments
FOR EACH ROW
BEGIN
    INSERT INTO Audit_Logs (table_name, record_id, action, old_value, new_value, changed_by)
    VALUES (
        'Rent_Payments',
        NEW.payment_id,
        'INSERT',
        NULL,
        JSON_OBJECT(
            'agreement_id',   NEW.agreement_id,
            'amount_due',     NEW.amount_due,
            'amount_paid',    NEW.amount_paid,
            'due_date',       NEW.due_date,
            'payment_date',   NEW.payment_date,
            'status',         NEW.status,
            'payment_mode',   NEW.payment_mode
        ),
        'system'
    );
END$$

-- ============================================================
-- TRIGGER 2: trg_after_payment_update
-- Fires  : AFTER UPDATE on Rent_Payments
-- Action : Logs old and new status + amounts when a payment
--          record is modified (e.g., marked as paid).
-- ============================================================
DROP TRIGGER IF EXISTS trg_after_payment_update$$

CREATE TRIGGER trg_after_payment_update
AFTER UPDATE ON Rent_Payments
FOR EACH ROW
BEGIN
    IF OLD.status <> NEW.status OR OLD.amount_paid <> NEW.amount_paid THEN
        INSERT INTO Audit_Logs (table_name, record_id, action, old_value, new_value, changed_by)
        VALUES (
            'Rent_Payments',
            NEW.payment_id,
            'UPDATE',
            JSON_OBJECT(
                'status',       OLD.status,
                'amount_paid',  OLD.amount_paid,
                'payment_date', OLD.payment_date,
                'payment_mode', OLD.payment_mode
            ),
            JSON_OBJECT(
                'status',       NEW.status,
                'amount_paid',  NEW.amount_paid,
                'payment_date', NEW.payment_date,
                'payment_mode', NEW.payment_mode
            ),
            'system'
        );
    END IF;
END$$

-- ============================================================
-- TRIGGER 3: trg_after_agreement_update
-- Fires  : AFTER UPDATE on Rental_Agreements
-- Action : (a) Logs status changes to Audit_Logs.
--          (b) If agreement is set to 'expired' or 'terminated',
--              automatically marks the property as 'vacant'.
-- ============================================================
DROP TRIGGER IF EXISTS trg_after_agreement_update$$

CREATE TRIGGER trg_after_agreement_update
AFTER UPDATE ON Rental_Agreements
FOR EACH ROW
BEGIN
    -- Log status changes
    IF OLD.status <> NEW.status THEN
        INSERT INTO Audit_Logs (table_name, record_id, action, old_value, new_value, changed_by)
        VALUES (
            'Rental_Agreements',
            NEW.agreement_id,
            'UPDATE',
            JSON_OBJECT(
                'status',    OLD.status,
                'end_date',  OLD.end_date
            ),
            JSON_OBJECT(
                'status',    NEW.status,
                'end_date',  NEW.end_date
            ),
            'system'
        );

        -- Auto-mark property as vacant when lease ends
        IF NEW.status IN ('expired', 'terminated') THEN
            UPDATE Properties
            SET status     = 'vacant',
                updated_at = CURRENT_TIMESTAMP
            WHERE property_id = NEW.property_id
              AND status = 'occupied';
        END IF;

        -- Auto-mark property as occupied when new lease activates
        IF NEW.status = 'active' AND OLD.status <> 'active' THEN
            UPDATE Properties
            SET status     = 'occupied',
                updated_at = CURRENT_TIMESTAMP
            WHERE property_id = NEW.property_id;
        END IF;
    END IF;
END$$

DELIMITER ;

-- ============================================================
-- Verify triggers are created
-- ============================================================
SELECT trigger_name, event_manipulation, event_object_table, action_timing
FROM information_schema.triggers
WHERE trigger_schema = 'real_estate_db'
ORDER BY event_object_table;
