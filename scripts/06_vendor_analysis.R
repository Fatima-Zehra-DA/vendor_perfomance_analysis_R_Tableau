source("config/paths.R")

# --------------------------------------------------
# File: 05_eda.R
# Purpose: Exploratory Data Analysis for Vendor Performance
# Dataset: vendor_sales_summary
# Grain: One row per Vendor × Brand
# --------------------------------------------------
library(skimr)
library(tidyverse)
library(scales)

# -------------------------------
# 2. # Load Vendor sales summary
# -------------------------------

vendor_sales <- read_csv(paste0(processed_data_path, "vendor_sales_summary.csv"))

# -----------------------------
# 2. Structure & summary checks
# -----------------------------
skim(vendor_sales)
str(vendor_sales)
summary(vendor_sales)
glimpse(vendor_sales)

# -----------------------------
# 3. Sanity Checks
# -----------------------------
# Missing values check
vendor_sales %>%
  summarise(across(everything(), ~ sum(is.na(.))))

# Basic distributions
summary(vendor_sales$ProfitMargin )
summary(vendor_sales$stockTurnover)

# Negative or impossible values
vendor_sales %>%
  filter(
    ProfitMargin < -1 |
      ProfitMargin > 1 |
      stockTurnover < 0
  )

# --------------------------------
# 4. Objective-mapped EDA sections
# --------------------------------

# Objective 1: Identify underperforming vendors 

vendor_sales %>%
  arrange(ProfitMargin) %>%
  slice_head(n = 10)





# Objective 2: Top-performing vendors

vendor_sales %>%
  arrange(desc(TotalSalesDollars)) %>%
  slice_head(n = 10)


# Objective 3: Freight erosion analysis

vendor_sales %>%
  mutate(
    FreightPctOfSales = TotalFreightCost / TotalSalesDollars
  ) %>%
  arrange(desc(FreightPctOfSales))


# Objective 4: Profitability distribution

ggplot(vendor_sales, aes(ProfitMargin )) +
  geom_histogram(bins = 30) +
  labs(
    title = "Distribution of Vendor Landed Margins",
    x = "Landed Margin %",
    y = "Vendor Count"
  )

# Objective 5: High vs low performer comparison

vendor_sales %>%
  mutate(
    PerformanceTier = case_when(
      ProfitMargin >= quantile(ProfitMargin, 0.75, na.rm = TRUE) ~ "Top",
      ProfitMargin <= quantile(ProfitMargin, 0.25, na.rm = TRUE) ~ "Bottom",
      TRUE ~ "Middle"
    )
  ) %>%
  group_by(PerformanceTier) %>%
  summarise(
    AvgSales = mean(TotalSalesDollars, na.rm = TRUE),
    AvgMargin = mean(ProfitMargin, na.rm = TRUE)
  )


















