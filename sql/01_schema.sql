-- ============================================================
--  Real Estate & Property Management System
--  File        : 01_schema.sql
--  Database    : MySQL 8.0+
--  Description : Creates all 9 tables with constraints & indexes
-- ============================================================

CREATE DATABASE IF NOT EXISTS real_estate_db
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE real_estate_db;

-- ============================================================
-- TABLE 1: Owners
-- ============================================================
CREATE TABLE Owners (
    owner_id      INT             AUTO_INCREMENT PRIMARY KEY,
    full_name     VARCHAR(100)    NOT NULL,
    email         VARCHAR(100)    NOT NULL UNIQUE,
    phone         VARCHAR(15)     NOT NULL,
    address       VARCHAR(255),
    city          VARCHAR(50),
    state         VARCHAR(50),
    created_at    TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    updated_at    TIMESTAMP       DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- ============================================================
-- TABLE 2: Properties
-- ============================================================
CREATE TABLE Properties (
    property_id     INT             AUTO_INCREMENT PRIMARY KEY,
    owner_id        INT             NOT NULL,
    title           VARCHAR(150)    NOT NULL,
    address         VARCHAR(255)    NOT NULL,
    city            VARCHAR(50)     NOT NULL,
    state           VARCHAR(50)     NOT NULL,
    pincode         VARCHAR(10),
    property_type   ENUM('apartment','house','villa','commercial','studio')  NOT NULL,
    bedrooms        TINYINT         DEFAULT 1,
    bathrooms       TINYINT         DEFAULT 1,
    area_sqft       DECIMAL(8,2),
    rent_amount     DECIMAL(12,2)   NOT NULL  CHECK (rent_amount > 0),
    status          ENUM('occupied','vacant','under_maintenance')  NOT NULL  DEFAULT 'vacant',
    created_at      TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP       DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_property_owner
        FOREIGN KEY (owner_id) REFERENCES Owners(owner_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE INDEX idx_properties_owner   ON Properties(owner_id);
CREATE INDEX idx_properties_city    ON Properties(city);
CREATE INDEX idx_properties_status  ON Properties(status);
CREATE INDEX idx_properties_type    ON Properties(property_type);

-- ============================================================
-- TABLE 3: Tenants
-- ============================================================
CREATE TABLE Tenants (
    tenant_id       INT             AUTO_INCREMENT PRIMARY KEY,
    full_name       VARCHAR(100)    NOT NULL,
    email           VARCHAR(100)    NOT NULL UNIQUE,
    phone           VARCHAR(15)     NOT NULL,
    date_of_birth   DATE,
    id_proof_type   ENUM('aadhar','passport','driving_license','voter_id','pan')  NOT NULL,
    id_proof_number VARCHAR(30)     NOT NULL,
    emergency_contact_name  VARCHAR(100),
    emergency_contact_phone VARCHAR(15),
    created_at      TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP       DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE INDEX idx_tenants_email ON Tenants(email);

-- ============================================================
-- TABLE 4: Rental_Agreements
-- ============================================================
CREATE TABLE Rental_Agreements (
    agreement_id        INT             AUTO_INCREMENT PRIMARY KEY,
    property_id         INT             NOT NULL,
    tenant_id           INT             NOT NULL,
    start_date          DATE            NOT NULL,
    end_date            DATE            NOT NULL,
    monthly_rent        DECIMAL(12,2)   NOT NULL  CHECK (monthly_rent > 0),
    security_deposit    DECIMAL(12,2)   DEFAULT 0,
    status              ENUM('active','expired','terminated')  NOT NULL  DEFAULT 'active',
    notes               TEXT,
    created_at          TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP       DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_agreement_property
        FOREIGN KEY (property_id) REFERENCES Properties(property_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_agreement_tenant
        FOREIGN KEY (tenant_id) REFERENCES Tenants(tenant_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_dates CHECK (end_date > start_date)
) ENGINE=InnoDB;

CREATE INDEX idx_agreements_property  ON Rental_Agreements(property_id);
CREATE INDEX idx_agreements_tenant    ON Rental_Agreements(tenant_id);
CREATE INDEX idx_agreements_status    ON Rental_Agreements(status);
CREATE INDEX idx_agreements_dates     ON Rental_Agreements(start_date, end_date);

-- ============================================================
-- TABLE 5: Rent_Payments
-- ============================================================
CREATE TABLE Rent_Payments (
    payment_id      INT             AUTO_INCREMENT PRIMARY KEY,
    agreement_id    INT             NOT NULL,
    amount_due      DECIMAL(12,2)   NOT NULL  CHECK (amount_due > 0),
    amount_paid     DECIMAL(12,2)   DEFAULT 0 CHECK (amount_paid >= 0),
    due_date        DATE            NOT NULL,
    payment_date    DATE,
    status          ENUM('paid','pending','overdue','partial')  NOT NULL  DEFAULT 'pending',
    payment_mode    ENUM('cash','bank_transfer','upi','cheque')  DEFAULT NULL,
    transaction_ref VARCHAR(100),
    notes           TEXT,
    created_at      TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP       DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_payment_agreement
        FOREIGN KEY (agreement_id) REFERENCES Rental_Agreements(agreement_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE INDEX idx_payments_agreement ON Rent_Payments(agreement_id);
CREATE INDEX idx_payments_status    ON Rent_Payments(status);
CREATE INDEX idx_payments_due_date  ON Rent_Payments(due_date);
CREATE INDEX idx_payments_date      ON Rent_Payments(payment_date);

-- ============================================================
-- TABLE 6: Maintenance_Requests
-- ============================================================
CREATE TABLE Maintenance_Requests (
    request_id      INT             AUTO_INCREMENT PRIMARY KEY,
    property_id     INT             NOT NULL,
    tenant_id       INT,
    description     TEXT            NOT NULL,
    priority        ENUM('low','medium','high','urgent')  NOT NULL  DEFAULT 'medium',
    status          ENUM('open','in_progress','resolved','closed')  NOT NULL  DEFAULT 'open',
    request_date    DATE            NOT NULL  DEFAULT (CURRENT_DATE),
    resolved_date   DATE,
    created_at      TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP       DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_maintenance_property
        FOREIGN KEY (property_id) REFERENCES Properties(property_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_maintenance_tenant
        FOREIGN KEY (tenant_id) REFERENCES Tenants(tenant_id)
        ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE INDEX idx_maintenance_property ON Maintenance_Requests(property_id);
CREATE INDEX idx_maintenance_status   ON Maintenance_Requests(status);
CREATE INDEX idx_maintenance_priority ON Maintenance_Requests(priority);

-- ============================================================
-- TABLE 7: Expenses
-- ============================================================
CREATE TABLE Expenses (
    expense_id      INT             AUTO_INCREMENT PRIMARY KEY,
    property_id     INT             NOT NULL,
    request_id      INT             DEFAULT NULL,
    category        ENUM('repair','cleaning','legal','utility','insurance','tax','other')  NOT NULL,
    amount          DECIMAL(12,2)   NOT NULL  CHECK (amount > 0),
    description     VARCHAR(255),
    expense_date    DATE            NOT NULL,
    vendor_name     VARCHAR(100),
    receipt_ref     VARCHAR(100),
    created_at      TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_expense_property
        FOREIGN KEY (property_id) REFERENCES Properties(property_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_expense_request
        FOREIGN KEY (request_id) REFERENCES Maintenance_Requests(request_id)
        ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE INDEX idx_expenses_property ON Expenses(property_id);
CREATE INDEX idx_expenses_date     ON Expenses(expense_date);
CREATE INDEX idx_expenses_category ON Expenses(category);

-- ============================================================
-- TABLE 8: Property_Valuations
-- ============================================================
CREATE TABLE Property_Valuations (
    valuation_id    INT             AUTO_INCREMENT PRIMARY KEY,
    property_id     INT             NOT NULL,
    market_value    DECIMAL(15,2)   NOT NULL  CHECK (market_value > 0),
    valuation_date  DATE            NOT NULL,
    assessed_by     VARCHAR(100),
    notes           TEXT,
    created_at      TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_valuation_property
        FOREIGN KEY (property_id) REFERENCES Properties(property_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE INDEX idx_valuations_property ON Property_Valuations(property_id);
CREATE INDEX idx_valuations_date     ON Property_Valuations(valuation_date);

-- ============================================================
-- TABLE 9: Audit_Logs
-- ============================================================
CREATE TABLE Audit_Logs (
    log_id          INT             AUTO_INCREMENT PRIMARY KEY,
    table_name      VARCHAR(50)     NOT NULL,
    record_id       INT             NOT NULL,
    action          ENUM('INSERT','UPDATE','DELETE')  NOT NULL,
    old_value       JSON,
    new_value       JSON,
    changed_by      VARCHAR(100)    DEFAULT 'system',
    changed_at      TIMESTAMP       DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE INDEX idx_audit_table      ON Audit_Logs(table_name);
CREATE INDEX idx_audit_record     ON Audit_Logs(record_id);
CREATE INDEX idx_audit_changed_at ON Audit_Logs(changed_at);

-- ============================================================
-- Verify all tables created
-- ============================================================
SELECT table_name, engine, table_rows
FROM information_schema.tables
WHERE table_schema = 'real_estate_db'
ORDER BY table_name;
