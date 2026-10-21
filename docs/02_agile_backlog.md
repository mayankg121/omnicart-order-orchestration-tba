# Agile Backlog & User Stories
## Project Name: OmniCart Order & Payment Orchestration Engine

## Epic 1: Checkout & Inventory Management

### User Story 1 (US-01): Timed Inventory Reservation Lock
**As a** customer checking out items during a flash sale,  
**I want** the system to reserve my selected product inventory for 15 minutes,  
**So that** items are not sold out from under me while I complete payment details.

#### Acceptance Criteria (Gherkin Syntax):
- **Given** a customer submits a valid checkout request for available stock items,
- **When** the order is created,
- **Then** the system assigns a 15-minute `lock_expires_at` TTL timestamp, temporarily decrements product stock, and sets order status to `PENDING_PAYMENT`.

### User Story 2 (US-02): Idempotent Order Creation
**As a** mobile app client experiencing unstable network connectivity,  
**I want** the API to reject duplicate order submissions sent with the same idempotency key,  
**So that** users are never double-charged or assigned duplicate orders.

#### Acceptance Criteria (Gherkin Syntax):
- **Given** an order has already been successfully created using a specific `X-Idempotency-Key` header,
- **When** a duplicate request with the identical key is received within the cache window,
- **Then** the database enforces a unique constraint violation and the API returns the original order confirmation without duplicating charges.