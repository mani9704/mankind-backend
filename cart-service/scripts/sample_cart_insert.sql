-- sample_cart_insert.sql
USE mankind_matrix_db;

-- Insert sample carts
INSERT INTO cart (user_id, session_id, status, subtotal, tax, total, created_at, updated_at)
VALUES
    (101, NULL, 'ACTIVE', 69.97, 7.00, 76.97, NOW(), NOW()),
    (102, NULL, 'ACTIVE', 59.97, 6.00, 65.97, NOW(), NOW()),
    (103, NULL, 'ACTIVE', 49.95, 5.00, 54.95, NOW(), NOW()),
    (NULL, 'guest-session-123', 'ACTIVE', 14.99, 1.50, 16.49, NOW(), NOW());

-- Insert sample cart items
INSERT INTO cart_item (cart_id, product_id, quantity, price)
VALUES
    (1, 201, 2, 19.99),
    (1, 202, 1, 29.99),
    (2, 201, 3, 19.99),
    (3, 203, 5, 9.99),
    (4, 204, 1, 14.99);
