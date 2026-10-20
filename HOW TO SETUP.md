# Awake Coffee - Installation & Setup Guide

This guide will walk you through setting up the Awake Coffee application, including both the Laravel backend and Flutter frontend.

---

## Table of Contents

1. [Requirements](#requirements)
2. [Backend Setup](#backend-setup)
   - [Option A: Docker (Recommended)](#option-a-docker-recommended)
   - [Option B: Manual Setup](#option-b-manual-setup)
3. [Frontend Setup (Flutter)](#frontend-setup-flutter)
4. [Configuration](#configuration)
5. [Running the Application](#running-the-application)
6. [Admin Panel Access](#admin-panel-access)
7. [Demo Accounts](#demo-accounts)
8. [Troubleshooting](#troubleshooting)

---

## Requirements

### Backend Requirements

- **PHP** 8.4 or higher
- **Composer** 2.x
- **MySQL** 8.0 or higher
- **Docker & Docker Compose** (if using Docker setup)

### Frontend Requirements

- **Flutter SDK** 3.10.1 or higher
- **Dart SDK** 3.0 or higher
- **Android Studio** (for Android development)
- **Xcode** (for iOS development, macOS only)

---

## Backend Setup

Navigate to the backend directory:

```bash
cd backend
```

### Option A: Docker (Recommended)

Docker provides the easiest and most consistent setup experience.

#### Step 1: Create Environment Files

```bash
# Copy the Docker environment file
cp .env.docker.example .env.docker

# Copy the Laravel environment file
cp src/.env.example src/.env
```

#### Step 2: Configure Laravel Environment

Edit `src/.env` with your settings:

```env
APP_NAME=Awake
APP_ENV=local
APP_DEBUG=true
APP_URL=http://localhost:8000
APP_TIMEZONE=Asia/Jakarta

DB_CONNECTION=mysql
DB_HOST=database
DB_PORT=3306
DB_DATABASE=awake
DB_USERNAME=laravel
DB_PASSWORD=password

MAIL_MAILER=smtp
MAIL_HOST=sandbox.smtp.mailtrap.io
MAIL_PORT=2525
MAIL_USERNAME=your_mailtrap_username
MAIL_PASSWORD=your_mailtrap_password
MAIL_FROM_ADDRESS="noreply@awake.coffee"
MAIL_FROM_NAME="${APP_NAME}"

# Set to true to skip sending emails (OTP will be logged instead)
MAIL_SKIP_SENDING=false
```

#### Step 3: Start Docker Containers

```bash
docker compose -f docker-compose.dev.yml up -d
```

#### Step 4: Install Dependencies

```bash
docker compose -f docker-compose.dev.yml exec app mkdir -p bootstrap/cache storage/framework/views
docker compose -f docker-compose.dev.yml exec app composer config --global process-timeout 2000
docker compose -f docker-compose.dev.yml exec app composer install
```

#### Step 5: Generate Application Key

```bash
docker compose -f docker-compose.dev.yml exec app php artisan key:generate
```

#### Step 6: Run Migrations & Seeders

```bash
# Run database migrations
docker compose -f docker-compose.dev.yml exec app php artisan migrate

# Seed the database with demo data
docker compose -f docker-compose.dev.yml exec app php artisan db:seed
```

#### Step 7: Create Storage Link

```bash
docker compose -f docker-compose.dev.yml exec app php artisan storage:link
```

The backend API will be available at `http://localhost:8000`

---

### Option B: Manual Setup

If you prefer not to use Docker, you can set up the backend manually.

#### Step 1: Navigate to Source Directory

```bash
cd src
```

#### Step 2: Create Environment File

```bash
cp .env.example .env
```

#### Step 3: Configure Environment

Edit `.env` with your local database settings:

```env
APP_NAME=Awake
APP_ENV=local
APP_DEBUG=true
APP_URL=http://localhost:8000
APP_TIMEZONE=Asia/Jakarta

DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=awake
DB_USERNAME=root
DB_PASSWORD=your_password

MAIL_MAILER=smtp
MAIL_HOST=sandbox.smtp.mailtrap.io
MAIL_PORT=2525
MAIL_USERNAME=your_mailtrap_username
MAIL_PASSWORD=your_mailtrap_password
MAIL_FROM_ADDRESS="noreply@awake.coffee"
MAIL_FROM_NAME="${APP_NAME}"
```

#### Step 4: Install Dependencies

```bash
mkdir -p bootstrap/cache storage/framework/views
composer config --global process-timeout 2000
composer install
```

#### Step 5: Generate Application Key

```bash
php artisan key:generate
```

#### Step 6: Create Database

Create a MySQL database named `awake`:

```sql
CREATE DATABASE awake CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

#### Step 7: Run Migrations & Seeders

```bash
php artisan migrate
php artisan db:seed
```

#### Step 8: Create Storage Link

```bash
php artisan storage:link
```

#### Step 9: Start the Server

```bash
php artisan serve --port=8000
```

The backend API will be available at `http://localhost:8000`

---

## Frontend Setup (Flutter)

Navigate to the root project directory (where `pubspec.yaml` is located).

#### Step 1: Install Flutter Dependencies

```bash
flutter pub get
```

#### Step 2: Configure API Base URL (Optional)

The API endpoints are configured in `lib/core/network/api_endpoints.dart`. By default, it's set up for local development:

- **Android Emulator**: `http://10.0.2.2:8000/api`
- **iOS Simulator**: `http://localhost:8000/api`

If your backend runs on a different URL, update this file:

```dart
static String get baseUrl {
  if (Platform.isAndroid) {
    return 'http://10.0.2.2:8000/api'; // Android emulator
  } else {
    return 'http://localhost:8000/api'; // iOS simulator
  }
}

static String get storageBaseUrl {
  if (Platform.isAndroid) {
    return 'http://10.0.2.2:8000'; // Android emulator
  } else {
    return 'http://localhost:8000'; // iOS simulator
  }
}
```

For physical devices on the same network, replace with your computer's local IP address:

```dart
return 'http://192.168.x.x:8000/api';
```

#### Step 3: Run the App

```bash
# Run on connected device or emulator
flutter run

# Or specify a device
flutter run -d <device_id>

# List available devices
flutter devices
```

---

## Configuration

### Email Configuration (OTP)

Awake Coffee uses email OTP for two-factor authentication. You can use [Mailtrap](https://mailtrap.io) for development:

1. Create a free Mailtrap account
2. Get your SMTP credentials from the inbox settings
3. Update the `.env` file with your credentials

**Development Mode**: Set `MAIL_SKIP_SENDING=true` to skip sending emails. OTP codes will be logged to `storage/logs/laravel.log` instead.

### Timezone Configuration

Set your timezone in the `.env` file:

```env
APP_TIMEZONE=Asia/Jakarta
```

After changing timezone, clear the config cache:

```bash
php artisan config:clear
```

---

## Running the Application

### Start Backend (Docker)

```bash
cd backend
docker compose -f docker-compose.dev.yml up -d
```

### Start Backend (Manual)

```bash
cd backend/src
php artisan serve --port=8000
```

### Start Flutter App

```bash
flutter run
```

---

## Admin Panel Access

The admin panel is powered by Filament and available at:

```
http://localhost:8000/admin
```

### Default Admin Credentials

After running seeders, use these credentials:

| Email | Password | Role |
|-------|----------|------|
| admin@awake.coffee | password | Admin |

### Admin Features

- **User Management** - Create, edit, view users
- **Product Management** - Manage menu items and pricing
- **Category Management** - Organize product categories
- **Cafe Management** - Manage branches, photos, operating hours
- **City Management** - Manage city locations
- **Order Management** - View and update order status
- **Wallet Transactions** - Approve/reject top-up requests

---

## Demo Accounts

After running database seeders, these accounts are available:

| Email | Password | Role |
|-------|----------|------|
| admin@awake.coffee | password | Admin / Cafe Manager |
| customer@awake.coffee | password | Customer |

---

## Troubleshooting

### Common Issues

#### 1. "Connection refused" error in Flutter app

- Ensure the backend server is running on port 8000
- For Android emulator, use `10.0.2.2` instead of `localhost`
- For physical devices, use your computer's local IP address
- Check if firewall is blocking the connection

#### 2. Database connection error

- Verify MySQL is running
- Check database credentials in `.env`
- Ensure the database exists

#### 3. Docker containers not starting

```bash
# Check container status
docker compose -f docker-compose.dev.yml ps

# View logs
docker compose -f docker-compose.dev.yml logs -f
```

#### 4. Storage/upload issues

Ensure storage link is created:

```bash
php artisan storage:link
```

Set proper permissions (Linux/Mac):

```bash
chmod -R 775 storage bootstrap/cache
```

#### 5. OTP not received

- Check Mailtrap inbox (emails may take a few seconds)
- Verify SMTP credentials in `.env`
- Set `MAIL_SKIP_SENDING=true` for development (check logs)

#### 6. "Class not found" errors

```bash
composer dump-autoload
php artisan config:clear
php artisan cache:clear
```

#### 7. Composer install times out while extracting packages

If Composer reports that `/usr/bin/unzip` exceeded the 300-second process timeout, increase Composer's process timeout and retry the installation. If Composer then reports that `bootstrap/cache` or a Laravel view cache path is missing, create those directories first:

```bash
# Docker setup
docker compose -f docker-compose.dev.yml exec app mkdir -p bootstrap/cache storage/framework/views
docker compose -f docker-compose.dev.yml exec app composer config --global process-timeout 2000
docker compose -f docker-compose.dev.yml exec app composer install

# Manual setup (run from the backend directory)
mkdir -p bootstrap/cache storage/framework/views
composer config --global process-timeout 2000
composer install
```

### Useful Commands

```bash
# Clear all Laravel caches
php artisan optimize:clear

# Re-run migrations (WARNING: drops all tables)
php artisan migrate:fresh --seed

# Check API routes
php artisan route:list --path=api

# Run queue worker (for background jobs)
php artisan queue:work
```

---

## Production Deployment

For production deployment, consider:

1. Set `APP_ENV=production` and `APP_DEBUG=false`
2. Use a proper web server (Nginx/Apache) instead of `php artisan serve`
3. Configure HTTPS
4. Set up proper database credentials
5. Configure email service (SendGrid, Mailgun, etc.)
6. Set up queue workers for background processing
7. Build Flutter app for release:

```bash
# Android
flutter build apk --release
flutter build appbundle --release

# iOS
flutter build ios --release
```

---

## Support

If you encounter any issues not covered in this guide, please check:

1. Laravel logs: `backend/src/storage/logs/laravel.log`
2. Flutter console output
3. Browser developer tools (for API errors)

---

Happy coding! ☕
