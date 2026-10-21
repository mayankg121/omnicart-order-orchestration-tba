-- ============================================================================
-- QUERY 1: Inventory Lock Expiry & Checkout Drop-Off Root Cause
-- ============================================================================
-- BUSINESS QUESTION:
-- Which orders failed or timed out during the 15-minute reservation window, 
-- how much revenue was left in limbo, and at what exact stage did shoppers drop off?
--
-- TECHNICAL APPROACH:
-- - Implemented a Common Table Expression (CTE) joining `orders` and `payment_transactions`.
-- - Applied conditional logic (`CASE WHEN`) to classify drop-offs into actionable technical buckets.
--
-- BUSINESS IMPACT / ACTION:
-- Informs the product and engineering teams whether to increase the lock TTL, 
-- implement automated cart-recovery emails, or resolve gateway OTP friction.
-- ============================================================================

USE omnicart_db;

WITH OrderDropoffs AS (
    SELECT 
        o.order_id,
        c.full_name,
        o.total_amount,
        o.order_status,
        o.created_at AS order_time,
        p.transaction_status,
        p.response_code
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    LEFT JOIN payment_transactions p ON o.order_id = p.order_id
    WHERE o.order_status IN ('EXPIRED', 'CANCELLED', 'PENDING_PAYMENT')
)
SELECT 
    order_id,
    full_name,
    total_amount,
    order_status,
    CASE 
        WHEN transaction_status IS NULL AND order_status = 'EXPIRED' 
            THEN 'ABANDONED_ON_PAYMENT_PAGE'
        WHEN transaction_status IS NULL AND order_status = 'PENDING_PAYMENT' 
            THEN 'AWAITING_CUSTOMER_ACTION'
        WHEN transaction_status = 'FAILED' 
            THEN CONCAT('GATEWAY_DECLINED: ', response_code)
        ELSE 'OTHER'
    END AS technical_root_cause
FROM OrderDropoffs
ORDER BY total_amount DESC;


-- ============================================================================
-- QUERY 2: Payment Rail Conversion Rates & Gateway Reliability
-- ============================================================================
-- BUSINESS QUESTION:
-- Which payment methods (Credit Card, UPI/Wallets, Net Banking) yield the highest 
-- checkout completion rates, and which payment rails are experiencing elevated 
-- failure rates that necessitate secondary gateway routing fallback?
--
-- TECHNICAL APPROACH:
-- - Aggregated transaction volume across payment methods using conditional counting (`SUM(CASE WHEN ...)`).
-- - Calculated success rate percentages and total realized revenue using `ROUND()` and `GROUP BY`.
--
-- BUSINESS IMPACT / ACTION:
-- Provides data to engineering and product teams to prioritize dynamic payment 
-- routing (e.g., automatically switching to an alternate gateway when Card decline 
-- rates exceed 15%) and re-rank high-converting payment options on the checkout UI.
-- ============================================================================

USE omnicart_db;

SELECT 
    p.payment_method,
    COUNT(p.transaction_id) AS total_attempts,
    SUM(CASE WHEN p.transaction_status = 'SUCCESS' THEN 1 ELSE 0 END) AS successful_transactions,
    SUM(CASE WHEN p.transaction_status = 'FAILED' THEN 1 ELSE 0 END) AS failed_transactions,
    ROUND(
        (SUM(CASE WHEN p.transaction_status = 'SUCCESS' THEN 1.0 ELSE 0 END) / COUNT(p.transaction_id)) * 100, 
        2
    ) AS success_rate_pct,
    ROUND(SUM(CASE WHEN p.transaction_status = 'SUCCESS' THEN p.transaction_amount ELSE 0 END), 2) AS realized_volume_usd
FROM payment_transactions p
GROUP BY p.payment_method
ORDER BY success_rate_pct DESC;


-- ============================================================================
-- QUERY 3: Multi-Attempt Customer Journey & Funnel Recovery Analysis
-- ============================================================================
-- BUSINESS QUESTION:
-- When customers encounter a checkout friction point (such as an expired 15-minute 
-- inventory lock or bank card decline), do they abandon the platform permanently, 
-- or do they return to complete the order successfully?
--
-- TECHNICAL APPROACH:
-- - Applied window functions (`ROW_NUMBER()` and `LAG()`) partitioned by `customer_id` 
--   and ordered chronologically by `created_at` to trace sequential purchase journeys.
-- - Used conditional tagging (`CASE WHEN`) to categorize checkout lifecycle states into 
--   actionable cohorts: 'FIRST_PASS_SUCCESS', 'RECOVERED_CUSTOMER', and 'REPEAT_BUYER'.
--
-- BUSINESS IMPACT / ACTION:
-- Helps product managers measure customer resiliency against checkout friction and 
-- evaluate the ROI of automated cart recovery triggers (e.g., sending instant SMS/email 
-- notifications when an inventory lock expires).
-- ============================================================================

