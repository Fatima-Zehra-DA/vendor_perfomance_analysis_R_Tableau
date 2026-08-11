library(tidyverse)
source("config/paths.R")

vendor_kpi <- read_csv(paste0(output_tables_path, "vendor_kpi.csv"))

# Top vendors by purchase cost
ggplot(vendor_kpi,
       aes(x = reorder(vendor_name, total_purchase_cost),
           y = total_purchase_cost)) +
  geom_col() +
  coord_flip() +
  labs(
    title = "Total Purchase Cost by Vendor",
    x = "Vendor",
    y = "Total Cost"
  )

ggsave(
  filename = paste0(output_figures_path, "vendor_purchase_cost.png"),
  width = 8,
  height = 5
)
