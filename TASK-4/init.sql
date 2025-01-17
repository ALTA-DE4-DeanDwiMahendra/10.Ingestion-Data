-- Create the brands table
CREATE TABLE brands (
  brand_id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL
);

-- Create the products table
CREATE TABLE products (
  product_id SERIAL PRIMARY KEY,
  brand_id INT REFERENCES brands(brand_id),
  name VARCHAR(255) NOT NULL,
  price DECIMAL(10, 2) NOT NULL
);

-- Create the orders table
CREATE TABLE orders (
  order_id SERIAL PRIMARY KEY,
  order_date TIMESTAMP DEFAULT current_timestamp,
  customer_phone VARCHAR(15)
);

-- Create the order_details table
CREATE TABLE order_details (
  order_detail_id SERIAL PRIMARY KEY,
  order_id INT REFERENCES orders(order_id),
  product_id INT REFERENCES products(product_id),
  quantity INT NOT NULL,
  price DECIMAL(10, 2) NOT NULL
);

INSERT INTO brands (name) VALUES
('Apple'),
('Samsung'),
('Sony');

-- Populate products table
INSERT INTO products (brand_id, name, price) VALUES
(1, 'iPhone 13', 799.99),
(1, 'MacBook Pro', 1299.99),
(2, 'Galaxy S21', 699.99),
(3, 'PlayStation 5', 499.99);

DO $$ 
DECLARE 
  day_counter DATE;
  phone_prefix VARCHAR(2);
  phone_number VARCHAR(15);
BEGIN
  FOR day_counter IN SELECT generate_series(
      current_date - INTERVAL '14 days',
      current_date,
      INTERVAL '1 day'
    )::DATE
  LOOP
    -- Generate a random phone number with prefix '91' or '62'
    phone_prefix := CASE WHEN random() < 0.5 THEN '91' ELSE '62' END;
    phone_number := phone_prefix || floor(random() * (9999999999 - 1000000000 + 1) + 1000000000)::TEXT;
    
    -- Optionally add '+' sign
    IF random() < 0.5 THEN
      phone_number := '+' || phone_number;
    END IF;
    INSERT INTO orders (order_date, customer_phone)
    SELECT
      day_counter + (random() * INTERVAL '1 day'),
      phone_number
    FROM
      generate_series(1, floor(random() * (50 - 10 + 1) + 10)::INT);
  END LOOP;
END $$;

DO $$ 
DECLARE 
  target_order_id INT;
  random_product_id INT;
  random_quantity INT;
  product_price DECIMAL(10, 2);
BEGIN
  FOR target_order_id IN SELECT order_id FROM orders
  LOOP
    -- Randomly choose a product ID, let's assume IDs are between 1 and 4
    random_product_id := floor(random() * 4 + 1)::INT;
    -- Random quantity between 1 and 10
    random_quantity := floor(random() * 10 + 1)::INT;

    SELECT price INTO product_price FROM products WHERE product_id = random_product_id;

    INSERT INTO order_details (order_id, product_id, quantity, price)
    VALUES (target_order_id, random_product_id, random_quantity, product_price * random_quantity);
  END LOOP;
END $$;