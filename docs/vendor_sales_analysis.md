---
title: "  Vendor Sales Performance Analysis"
output: html_document
---


## 1. Business Objective

The primary objective of this analysis is to evaluate vendor performance using transactional purchase, sales, pricing, and invoice data in order to support strategic decision-making.

Specifically, this project aims to:

- Identify underperforming brands and vendors that may require pricing or promotional adjustments
- Determine top-performing vendors based on sales contribution and gross profit
- Analyze the impact of bulk purchasing on unit costs and vendor efficiency
- Assess inventory turnover to identify opportunities to reduce holding costs and improve operational efficiency
- Compare profitability variance between high-performing and low-performing vendors


## 2. Data Overview
- Data sources
- Tables used
- Key fields

## 3. Data Preparation Summary
- Cleaning steps
  + Vendor Integrity Checks
  + Inventory Data Handling
  + Date Handling
  + Missing Data Treatment
  + Scope Decisions
- Filtering logic
  + Rather than dropping rows aggressively, invalid cases were retained and excluded at the metric-calculation level using conditional logic.
- Derived metrics
  + Gross Profit
  + Profit Margin (0–1)
  + Sales to Purchase Retio
  + Stock Turnover

## 4. Exploratory Data Analysis (EDA)

### 4.1 Summary Statistics Insights
- Gross Profit: Minimum value is -52,002.78, indicating losses.Some products or transactions are sold at a loss, likely driven by high procurement costs, freight expenses, or aggressive discounting below purchase price.
- Profit Margin: Includes negative and undefined values, indicating cases where revenue is zero or lower than total costs.
- Total Sales Quantity & Sales Dollars: Minimum values are 0, meaning some products were purchased but never sold. These could be slow-moving or obsolete
stock.
- This suggests slow-moving or obsolete inventory and represents tied-up working capital.

### 4.2 Distribution Analysis
(Histograms, boxplots)

### 4.3 Outlier Analysis
 
- Purchase & Actual Prices: The max values (5,681.81 & 7,499.99) are significantly higher than the mean (24.39 & 35.64), indicating potential premium
products.
- Freight Cost: Huge variation, from 0.09 to 257,032.07, suggests logistics inefficiencies or bulk shipments.
- Stock Turnover: Ranges from 0 to 274.5, implying some products sell extremely fast while others remain in stock indefinitely. Value more than 1 indicates that
Sold quantity for that product is higher than purchased quantity due to either sales are being fulfilled from older stock.


### 4.4 Correlation Insights 

- GrossProfit shows a very strong positive correlation with TotalSalesDollars (0.98) and TotalSalesQuantity (0.70), indicating that profitability is primarily driven by sales volume rather than pricing or margin expansion.

- TotalPurchaseQuantity and TotalSalesQuantity are almost perfectly correlated (0.999), reflecting strong alignment between procurement and sales demand, with minimal inventory mismatch.

- PurchasePrice exhibits negligible correlation with both TotalSalesDollars (-0.01) and GrossProfit (-0.02), suggesting that variations in unit cost do not materially influence overall revenue or profit outcomes.

- ProfitMargin has a modest negative correlation with TotalSalesPrice (-0.18), indicating potential pricing pressure or increased costs associated with higher-priced sales.


### 4.5 Vendor Contribution Analysis

#### Objective

The objective of this analysis is to identify vendors that contribute the most to total purchase dollars and to assess the level of vendor concentration within the procurement portfolio. This helps evaluate dependency risk and opportunities for supplier optimization.

#### Key Insights

- High concentration among top vendors:
The analysis shows that a small group of vendors (Top 10) accounts for a disproportionately large share of total purchase dollars. This indicates a concentrated procurement structure rather than an evenly distributed vendor base.

- Presence of dominant vendors:
The leading vendors individually contribute a significant portion of total purchase spend, highlighting their strategic importance in the supply chain. Any disruption, pricing change, or contract renegotiation with these vendors could materially impact overall procurement costs.

- Long tail of low-contributing vendors:
Beyond the top contributors, a large number of vendors contribute marginally to total purchase dollars. This long-tail pattern suggests potential opportunities for vendor rationalization and consolidation.

- Operational and negotiation implications:
High purchase concentration with a limited number of vendors can improve bargaining power and operational efficiency, but it also introduces dependency risk. A balanced sourcing strategy may help mitigate supply risk while preserving cost advantages.

### Business Implications

- Procurement teams should closely monitor performance and pricing of top contributing vendors due to their outsized financial impact.

- Risk mitigation strategies such as secondary suppliers or diversified sourcing should be evaluated for highly concentrated categories.

- Low-contribution vendors should be reviewed for strategic relevance, potential consolidation, or elimination to reduce administrative and operational overhead.


