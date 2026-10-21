# Business Requirements Document (BRD)
## Project Name: OmniCart Order & Payment Orchestration Engine

## 1. Executive Summary
OmniCart is an e-commerce platform seeking to optimize its checkout architecture. Currently, the platform suffers from inventory lock contention during high-traffic events, payment gateway failures, and revenue leakage from unrecovered cart abandonments. This project establishes an API-first orchestration engine alongside an executive analytics dashboard to ensure reliable checkouts and real-time transaction visibility.

## 2. Business Objectives & Goals
- **Eliminate Double-Charging:** Implement strict request idempotency headers to prevent duplicate orders during unstable network retries.
- **Protect Inventory Integrity:** Introduce a 15-minute Time-To-Live (TTL) reservation lock mechanism to prevent phantom stock hoarding.
- **Minimize Revenue Leakage:** Provide product and engineering teams with real-time visibility into expired and failed payment transactions.

## 3. Key Performance Indicators (KPIs) & Success Metrics
| Metric Name | Business Definition | Target Goal |
| :--- | :--- | :--- |
| **Checkout Conversion Rate** | Percentage of initiated orders successfully settled as `PAID`. | $\ge 75\%$ |
| **Revenue Leakage** | Total gross merchandise value (GMV) lost due to `EXPIRED` or `CANCELLED` orders. | $< 10\%$ of total GMV |