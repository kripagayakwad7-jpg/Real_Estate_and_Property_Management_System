-- ============================================================
--  Real Estate & Property Management System
--  File        : 02_sample_data.sql
--  Description : Realistic seed data for all 9 tables
--  Run AFTER   : 01_schema.sql
-- ============================================================

USE real_estate_db;

-- ============================================================
-- 1. OWNERS (5 records)
-- ============================================================
INSERT INTO Owners (full_name, email, phone, address, city, state) VALUES
('Rajesh Sharma',    'rajesh.sharma@email.com',  '9876543210', '12, Park Avenue',       'Mumbai',    'Maharashtra'),
('Priya Mehta',      'priya.mehta@email.com',    '9845123456', '45, MG Road',           'Bangalore', 'Karnataka'),
('Vikram Patel',     'vikram.patel@email.com',   '9912345678', '7, Gandhi Nagar',       'Ahmedabad', 'Gujarat'),
('Sunita Reddy',     'sunita.reddy@email.com',   '9801234567', '23, Jubilee Hills',     'Hyderabad', 'Telangana'),
('Arjun Nair',       'arjun.nair@email.com',     '9765432190', '89, Marine Drive',     'Kochi',     'Kerala');

-- ============================================================
-- 2. PROPERTIES (15 records)
-- ============================================================
INSERT INTO Properties (owner_id, title, address, city, state, pincode, property_type, bedrooms, bathrooms, area_sqft, rent_amount, status) VALUES
-- Rajesh Sharma (owner_id = 1) - 4 properties
(1, 'Sharma Apartment 2BHK',     '101, Sea View Towers, Andheri',   'Mumbai',    'Maharashtra', '400053', 'apartment', 2, 2, 950.00,  28000.00, 'occupied'),
(1, 'Sharma Studio Bandra',      '5B, Hill Road, Bandra',           'Mumbai',    'Maharashtra', '400050', 'studio',    1, 1, 450.00,  18000.00, 'occupied'),
(1, 'Sharma Villa Pune',         '34, Koregaon Park',               'Pune',      'Maharashtra', '411001', 'villa',     4, 3, 3200.00, 75000.00, 'vacant'),
(1, 'Sharma Commercial Dadar',   '12, Commerce House, Dadar',       'Mumbai',    'Maharashtra', '400014', 'commercial',0, 2, 1200.00, 55000.00, 'occupied'),

-- Priya Mehta (owner_id = 2) - 3 properties
(2, 'Mehta Apartment Koramangala','14, 5th Block, Koramangala',     'Bangalore', 'Karnataka',   '560034', 'apartment', 3, 2, 1400.00, 35000.00, 'occupied'),
(2, 'Mehta House Whitefield',    '78, Whitefield Main Road',        'Bangalore', 'Karnataka',   '560066', 'house',     3, 2, 1800.00, 32000.00, 'vacant'),
(2, 'Mehta Studio Indiranagar',  '22, CMH Road, Indiranagar',       'Bangalore', 'Karnataka',   '560038', 'studio',    1, 1, 500.00,  15000.00, 'under_maintenance'),

-- Vikram Patel (owner_id = 3) - 3 properties
(3, 'Patel Apartment SG Highway','302, SG Highway Complex',         'Ahmedabad', 'Gujarat',     '380054', 'apartment', 2, 2, 1100.00, 18000.00, 'occupied'),
(3, 'Patel Villa Satellite',     '7, Satellite Road',               'Ahmedabad', 'Gujarat',     '380015', 'villa',     5, 4, 4000.00, 85000.00, 'vacant'),
(3, 'Patel House Navrangpura',   '56, Navrangpura',                 'Ahmedabad', 'Gujarat',     '380009', 'house',     3, 2, 1600.00, 22000.00, 'occupied'),

-- Sunita Reddy (owner_id = 4) - 3 properties
(4, 'Reddy Apartment Banjara',   '12A, Banjara Hills Road No.1',    'Hyderabad', 'Telangana',   '500034', 'apartment', 2, 2, 1050.00, 25000.00, 'occupied'),
(4, 'Reddy Villa Gachibowli',    '45, Financial District',          'Hyderabad', 'Telangana',   '500032', 'villa',     4, 3, 3500.00, 70000.00, 'occupied'),
(4, 'Reddy Commercial Hitech',   '89, Hitech City',                 'Hyderabad', 'Telangana',   '500081', 'commercial',0, 2, 2000.00, 90000.00, 'vacant'),

