\set ON_ERROR_STOP off
-- Void a ticket after a refund: allowed, only the status column
UPDATE tickets SET status = 'void' WHERE id = 2;
-- Change a ticket's QR code: not allowed
UPDATE tickets SET code = 'QR-FORGED' WHERE id = 1;
-- Delete an order: not allowed
DELETE FROM orders WHERE id = 2;
-- Write to the audit log: allowed
INSERT INTO audit_log (actor, action) VALUES ('api', 'void ticket 2');
-- Rewrite the audit log: not allowed
UPDATE audit_log SET action = 'nothing happened';
