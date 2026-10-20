# AWAKE Coffee - Database Schema (MVP)

This document outlines all database tables required for the AWAKE Coffee Flutter app backend (Laravel).

---

## 1. users

Stores user account information.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INT | PK, AUTO_INCREMENT | Primary key |
| name | STRING | NOT NULL | User's full name |
| email | STRING | NOT NULL, UNIQUE | Email address |
| email_verified_at | TIMESTAMP | NULLABLE | Email verification timestamp |
| password | STRING | NOT NULL | Hashed password |
| gender | STRING | NULLABLE | User's gender |
| phone | STRING | NULLABLE | Phone number |
| photo | STRING | NULLABLE | Profile photo URL |
| remember_token | STRING | NULLABLE | Laravel remember me token |
| created_at | TIMESTAMP | | |
| updated_at | TIMESTAMP | | |

---

## 2. otp_codes

Stores OTP verification codes for email verification.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INT | PK, AUTO_INCREMENT | Primary key |
| user_id | INT | FK -> users.id | User reference |
| code | STRING | NOT NULL | OTP code |
| expires_at | DATE | NOT NULL | Expiration date |
| created_at | TIMESTAMP | | |
| updated_at | TIMESTAMP | | |

---

## 3. wallets

Stores user wallet balance.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INT | PK, AUTO_INCREMENT | Primary key |
| user_id | INT | FK -> users.id | User reference |
| balance | INT | DEFAULT 0 | Current wallet balance |
| created_at | TIMESTAMP | | |
| updated_at | TIMESTAMP | | |

---

## 4. wallet_transactions

Stores wallet top-up and payment/refund transactions.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INT | PK, AUTO_INCREMENT | Primary key |
| wallet_id | INT | FK -> wallets.id | Wallet reference |
| amount | INT | NOT NULL | Pure amount added/deducted to/from wallet |
| total_amount | INT | NOT NULL | Total transfer amount (amount + service_fee - unique_code) |
| type | STRING | NOT NULL | Transaction type (topup/payment/refund) |
| status | STRING | NOT NULL | Status (pending/approved/rejected) |
| transaction_id | INT | FK -> transactions.id, NULLABLE | Related order transaction |
| proof_of_payment | STRING | NULLABLE | Payment proof image URL |
| service_fee | INT | DEFAULT 0 | Service fee amount |
| unique_code | INT | NULLABLE | Unique code for verification |
| created_at | TIMESTAMP | | |
| updated_at | TIMESTAMP | | |

---

## 5. categories

Product categories.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INT | PK, AUTO_INCREMENT | Primary key |
| name | STRING | NOT NULL | Category name |
| slug | STRING | NOT NULL, UNIQUE | URL-friendly name |
| created_at | TIMESTAMP | | |
| updated_at | TIMESTAMP | | |

**Default Categories:** Coffee, Non Coffee, Tea, Snack, Merchandise

---

## 6. products

Menu items/products.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INT | PK, AUTO_INCREMENT | Primary key |
| name | STRING | NOT NULL | Product name |
| price | INT | NOT NULL | Base price |
| rate | INT | DEFAULT 0 | Rating (0-5) |
| thumbnail | STRING | NULLABLE | Product image URL |
| slug | STRING | NOT NULL, UNIQUE | URL-friendly name |
| category_id | INT | FK -> categories.id | Category reference |
| about | TEXT | NULLABLE | Product description |
| service_time | INT | NULLABLE | Preparation time in minutes |
| is_featured | BOOLEAN | DEFAULT FALSE | Show in featured products section |
| created_at | TIMESTAMP | | |
| updated_at | TIMESTAMP | | |

---

## 7. product_options

Customization options for products (size, sweetness, ice, dairy).

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INT | PK, AUTO_INCREMENT | Primary key |
| name | STRING | NOT NULL | Option name (e.g., "Large", "No Sugar") |
| price | INT | DEFAULT 0 | Additional price |
| type | STRING | NOT NULL | Option type (size/sweetness/ice/dairy) |
| product_id | INT | FK -> products.id | Product reference |
| created_at | TIMESTAMP | | |
| updated_at | TIMESTAMP | | |

---

## 8. cities

City locations for cafes.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INT | PK, AUTO_INCREMENT | Primary key |
| name | STRING | NOT NULL | City name |
| photo | STRING | NULLABLE | City image URL |
| slug | STRING | NOT NULL, UNIQUE | URL-friendly name |
| created_at | TIMESTAMP | | |
| updated_at | TIMESTAMP | | |

---

## 9. cafes

Coffee shop branch locations.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INT | PK, AUTO_INCREMENT | Primary key |
| name | STRING | NOT NULL | Branch name |
| thumbnail | STRING | NULLABLE | Main image URL |
| photos | JSON | NULLABLE | Array of photo URLs |
| slug | STRING | NOT NULL, UNIQUE | URL-friendly name |
| city_id | INT | FK -> cities.id | City reference |
| about | TEXT | NULLABLE | Branch description |
| facilities | JSON | NULLABLE | Array of facilities |
| manager_name | STRING | NULLABLE | Branch manager name |
| created_at | TIMESTAMP | | |
| updated_at | TIMESTAMP | | |

