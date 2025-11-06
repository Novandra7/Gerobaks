-- Gerobaks Database Creation and Seeding Script
-- Laravel 11 + MySQL Database for Waste Management App
-- Generated: December 30, 2024

-- Create database if not exists
CREATE DATABASE IF NOT EXISTS gerobaks_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE gerobaks_db;

-- Drop existing tables if they exist (in correct order due to foreign keys)
DROP TABLE IF EXISTS subscriptions;
DROP TABLE IF EXISTS subscription_plans;
DROP TABLE IF EXISTS personal_access_tokens;
DROP TABLE IF EXISTS ratings;
DROP TABLE IF EXISTS chats;
DROP TABLE IF EXISTS notifications;
DROP TABLE IF EXISTS balances;
DROP TABLE IF EXISTS trackings;
DROP TABLE IF EXISTS activities;
DROP TABLE IF EXISTS payments;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS schedules;
DROP TABLE IF EXISTS services;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS failed_jobs;
DROP TABLE IF EXISTS password_reset_tokens;
DROP TABLE IF EXISTS migrations;

-- Create migrations table
CREATE TABLE migrations (
    id int unsigned NOT NULL AUTO_INCREMENT,
    migration varchar(255) NOT NULL,
    batch int NOT NULL,
    PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create failed_jobs table
CREATE TABLE failed_jobs (
    id bigint unsigned NOT NULL AUTO_INCREMENT,
    uuid varchar(255) NOT NULL,
    connection text NOT NULL,
    queue text NOT NULL,
    payload longtext NOT NULL,
    exception longtext NOT NULL,
    failed_at timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY failed_jobs_uuid_unique (uuid)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create password_reset_tokens table
CREATE TABLE password_reset_tokens (
    email varchar(255) NOT NULL,
    token varchar(255) NOT NULL,
    created_at timestamp NULL DEFAULT NULL,
    PRIMARY KEY (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create users table
CREATE TABLE users (
    id bigint unsigned NOT NULL AUTO_INCREMENT,
    name varchar(255) NOT NULL,
    email varchar(255) NOT NULL,
    phone varchar(255) DEFAULT NULL,
    email_verified_at timestamp NULL DEFAULT NULL,
    password varchar(255) NOT NULL,
    role enum('admin','mitra','end_user') NOT NULL DEFAULT 'end_user',
    status enum('active','inactive','suspended') NOT NULL DEFAULT 'active',
    address text,
    profile_image varchar(255) DEFAULT NULL,
    date_of_birth date DEFAULT NULL,
    gender enum('male','female','other') DEFAULT NULL,
    remember_token varchar(100) DEFAULT NULL,
    created_at timestamp NULL DEFAULT NULL,
    updated_at timestamp NULL DEFAULT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY users_email_unique (email),
    KEY users_role_index (role),
    KEY users_status_index (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create personal_access_tokens table (Sanctum)
CREATE TABLE personal_access_tokens (
    id bigint unsigned NOT NULL AUTO_INCREMENT,
    tokenable_type varchar(255) NOT NULL,
    tokenable_id bigint unsigned NOT NULL,
    name varchar(255) NOT NULL,
    token varchar(64) NOT NULL,
    abilities text,
    last_used_at timestamp NULL DEFAULT NULL,
    expires_at timestamp NULL DEFAULT NULL,
    created_at timestamp NULL DEFAULT NULL,
    updated_at timestamp NULL DEFAULT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY personal_access_tokens_token_unique (token),
    KEY personal_access_tokens_tokenable_type_tokenable_id_index (tokenable_type,tokenable_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create services table
CREATE TABLE services (
    id bigint unsigned NOT NULL AUTO_INCREMENT,
    name varchar(255) NOT NULL,
    description text,
    price decimal(10,2) NOT NULL,
    unit varchar(255) NOT NULL DEFAULT 'kg',
    is_active tinyint(1) NOT NULL DEFAULT '1',
    category varchar(255) DEFAULT NULL,
    image varchar(255) DEFAULT NULL,
    created_at timestamp NULL DEFAULT NULL,
    updated_at timestamp NULL DEFAULT NULL,
    PRIMARY KEY (id),
    KEY services_is_active_index (is_active),
    KEY services_category_index (category)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create subscription_plans table
CREATE TABLE subscription_plans (
    id bigint unsigned NOT NULL AUTO_INCREMENT,
    name varchar(255) NOT NULL,
    description text,
    price decimal(10,2) NOT NULL,
    billing_cycle enum('monthly','yearly') NOT NULL,
    features json DEFAULT NULL,
    is_active tinyint(1) NOT NULL DEFAULT '1',
    max_orders_per_month int DEFAULT NULL,
    max_tracking_locations int DEFAULT NULL,
    priority_support tinyint(1) NOT NULL DEFAULT '0',
    advanced_analytics tinyint(1) NOT NULL DEFAULT '0',
    custom_branding tinyint(1) NOT NULL DEFAULT '0',
    created_at timestamp NULL DEFAULT NULL,
    updated_at timestamp NULL DEFAULT NULL,
    PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create subscriptions table
CREATE TABLE subscriptions (
    id bigint unsigned NOT NULL AUTO_INCREMENT,
    user_id bigint unsigned NOT NULL,
    subscription_plan_id bigint unsigned NOT NULL,
    status enum('active','expired','cancelled','pending') NOT NULL DEFAULT 'pending',
    start_date date NOT NULL,
    end_date date NOT NULL,
    amount_paid decimal(10,2) NOT NULL,
    payment_method varchar(255) DEFAULT NULL,
    payment_reference varchar(255) DEFAULT NULL,
    cancelled_at timestamp NULL DEFAULT NULL,
    cancellation_reason text,
    auto_renew tinyint(1) NOT NULL DEFAULT '1',
    created_at timestamp NULL DEFAULT NULL,
    updated_at timestamp NULL DEFAULT NULL,
    PRIMARY KEY (id),
    KEY subscriptions_user_id_foreign (user_id),
    KEY subscriptions_subscription_plan_id_foreign (subscription_plan_id),
    KEY subscriptions_user_id_status_index (user_id,status),
    KEY subscriptions_subscription_plan_id_index (subscription_plan_id),
    KEY subscriptions_start_date_end_date_index (start_date,end_date),
    CONSTRAINT subscriptions_subscription_plan_id_foreign FOREIGN KEY (subscription_plan_id) REFERENCES subscription_plans (id) ON DELETE CASCADE,
    CONSTRAINT subscriptions_user_id_foreign FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create schedules table
CREATE TABLE schedules (
    id bigint unsigned NOT NULL AUTO_INCREMENT,
    user_id bigint unsigned NOT NULL,
    mitra_id bigint unsigned DEFAULT NULL,
    service_id bigint unsigned NOT NULL,
    scheduled_date date NOT NULL,
    scheduled_time time NOT NULL,
    address text NOT NULL,
    notes text,
    status enum('pending','confirmed','in_progress','completed','cancelled') NOT NULL DEFAULT 'pending',
    created_at timestamp NULL DEFAULT NULL,
    updated_at timestamp NULL DEFAULT NULL,
    PRIMARY KEY (id),
    KEY schedules_user_id_foreign (user_id),
    KEY schedules_mitra_id_foreign (mitra_id),
    KEY schedules_service_id_foreign (service_id),
    KEY schedules_status_index (status),
    KEY schedules_scheduled_date_index (scheduled_date),
    CONSTRAINT schedules_mitra_id_foreign FOREIGN KEY (mitra_id) REFERENCES users (id) ON DELETE SET NULL,
    CONSTRAINT schedules_service_id_foreign FOREIGN KEY (service_id) REFERENCES services (id) ON DELETE CASCADE,
    CONSTRAINT schedules_user_id_foreign FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create orders table
CREATE TABLE orders (
    id bigint unsigned NOT NULL AUTO_INCREMENT,
    user_id bigint unsigned NOT NULL,
    mitra_id bigint unsigned DEFAULT NULL,
    service_id bigint unsigned NOT NULL,
    schedule_id bigint unsigned DEFAULT NULL,
    quantity decimal(8,2) NOT NULL,
    unit_price decimal(10,2) NOT NULL,
    total_price decimal(10,2) NOT NULL,
    status enum('pending','confirmed','in_progress','completed','cancelled') NOT NULL DEFAULT 'pending',
    pickup_address text NOT NULL,
    pickup_date date NOT NULL,
    pickup_time time NOT NULL,
    notes text,
    created_at timestamp NULL DEFAULT NULL,
    updated_at timestamp NULL DEFAULT NULL,
    PRIMARY KEY (id),
    KEY orders_user_id_foreign (user_id),
    KEY orders_mitra_id_foreign (mitra_id),
    KEY orders_service_id_foreign (service_id),
    KEY orders_schedule_id_foreign (schedule_id),
    KEY orders_status_index (status),
    KEY orders_pickup_date_index (pickup_date),
    CONSTRAINT orders_mitra_id_foreign FOREIGN KEY (mitra_id) REFERENCES users (id) ON DELETE SET NULL,
    CONSTRAINT orders_schedule_id_foreign FOREIGN KEY (schedule_id) REFERENCES schedules (id) ON DELETE SET NULL,
    CONSTRAINT orders_service_id_foreign FOREIGN KEY (service_id) REFERENCES services (id) ON DELETE CASCADE,
    CONSTRAINT orders_user_id_foreign FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create payments table
CREATE TABLE payments (
    id bigint unsigned NOT NULL AUTO_INCREMENT,
    order_id bigint unsigned NOT NULL,
    user_id bigint unsigned NOT NULL,
    amount decimal(10,2) NOT NULL,
    payment_method enum('cash','transfer','e_wallet','credit_card') NOT NULL,
    payment_status enum('pending','completed','failed','refunded') NOT NULL DEFAULT 'pending',
    payment_reference varchar(255) DEFAULT NULL,
    payment_date timestamp NULL DEFAULT NULL,
    notes text,
    created_at timestamp NULL DEFAULT NULL,
    updated_at timestamp NULL DEFAULT NULL,
    PRIMARY KEY (id),
    KEY payments_order_id_foreign (order_id),
    KEY payments_user_id_foreign (user_id),
    KEY payments_payment_status_index (payment_status),
    KEY payments_payment_method_index (payment_method),
    CONSTRAINT payments_order_id_foreign FOREIGN KEY (order_id) REFERENCES orders (id) ON DELETE CASCADE,
    CONSTRAINT payments_user_id_foreign FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create activities table
CREATE TABLE activities (
    id bigint unsigned NOT NULL AUTO_INCREMENT,
    user_id bigint unsigned NOT NULL,
    type varchar(255) NOT NULL,
    description text NOT NULL,
    related_id bigint unsigned DEFAULT NULL,
    related_type varchar(255) DEFAULT NULL,
    created_at timestamp NULL DEFAULT NULL,
    updated_at timestamp NULL DEFAULT NULL,
    PRIMARY KEY (id),
    KEY activities_user_id_foreign (user_id),
    KEY activities_type_index (type),
    KEY activities_related_id_related_type_index (related_id,related_type),
    CONSTRAINT activities_user_id_foreign FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create trackings table
CREATE TABLE trackings (
    id bigint unsigned NOT NULL AUTO_INCREMENT,
    order_id bigint unsigned NOT NULL,
    mitra_id bigint unsigned NOT NULL,
    latitude decimal(10,8) NOT NULL,
    longitude decimal(11,8) NOT NULL,
    status varchar(255) NOT NULL,
    notes text,
    timestamp timestamp NOT NULL,
    created_at timestamp NULL DEFAULT NULL,
    updated_at timestamp NULL DEFAULT NULL,
    PRIMARY KEY (id),
    KEY trackings_order_id_foreign (order_id),
    KEY trackings_mitra_id_foreign (mitra_id),
    KEY trackings_timestamp_index (timestamp),
    CONSTRAINT trackings_mitra_id_foreign FOREIGN KEY (mitra_id) REFERENCES users (id) ON DELETE CASCADE,
    CONSTRAINT trackings_order_id_foreign FOREIGN KEY (order_id) REFERENCES orders (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create balances table
CREATE TABLE balances (
    id bigint unsigned NOT NULL AUTO_INCREMENT,
    user_id bigint unsigned NOT NULL,
    transaction_type enum('credit','debit') NOT NULL,
    amount decimal(10,2) NOT NULL,
    balance_after decimal(10,2) NOT NULL,
    description text NOT NULL,
    reference_id bigint unsigned DEFAULT NULL,
    reference_type varchar(255) DEFAULT NULL,
    created_at timestamp NULL DEFAULT NULL,
    updated_at timestamp NULL DEFAULT NULL,
    PRIMARY KEY (id),
    KEY balances_user_id_foreign (user_id),
    KEY balances_transaction_type_index (transaction_type),
    KEY balances_reference_id_reference_type_index (reference_id,reference_type),
    CONSTRAINT balances_user_id_foreign FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create notifications table
CREATE TABLE notifications (
    id bigint unsigned NOT NULL AUTO_INCREMENT,
    user_id bigint unsigned NOT NULL,
    title varchar(255) NOT NULL,
    message text NOT NULL,
    type varchar(255) NOT NULL DEFAULT 'info',
    is_read tinyint(1) NOT NULL DEFAULT '0',
    read_at timestamp NULL DEFAULT NULL,
    data json DEFAULT NULL,
    created_at timestamp NULL DEFAULT NULL,
    updated_at timestamp NULL DEFAULT NULL,
    PRIMARY KEY (id),
    KEY notifications_user_id_foreign (user_id),
    KEY notifications_is_read_index (is_read),
    KEY notifications_type_index (type),
    CONSTRAINT notifications_user_id_foreign FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create chats table
CREATE TABLE chats (
    id bigint unsigned NOT NULL AUTO_INCREMENT,
    sender_id bigint unsigned NOT NULL,
    receiver_id bigint unsigned NOT NULL,
    message text NOT NULL,
    is_read tinyint(1) NOT NULL DEFAULT '0',
    order_id bigint unsigned DEFAULT NULL,
    created_at timestamp NULL DEFAULT NULL,
    updated_at timestamp NULL DEFAULT NULL,
    PRIMARY KEY (id),
    KEY chats_sender_id_foreign (sender_id),
    KEY chats_receiver_id_foreign (receiver_id),
    KEY chats_order_id_foreign (order_id),
    KEY chats_is_read_index (is_read),
    CONSTRAINT chats_order_id_foreign FOREIGN KEY (order_id) REFERENCES orders (id) ON DELETE SET NULL,
    CONSTRAINT chats_receiver_id_foreign FOREIGN KEY (receiver_id) REFERENCES users (id) ON DELETE CASCADE,
    CONSTRAINT chats_sender_id_foreign FOREIGN KEY (sender_id) REFERENCES users (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create ratings table
CREATE TABLE ratings (
    id bigint unsigned NOT NULL AUTO_INCREMENT,
    order_id bigint unsigned NOT NULL,
    user_id bigint unsigned NOT NULL,
    mitra_id bigint unsigned NOT NULL,
    rating tinyint unsigned NOT NULL,
    comment text,
    created_at timestamp NULL DEFAULT NULL,
    updated_at timestamp NULL DEFAULT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY ratings_order_id_unique (order_id),
    KEY ratings_user_id_foreign (user_id),
    KEY ratings_mitra_id_foreign (mitra_id),
    KEY ratings_rating_index (rating),
    CONSTRAINT ratings_mitra_id_foreign FOREIGN KEY (mitra_id) REFERENCES users (id) ON DELETE CASCADE,
    CONSTRAINT ratings_order_id_foreign FOREIGN KEY (order_id) REFERENCES orders (id) ON DELETE CASCADE,
    CONSTRAINT ratings_user_id_foreign FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
    CONSTRAINT ratings_rating_check CHECK ((rating >= 1) AND (rating <= 5))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insert migration records
INSERT INTO migrations (migration, batch) VALUES
('0001_01_01_000000_create_users_table', 1),
('0001_01_01_000001_create_cache_table', 1),
('0001_01_01_000002_create_jobs_table', 1),
('2024_12_26_000001_create_services_table', 1),
('2024_12_26_000002_create_schedules_table', 1),
('2024_12_26_000003_create_orders_table', 1),
('2024_12_26_000004_create_payments_table', 1),
('2024_12_26_000005_create_activities_table', 1),
('2024_12_26_000006_create_trackings_table', 1),
('2024_12_26_000007_create_balances_table', 1),
('2024_12_26_000008_create_notifications_table', 1),
('2024_12_26_000009_create_chats_table', 1),
('2024_12_26_000010_create_ratings_table', 1),
('2024_12_30_000001_create_subscription_plans_table', 1),
('2024_12_30_000002_create_subscriptions_table', 1);

-- Seed Data

-- Insert test user
INSERT INTO users (name, email, email_verified_at, password, role, status, created_at, updated_at) VALUES
('Test User', 'test@example.com', NOW(), '$2y$12$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'end_user', 'active', NOW(), NOW());

-- Insert admin user
INSERT INTO users (name, email, email_verified_at, password, role, status, phone, address, created_at, updated_at) VALUES
('Administrator', 'admin@gerobaks.com', NOW(), '$2y$12$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'admin', 'active', '+6281234567890', 'Jakarta Pusat, DKI Jakarta', NOW(), NOW());

-- Insert mitra users
INSERT INTO users (name, email, email_verified_at, password, role, status, phone, address, created_at, updated_at) VALUES
('Mitra Jakarta Utara', 'mitra.jakut@gerobaks.com', NOW(), '$2y$12$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'mitra', 'active', '+6281234567891', 'Jakarta Utara, DKI Jakarta', NOW(), NOW()),
('Mitra Jakarta Selatan', 'mitra.jaksel@gerobaks.com', NOW(), '$2y$12$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'mitra', 'active', '+6281234567892', 'Jakarta Selatan, DKI Jakarta', NOW(), NOW()),
('Mitra Jakarta Timur', 'mitra.jaktim@gerobaks.com', NOW(), '$2y$12$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'mitra', 'active', '+6281234567893', 'Jakarta Timur, DKI Jakarta', NOW(), NOW()),
('Mitra Jakarta Barat', 'mitra.jakbar@gerobaks.com', NOW(), '$2y$12$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'mitra', 'active', '+6281234567894', 'Jakarta Barat, DKI Jakarta', NOW(), NOW());

-- Insert end users
INSERT INTO users (name, email, email_verified_at, password, role, status, phone, address, gender, date_of_birth, created_at, updated_at) VALUES
('Budi Santoso', 'budi@example.com', NOW(), '$2y$12$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'end_user', 'active', '+6285123456789', 'Jl. Merdeka No. 123, Jakarta Pusat', 'male', '1990-05-15', NOW(), NOW()),
('Sari Wahyuni', 'sari@example.com', NOW(), '$2y$12$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'end_user', 'active', '+6285123456788', 'Jl. Sudirman No. 456, Jakarta Selatan', 'female', '1985-12-20', NOW(), NOW()),
('Ahmad Fauzi', 'ahmad@example.com', NOW(), '$2y$12$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'end_user', 'active', '+6285123456787', 'Jl. Thamrin No. 789, Jakarta Pusat', 'male', '1988-08-10', NOW(), NOW());

-- Insert services
INSERT INTO services (name, description, price, unit, is_active, category, created_at, updated_at) VALUES
('Organic Waste Collection', 'Collection and processing of organic kitchen waste', 15000, 'kg', 1, 'organic', NOW(), NOW()),
('Plastic Waste Collection', 'Collection and recycling of plastic waste materials', 8000, 'kg', 1, 'plastic', NOW(), NOW()),
('Paper Waste Collection', 'Collection and recycling of paper and cardboard waste', 5000, 'kg', 1, 'paper', NOW(), NOW()),
('Electronic Waste Disposal', 'Safe disposal of electronic devices and components', 25000, 'unit', 1, 'electronics', NOW(), NOW()),
('Metal Waste Collection', 'Collection and recycling of metal waste materials', 12000, 'kg', 1, 'metal', NOW(), NOW()),
('Glass Waste Collection', 'Collection and recycling of glass bottles and containers', 6000, 'kg', 1, 'glass', NOW(), NOW()),
('Hazardous Waste Disposal', 'Safe disposal of hazardous materials and chemicals', 50000, 'kg', 1, 'hazardous', NOW(), NOW()),
('Mixed Waste Collection', 'General waste collection service for mixed materials', 10000, 'kg', 1, 'mixed', NOW(), NOW());

-- Insert subscription plans
INSERT INTO subscription_plans (name, description, price, billing_cycle, features, is_active, max_orders_per_month, max_tracking_locations, priority_support, advanced_analytics, custom_branding, created_at, updated_at) VALUES
('Basic Plan', 'Perfect for small businesses just getting started with waste management', 99000, 'monthly', '["Up to 50 orders per month", "Basic tracking", "Email support", "Standard dashboard"]', 1, 50, 10, 0, 0, 0, NOW(), NOW()),
('Professional Plan', 'Ideal for growing businesses with enhanced features and support', 199000, 'monthly', '["Up to 200 orders per month", "Advanced tracking with real-time updates", "Priority support", "Advanced analytics", "Custom notifications"]', 1, 200, 50, 1, 1, 0, NOW(), NOW()),
('Enterprise Plan', 'Complete solution for large enterprises with unlimited features', 399000, 'monthly', '["Unlimited orders", "Premium tracking with GPS accuracy", "24/7 dedicated support", "Advanced analytics & reporting", "Custom branding", "API access", "Multi-location management"]', 1, NULL, NULL, 1, 1, 1, NOW(), NOW()),
('Basic Annual', 'Basic plan with annual billing - save 20%', 950000, 'yearly', '["Up to 50 orders per month", "Basic tracking", "Email support", "Standard dashboard", "20% savings with annual billing"]', 1, 50, 10, 0, 0, 0, NOW(), NOW()),
('Professional Annual', 'Professional plan with annual billing - save 20%', 1900000, 'yearly', '["Up to 200 orders per month", "Advanced tracking with real-time updates", "Priority support", "Advanced analytics", "Custom notifications", "20% savings with annual billing"]', 1, 200, 50, 1, 1, 0, NOW(), NOW()),
('Enterprise Annual', 'Enterprise plan with annual billing - save 20%', 3800000, 'yearly', '["Unlimited orders", "Premium tracking with GPS accuracy", "24/7 dedicated support", "Advanced analytics & reporting", "Custom branding", "API access", "Multi-location management", "20% savings with annual billing"]', 1, NULL, NULL, 1, 1, 1, NOW(), NOW());

-- Create sample schedule
INSERT INTO schedules (user_id, mitra_id, service_id, scheduled_date, scheduled_time, address, notes, status, created_at, updated_at) VALUES
(6, 3, 1, '2024-12-31', '09:00:00', 'Jl. Merdeka No. 123, Jakarta Pusat', 'Pickups organic waste from kitchen', 'confirmed', NOW(), NOW()),
(7, 4, 2, '2024-12-31', '14:00:00', 'Jl. Sudirman No. 456, Jakarta Selatan', 'Plastic bottles and containers', 'pending', NOW(), NOW());

-- Create sample orders
INSERT INTO orders (user_id, mitra_id, service_id, schedule_id, quantity, unit_price, total_price, status, pickup_address, pickup_date, pickup_time, notes, created_at, updated_at) VALUES
(6, 3, 1, 1, 5.50, 15000, 82500, 'in_progress', 'Jl. Merdeka No. 123, Jakarta Pusat', '2024-12-31', '09:00:00', 'Organic kitchen waste', NOW(), NOW()),
(7, 4, 2, 2, 3.20, 8000, 25600, 'confirmed', 'Jl. Sudirman No. 456, Jakarta Selatan', '2024-12-31', '14:00:00', 'Plastic bottles and containers', NOW(), NOW()),
(8, 3, 3, NULL, 2.00, 5000, 10000, 'completed', 'Jl. Thamrin No. 789, Jakarta Pusat', '2024-12-30', '10:30:00', 'Cardboard boxes and paper', NOW(), NOW());

-- Create sample payments
INSERT INTO payments (order_id, user_id, amount, payment_method, payment_status, payment_reference, payment_date, notes, created_at, updated_at) VALUES
(1, 6, 82500, 'e_wallet', 'completed', 'PAY-202412-001', NOW(), 'Payment via GoPay', NOW(), NOW()),
(2, 7, 25600, 'transfer', 'pending', 'PAY-202412-002', NULL, 'Bank transfer pending confirmation', NOW(), NOW()),
(3, 8, 10000, 'cash', 'completed', 'CASH-202412-001', NOW(), 'Cash payment on delivery', NOW(), NOW());

-- Create sample activities
INSERT INTO activities (user_id, type, description, related_id, related_type, created_at, updated_at) VALUES
(6, 'order_created', 'Created new waste collection order', 1, 'order', NOW(), NOW()),
(3, 'order_assigned', 'Assigned to handle waste collection order', 1, 'order', NOW(), NOW()),
(7, 'order_created', 'Created new plastic waste collection order', 2, 'order', NOW(), NOW()),
(8, 'order_completed', 'Completed paper waste collection order', 3, 'order', NOW(), NOW());

-- Create sample trackings
INSERT INTO trackings (order_id, mitra_id, latitude, longitude, status, notes, timestamp, created_at, updated_at) VALUES
(1, 3, -6.2088, 106.8456, 'en_route', 'On the way to pickup location', NOW(), NOW(), NOW()),
(1, 3, -6.2000, 106.8300, 'pickup_completed', 'Waste collected successfully', NOW(), NOW(), NOW()),
(3, 3, -6.1944, 106.8229, 'completed', 'Delivered to processing facility', '2024-12-30 11:00:00', NOW(), NOW());

-- Create sample balance records
INSERT INTO balances (user_id, transaction_type, amount, balance_after, description, reference_id, reference_type, created_at, updated_at) VALUES
(6, 'debit', 82500, 417500, 'Payment for organic waste collection', 1, 'payment', NOW(), NOW()),
(3, 'credit', 74250, 274250, 'Revenue from organic waste collection (90% of 82500)', 1, 'payment', NOW(), NOW()),
(8, 'debit', 10000, 490000, 'Payment for paper waste collection', 3, 'payment', NOW(), NOW()),
(3, 'credit', 9000, 283250, 'Revenue from paper waste collection (90% of 10000)', 3, 'payment', NOW(), NOW());

-- Create sample notifications
INSERT INTO notifications (user_id, title, message, type, is_read, read_at, data, created_at, updated_at) VALUES
(6, 'Order Confirmed', 'Your waste collection order has been confirmed and assigned to Mitra Jakarta Utara', 'order', 0, NULL, '{"order_id": 1, "mitra_name": "Mitra Jakarta Utara"}', NOW(), NOW()),
(3, 'New Order Assignment', 'You have been assigned a new waste collection order', 'assignment', 1, NOW(), '{"order_id": 1, "user_name": "Budi Santoso"}', NOW(), NOW()),
(7, 'Payment Pending', 'Your payment for plastic waste collection is pending confirmation', 'payment', 0, NULL, '{"order_id": 2, "amount": 25600}', NOW(), NOW()),
(8, 'Order Completed', 'Your paper waste collection order has been completed successfully', 'completion', 1, NOW(), '{"order_id": 3, "rating_requested": true}', NOW(), NOW());

-- Create sample chats
INSERT INTO chats (sender_id, receiver_id, message, is_read, order_id, created_at, updated_at) VALUES
(6, 3, 'Hi, I have organic waste ready for pickup. The location is easy to find.', 1, 1, NOW(), NOW()),
(3, 6, 'Thank you for the information. I will be there at 9 AM as scheduled.', 1, 1, NOW(), NOW()),
(6, 3, 'Perfect, I will wait for you. The waste is approximately 5.5 kg.', 0, 1, NOW(), NOW()),
(7, 4, 'Hello, do you have large capacity for plastic waste collection?', 1, 2, NOW(), NOW()),
(4, 7, 'Yes, we can handle large quantities. What type of plastic waste do you have?', 0, 2, NOW(), NOW());

-- Create sample ratings
INSERT INTO ratings (order_id, user_id, mitra_id, rating, comment, created_at, updated_at) VALUES
(3, 8, 3, 5, 'Excellent service! Very professional and punctual. The mitra was friendly and handled the waste properly.', NOW(), NOW());

-- Create sample subscriptions
INSERT INTO subscriptions (user_id, subscription_plan_id, status, start_date, end_date, amount_paid, payment_method, payment_reference, auto_renew, created_at, updated_at) VALUES
(3, 2, 'active', '2024-12-01', '2025-01-01', 199000, 'transfer', 'SUB-202412-001', 1, NOW(), NOW()),
(4, 1, 'active', '2024-12-15', '2025-01-15', 99000, 'e_wallet', 'SUB-202412-002', 1, NOW(), NOW());

-- Final message
SELECT 'Gerobaks Database created and seeded successfully!' as message;
SELECT 'Users created: 8 (1 admin, 4 mitra, 3 end_users)' as users_info;
SELECT 'Services available: 8 waste collection types' as services_info;
SELECT 'Subscription plans: 6 plans (3 monthly, 3 annual)' as subscription_info;
SELECT 'Sample data includes: orders, payments, trackings, notifications, chats, ratings' as sample_data_info;