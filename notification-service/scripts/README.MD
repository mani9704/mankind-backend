# Notification Service Scripts

This directory contains database scripts for the Notification Service.

## Scripts Overview

### notification_tables.sql
This script creates the database schema for the Notification Service. It includes:
- Creation of the `notifications` table
- Definition of constraints and indexes
- Comments for documentation

### sample_notification_insert.sql
This script populates the database with sample notification data for testing and development purposes. It includes:
- Sample email notifications
- Sample SMS notifications
- Sample push notifications

## Usage Instructions

### Setting Up the Database

1. Create a new database for the Notification Service (if not already created):
   ```sql
   CREATE DATABASE notification_service;
   USE notification_service;
   ```

2. Run the table creation script:
   ```bash
   mysql -u username -p notification_service < notification_tables.sql
   ```

3. (Optional) Load sample data:
   ```bash
   mysql -u username -p notification_service < sample_notification_insert.sql
   ```

### Resetting the Database

If you need to reset the database to its initial state:

1. Run the table creation script again (it includes DROP TABLE statements):
   ```bash
   mysql -u username -p notification_service < notification_tables.sql
   ```

2. Optionally, reload the sample data:
   ```bash
   mysql -u username -p notification_service < sample_notification_insert.sql
   ```

## Database Schema

### notifications
- `id`: Unique identifier for the notification (BIGINT, AUTO_INCREMENT)
- `user_id`: ID of the user to whom the notification is sent (BIGINT)
- `type`: Type of notification (VARCHAR(20)) - EMAIL, SMS, PUSH
- `subject`: Subject of the notification (VARCHAR(255))
- `content`: Content of the notification (TEXT)
- `status`: Status of the notification (VARCHAR(20)) - PENDING, SENT, FAILED
- `created_at`: Timestamp when the notification was created (TIMESTAMP)
- `updated_at`: Timestamp when the notification was last updated (TIMESTAMP)

## Indexes
- `idx_notifications_user_id`: Index on user_id for faster queries by user
- `idx_notifications_status`: Index on status for filtering by notification status
- `idx_notifications_created_at`: Index on created_at for time-based queries