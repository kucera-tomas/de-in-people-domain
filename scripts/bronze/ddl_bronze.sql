/*
===============================================================================
DDL Script: Create Bronze Tables (HR / ATS)
===============================================================================
Script Purpose:
    This script creates tables in the 'dw_bronze' database, dropping existing tables 
    if they already exist.
      Run this script to re-define the DDL structure of 'bronze' Tables
===============================================================================
*/

USE dw_bronze;

-- =======================================================
-- Source: HR ATS (Applicant Tracking System)
-- =======================================================

-- 1. Raw Candidates
DROP TABLE IF EXISTS ats_raw_candidates;
CREATE TABLE ats_raw_candidates
(
    candidate_id NVARCHAR(50),
    full_name NVARCHAR(100),
    source NVARCHAR(50),
    profile_created_date NVARCHAR(50)
);

-- 2. Raw Applications
DROP TABLE IF EXISTS ats_raw_applications;
CREATE TABLE ats_raw_applications
(
    app_id NVARCHAR(50),
    candidate_id NVARCHAR(50),
    role_level NVARCHAR(50),
    applied_date NVARCHAR(50),
    decision_date NVARCHAR(50),
    expected_salary NVARCHAR(50)
);

-- 3. Raw Interviews
DROP TABLE IF EXISTS ats_raw_interviews;
CREATE TABLE ats_raw_interviews
(
    interview_id NVARCHAR(50),
    app_id NVARCHAR(50),
    interview_date NVARCHAR(50),
    outcome NVARCHAR(50)
);