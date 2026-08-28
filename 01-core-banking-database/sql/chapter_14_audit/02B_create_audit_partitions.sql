/* ============================================================
   PROJECT 01 - BANKING DATABASE DESIGN
   CHAPTER 14 - AUDIT DATA MODEL
   FILE 02B - CREATE AUDIT PARTITIONS
   ============================================================ */


/* ============================================================
   AUGUST 2026
   ============================================================ */

CREATE TABLE IF NOT EXISTS audit.audit_event_2026_08
PARTITION OF audit.audit_event
FOR VALUES FROM ('2026-08-01 00:00:00+07')
             TO   ('2026-09-01 00:00:00+07');


/* ============================================================
   SEPTEMBER 2026
   ============================================================ */

CREATE TABLE IF NOT EXISTS audit.audit_event_2026_09
PARTITION OF audit.audit_event
FOR VALUES FROM ('2026-09-01 00:00:00+07')
             TO   ('2026-10-01 00:00:00+07');


/* ============================================================
   OCTOBER 2026
   ============================================================ */

CREATE TABLE IF NOT EXISTS audit.audit_event_2026_10
PARTITION OF audit.audit_event
FOR VALUES FROM ('2026-10-01 00:00:00+07')
             TO   ('2026-11-01 00:00:00+07');


/* ============================================================
   NOVEMBER 2026
   ============================================================ */

CREATE TABLE IF NOT EXISTS audit.audit_event_2026_11
PARTITION OF audit.audit_event
FOR VALUES FROM ('2026-11-01 00:00:00+07')
             TO   ('2026-12-01 00:00:00+07');


/* ============================================================
   DECEMBER 2026
   ============================================================ */

CREATE TABLE IF NOT EXISTS audit.audit_event_2026_12
PARTITION OF audit.audit_event
FOR VALUES FROM ('2026-12-01 00:00:00+07')
             TO   ('2027-01-01 00:00:00+07');


/* ============================================================
   JANUARY 2027
   ============================================================ */

CREATE TABLE IF NOT EXISTS audit.audit_event_2027_01
PARTITION OF audit.audit_event
FOR VALUES FROM ('2027-01-01 00:00:00+07')
             TO   ('2027-02-01 00:00:00+07');