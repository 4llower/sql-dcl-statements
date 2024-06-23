CREATE USER rentaluser WITH PASSWORD 'rentalpassword';
GRANT CONNECT ON DATABASE dvdrental TO rentaluser;
GRANT SELECT ON customer TO rentaluser;
-- Verify under rentaluser -> should work
-- SELECT * FROM customer;

CREATE ROLE rental;
GRANT INSERT, UPDATE, SELECT ON rental TO rental; -- idk why, but without SELECT grant update doesn't work :(
GRANT USAGE, UPDATE ON SEQUENCE rental_rental_id_seq TO rental;
GRANT rental TO rentaluser;
-- Verify under rentaluser -> should work
-- INSERT INTO rental (inventory_id, rental_date, customer_id, staff_id) VALUES (1, '2024-06-23', 1, 1);
-- UPDATE rental SET rental_date = '2024-06-24' WHERE rental_id = 1;

REVOKE INSERT ON rental FROM rental;

-- Verify under rentaluser -> should fail with permission error
-- INSERT INTO rental (inventory_id, rental_date, customer_id, staff_id) VALUES (1, '2024-06-23', 1, 1);

CREATE ROLE client_Mary_Smith LOGIN PASSWORD 'securePassword123';

GRANT USAGE ON SCHEMA public TO client_Mary_Smith;

GRANT SELECT ON customer TO client_Mary_Smith;

-- Run this query to get customer_id and hard-code it 
-- yes... I tried to create dynamic policy (select customer_id in policy by first_name and last_name and spent a 2h to debug it and decided to hard-code, maybe missed some knowledges), but sorry i'm stupid
-- SELECT customer_id FROM customer WHERE first_name = 'Mary' AND last_name = 'Smith';

ALTER TABLE rental ENABLE ROW LEVEL SECURITY;
ALTER TABLE payment ENABLE ROW LEVEL SECURITY;

CREATE POLICY select_rental ON rental FOR SELECT TO client_Mary_Smith
USING (customer_id = 1);

CREATE POLICY select_payment ON payment FOR SELECT TO client_Mary_Smith
USING (rental_id IN (SELECT rental_id FROM rental WHERE customer_id = 1));

-- Grant SELECT on the tables to the role
GRANT SELECT ON rental TO client_Mary_Smith;
GRANT SELECT ON payment TO client_Mary_Smith;

-- I just removed rental role from rentaluser and gave new create client_Mary_Smith for testing purposes -> you can do other way :)
-- GRANT client_Mary_Smith TO rentaluser;
-- SELECT * FROM payment; -- to check everything shows in payment
-- SELECT * FROM rental; -- to check everything shows in rental