# Internal Wallet Transaction System API

A Ruby on Rails application implementing a generic wallet solution for multiple entities (e.g., users), supporting append-only ledger transactions with snapshot-based wallet balances. It also includes a naive sign-in approach (no external auth gem) and concurrency handling with pessimistic row-level locking.

## Description

This repository provides a wallet transaction API that:

- Allows users to sign in using a naive approach (no sign-up endpoint—if the user doesn’t exist, it’s created).
- Implements append-only transactions to maintain a clear audit trail via a double-entry ledger system.
- Uses wallet snapshots to store each user’s running balance after every transaction, enabling quick balance lookups.
- Employs row-level locking to handle concurrency, preventing double spends or race conditions.
- Demonstrates a form object pattern to keep controllers clean.

## Setup & Installation

### Prerequisites
1. Ruby (3.4)
2. Rails 8
3. PostgreSQL 
4. Bundler (gem install bundler)

### Configuration & Environment Variables
- Database credentials: Provide your DB config in config/database.yml or via environment variables (e.g., DATABASE_URL).
- RapidAPI Keys (if you plan to integrate with stock price services):
  - RAPIDAPI_KEY
  - URL = https://latest-stock-price.p.rapidapi.com

### Database Setup
```
# Clone the repository
git clone https://github.com/<your-username>/wallet-transaction-api.git
cd wallet-transaction-api

# Install gems
bundle install

# Create & migrate the database
rails db:create
rails db:migrate

# (Optional) Seed the database with sample data
rails db:seed

```
### Running locally
```
# Start the Rails server
rails server

# By default, it runs on http://localhost:3000

```

## High-Level Functionalities
1. Naive Sign-In
   - POST /auth/login with email and password.
   - Creates the user if not found, or validates the password if found.
   - Returns a bearer token stored in a simple in-memory TOKEN_STORE.
2. Wallet Transactions
   - Each user’s balance is tracked in the wallets table, with a new row each time their balance changes.
   - Look up the current balance by selecting the latest row for that user.

## How Things Work

### Architecture of the Wallet Solution
1. Double-Entry Ledger:
    The transactions table records all money movements. For a user-to-user transfer:
    A debit row for the sender.
    A credit row for the receiver.
2. Snapshots for Balances:
    The wallets table is append-only, storing each user’s updated balance whenever a transaction affects them. To compute a user’s balance at any point, fetch their latest wallet record.
3. Naive Auth:
    POST /auth/login with {email, password}. If a user with email doesn’t exist, we create one (with a hashed password). If the user does exist, we validate the password; on success, return a token.

### Model Relationships & Validations
1. User
    - has_many :transactions
    - has_many :wallets
    - Validates presence of email and password_digest.
    - Provides a method to compute current_balance from the wallets table.
2. Transaction
   - Belongs to a user.
   - Contains debit or credit amounts.
   - For concurrency, each transaction runs in a ActiveRecord::Base.transaction block with row-level locks on the relevant users.
3. Wallet
   - Belongs to a user.
   - balance is the user’s current or historical snapshot after a transaction.
   - Each new row in wallets is append-only—never updated—ensuring a consistent audit trail.

### Design Patterns Used

1. Append-Only Ledger:
    Avoids direct balance updates; all money movements are recorded historically.
2. Form Object:
    Encapsulates business logic for transactions in app/forms/transactions/create_form.rb (or similar). The controller delegates to the form object, which handles validations, concurrency locks, ledger entries, and wallet snapshots.
3. Row-Level Pessimistic Locking:
    We lock the sender and receiver user records in ascending ID order to avoid deadlocks.