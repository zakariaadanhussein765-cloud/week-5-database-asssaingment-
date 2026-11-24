-- ================================================================
-- PLP DATABASE ASSIGNMENT - WEEK 5
-- Topic: Database Indexing, User Accounts, Privileges and Security
-- Database platform: MySQL 8.x
--
-- IMPORTANT:
-- 1. Run this script using an administrator account (for example root).
-- 2. The assignment names the target database salesDB. The screenshot
--    supplied for this assignment shows a schema named sales instead.
-- 3. To satisfy the assignment exactly and make the GRANT statement
--    executable, this script creates salesDB only if it does not exist.
--    This does NOT rename or modify the existing sales database.
-- 4. Question 1 is safely guarded: it drops IdxPhone only if that
--    index exists on customers. If it is absent, the script reports it.
-- ================================================================

-- ------------------------------------------------
-- QUESTION 1
-- Drop the index named IdxPhone from customers.
-- ------------------------------------------------

USE sales;

SET @idx_exists = (
    SELECT COUNT(*)
    FROM information_schema.statistics
    WHERE table_schema = DATABASE()
      AND table_name = 'customers'
      AND index_name = 'IdxPhone'
);

SET @q1_sql = IF(
    @idx_exists > 0,
    'DROP INDEX `IdxPhone` ON `customers`',
    'SELECT ''IdxPhone was not found on sales.customers; no index was dropped.'' AS Q1_status'
);

PREPARE q1_stmt FROM @q1_sql;
EXECUTE q1_stmt;
DEALLOCATE PREPARE q1_stmt;

-- ------------------------------------------------
-- QUESTION 2
-- Create the MySQL account bob restricted to localhost.
-- The ALTER USER line also makes reruns deterministic:
-- it sets the requested initial password even if bob exists.
-- ------------------------------------------------

CREATE USER IF NOT EXISTS 'bob'@'localhost'
IDENTIFIED BY 'S$cu3r3!';

ALTER USER 'bob'@'localhost'
IDENTIFIED BY 'S$cu3r3!';

-- ------------------------------------------------
-- QUESTION 3
-- Grant INSERT privilege to bob on the assignment's
-- target database, salesDB.
--
-- Create salesDB only if it is missing so that the GRANT
-- statement can be executed exactly as the assignment asks.
-- Existing schema sales is left untouched.
-- ------------------------------------------------

CREATE DATABASE IF NOT EXISTS `salesDB`;

GRANT INSERT ON `salesDB`.*
TO 'bob'@'localhost';

-- ------------------------------------------------
-- QUESTION 4
-- Change bob's password to the new password specified
-- in the assignment.
-- ------------------------------------------------

ALTER USER 'bob'@'localhost'
IDENTIFIED BY 'P$55!23';

-- ------------------------------------------------
-- FINAL VERIFICATION
-- Run these statements as an administrator.
-- The SHOW GRANTS output should include:
-- GRANT INSERT ON `salesDB`.* TO `bob`@`localhost`
-- ------------------------------------------------

SHOW GRANTS FOR 'bob'@'localhost';

SELECT user, host
FROM mysql.user
WHERE user = 'bob'
  AND host = 'localhost';

SELECT schema_name
FROM information_schema.schemata
WHERE schema_name IN ('sales', 'salesDB');

-- Verify whether IdxPhone remains on sales.customers.
-- A result of 0 means the index is absent.
SELECT COUNT(*) AS IdxPhone_remaining
FROM information_schema.statistics
WHERE table_schema = 'sales'
  AND table_name = 'customers'
  AND index_name = 'IdxPhone';

-- ================================================================
-- END OF WEEK 5 DATABASE ASSIGNMENT
-- ================================================================
