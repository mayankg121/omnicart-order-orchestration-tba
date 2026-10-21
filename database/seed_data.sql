-- ============================================================================
-- File: seed_data.sql
-- Project: OmniCart Order & Payment Orchestration Engine
-- Purpose: DML Sample Data Insertion for Testing & Analytics
-- ============================================================================

USE omnicart_db;

-- 1. Insert Customers
INSERT INTO customers (customer_id, full_name, email, city, created_at) VALUES
('c1010001', 'Aarav Sharma', 'aarav.sharma@example.com', 'Jaipur', '2026-08-01 10:00:00'),
('c1010002', 'Priya Patel', 'priya.patel@example.com', 'Mumbai', '2026-08-05 11:30:00'),
('c1010003', 'Rohan Mehta', 'rohan.m@example.com', 'Bengaluru', '2026-08-12 14:15:00'),
('c1010004', 'Sneha Verma', 'sneha.v@example.com', 'Delhi', '2026-08-20 09:45:00'),
('c1010005', 'Vikram Singh', 'vikram.s@example.com', 'Jaipur', '2026-09-01 16:20:00'),
('c1010006', 'Ananya Iyer', 'ananya.iyer@example.com', 'Chennai', '2026-09-05 18:00:00'),
('c1010007', 'Kabir Das', 'kabir.das@example.com', 'Kolkata', '2026-09-10 12:10:00'),
('c1010008', 'Neha Kapoor', 'neha.k@example.com', 'Gurugram', '2026-09-15 15:40:00');

-- 2. Insert Products
INSERT INTO products (product_id, product_name, category, unit_price, stock_quantity) VALUES
('SKU-HEADPHONE-ANC', 'Wireless ANC Headphones', 'Audio', 120.00, 42),
('SKU-SMARTWATCH-ULTRA', 'Amoled Fitness Smartwatch', 'Wearables', 85.00, 78),
('SKU-MECH-KEYBOARD', 'RGB Mechanical Gaming Keyboard', 'Peripherals', 95.00, 24),
('SKU-TYPEC-DOCK', '7-in-1 USB-C Hub Adapter', 'Accessories', 45.00, 108),
('SKU-FAST-CHARGER', '65W GaN Dual Port Charger', 'Accessories', 35.00, 147),
('SKU-BT-SPEAKER', 'Portable Bluetooth Speaker', 'Audio', 55.00, 60);

-- 3. Insert Orders
INSERT INTO orders (order_id, customer_id, order_status, total_amount, currency, idempotency_key, lock_token, lock_expires_at, created_at) VALUES
('ord-9001', 'c1010001', 'PAID', 120.00, 'USD', 'idemp_9001_a1', 'lk_9001', '2026-10-10 10:45:00', '2026-10-10 10:30:00'),
('ord-9002', 'c1010002', 'PAID', 130.00, 'USD', 'idemp_9002_b2', 'lk_9002', '2026-10-10 11:20:00', '2026-10-10 11:05:00'),
('ord-9003', 'c1010003', 'EXPIRED', 95.00, 'USD', 'idemp_9003_c3', 'lk_9003', '2026-10-11 12:15:00', '2026-10-11 12:00:00'),
('ord-9004', 'c1010004', 'CANCELLED', 85.00, 'USD', 'idemp_9004_d4', 'lk_9004', '2026-10-11 15:45:00', '2026-10-11 15:30:00'),
('ord-9005', 'c1010005', 'PENDING_PAYMENT', 45.00, 'USD', 'idemp_9005_e5', 'lk_9005', '2026-10-12 18:25:00', '2026-10-12 18:10:00'),
('ord-9006', 'c1010006', 'PAID', 155.00, 'USD', 'idemp_9006_f6', 'lk_9006', '2026-10-13 19:15:00', '2026-10-13 19:00:00'),
('ord-9007', 'c1010007', 'PAID', 55.00, 'USD', 'idemp_9007_g7', 'lk_9007', '2026-10-14 09:15:00', '2026-10-14 09:00:00'),
('ord-9008', 'c1010001', 'PAID', 80.00, 'USD', 'idemp_9008_h8', 'lk_9008', '2026-10-14 14:30:00', '2026-10-14 14:15:00'),
('ord-9009', 'c1010008', 'EXPIRED', 120.00, 'USD', 'idemp_9009_i9', 'lk_9009', '2026-10-15 08:45:00', '2026-10-15 08:30:00'),
('ord-9010', 'c1010003', 'PAID', 95.00, 'USD', 'idemp_9010_j1', 'lk_9010', '2026-10-15 11:20:00', '2026-10-15 11:05:00');

-- 4. Insert Order Items
INSERT INTO order_items (item_id, order_id, product_id, quantity, unit_price) VALUES
('itm-101', 'ord-9001', 'SKU-HEADPHONE-ANC', 1, 120.00),
('itm-102', 'ord-9002', 'SKU-SMARTWATCH-ULTRA', 1, 85.00),
('itm-103', 'ord-9002', 'SKU-TYPEC-DOCK', 1, 45.00),
('itm-104', 'ord-9003', 'SKU-MECH-KEYBOARD', 1, 95.00),
('itm-105', 'ord-9004', 'SKU-SMARTWATCH-ULTRA', 1, 85.00),
('itm-106', 'ord-9005', 'SKU-TYPEC-DOCK', 1, 45.00),
('itm-107', 'ord-9006', 'SKU-HEADPHONE-ANC', 1, 120.00),
('itm-108', 'ord-9006', 'SKU-FAST-CHARGER', 1, 35.00),
('itm-109', 'ord-9007', 'SKU-BT-SPEAKER', 1, 55.00),
('itm-110', 'ord-9008', 'SKU-TYPEC-DOCK', 1, 45.00),
('itm-111', 'ord-9008', 'SKU-FAST-CHARGER', 1, 35.00),
('itm-112', 'ord-9009', 'SKU-HEADPHONE-ANC', 1, 120.00),
('itm-113', 'ord-9010', 'SKU-MECH-KEYBOARD', 1, 95.00);

-- 5. Insert Payment Transactions
INSERT INTO payment_transactions (transaction_id, order_id, gateway_reference, payment_method, transaction_amount, transaction_status, response_code, processed_at) VALUES
('tx-501', 'ord-9001', 'ch_stripe_001', 'Credit Card', 120.00, 'SUCCESS', 'succeeded', '2026-10-10 10:32:15'),
('tx-502', 'ord-9002', 'ch_stripe_002', 'Apple Pay', 130.00, 'SUCCESS', 'succeeded', '2026-10-10 11:07:40'),
('tx-503', 'ord-9004', 'ch_stripe_003', 'Credit Card', 85.00, 'FAILED', 'card_declined', '2026-10-11 15:33:10'),
('tx-504', 'ord-9006', 'ch_stripe_004', 'Credit Card', 155.00, 'SUCCESS', 'succeeded', '2026-10-13 19:02:10'),
('tx-505', 'ord-9007', 'ch_stripe_005', 'PayPal', 55.00, 'SUCCESS', 'succeeded', '2026-10-14 09:03:50'),
('tx-506', 'ord-9008', 'ch_stripe_006', 'Google Pay', 80.00, 'SUCCESS', 'succeeded', '2026-10-14 14:17:22'),
('tx-507', 'ord-9010', 'ch_stripe_007', 'Credit Card', 95.00, 'SUCCESS', 'succeeded', '2026-10-15 11:07:05');