---
title: "Vendor Sales Summary"
output: html_document
---

## Overview

The vendor_sales_summary table is a pre-aggregated dataset designed to consolidate vendor-level sales, purchase, pricing, and freight 
information into a single analytical view. This table is intended to support efficient analysis and reporting of vendor performance without
repeatedly executing expensive joins and aggregations on large transactional datasets.


## Performance Optimization

- This table is built using heavy joins and aggregations across large datasets such as sales, purchases, purchase prices, and vendor invoices.

- Pre-aggregating these metrics significantly reduces computational overhead during exploratory analysis, dashboarding, and reporting.

- Downstream dashboards and analyses can directly query vendor_sales_summary instead of recalculating metrics repeatedly.

- This approach improves performance, consistency, and analytical reliability.

## Business Questions Supported

This summary table enables analysis of the following key business questions:

- Which vendors generate the highest total sales?

- Which vendors incur the highest purchase costs?

- How does freight cost impact vendor-level profitability?

- Are there vendors with high sales volume but relatively low margins?

- How do pricing and purchase behavior vary across vendors and brands?


## Data Sources

- Sales transactions

- Purchase transactions

- Purchase price reference data

- Vendor invoice data (freight)

##  Table Grain

One row per Vendor × Brand

All metrics are aggregated at this level
