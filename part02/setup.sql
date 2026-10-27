CREATE ROLE shop_owner NOLOGIN;
CREATE ROLE shop_api LOGIN PASSWORD 'lab-only-change-me';
CREATE ROLE shop_worker LOGIN PASSWORD 'lab-only-change-me';
CREATE DATABASE shop OWNER shop_owner;
\connect shop
SET ROLE shop_owner;

CREATE TABLE events (id int GENERATED ALWAYS AS IDENTITY PRIMARY KEY, name text NOT NULL);
CREATE TABLE orders (
  id int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  email text NOT NULL,
  total numeric(10, 2) NOT NULL CHECK (total >= 0),
  status text NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'paid', 'fulfilled', 'refunded'))
);
CREATE TABLE tickets (
  id int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  order_id int NOT NULL REFERENCES orders,
  code text NOT NULL UNIQUE,
  status text NOT NULL DEFAULT 'valid' CHECK (status IN ('valid', 'void'))
);
CREATE TABLE audit_log (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  at timestamptz NOT NULL DEFAULT now(),
  actor text NOT NULL,
  action text NOT NULL
);

INSERT INTO events (name) VALUES ('Spring concert');
INSERT INTO orders (email, total, status) VALUES
  ('ana@example.com', 90.00, 'fulfilled'),
  ('ben@example.com', 45.00, 'paid');
INSERT INTO tickets (order_id, code) VALUES (1, 'QR-7F3A'), (1, 'QR-9C21');

GRANT CONNECT ON DATABASE shop TO shop_api, shop_worker;
GRANT USAGE ON SCHEMA public TO shop_api, shop_worker;
GRANT SELECT ON events TO shop_api;
GRANT SELECT, INSERT, UPDATE ON orders TO shop_api;
GRANT SELECT, UPDATE (status) ON tickets TO shop_api;
GRANT INSERT ON audit_log TO shop_api;
GRANT SELECT, UPDATE (status) ON orders TO shop_worker;
GRANT SELECT, INSERT ON tickets TO shop_worker;
GRANT INSERT ON audit_log TO shop_worker;