-- Arjun Nair (owner_id = 5) - 2 properties
(5, 'Nair Apartment Marine',     '23, Marine Drive, Ernakulam',     'Kochi',     'Kerala',      '682011', 'apartment', 2, 1, 900.00,  20000.00, 'occupied'),
(5, 'Nair House Kakkanad',       '67, IT Park Road, Kakkanad',      'Kochi',     'Kerala',      '682030', 'house',     3, 2, 1500.00, 18000.00, 'vacant');

-- ============================================================
-- 3. TENANTS (12 records)
-- ============================================================
INSERT INTO Tenants (full_name, email, phone, date_of_birth, id_proof_type, id_proof_number, emergency_contact_name, emergency_contact_phone) VALUES
('Aditya Kumar',     'aditya.kumar@email.com',   '9711234567', '1992-05-14', 'aadhar',          'ADTK-1234-5678', 'Ramesh Kumar',    '9811234567'),
('Sneha Verma',      'sneha.verma@email.com',    '9822345678', '1995-08-22', 'passport',        'P1234567',       'Ravi Verma',      '9922345678'),
('Karthik Rao',      'karthik.rao@email.com',    '9533456789', '1990-03-10', 'driving_license', 'KA19D1234567',   'Latha Rao',       '9633456789'),
('Meena Pillai',     'meena.pillai@email.com',   '9744567890', '1993-11-30', 'voter_id',        'KL/07/234/567890','Suresh Pillai',  '9844567890'),
('Rohit Gupta',      'rohit.gupta@email.com',    '9655678901', '1988-07-18', 'aadhar',          'RHTG-9876-5432', 'Sunita Gupta',    '9755678901'),
('Ananya Das',       'ananya.das@email.com',     '9566789012', '1997-02-05', 'pan',             'ABCPD1234E',     'Biswas Das',      '9466789012'),
('Sameer Khan',      'sameer.khan@email.com',    '9877890123', '1991-09-25', 'passport',        'P7654321',       'Rahim Khan',      '9977890123'),
('Pooja Singh',      'pooja.singh@email.com',    '9788901234', '1994-04-12', 'aadhar',          'PJSG-4567-8901', 'Arvind Singh',    '9888901234'),
('Deepak Joshi',     'deepak.joshi@email.com',   '9699012345', '1989-12-08', 'driving_license', 'MH01DL567890',   'Kamla Joshi',     '9599012345'),
('Lakshmi Iyer',     'lakshmi.iyer@email.com',   '9510123456', '1996-06-20', 'voter_id',        'TN/05/123/456789','Venkat Iyer',    '9410123456'),
('Manish Tiwari',    'manish.tiwari@email.com',  '9321234567', '1987-01-15', 'aadhar',          'MNSH-2345-6789', 'Geeta Tiwari',   '9421234567'),
('Divya Krishnan',   'divya.krishnan@email.com', '9432345678', '1998-10-03', 'passport',        'P9876543',       'Mohan Krishnan', '9532345678');

-- ============================================================
-- 4. RENTAL AGREEMENTS (15 records)
-- ============================================================
INSERT INTO Rental_Agreements (property_id, tenant_id, start_date, end_date, monthly_rent, security_deposit, status) VALUES
-- Active agreements
(1,  1,  '2024-01-01', '2025-12-31', 28000.00,  56000.00, 'active'),     -- Aditya → Mumbai Apartment
(2,  2,  '2024-03-01', '2025-02-28', 18000.00,  36000.00, 'active'),     -- Sneha → Studio Bandra
(4,  3,  '2023-06-01', '2025-05-31', 55000.00, 110000.00, 'active'),     -- Karthik → Commercial Dadar
(5,  4,  '2024-02-01', '2025-01-31', 35000.00,  70000.00, 'active'),     -- Meena → Bangalore Koramangala
(8,  5,  '2024-04-01', '2025-03-31', 18000.00,  36000.00, 'active'),     -- Rohit → Ahmedabad Apartment
(10, 6,  '2023-09-01', '2025-08-31', 22000.00,  44000.00, 'active'),     -- Ananya → Navrangpura House
(11, 7,  '2024-01-01', '2025-12-31', 25000.00,  50000.00, 'active'),     -- Sameer → Banjara Apartment
(12, 8,  '2023-07-01', '2025-06-30', 70000.00, 140000.00, 'active'),     -- Pooja → Villa Gachibowli
(14, 9,  '2024-05-01', '2025-04-30', 20000.00,  40000.00, 'active'),     -- Deepak → Marine Apartment
-- Expired agreements (historical)
(1,  10, '2022-06-01', '2023-12-31', 24000.00,  48000.00, 'expired'),    -- Lakshmi → Mumbai Apartment (prev tenant)
(5,  11, '2022-01-01', '2023-12-31', 30000.00,  60000.00, 'expired'),    -- Manish → Koramangala (prev tenant)
(6,  12, '2023-01-01', '2024-01-31', 30000.00,  60000.00, 'expired'),    -- Divya → Whitefield (now vacant)
(9,  1,  '2021-01-01', '2022-12-31', 70000.00, 140000.00, 'expired'),    -- Aditya → Patel Villa (old)
(15, 2,  '2022-06-01', '2023-06-30', 16000.00,  32000.00, 'expired'),    -- Sneha → Kakkanad House (old)
-- Terminated
(13, 3,  '2023-01-01', '2023-09-30', 85000.00, 170000.00, 'terminated'); -- Karthik → Commercial Hitech

