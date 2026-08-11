source("config/paths.R")

# --------------------------------------------------
# File: 04_eda.R
# Purpose: Exploratory Data Analysis for Vendor Performance
# Dataset: vendor_sales_summary
# Grain: One row per Vendor × Brand
# --------------------------------------------------
library(skimr)
library(tidyverse)
library(scales)
library(dplyr)
library(ggplot2)
library(readr)
library(forcats)
library(tidyr)
library(scales)

install.packages("patchwork", type = "source")

library(patchwork)

library(ggrepel)
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

#---------------------------------------
# Distribution Plots for Numeric Column
#---------------------------------------

numeric_cols <- vendor_sales %>%
  select(where(is.numeric))

class(numeric_cols)

numeric_long <- numeric_cols %>%
  pivot_longer(
    cols = everything(),
    names_to = "variable",
    values_to = "value"
  )

# Histogram
ggplot(numeric_long, aes(x = value)) +
  geom_histogram(bins = 30, fill = "steelblue", alpha = 0.7) +
  facet_wrap(~ variable, scales = "free", ncol = 4) +
  labs(
    title = "Distribution of Numeric Variables",
    x = "Value",
    y = "Count"
  ) +
  theme(
    panel.border = element_rect(
      colour = "black",
      fill = NA,
      linewidth = 1
    )
  )

#-------------------------------------------------------------
# Save Plot : Distribution of Numeric Variables
#-------------------------------------------------------------
ggsave(
  filename = paste0("outputs/plots/histogram_distribution.png"),
  width = 8,
  height = 8
)

# box Plot outlier detector
ggplot(numeric_long, aes(x = variable, y = value)) +
  geom_boxplot( fill = "steelblue", alpha = 0.7) +
  facet_wrap(~ variable, scales = "free", ncol = 4) +
  labs(
    title = "Distribution of Numeric Variables",
    x = NULL,
    y = "Value"
  ) +
  theme(
    panel.border = element_rect(
      colour = "black",
      fill = NA,
      linewidth = 1
    )
  )







#-------------------------------------------------------------
# Save Plot : Outlier Detection Across Numeric Metrics
#-------------------------------------------------------------
ggsave(
  filename = paste0("outputs/plots/boxplot_outlier_detector.png"),
  width = 8,
  height = 8
)

#Summary Statistics Insights:
  
  # - Negative gross profit cases indicating loss-making transactions
  # - Zero sales quantities for some purchased products
  # - High variance in freight costs suggesting logistics inefficiencies
  


#----------------------------------------------
# Remove outliers : 
#----------------------------------------------
  
df <- vendor_sales %>% 
  filter(
    GrossProfit > 0,
    ProfitMargin > 0,
    TotalSalesQuantity > 0
  )

glimpse(df)
#----------------------------------------------
# Distribution Plots : after filtering outliers
#----------------------------------------------

numeric_cols_2 <- df %>%
  select(where(is.numeric))

numeric_long_2 <- numeric_cols_2 %>%
  pivot_longer(
    cols = everything(),
    names_to = "variable",
    values_to = "value"
  )
class(numeric_cols_2)


# Histogram
ggplot(numeric_long_2, aes(x = value)) +
  geom_histogram(bins = 30, fill = "steelblue", alpha = 0.7) +
  facet_wrap(~ variable, scales = "free", ncol = 4) +
  labs(
    title = "Distribution of Numeric Variables",
    x = "Value",
    y = "Count"
  ) +
  theme(
    panel.border = element_rect(
      colour = "black",
      fill = NA,
      linewidth = 1
    )
  )

#----------------------------------------------
#  Plots : Top 10 Vendor and Products
#----------------------------------------------


p1 <- df %>%
  count(VendorName, sort = TRUE) %>%
  slice_head(n = 10) %>%
  ggplot(aes(x = n, y = reorder(VendorName, n))) +
  geom_col(fill = "steelblue") +
  labs(title = "Count plot of VendorName", x = "Count", y = NULL) +
  theme_minimal()

p2 <- df %>%
  count(Description, sort = TRUE) %>%
  slice_head(n = 10) %>%
  ggplot(aes(x = n, y = reorder(Description, n))) +
  geom_col(fill = "steelblue") +
  labs(title = "Count plot of Description", x = "Count", y = NULL) +
  theme_minimal()

p1 | p2


