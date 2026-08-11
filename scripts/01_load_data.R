
source("config/paths.R")


packages <- c("readr", "dplyr", "janitor", "lubridate", "here", "skimr","tidyverse","patchwork","ggrepel","glimpse")

# Install any missing packages
installed_packages <- rownames(installed.packages())
for (p in packages) {
  if (!(p %in% installed_packages)) {
    install.packages(p)
  }
}
library(readr)



# Load CSV files
begin_inventory <- read_csv(paste0(raw_data_path, "begin_inventory.csv"))
end_inventory   <- read_csv(paste0(raw_data_path, "end_inventory.csv"))
purchase_prices <- read_csv(paste0(raw_data_path, "purchase_prices.csv"))
purchases       <- read_csv(paste0(raw_data_path, "purchases.csv"))
sales           <- read_csv(paste0(raw_data_path, "sales.csv"))
vendor_invoice  <- read_csv(paste0(raw_data_path, "vendor_invoice.csv"))

# Quick structure check
glimpse(begin_inventory)
glimpse(purchases)
glimpse(sales)
glimpse(end_inventory)
glimpse(purchase_prices)
glimpse(vendor_invoice)
