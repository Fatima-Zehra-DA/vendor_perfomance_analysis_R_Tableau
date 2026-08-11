
source("config/paths.R")
source("scripts/01_load_data.R")


# Load cleaned data
purchase_prices <- read.csv(paste0(processed_data_path, "purchase_prices_clean.csv"))
purchases       <- read_csv(paste0(processed_data_path, "purchases_clean.csv"))
sales           <- read_csv(paste0(processed_data_path, "sales_clean.csv"))
vendor_invoice  <- read_csv(paste0(processed_data_path, "vendor_invoice_clean.csv"))


# -----------------------------
# Freight Summary
# -----------------------------
#VendorInvoice:
#Quantity as TotalPurchaseQuantity, Dollars as TotalPurchaseDollars, 
#Freight as TotalFrieghtCost


freight_summary <- vendor_invoice %>%
  group_by(VendorNumber) %>%
  summarise(
    TotalFreightCost = sum(Freight, na.rm = TRUE),
    .groups = "drop"
  )

#just for checking freight_summary_copy is exist next day or not

freight_summary_copy <- vendor_invoice %>%
  group_by(VendorNumber) %>%
  summarise(
    TotalFreightCost = sum(Freight, na.rm = TRUE),
    #.groups = "drop"
  )




# -----------------------------
# Purchases Summary
# -----------------------------
  
purchase_summary <- purchases %>%
  filter(PurchasePrice > 0, Quantity > 0, Dollars > 0) %>%
  group_by(VendorNumber, VendorName, Brand, Description) %>%
  summarise(
    TotalPurchaseQuantity = sum(Quantity, na.rm = TRUE),
    TotalPurchaseDollars = sum(Dollars, na.rm = TRUE),
    PurchasePrice = first(PurchasePrice),
    .groups = "drop"
  )

#------
# -----------------------------
# Purchases Price Summary
# -----------------------------
  
  #Purchase_Price
  #VendorNumber,
  #Brand, 
  #Price as ActualPrice,
  #PurchasePrice
  
  Purchase_price_summary <- purchase_prices %>%
    filter(Price > 0) %>%
    select(VendorNumber, Brand, Volume, ActualPrice = Price) %>%
    distinct()
  
  
  
  
  # -----------------------------
  # Sales Summary
  # -----------------------------
  #sales:
  #SalesQuantity as TotalSalesQuantity,
  #SalesDollars as TotalSalesDollars,
  #SalesPrice as TotalSalesPrice,
  #ExciseTax as TotalExciseTax
  
  sales_summary <- sales %>%
    group_by(VendorNo, Brand) %>%
    summarise(
      TotalSalesQuantity = sum(SalesQuantity, na.rm = TRUE),
      TotalSalesDollars = sum(SalesDollars, na.rm = TRUE),
      TotalSalesPrice = sum(SalesPrice, na.rm = TRUE),
      TotalExciseTax = sum(ExciseTax, na.rm = TRUE),
      .groups = "drop"
    )
  
 
  
  # -----------------------------------
  # Combining all summaries with Joins
  # -----------------------------------
  
  vendor_sales_summary <- purchase_summary %>%
    
    left_join(
      sales_summary,
      by = c("VendorNumber" = "VendorNo", "Brand" = "Brand")
    ) %>%
    
    left_join(
      freight_summary,
      by = "VendorNumber"
    ) %>%
    
    left_join(
      Purchase_price_summary,
      by = c("VendorNumber", "Brand")
    )
  
  View(vendor_sales_summary)
  
  
  
  # -------------------------------
  # 2. Derived Metrics KPIs
  # -------------------------------
  
  
  vendor_sales_summary <- vendor_sales_summary %>%
    mutate(
      
      GrossProfit = TotalSalesDollars - # 1. -- done  GrossProfit
        TotalPurchaseDollars,
      
      ProfitMargin = if_else(
        TotalSalesDollars > 0,
        GrossProfit / TotalSalesDollars * 100, # 2. -- done  ProfitMargin in percentage
        NA_real_
      ),
      stockTurnover = if_else(
        TotalPurchaseQuantity > 0,
        TotalSalesQuantity / TotalPurchaseQuantity, # 3. -- done  stockTurnover
        NA_real_
      ),
      
      salestoPurchaseRatio = if_else(
        TotalPurchaseDollars  > 0,
        TotalSalesDollars / TotalPurchaseDollars, # 3. -- done  salestoPurchaseRatio
        NA_real_
      )
    )
  
  #-------------
  #  Notes:
  #-------------
  
  # 1. GrossProfit = TotalSalesDollars - TotalPurchaseDollars # -- done
  
  # 2. ProfitMargin = GrossProfit / TotalSalesDollars * 100  # -- done
  
  # 3. stockTurnover = TotalSalesQuantity / TotalPurchaseQuantity # -- done
  
  # 4. salestoPurchaseRatio = TotalSalesDollars / TotalPurchaseDollars # --  done
  
 
  

  # -----------------------------
  # Saving and Utilizing the Final Clean Table 
  # -----------------------------
  
  
  write_csv(
    vendor_sales_summary,
    "data/processed/vendor_sales_summary.csv"
  )
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  