#----------------------------------------------
#  Plots : Correlation Heatmap
#----------------------------------------------



  
# Step 1: Select only numeric columns
 

numeric_cols_2 <- df %>%
  select(where(is.numeric))
  
# Step 2: Compute correlation matrix
cor_matrix <- cor(
  numeric_cols_2,
  use = "complete.obs",
  method = "pearson"
)

# Step 3: Convert matrix to long format (for ggplot)


cor_long <- as.data.frame(cor_matrix) %>%
  mutate(Var1 = rownames(.)) %>%
  pivot_longer(
    cols = -Var1,
    names_to = "Var2",
    values_to = "Correlation"
  )

# Step 4: Plot correlation heatmap


ggplot(cor_long, aes(x = Var1, y = Var2, fill = Correlation)) +
  geom_tile(color = "white") +
  scale_fill_gradient2(
    low = "red",
    mid = "white",
    high = "steelblue",
    midpoint = 0
  ) +
  labs(
    title = "Correlation Heatmap (Numeric Variables)",
    x = NULL,
    y = NULL
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),
    panel.grid = element_blank()
  )
  
  
# heatmap 2 final

ggplot(cor_long, aes(x = Var1, y = Var2, fill = Correlation)) +
  geom_tile(color = "white", linewidth = 0.5) +
  geom_text(
    aes(label = sprintf("%.2f", Correlation)),
    size = 3
  ) +
  scale_fill_gradient2(
    low = "#4575b4",   # blue  
    mid = "white",
    high = "#d73027", # red  
    midpoint = 0,
    limits = c(-1, 1),
    name = "Correlation"
  ) +
  labs(
    title = "Correlation Heatmap",
    x = NULL,
    y = NULL
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),
    panel.grid = element_blank()
  )

#ggsave(
 # "outputs/plots/correlation_heatmap.png",
  #width = 12,
  #height = 8,
  #dpi = 300
#)



  
#  Refined Correlation Insights

#- GrossProfit shows a very strong positive correlation with TotalSalesDollars (0.98) and TotalSalesQuantity (0.70), indicating that profitability is primarily driven by sales volume rather than pricing or margin expansion.

#- TotalPurchaseQuantity and TotalSalesQuantity are almost perfectly correlated (0.999), reflecting strong alignment between procurement and sales demand, with minimal inventory mismatch.

#- PurchasePrice exhibits negligible correlation with both TotalSalesDollars (-0.01) and GrossProfit (-0.02), suggesting that variations in unit cost do not materially influence overall revenue or profit outcomes.

#- ProfitMargin has a modest negative correlation with TotalSalesPrice (-0.18), indicating potential pricing pressure or increased costs associated with higher-priced sales.


#-------------------------------------
# Create final Tableau dataset
#-------------------------------------
vendor_Performance_clean_data <- df

# Export final dataset for Tableau
write.csv(
  vendor_Performance_clean_data,
  "data/processed/vendor_Performance_clean_data.csv",
  row.names = FALSE
)

colSums(is.na(vendor_Performance_clean_data))



# Final analysis-ready dataset for Tableau
#----------------------------------------------------

sum(df$TotalFreightCost, na.rm = TRUE)
sum(vendor_Performance_clean_data$TotalFreightCost, na.rm = TRUE)


sum(df$TotalSalesDollars, na.rm = TRUE)
sum(vendor_Performance_clean_data$TotalSalesDollars, na.rm = TRUE)

summary(df$TotalFreightCost)
max(df$TotalFreightCost, na.rm = TRUE)
#----------------------------------------------------
# Q1 - Identify Brand Performance
#----------------------------------------------------


brand_performance <- df %>%
  group_by(Description) %>% 
  summarize(TotalSalesDollars = sum(TotalSalesDollars),
            ProfitMargin = mean(ProfitMargin),
            .group = "drop")
 

low_sales_threshold <- quantile (
  brand_performance$TotalSalesDollars,
  prob = 0.15,
  na.rm = TRUE
)

high_margin_threshold <- quantile(
  brand_performance$ProfitMargin ,
  prob = 0.85,
  na.rm = TRUE
)
#------------------------------------------------------------------
# Question 1 : filter Brands with low sales but high profit margin
#------------------------------------------------------------------

target_brands <- brand_performance %>% 
  filter(
    TotalSalesDollars <= low_sales_threshold,
    ProfitMargin >= high_margin_threshold 
  ) %>%
  arrange(TotalSalesDollars)

