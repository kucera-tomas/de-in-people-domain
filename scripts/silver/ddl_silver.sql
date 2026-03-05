/*
===============================================================================
DDL Script: Create Silver Tables
===============================================================================
Script Purpose:
    This script creates tables in the 'dw_silver' database, dropping existing tables 
    if they already exist.
	  Run this script to re-define the DDL structure of 'silver' Tables
===============================================================================
*/

USE dw_silver;

-- =======================================================
-- Source: ATS (Applicant Tracking System)
-- =======================================================

-- 1. Raw Candidates
DROP TABLE IF EXISTS ats_candidates;
CREATE TABLE ats_candidates
(
    candidate_id NVARCHAR(8),
    full_name NVARCHAR(100),
    source NVARCHAR(50),
    profile_created_date DATE
);

-- 2. Raw Applications
DROP TABLE IF EXISTS ats_applications;
CREATE TABLE ats_applications
(
    app_id NVARCHAR(8),
    candidate_id NVARCHAR(8),
    role_level NVARCHAR(50),
    applied_date DATE,
    decision_date DATE,
    expected_salary INT
);

-- 3. Raw Interviews
DROP TABLE IF EXISTS ats_interviews;
CREATE TABLE ats_interviews
(
    interview_id NVARCHAR(8),
    app_id NVARCHAR(8),
    interview_date DATE,
    outcome NVARCHAR(50)
);