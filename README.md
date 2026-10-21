# OmniCart Order & Payment Orchestration Engine

## 🚀 Project Overview
A production-grade technical analytics project built to solve e-commerce cart abandonment, inventory lock race conditions, and payment gateway revenue leakage. This project bridges **System Architecture, Agile Requirements, Relational Database Design, and Business Intelligence**.

---

## 📂 Repository Structure
- **`database/`**: Normalized 3NF MySQL DDL schema (`schema.sql`), seed data (`seed_data.sql`), and advanced analytical queries (`analytical_queries.sql`).
- **`docs/`**: Business Requirements Document (BRD), Agile User Stories with Gherkin acceptance criteria, and a Stakeholder Management Plan.
- **`api/`**: OpenAPI 3.0 REST specification handling checkout locks and asynchronous payment webhooks (`openapi_v1.0.yaml`).
- **`OmniCart_Dashboard.pbix`**: Executive monitoring dashboard file.

---

## 🗄️ SQL & Analytics Highlights
- **CTEs & Conditional Logic:** Diagnosed inventory expiration root causes.
- **Window Functions (`ROW_NUMBER()`, `LAG()`, `DENSE_RANK()`):** Tracked multi-attempt customer payment funnels.
- **`LEFT JOIN` & Gap Analysis:** Isolated uninitiated checkouts and measured revenue leakage.

---

## 📊 Power BI Executive Dashboard
- **Star Schema Model:** Configured clean `1-to-many` relationships across operational tables.
- **DAX Measures:** Custom metrics tracking *Realized Revenue*, *Checkout Conversion Rate*, *Revenue Leakage*, and *Total Orders*.
- **Interactive Visuals:** Executive dark-themed monitoring layout with a responsive date range slicer.

  <img width="641" height="252" alt="table" src="https://github.com/user-attachments/assets/6053a9e2-7cb5-4a80-9d4c-27fd4fddc8e3" />
<img width="1342" height="545" alt="charts" src="https://github.com/user-attachments/assets/6b001a78-51c3-4003-9900-6fc823125690" />
<img width="732" height="202" alt="kpi_cards" src="https://github.com/user-attachments/assets/7abdedee-9daf-42ee-832d-41e0f8558c73" />