print("Brands with Low Sales but High Profit Margins:")
target_brands

# Scatter plot to identify the brand 
brand_performance <- brand_performance %>% 
  filter(TotalSalesDollars < 10000)
  
#-----------------------------------------------------------------

ggplot() +
  # All brands
  geom_point(
    data = brand_performance,
    aes(
      x = TotalSalesDollars,
      y = ProfitMargin,
      color = "All Brands"
    ),
    alpha = 0.2
  ) +
  
  # Target brands
  geom_point(
    data = target_brands,
    aes(
      x = TotalSalesDollars,
      y = ProfitMargin,
      color = "Target Brands"
    ),
    size = 2
  ) +
  
  # Threshold lines
  geom_hline(
    yintercept = high_margin_threshold,
    linetype = "dashed",
    color = "black"
  ) +
  geom_vline(
    xintercept = low_sales_threshold,
    linetype = "dashed",
    color = "black"
  ) +
  
  # Axis formatting
    scale_y_continuous(
      labels = function(x) paste0(x, "%"),
      limits = c(0, 100)
    ) +
  #scale_y_continuous(
   # labels = percent_format(accuracy = 1)
 # ) +
  
  # Manual legend colors
  scale_color_manual(
    values = c(
      "All Brands" = "blue",
      "Target Brands" = "red",
      "High Margin Threshold" = "black",
      "Low Sales Threshold" = "black"
    )
  ) +
  
  # Labels
  labs(
    title = "Brands for Promotional or Pricing Adjustments",
    x = "Total Sales ($)",
    y = "Profit Margin (%)",
    color = "Legend"
  ) +
  
  theme_minimal()

#-------------------------
# SAVE Plot
#-------------------------

ggsave(
 "outputs/plots/Brands for Promotional or Pricing Adjustments.png",
width = 12,
height = 8,
dpi = 300
)


#------------------------------------------------------------------------------
# Q2 -  Which Vendors and Brands demonstrate the highest sales performance ?
#------------------------------------------------------------------------------


# Top_vendor 

top_vendor <- df %>%
  group_by(VendorName) %>% 
  summarise(top_vendor = sum(TotalSalesDollars, na.rm = TRUE)) %>% 
  arrange(-top_vendor)

# Top_brand

Top_brand <- df %>%
  group_by(Description) %>% 
  summarise(Top_brand = sum(TotalSalesDollars, na.rm = TRUE)) %>% 
  arrange(-Top_brand)


# Top 10 vendors sale in Mellon

top_vendor <- df %>% 
  group_by(VendorName) %>% 
  summarise(total_sales = sum(TotalSalesDollars, na.rm = TRUE),
            .groups = "drop") %>% 
  arrange(-total_sales) %>% 
  slice_head(n = 10) %>% 
  mutate(
    top_vendor = label_number(
      scale_cut = cut_si(unit = ""),
      accuracy = 0.1
          )(total_sales)
        )

# Top 10 Brand sale in Mellon/Thousand

top_brand <- df %>% 
  group_by(Description) %>% 
  summarise(total_sales = sum(TotalSalesDollars, na.rm = TRUE),
            .groups = "drop") %>% 
  arrange(-total_sales) %>% 
  slice_head(n = 10) %>% 
  mutate(
    top_brand = label_number(
      scale_cut = cut_si(unit =""),
      accuracy = 0.1
    )(total_sales)
  )


# Bar Plot : top 10 Vendor 


top_10_v_P1 <- ggplot(top_vendor, aes(
  x = total_sales,
  y = reorder(VendorName, total_sales),
  fill = total_sales
)) +
  geom_col(width = 0.7) +
  #coord_flip()  +
  
  # Gradient: light (low) → dark (high)
  scale_fill_gradient(
    low = "#dbe9f6",
    high = "#08306b"
  ) +
# Value labels
geom_text(
  aes(label = label_number(scale_cut = cut_si(unit = ""),
                           accuracy = 0.01)(total_sales)),
  hjust = -0.05,
  size = 3.5
) +
  labs(
    title = "Top 10 Vendors by Sales",
    x = "Total Sales ($ Millions)",
    y = "Vendor Name"
  ) +
  scale_x_continuous(
    labels = label_number(scale_cut = cut_si(unit = ""))
  ) +
  
  theme_minimal()






# Bar Plot : top 10 Brand

