-- ============================================================================
-- File: schema.sql
-- Project: OmniCart Order & Payment Orchestration Engine
-- Purpose: Database DDL Schema (Tables, Primary/Foreign Keys, Indexes)
-- ============================================================================

DROP DATABASE IF EXISTS omnicart_db;
CREATE DATABASE omnicart_db;
USE omnicart_db;

-- 1. Customers Table
CREATE TABLE customers (
    customer_id VARCHAR(50) PRIMARY KEY,
    full_name VARCHAR(120) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    city VARCHAR(80),
    created_at DATETIME NOT NULL
) ENGINE=InnoDB;

-- 2. Products Table
CREATE TABLE products (
    product_id VARCHAR(50) PRIMARY KEY,
    product_name VARCHAR(255) NOT NULL,
    category VARCHAR(80) NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    stock_quantity INT NOT NULL
) ENGINE=InnoDB;

-- 3. Orders Table
CREATE TABLE orders (
    order_id VARCHAR(50) PRIMARY KEY,
    customer_id VARCHAR(50) NOT NULL,
    order_status VARCHAR(30) NOT NULL,
    total_amount DECIMAL(10, 2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'USD',
    idempotency_key VARCHAR(64) UNIQUE NOT NULL,
    lock_token VARCHAR(64),
    lock_expires_at DATETIME,
    created_at DATETIME NOT NULL,
    CONSTRAINT fk_orders_customer FOREIGN KEY (customer_id) 
        REFERENCES customers(customer_id) ON DELETE RESTRICT
) ENGINE=InnoDB;

-- 4. Order Items Table
CREATE TABLE order_items (
    item_id VARCHAR(50) PRIMARY KEY,
    order_id VARCHAR(50) NOT NULL,
    product_id VARCHAR(50) NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    CONSTRAINT fk_items_order FOREIGN KEY (order_id) 
        REFERENCES orders(order_id) ON DELETE CASCADE,
    CONSTRAINT fk_items_product FOREIGN KEY (product_id) 
        REFERENCES products(product_id) ON DELETE RESTRICT
) ENGINE=InnoDB;

-- 5. Payment Transactions Table
CREATE TABLE payment_transactions (
    transaction_id VARCHAR(50) PRIMARY KEY,
    order_id VARCHAR(50) NOT NULL,
    gateway_reference VARCHAR(100) UNIQUE NOT NULL,
    payment_method VARCHAR(50) NOT NULL,
    transaction_amount DECIMAL(10, 2) NOT NULL,
    transaction_status VARCHAR(30) NOT NULL,
    response_code VARCHAR(50),
    processed_at DATETIME NOT NULL,
    CONSTRAINT fk_transactions_order FOREIGN KEY (order_id) 
        REFERENCES orders(order_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Indexes for Query Optimization
CREATE INDEX idx_orders_status ON orders(order_status);
CREATE INDEX idx_orders_customer ON orders(customer_id);
CREATE INDEX idx_trans_order ON payment_transactions(order_id);