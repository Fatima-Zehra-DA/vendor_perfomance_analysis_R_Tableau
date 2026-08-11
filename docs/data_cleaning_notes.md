---
title: "Data Cleaning Notes"
output: html_document
---


## Overview
This project uses transactional datasets related to purchases, sales, pricing, vendor invoices, and inventory.  
The data appeared to be pre-processed and derived from upstream systems; therefore, the cleaning strategy focused on enforcing business rules and validating data integrity rather than applying aggressive transformations.

## Duplicate Validation
Exact duplicate rows were evaluated across all datasets using full-row comparison.  
Row counts before and after deduplication were identical, indicating no true duplicate records were present.

## Business Rule Enforcement
The following rules were applied to ensure analytical validity:

- Purchase records were filtered to retain only positive quantities and purchase prices
- Sales records were filtered to retain only positive quantities and sales prices
- Purchase prices were required to be strictly positive
- Vendor invoice records were filtered to exclude missing vendor names and non-positive dollar values
- Inventory records were filtered to retain only positive price values

## Vendor Integrity Checks
Given that the analysis focuses on vendor performance, vendor identifiers were reviewed to ensure completeness.  
Records with missing or invalid vendor information were excluded where applicable.

## Inventory Data Handling
Begin and end inventory datasets were reviewed for duplicate inventory identifiers.  
No aggressive deduplication was applied, as repeated inventory IDs may represent legitimate business scenarios (e.g., multiple inventory states or locations).

## Date Handling
Date columns were verified for correct data types.  
No additional date transformations were applied where types were already consistent and valid.

## Missing Data Treatment
No imputation techniques were used.  
Records with critical missing values related to vendor identification or financial metrics were excluded to maintain analytical reliability.

## Scope Decisions
- The primary focus of this analysis is vendor performance
- Inventory tables are included for optional validation and potential turnover analysis
- No assumptions were made beyond documented business rules

## Assumptions
- Source datasets reflect accurate transactional records
- Derived tables maintain referential integrity across joins
- Minor data quality issues are not material to vendor-level aggregation

## Output
Cleaned datasets are stored in the processed data directory and used as inputs for exploratory data analysis and KPI computation.