---

## 10. cafe_time_slots

Operating hours for each cafe by day of week.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INT | PK, AUTO_INCREMENT | Primary key |
| cafe_id | INT | FK -> cafes.id | Cafe reference |
| day_of_week | INT | NOT NULL | Day (0=Sunday, 1=Monday, ..., 6=Saturday) |
| start_time | TIME | NOT NULL | Opening time |
| end_time | TIME | NOT NULL | Closing time |
| is_active | BOOLEAN | DEFAULT TRUE | Is open on this day |
| created_at | TIMESTAMP | | |
| updated_at | TIMESTAMP | | |

---

## 11. transactions

Customer orders/transactions.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INT | PK, AUTO_INCREMENT | Primary key |
| user_id | INT | FK -> users.id | Customer reference |
| payment_status | STRING | NOT NULL | Payment status (pending/paid/failed) |
| order_status | STRING | NOT NULL | Order status (pending/preparing/ready/finished/cancelled) |
| grand_total_amount | INT | NOT NULL | Grand total |
| total_tax_amount | INT | DEFAULT 0 | Tax amount |
| service_fee_amount | INT | DEFAULT 0 | Service fee |
| discount | INT | DEFAULT 0 | Discount amount |
| tax_percentage_amount | INT | DEFAULT 0 | Tax percentage |
| total_items | INT | NOT NULL | Total number of items |
| proof_of_payment | STRING | NULLABLE | Payment proof URL |
| cafe_id | INT | FK -> cafes.id | Branch reference |
| payment_method | STRING | NOT NULL | Payment method (wallet/cash/card) |
| created_at | TIMESTAMP | | |
| updated_at | TIMESTAMP | | |

---

## 12. transaction_details

Individual items within a transaction/order.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INT | PK, AUTO_INCREMENT | Primary key |
| transaction_id | INT | FK -> transactions.id | Transaction reference |
| product_id | INT | FK -> products.id | Product reference |
| price | INT | NOT NULL | Unit price |
| quantity | INT | NOT NULL | Item quantity |
| total_amount | INT | NOT NULL | price * quantity |
| created_at | TIMESTAMP | | |
| updated_at | TIMESTAMP | | |

---

## 13. transaction_detail_options

Stores product options (size, sweetness, ice, dairy) selected for each order item.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INT | PK, AUTO_INCREMENT | Primary key |
| transaction_detail_id | INT | FK -> transaction_details.id | Transaction detail reference |
| product_option_id | INT | FK -> product_options.id | Selected option reference |
| price | INT | DEFAULT 0 | Option price at time of purchase |
| created_at | TIMESTAMP | | |
| updated_at | TIMESTAMP | | |

---

## Entity Relationship Diagram

```
users
├── otp_codes (1:N)
├── wallets (1:1)
└── transactions (1:N)

wallets
└── wallet_transactions (1:N)

cities
└── cafes (1:N)

cafes
├── cafe_time_slots (1:N)
└── transactions (1:N)

categories
└── products (1:N)

products
├── product_options (1:N)
└── transaction_details (1:N)

transactions
└── transaction_details (1:N)
    └── transaction_detail_options (1:N)

product_options
└── transaction_detail_options (1:N)
```

---

## Laravel Migration Order

Run migrations in this order to respect foreign key constraints:

1. users
2. otp_codes
3. wallets
4. categories
5. cities
6. cafes
7. cafe_time_slots
8. products
9. product_options
10. transactions
11. transaction_details
12. transaction_detail_options
13. wallet_transactions

---

## Notes for Laravel Implementation

1. Use Laravel's built-in `timestamps()` for created_at/updated_at
2. Use `softDeletes()` for users, products, transactions if needed
3. Use Laravel Sanctum for API authentication
4. Use `Hash::make()` for passwords
5. Use Laravel Observers for wallet balance updates after transactions
6. Use Laravel Events for notifications on order status changes
7. JSON columns (`photos`, `facilities`) use `$casts` in model:
   ```php
   protected $casts = [
       'photos' => 'array',
       'facilities' => 'array',
   ];
   ```

---

## User Roles & Permissions

User roles and permissions are managed using **[Spatie Laravel Permission](https://spatie.be/docs/laravel-permission)** package.

### Installation
```bash
composer require spatie/laravel-permission
php artisan vendor:publish --provider="Spatie\Permission\PermissionServiceProvider"
php artisan migrate
```

### Suggested Roles for MVP
| Role | Description |
|------|-------------|
| admin | Full access to all features and management |
| cafe_manager | Manage specific cafe branch, view orders, update order status |
| customer | Regular app user, can place orders and manage wallet |

### Usage Example
```php
// Assign role to user
$user->assignRole('customer');

// Check role
if ($user->hasRole('admin')) {
    // Admin actions
}

// Middleware protection
Route::middleware(['role:admin'])->group(function () {
    // Admin routes
});
```

**Note:** The `users` table does not need a `role` column. Spatie package creates its own tables (`roles`, `permissions`, `model_has_roles`, `model_has_permissions`, `role_has_permissions`) to handle role management.