-- ============================================================
-- 5. RENT PAYMENTS (55 records)
-- ============================================================
INSERT INTO Rent_Payments (agreement_id, amount_due, amount_paid, due_date, payment_date, status, payment_mode, transaction_ref) VALUES
-- Agreement 1 (Aditya → Mumbai Apt, ₹28,000/month) — Jan 2024 to Oct 2024
(1, 28000, 28000, '2024-01-05', '2024-01-04', 'paid', 'upi',           'UPI2401001'),
(1, 28000, 28000, '2024-02-05', '2024-02-06', 'paid', 'bank_transfer', 'NEFT2402001'),
(1, 28000, 28000, '2024-03-05', '2024-03-05', 'paid', 'upi',           'UPI2403001'),
(1, 28000, 28000, '2024-04-05', '2024-04-07', 'paid', 'upi',           'UPI2404001'),
(1, 28000, 28000, '2024-05-05', '2024-05-05', 'paid', 'bank_transfer', 'NEFT2405001'),
(1, 28000, 28000, '2024-06-05', '2024-06-08', 'paid', 'upi',           'UPI2406001'),
(1, 28000, 28000, '2024-07-05', '2024-07-04', 'paid', 'cash',          NULL),
(1, 28000, 28000, '2024-08-05', '2024-08-06', 'paid', 'upi',           'UPI2408001'),
(1, 28000, 28000, '2024-09-05', '2024-09-05', 'paid', 'bank_transfer', 'NEFT2409001'),
(1, 28000, 15000, '2024-10-05', '2024-10-10', 'partial', 'upi',        'UPI2410001'),
(1, 28000, 0,     '2024-11-05', NULL,          'overdue', NULL,         NULL),
(1, 28000, 0,     '2024-12-05', NULL,          'pending', NULL,         NULL),

-- Agreement 2 (Sneha → Studio, ₹18,000/month)
(2, 18000, 18000, '2024-03-05', '2024-03-05', 'paid', 'upi',           'UPI2403002'),
(2, 18000, 18000, '2024-04-05', '2024-04-04', 'paid', 'upi',           'UPI2404002'),
(2, 18000, 18000, '2024-05-05', '2024-05-06', 'paid', 'bank_transfer', 'NEFT2405002'),
(2, 18000, 18000, '2024-06-05', '2024-06-05', 'paid', 'upi',           'UPI2406002'),
(2, 18000, 18000, '2024-07-05', '2024-07-07', 'paid', 'cheque',        'CHQ2407002'),
(2, 18000, 18000, '2024-08-05', '2024-08-05', 'paid', 'upi',           'UPI2408002'),
(2, 18000, 0,     '2024-09-05', NULL,          'overdue', NULL,         NULL),
(2, 18000, 0,     '2024-10-05', NULL,          'overdue', NULL,         NULL),
(2, 18000, 0,     '2024-11-05', NULL,          'pending', NULL,         NULL),

-- Agreement 3 (Karthik → Commercial, ₹55,000/month)
(3, 55000, 55000, '2024-01-05', '2024-01-05', 'paid', 'bank_transfer', 'NEFT2401003'),
(3, 55000, 55000, '2024-02-05', '2024-02-05', 'paid', 'bank_transfer', 'NEFT2402003'),
(3, 55000, 55000, '2024-03-05', '2024-03-04', 'paid', 'bank_transfer', 'NEFT2403003'),
(3, 55000, 55000, '2024-04-05', '2024-04-05', 'paid', 'bank_transfer', 'NEFT2404003'),
(3, 55000, 55000, '2024-05-05', '2024-05-06', 'paid', 'bank_transfer', 'NEFT2405003'),
(3, 55000, 55000, '2024-06-05', '2024-06-05', 'paid', 'bank_transfer', 'NEFT2406003'),
(3, 55000, 55000, '2024-07-05', '2024-07-05', 'paid', 'bank_transfer', 'NEFT2407003'),
(3, 55000, 55000, '2024-08-05', '2024-08-06', 'paid', 'bank_transfer', 'NEFT2408003'),
(3, 55000, 55000, '2024-09-05', '2024-09-05', 'paid', 'bank_transfer', 'NEFT2409003'),
(3, 55000, 55000, '2024-10-05', '2024-10-05', 'paid', 'bank_transfer', 'NEFT2410003'),
(3, 55000, 55000, '2024-11-05', '2024-11-05', 'paid', 'bank_transfer', 'NEFT2411003'),

