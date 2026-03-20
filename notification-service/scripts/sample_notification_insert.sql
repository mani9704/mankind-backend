-- Sample data for notifications table

-- Clear existing data
DELETE FROM notifications;

-- Reset auto-increment
ALTER TABLE notifications AUTO_INCREMENT = 1;

-- Insert sample email notifications
INSERT INTO notifications (user_id, type, subject, content, status)
VALUES 
(1, 'EMAIL', 'Welcome to Mankind', 'Thank you for registering with Mankind! We are excited to have you on board.', 'SENT'),
(1, 'EMAIL', 'Your order has been placed', 'Your order #12345 has been successfully placed and is being processed.', 'SENT'),
(2, 'EMAIL', 'Welcome to Mankind', 'Thank you for registering with Mankind! We are excited to have you on board.', 'SENT'),
(2, 'EMAIL', 'Password Reset Request', 'You have requested a password reset. Click the link below to reset your password.', 'PENDING'),
(3, 'EMAIL', 'Welcome to Mankind', 'Thank you for registering with Mankind! We are excited to have you on board.', 'SENT');

-- Insert sample SMS notifications
INSERT INTO notifications (user_id, type, subject, content, status)
VALUES 
(1, 'SMS', 'Order Confirmation', 'Your Mankind order #12345 has been confirmed. Est. delivery: 3-5 days.', 'SENT'),
(2, 'SMS', 'Verification Code', 'Your Mankind verification code is: 123456', 'SENT'),
(3, 'SMS', 'Delivery Update', 'Your Mankind order is out for delivery and will arrive today.', 'PENDING');

-- Insert sample push notifications
INSERT INTO notifications (user_id, type, subject, content, status)
VALUES 
(1, 'PUSH', 'New Promotion', 'Check out our latest sale! 20% off all products this weekend.', 'SENT'),
(2, 'PUSH', 'Cart Reminder', 'You have items in your cart. Complete your purchase now!', 'FAILED'),
(3, 'PUSH', 'New Feature', 'We have added new features to our app. Update now to check them out!', 'PENDING');