library(tidyverse)
source("config/paths.R")

# Load processed data
begin_inventory <- read_csv(paste0(processed_data_path, "begin_inventory_clean.csv"))
purchases <- read_csv(paste0(processed_data_path, "purchases_clean.csv"))
sales <- read_csv(paste0(processed_data_path, "sales_clean.csv"))

# Merge purchases with vendor invoice
vendor_purchases <- purchases %>%
  left_join(vendor_invoice, by = "vendor_id")

# Save integrated dataset
write_csv(vendor_purchases,
          paste0(processed_data_path, "vendor_purchases.csv"))