top_10_B_P1 <- ggplot(top_brand, aes(
  x = total_sales,
  y = reorder(Description, total_sales),
  fill = total_sales
)) +
  geom_col(width = 0.7) +
  #coord_flip()  +
  
  # Gradient: light (low) → dark (high)
  scale_fill_gradient(
    low = "#FFC2C2",        #d8ba9d
    high = "#C10A0A"   #720404
  ) +
  # Value labels
  geom_text(
    aes(label = label_number(scale_cut = cut_si(unit = ""),
                             accuracy = 0.01)(total_sales)),
    hjust = -0.05,
    size = 3.5
  ) +
  labs(
    title = "Top 10 Brands by Sales",
    x = "Total Sales ($ Millions)",
    y = "Brand Name "
  ) +
  scale_x_continuous(
    labels = label_number(scale_cut = cut_si(unit = ""))
  ) +
  theme_minimal()

top_10_v_P1 | top_10_B_P1

ggsave(
  "outputs/plots/top_10_vendors_and_Brands_by_Sales.png",
  width = 12,
  height = 8,
  dpi = 300
)



# Start Question number 3 here


#------------------------------------------------------------------------------
# Q3 -  Which Vendors contribute the most to total purchase dollars ?
#------------------------------------------------------------------------------

 vendor_performance <- df %>% 
      group_by(VendorName) %>% 
      summarise(
        TotalPurchaseDollars = sum(TotalPurchaseDollars , na.rm = TRUE),
        GrossProfit = sum(GrossProfit , na.rm = TRUE),
        TotalSalesDollars = sum(TotalSalesDollars , na.rm = TRUE),
        .groups = "drop"
        ) 
  
vendor_performance <- vendor_performance %>% 
  mutate(
    purchase_contribution_percent = TotalPurchaseDollars / sum(vendor_performance$TotalPurchaseDollars) * 100
    ,
    
    TotalPurchaseDollarsfmt = label_number(
      scale_cut = cut_si(unit=""),
      accuracy = 0.1
    )
    (TotalPurchaseDollars),
    GrossProfitfmt = label_number(
      scale_cut = cut_si(unit=""),
      accuracy = 0.1
    )
    (GrossProfit),
    TotalSalesDollarsfmt = label_number(
      scale_cut = cut_si(unit=""),
      accuracy = 0.1
    )(TotalSalesDollars)
    
  ) %>% 
  arrange(-purchase_contribution_percent) %>% 
  mutate(
    cumulative_contribution = cumsum(purchase_contribution_percent)
  )


top_vendors_df <- vendor_performance%>%
  select(VendorName,purchase_contribution_percent,
         cumulative_contribution ) %>% 
  slice_head(n = 10)


ggplot(top_vendors_df, aes(x = reorder(VendorName, -purchase_contribution_percent))) +
  
  # Bars: Purchase Contribution %
  geom_col(aes(y = purchase_contribution_percent), fill = "#4C72B0") +
  
  # Line: Cumulative %
  geom_line(
    aes(y = cumulative_contribution * max(purchase_contribution_percent) / 100, group = 1),
    color = "red",
    size = 1.2
  ) +
  geom_point(
    aes(y = cumulative_contribution * max(purchase_contribution_percent) / 100),
    color = "red",
    size = 3
  ) +
  
  # Dual axis (correct transformation)
  scale_y_continuous(
    name = "Purchase Contribution (%)",
    sec.axis = sec_axis(
      ~ . * 100 / max(top_vendors_df$purchase_contribution_percent),
      name = "Cumulative Contribution (%)",
      labels = percent_format(scale = 1)
    )
  ) +
  
  labs(
    title = "Pareto Chart: Vendor Contribution to Total Purchase",
    x = "Vendor"
  ) +
  
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 90, hjust = 1)
  )


ggsave(
  "outputs/plots/Vendor Contribution to Total Purchase.png",
  width = 12,
  height = 8,
  dpi = 300
)



top_vendors_df %>% 
  summarise(t = sum(purchase_contribution_percent))
#--------------------------------------------------------------------------


#-----------------------------------------------------
# Question - 4 Which vendors are actually profitable?
#-----------------------------------------------------
# Vendor Profitability (Gross Margin Focus)