-- Agreement 4 (Meena → Bangalore, ₹35,000/month)
(4, 35000, 35000, '2024-02-05', '2024-02-05', 'paid', 'upi',           'UPI2402004'),
(4, 35000, 35000, '2024-03-05', '2024-03-06', 'paid', 'upi',           'UPI2403004'),
(4, 35000, 35000, '2024-04-05', '2024-04-05', 'paid', 'bank_transfer', 'NEFT2404004'),
(4, 35000, 35000, '2024-05-05', '2024-05-05', 'paid', 'upi',           'UPI2405004'),
(4, 35000, 35000, '2024-06-05', '2024-06-07', 'paid', 'upi',           'UPI2406004'),
(4, 35000, 20000, '2024-07-05', '2024-07-15', 'partial', 'cash',       NULL),
(4, 35000, 0,     '2024-08-05', NULL,          'overdue', NULL,         NULL),
(4, 35000, 0,     '2024-09-05', NULL,          'overdue', NULL,         NULL),
(4, 35000, 0,     '2024-10-05', NULL,          'overdue', NULL,         NULL),

-- Agreement 7 (Sameer → Banjara, ₹25,000/month)
(7, 25000, 25000, '2024-01-05', '2024-01-05', 'paid', 'bank_transfer', 'NEFT2401007'),
(7, 25000, 25000, '2024-02-05', '2024-02-05', 'paid', 'bank_transfer', 'NEFT2402007'),
(7, 25000, 25000, '2024-03-05', '2024-03-05', 'paid', 'upi',           'UPI2403007'),
(7, 25000, 25000, '2024-04-05', '2024-04-06', 'paid', 'upi',           'UPI2404007'),
(7, 25000, 25000, '2024-05-05', '2024-05-05', 'paid', 'bank_transfer', 'NEFT2405007'),
(7, 25000, 25000, '2024-06-05', '2024-06-05', 'paid', 'upi',           'UPI2406007'),
(7, 25000, 25000, '2024-07-05', '2024-07-05', 'paid', 'upi',           'UPI2407007'),
(7, 25000, 25000, '2024-08-05', '2024-08-05', 'paid', 'bank_transfer', 'NEFT2408007'),
(7, 25000, 25000, '2024-09-05', '2024-09-05', 'paid', 'upi',           'UPI2409007'),
(7, 25000, 25000, '2024-10-05', '2024-10-05', 'paid', 'upi',           'UPI2410007'),
(7, 25000, 0,     '2024-11-05', NULL,          'pending', NULL,         NULL),

-- Agreement 8 (Pooja → Gachibowli Villa, ₹70,000/month)
(8, 70000, 70000, '2024-07-05', '2024-07-05', 'paid', 'bank_transfer', 'NEFT2407008'),
(8, 70000, 70000, '2024-08-05', '2024-08-05', 'paid', 'bank_transfer', 'NEFT2408008'),
(8, 70000, 70000, '2024-09-05', '2024-09-06', 'paid', 'bank_transfer', 'NEFT2409008'),
(8, 70000, 70000, '2024-10-05', '2024-10-05', 'paid', 'bank_transfer', 'NEFT2410008');

-- ============================================================
-- 6. MAINTENANCE REQUESTS (10 records)
-- ============================================================
INSERT INTO Maintenance_Requests (property_id, tenant_id, description, priority, status, request_date, resolved_date) VALUES
(1,  1,  'Water leakage from bathroom ceiling',          'high',   'resolved',     '2024-03-10', '2024-03-15'),
(2,  2,  'Air conditioner not cooling properly',         'medium', 'resolved',     '2024-05-20', '2024-05-25'),
(4,  3,  'Electrical short circuit in office area',      'urgent', 'resolved',     '2024-02-05', '2024-02-07'),
(5,  4,  'Broken window in master bedroom',              'medium', 'resolved',     '2024-04-12', '2024-04-18'),
(7,  NULL,'Complete plumbing overhaul required',         'high',   'in_progress',  '2024-06-01', NULL),
(8,  8,  'Pest control treatment needed',                'low',    'resolved',     '2024-07-15', '2024-07-20'),
(10, 6,  'Front gate lock broken',                       'high',   'resolved',     '2024-08-02', '2024-08-04'),
(11, 7,  'Painting required for living room walls',      'low',    'open',         '2024-09-10', NULL),
(12, 8,  'Swimming pool pump malfunction',               'high',   'in_progress',  '2024-10-01', NULL),
(14, 9,  'Geyser not working in bathroom',               'medium', 'resolved',     '2024-09-22', '2024-09-25');

