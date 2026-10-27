\set ON_ERROR_STOP off
CREATE ROLE reporting LOGIN PASSWORD 'lab-only-change-me';
GRANT CONNECT ON DATABASE shop TO reporting;
GRANT USAGE ON SCHEMA public TO reporting;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO reporting;

\echo '-- the next migration adds a table'
SET ROLE shop_owner;
CREATE TABLE refunds (order_id int REFERENCES orders, amount numeric(10, 2));
RESET ROLE;

\echo '-- reporting reads refunds'
SET ROLE reporting;
SELECT count(*) FROM refunds;
RESET ROLE;

\echo '-- fix: default privileges for future tables, and a grant for the one that slipped through'
ALTER DEFAULT PRIVILEGES FOR ROLE shop_owner IN SCHEMA public GRANT SELECT ON TABLES TO reporting;
GRANT SELECT ON refunds TO reporting;
SET ROLE shop_owner;
CREATE TABLE payouts (id int GENERATED ALWAYS AS IDENTITY PRIMARY KEY, amount numeric(10, 2));
RESET ROLE;

\echo '-- reporting reads refunds and the newer payouts'
SET ROLE reporting;
SELECT count(*) AS refunds FROM refunds;
SELECT count(*) AS payouts FROM payouts;