vendor_profit <- vendor_performance %>%
  group_by(VendorName) %>%
  summarise(
    Sales = sum(TotalSalesDollars, na.rm = TRUE),
    GrossProfit = sum(GrossProfit, na.rm = TRUE),
    GrossMarginPct = GrossProfit / Sales * 100,
    .groups = "drop"
  ) %>%
  filter(Sales > 0) %>%
  arrange(desc(GrossMarginPct)) %>%
  slice_head(n = 10)

# Plot: Vendor Profitability (Gross Margin Focus)

ggplot(vendor_profit,
       aes(x = reorder( VendorName, GrossMarginPct),
           y = GrossMarginPct
           ))+
  geom_col(fill = "#1D91C0" ) +  
  geom_text(
    aes(label = paste0(round(GrossMarginPct, 1), "%")),
    hjust = -0.1,
    size = 3
  ) +
  scale_y_continuous(
    labels =  label_percent(scale = 1)) +
    
  coord_flip() +
  labs(
    title = "Top Vendors by Gross Margin (%)",
    x = "Vendor",
    y = "Gross Margin (%)"
  ) +
  theme_minimal(base_size = 12)

ggsave( 
  "outputs/plots/Top Vendors by Gross Margin .png",
  width = 12,
  height = 8,
  dpi = 300
)

#---------------------------------------------------
# Purchase vs Profit (Decision-Making Chart)
#---------------------------------------------------

ggplot(vendor_profit,
       aes(x = Sales,
           y = GrossMarginPct,
           label = VendorName)) +
  geom_point(size = 3, color = "#2C7FB8") +
  geom_text(check_overlap = TRUE, hjust = 0, nudge_x = 0.02) +
  #cale_x_continuous(labels = label_number(scale_cut = cut_si())) +
 
  scale_y_continuous(
    labels = label_percent(scale = 1)
  ) +
  labs(
    title = "Vendor Performance: Sales vs Gross Margin",
    x = "Total Sales",
    y = "Gross Margin (%)"
  ) +
  theme_minimal(base_size = 12)

  scale_x_continuous(
    labels = label_number(scale = 1e-6, suffix = "M")
  ) 

    
    ggsave(
      "outputs/plots/Vendor Performance- Sales vs Gross Margin.png",
      width = 12,
      height = 8,
      dpi = 300
    )

    
    
  
    
    
    
