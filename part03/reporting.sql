\set ON_ERROR_STOP off
CREATE ROLE reporting LOGIN PASSWORD 'lab-only-change-me';
GRANT CONNECT ON DATABASE shop TO reporting;

-- Reports read views in their own schema, never the raw tables
SET ROLE shop_owner;
CREATE SCHEMA reporting;
CREATE VIEW reporting.sales AS
  SELECT status, count(*) AS orders, sum(total) AS revenue FROM orders GROUP BY status;
GRANT USAGE ON SCHEMA reporting TO reporting;
GRANT SELECT ON ALL TABLES IN SCHEMA reporting TO reporting;

\echo '-- the next migration adds a view'
CREATE VIEW reporting.tickets AS
  SELECT status, count(*) AS tickets FROM tickets GROUP BY status;
RESET ROLE;

\echo '-- reporting reads both views, and tries a raw table'
SET ROLE reporting;
SELECT * FROM reporting.sales;
SELECT * FROM reporting.tickets;
SELECT code FROM public.tickets;
RESET ROLE;

\echo '-- fix: default privileges for future views, and a grant for the one that slipped through'
SET ROLE shop_owner;
ALTER DEFAULT PRIVILEGES FOR ROLE shop_owner IN SCHEMA reporting GRANT SELECT ON TABLES TO reporting;
GRANT SELECT ON reporting.tickets TO reporting;
CREATE VIEW reporting.events AS SELECT count(*) AS events FROM events;
RESET ROLE;

\echo '-- reporting reads the fixed view and the newest one'
SET ROLE reporting;
SELECT * FROM reporting.tickets;
SELECT * FROM reporting.events;
