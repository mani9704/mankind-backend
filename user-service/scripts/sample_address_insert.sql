INSERT INTO address (user_id, address_type, is_default, street_address, city, state, postal_code, country, created_at, updated_at)
VALUES
    -- Admin user (ID: 1) addresses
    (1, 'billing', true, '123 Admin Street', 'New York', 'NY', '10001', 'USA', NOW(), NOW()),
    (1, 'shipping', true, '456 Admin Avenue', 'New York', 'NY', '10001', 'USA', NOW(), NOW()),
    
    -- Regular user (ID: 2) addresses
    (2, 'billing', true, '789 User Boulevard', 'San Francisco', 'CA', '94105', 'USA', NOW(), NOW()),
    (2, 'shipping', false, '101 User Lane', 'San Francisco', 'CA', '94105', 'USA', NOW(), NOW()),
    (2, 'shipping', true, '202 User Drive', 'Los Angeles', 'CA', '90001', 'USA', NOW(), NOW());
-- Note: Each user has a default billing address
-- User ID 1 (admin) has the same location for billing and shipping
-- User ID 2 (jj) has different addresses for billing and shipping, with multiple shipping addresses