#------------------------------------------------------------------------------
# Q4 -  How much if total procurement is dependent on the top vendor ?
#------------------------------------------------------------------------------
    
    top_vendors_df_cont <- vendor_performance %>%
      select(VendorName,purchase_contribution_percent,
             cumulative_contribution ) %>% 
      slice_head(n = 10) %>% 
      arrange(-purchase_contribution_percent)
    
    
    total_top10_contribution <- sum(top_vendors_df_cont$purchase_contribution_percent)
    
    remaining_contribution <- 100 - total_top10_contribution
    
    donut_data1 <- data.frame(
    category = c(top_vendors_df_cont$VendorName, "Other Vendors"),
      percentage = c(top_vendors_df_cont$purchase_contribution_percent, remaining_contribution)
      ) %>%
      mutate(
      # Calculate ymax and ymin for pie segments
      ymax = cumsum(percentage),
      ymin = c(0, head(ymax, -1)),
      # Calculate label position (midpoint of each segment)
      label_position = (ymin + ymax) / 2
      )
    
    
    
    ggplot(donut_data1, aes(ymax = ymax, ymin = ymin, xmax = 4, xmin = 3, fill = category)) +
      geom_rect() +
      geom_text(x = 3.5, aes(y = label_position, label = paste0(round(percentage, 2), "%")), size = 4) +
      #scale_fill_manual(values = c("Top 10 Vendors" = "steelblue", "Other Vendors" = "lightgray")) +
      coord_polar(theta = "y") + # Makes it a pie chart
      xlim(c(2, 4)) + # Creates the donut hole
      labs(
        title = "Total Procurement Dependency: Top 10 vs. Other Vendors",
        fill = "Vendor Group"
      ) +
      theme_void() + # Remove background, axis lines, etc.
      theme(
        plot.title = element_text(hjust = 0.5, size = 16, face = "bold"),
        legend.position = "bottom"
      )
    
    #---------------------------------------
     # Final Attempt of Donut chart
    #--------------------------------------
  
    
    
    donut_data <- data.frame(
      VendorName = c(top_vendors_df_cont$VendorName, "Other Vendors"),
      percentage = c(top_vendors_df_cont$purchase_contribution_percent, remaining_contribution)
    ) %>%
      arrange(desc(percentage)) %>% 
    mutate(
     # pct =  percentage / sum(percentage),
      pct_label = paste0(round(percentage, 1), "%"),
      ymax = cumsum(percentage),
      ymin = lag(ymax, default = 0),
      ymid = (ymax + ymin) / 2
    )
    
  
    #------------ PLOT ---------
    
    ggplot(donut_data) +
      
      # Donut slices
      geom_rect(aes(
        ymin = ymin,
        ymax = ymax,
        xmin = 3.2,
        xmax = 4,
        fill = VendorName
      ), color = "white") +
      
      # Percentage labels inside slices
      geom_text(aes(
        x = 3.5,
        y = ymid,
        label = pct_label
      ), size = 3) +
      
      # Vendor labels outside (radial)
      geom_text_repel(aes(
        x = 4.2,
        y = ymid,
        label = VendorName
      ),
      size = 3,
      direction = "y",
      nudge_x = 0.8,
      segment.size = 0.3,
      show.legend = FALSE,
      max.overlaps = Inf
      ) +
      
      # Polar transform
      coord_polar(theta = "y", direction = -1) +
      xlim(2, 5.2) +
      
      # Center annotation
      annotate(
        "text",
        x = 2,
        y = 0,
        label = paste0("Top 10 Total:\n", round(total_top10_contribution, 2), "%"),
        size = 4.4,
        fontface = "bold"
      ) +
      
      theme_void() +
      theme(
        legend.position = "none",
        plot.title = element_text(hjust = 0.5, size = 16, face = "bold")
      ) +
      labs(title = "Top 10 Vendor's Purchase Contribution (%)")
    
    #-------------Save Plot ---------
    ggsave(
      "outputs/plots/Vendor Contribution Donut.png",
      width = 18,
      height = 8,
      dpi = 300
    )
    
    
    #------------------------------------------------------------
    # Question 5 : Does Purchasing in bulk reduce the unit price,
    # and what is the optimal purchase volume for cost saving?
    #-----------------------------------------------------------
    
    UnitPurchasePrice = df$TotalPurchaseDollars / df$TotalPurchaseQuantity
    
    
    df2 <- df %>% 
      mutate(UnitPurchasePrice = TotalPurchaseDollars / TotalPurchaseQuantity,
             OrderSize = ntile(TotalPurchaseQuantity, 3),
             OrderSize = recode(OrderSize,
                                `1` = "Small",
                                `2` = "Medium",
                                `3` = "Large"))
    
    df2 %>% 
      group_by(OrderSize) %>% 
      summarise(mean(UnitPurchasePrice))
    
    # Ensure proper ordering
    df2$OrderSize <- factor(df2$OrderSize,
                           levels = c("Small", "Medium", "Large"),
                           ordered = TRUE)
    
    
    # box Plot 
    
      ggplot(df2, aes(x = OrderSize, y = UnitPurchasePrice, fill = OrderSize)) +
      geom_boxplot(width = 0.6, outlier.alpha = 0.4) +
      scale_fill_brewer(palette = "Set2") +
      scale_y_continuous(
        breaks = seq(0, max(df2$UnitPurchasePrice, na.rm = TRUE), by = 500)
      )+
      labs(
        title = "Impact of Bulk Purchasing on Unit Price",
        subtitle = "Unit price decreases as order size increases",
        x = "Order Size",
        y = "Average Unit Purchase Price"
      ) +
      theme_minimal(base_size = 14) +
      theme(
        legend.position = "none",
        plot.title = element_text(face = "bold")
      )
    
      # Save Plot
      
      ggsave(
        "outputs/plots/Impact_of_Bulk_Purchasing_on_Unit_Price.png",
        width = 12,
        height = 8,
        dpi = 300
      )
      
      
    
    # INSIGHITS 
    #. Vendors buying in bulk (Large Order Size) get the lowest unit price ($10.78 per unit), meaning higher margins if they can manage inventory efficiently.
    #· The price difference between Small and Large orders is substantial (~72% reduction in unit cost)
    #· This suggests that bulk pricing strategies successfully encourage vendors to purchase in larger volumes, leading to higher overall sales despite lower per-unit
    #  revenue.
    
   # Executive Insights (Refine Insights)
    
   # 1. The average unit price for Large orders is $10.78 per unit, representing approximately a 72% reduction compared to Small orders.
    
   # 2. Unit prices decline consistently as order size increases, confirming the presence of a structured volume discount strategy.
    
   # 3. Small orders exhibit significant price variability and extreme outliers, indicating inconsistent or specialized purchasing behavior.
    
   # 4. Large orders demonstrate tighter price dispersion, suggesting standardized contract pricing for bulk procurement.
    
   # 5. While per-unit revenue declines with larger volumes, the pricing structure incentivizes higher order quantities, which may improve total order value and strengthen vendor consolidation.
    
    
    
    #------------------------------------------------------------
    # Question 6 : Which vendor have the low inventory turnover,
    # indicating excess stock and slow-moving products?
    #-----------------------------------------------------------
    
    # Top 10 Low inventory Turnover (List)
    
    df2 %>% 
      group_by(VendorName) %>% 
      filter(
        stockTurnover < 1
      ) %>% 
      summarise(stockTurnover = mean(stockTurnover)) %>% 
      arrange(stockTurnover) %>%
      slice_head(n = 10)
    
    #------------------------------------------------------------
    # Question 7 : How much capital is locked in unsold inventory per vendor,
    # and which vendors contribute the most to it? Sales vs Profit Relationship
    #-----------------------------------------------------------
    
    
    UnsoldInventoryValue = (df2$TotalPurchaseQuantity - df2$TotalSalesQuantity) * df2$PurchasePrice
    
    sum(UnsoldInventoryValue)
    # total capital =  2709964 ( $2.71 M )
    
    df2 <- df2 %>% 
      mutate(
        UnsoldInventoryValue = (TotalPurchaseQuantity - TotalSalesQuantity) * PurchasePrice
        )
    
    df2 %>% 
      group_by(
        VendorName
      ) %>% 
      summarise(UnsoldInventoryValue  = sum(UnsoldInventoryValue )) %>% 
      arrange(desc(UnsoldInventoryValue) ) %>% 
      slice_head(n = 10)
    
    
    
    vendor_inventory <- df2 %>%
      group_by(VendorName) %>%
      summarise(
        TotalLockedCapital = sum(UnsoldInventoryValue, na.rm = TRUE),
        TotalPurchase = sum(TotalPurchaseDollars, na.rm = TRUE),
        TotalSales = sum(TotalSalesDollars, na.rm = TRUE),
        GrossProfit = sum(GrossProfit, na.rm = TRUE)
      ) %>%
      arrange(desc(TotalLockedCapital))
    
    vendor_inventory
    
    
    top10_locked <- vendor_inventory %>%
      slice_max(TotalLockedCapital, n = 10)
    
    top10_locked
    
    ggplot(top10_locked,
           aes(x = reorder(VendorName, TotalLockedCapital),
               y = TotalLockedCapital)) +
      
      geom_col(fill = "#D55E00") +
      
      coord_flip() +
      
      geom_text(
        aes(label = scales::dollar(TotalLockedCapital)),
        hjust = -0.1,
        size = 3.5
      ) +
      
      scale_y_continuous(
        labels = scales::label_dollar(scale_cut = scales::cut_short_scale())
      ) +
      
      labs(
        title = "Top 10 Vendors by Capital Locked in Unsold Inventory",
        x = "Vendor",
        y = "Locked Capital ($)"
      ) +
      
      theme_minimal(base_size = 13)
    
    #--- Sales vs Profit Relationship ---
    
    ggplot(df2,
           aes(x = TotalSalesDollars,
               y = GrossProfit)) +
      
      geom_point(
        alpha = 0.6,
        color = "#2E86AB"
      ) +
      
      geom_smooth(
        method = "lm",
        color = "red",
        se = TRUE
      ) +
      
      scale_x_continuous(
        labels = scales::label_dollar(scale_cut = scales::cut_short_scale())
      ) +
      
      scale_y_continuous(
        labels = scales::label_dollar(scale_cut = scales::cut_short_scale())
      ) +
      
      labs(
        title = "Sales vs Gross Profit Relationship",
        x = "Total Sales ($)",
        y = "Gross Profit ($)"
      ) +
      
      theme_minimal(base_size = 13)
    
    
    # INSIGHTS
   # "Total Sales explains approximately 96% of the variation in Gross Profit, 
    #indicating an exceptionally strong linear relationship."
    
    #-------------------------END PROJECT---------------------------------#
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    