USE omnicart_db;

WITH CustomerHistory AS (
    SELECT 
        customer_id,
        order_id,
        order_status,
        total_amount,
        created_at,
        ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY created_at ASC) AS attempt_number,
        LAG(order_status, 1) OVER (PARTITION BY customer_id ORDER BY created_at ASC) AS prev_status
    FROM orders
)
SELECT 
    customer_id,
    order_id,
    attempt_number,
    prev_status,
    order_status AS current_status,
    total_amount,
    CASE 
        WHEN attempt_number > 1 AND prev_status IN ('EXPIRED', 'CANCELLED') AND order_status = 'PAID'
            THEN 'RECOVERED_CUSTOMER'
        WHEN attempt_number > 1 AND prev_status = 'PAID' AND order_status = 'PAID'
            THEN 'REPEAT_BUYER'
        WHEN attempt_number = 1 AND order_status = 'PAID'
            THEN 'FIRST_PASS_SUCCESS'
        ELSE 'UNRESOLVED_OR_DROPPED'
    END AS customer_funnel_cohort
FROM CustomerHistory;


-- ============================================================================
-- QUERY 4: Uninitiated Checkouts & Abandoned Gateway Transitions (LEFT JOIN + NULL)
-- ============================================================================
-- BUSINESS QUESTION:
-- Which orders created an inventory reservation lock but NEVER initiated a payment 
-- session with Stripe/gateway (indicating users who bounced before entering any payment 
-- details), and which specific product categories are suffering the highest upfront abandonment?
--
-- TECHNICAL APPROACH:
-- - Executed a `LEFT JOIN` between `orders` and `payment_transactions` on `order_id`.
-- - Filtered using `WHERE p.transaction_id IS NULL` to isolate orders that failed to 
--   generate a downstream gateway transaction record.
-- - Joined with `order_items` and `products` to identify catalog drop-off patterns.
--
-- BUSINESS IMPACT / ACTION:
-- Isolates early-stage UI friction (e.g., shipping cost surprises, mandatory account 
-- login friction) from actual payment gateway failures. This tells the product team 
-- whether cart abandonment happens on our own checkout page or on the third-party gateway.
-- ============================================================================

USE omnicart_db;

SELECT 
    o.order_id,
    c.full_name,
    c.city,
    pr.product_name,
    pr.category,
    o.total_amount,
    o.order_status,
    o.created_at AS checkout_initiated_at,
    CASE 
        WHEN p.transaction_id IS NULL AND o.order_status = 'EXPIRED' 
            THEN 'BOUNCED_BEFORE_GATEWAY_REDIRECT'
        WHEN p.transaction_id IS NULL AND o.order_status = 'PENDING_PAYMENT' 
            THEN 'IN_PROGRESS_CHECKOUT_SESSION'
        ELSE 'OTHER_STATE'
    END AS dropoff_classification
FROM orders o
JOIN customers c 
    ON o.customer_id = c.customer_id
JOIN order_items oi 
    ON o.order_id = oi.order_id
JOIN products pr 
    ON oi.product_id = pr.product_id
LEFT JOIN payment_transactions p 
    ON o.order_id = p.order_id
WHERE p.transaction_id IS NULL
ORDER BY o.total_amount DESC;


-- ============================================================================
-- QUERY 5: Filter for Specific Rank Hierarchy (DENSE_RANK = 5)
-- ============================================================================
-- BUSINESS QUESTION:
-- Which product holds the exact 5th-tier revenue ranking across our entire 
-- catalog, and how can we programmatically filter window functions without 
-- incurring syntax errors?
--
-- TECHNICAL APPROACH:
-- - Applied `DENSE_RANK()` ordered by `realized_revenue DESC`.
-- - Wrapped the window calculation inside a CTE (`RankedCatalog`) so the outer 
--   query can evaluate `WHERE catalog_rank = 5`.
-- ============================================================================

USE omnicart_db;

WITH ProductSales AS (
    SELECT 
        pr.product_id,
        pr.product_name,
        pr.category,
        pr.unit_price,
        SUM(oi.quantity) AS total_units_sold,
        SUM(oi.quantity * oi.unit_price) AS realized_revenue
    FROM order_items oi
    JOIN products pr ON oi.product_id = pr.product_id
    JOIN orders o ON oi.order_id = o.order_id
    WHERE o.order_status = 'PAID'
    GROUP BY pr.product_id, pr.product_name, pr.category, pr.unit_price
),
RankedCatalog AS (
    SELECT 
        product_id,
        product_name,
        category,
        unit_price,
        total_units_sold,
        realized_revenue,
        DENSE_RANK() OVER (ORDER BY realized_revenue DESC) AS catalog_rank
    FROM ProductSales
)
SELECT 
    catalog_rank,
    product_name,
    category,
    unit_price,
    total_units_sold,
    realized_revenue
FROM RankedCatalog
WHERE catalog_rank = 5;

