/* ============================================================
   PROJECT 01 - BANKING DATABASE DESIGN
   CHAPTER 14 - AUDIT DATA MODEL
   FILE 08 - AUDIT ROLLBACK
   ============================================================ */


/*
   WARNING:

   This removes ONLY the audit schema created by Chapter 14.

   It does NOT remove:
       customer
       account
       card
       loan
       txn
       channel
       risk
       aml
       or other core banking schemas.
*/


DROP SCHEMA IF EXISTS audit CASCADE;

-- Không chạy 08_audit_rollback.sql, trừ khi bạn muốn xóa Chapter 14.