-- ============================================================
-- 7. EXPENSES (15 records)
-- ============================================================
INSERT INTO Expenses (property_id, request_id, category, amount, description, expense_date, vendor_name) VALUES
(1,  1, 'repair',    8500.00,  'Waterproofing and ceiling repair',        '2024-03-14', 'BuildFix Solutions'),
(2,  2, 'repair',    4200.00,  'AC servicing and gas refill',             '2024-05-24', 'CoolAir Services'),
(4,  3, 'repair',   12000.00,  'Electrical rewiring - office section',    '2024-02-06', 'Spark Electricals'),
(5,  4, 'repair',    3500.00,  'Window glass replacement',                '2024-04-17', 'GlassTech'),
(7,  5, 'repair',   35000.00,  'Full plumbing overhaul - pipes & fittings','2024-06-15', 'Plumb Perfect'),
(8,  6, 'cleaning',  2800.00,  'Pest control - full property treatment',  '2024-07-19', 'PestAway'),
(10, 7, 'repair',    1800.00,  'Gate lock and key replacement',           '2024-08-03', 'Locksmith Pro'),
(12, 9, 'repair',   22000.00,  'Pool pump motor replacement',             '2024-10-05', 'AquaTech'),
(14, 10,'repair',    2200.00,  'Geyser replacement - 25L capacity',       '2024-09-24', 'HeatWave Appliances'),
-- Non-maintenance expenses
(1,  NULL,'insurance', 15000.00, 'Annual property insurance premium',     '2024-01-15', 'PolicyBazaar'),
(5,  NULL,'tax',       42000.00, 'Annual property tax payment',           '2024-04-01', 'BBMP'),
(8,  NULL,'insurance', 28000.00, 'Annual property insurance premium',     '2024-07-01', 'HDFC Ergo'),
(11, NULL,'cleaning',   5000.00, 'Deep cleaning before new tenant',       '2024-01-10', 'CleanMaster'),
(12, NULL,'tax',       85000.00, 'Annual property tax - villa',           '2024-04-01', 'GHMC'),
(4,  NULL,'legal',     18000.00, 'Lease agreement renewal legal charges', '2024-06-15', 'LawAssist LLP');

-- ============================================================
-- 8. PROPERTY VALUATIONS (12 records)
-- ============================================================
INSERT INTO Property_Valuations (property_id, market_value, valuation_date, assessed_by) VALUES
(1,  7500000.00,  '2023-01-15', 'PropValue Consultants'),
(1,  8200000.00,  '2024-01-10', 'PropValue Consultants'),
(2,  4500000.00,  '2023-06-01', 'CityAppraisers'),
(3,  18000000.00, '2024-01-01', 'PropValue Consultants'),
(4,  12000000.00, '2024-01-15', 'CommerceValue Experts'),
(5,  9500000.00,  '2023-06-15', 'BangaloreAppraisers'),
(8,  5500000.00,  '2024-04-01', 'Gujarat Valuers'),
(9,  22000000.00, '2024-01-01', 'Gujarat Valuers'),
(10, 6800000.00,  '2024-01-01', 'Gujarat Valuers'),
(11, 8000000.00,  '2024-01-15', 'Hyderabad Valuers'),
(12, 20000000.00, '2023-07-01', 'Hyderabad Valuers'),
(14, 6200000.00,  '2024-05-01', 'Kerala Appraisals');

-- ============================================================
-- Verify row counts
-- ============================================================
SELECT 'Owners'               AS tbl, COUNT(*) AS rows FROM Owners
UNION ALL SELECT 'Properties',        COUNT(*) FROM Properties
UNION ALL SELECT 'Tenants',           COUNT(*) FROM Tenants
UNION ALL SELECT 'Rental_Agreements', COUNT(*) FROM Rental_Agreements
UNION ALL SELECT 'Rent_Payments',     COUNT(*) FROM Rent_Payments
UNION ALL SELECT 'Maintenance_Requests', COUNT(*) FROM Maintenance_Requests
UNION ALL SELECT 'Expenses',          COUNT(*) FROM Expenses
UNION ALL SELECT 'Property_Valuations', COUNT(*) FROM Property_Valuations;
