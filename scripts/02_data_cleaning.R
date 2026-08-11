
library(tidyverse)
library(here)
source("config/paths.R")
source("scripts/01_load_data.R")





# -----------------------------
# Clean Purchases
# -----------------------------

# total rows ------------------- 2372474
nrow(purchases) #--------------- 2372474
nrow(distinct(purchases)) # --- -2372474


# Data quality checks
sum(is.na(purchases$VendorNumber)) #---- 0


purchases %>%
  count(across(everything())) %>%
  filter(n > 1)

# Cleaning
purchases_clean <- purchases %>%
  filter(Quantity > 0,
         PurchasePrice > 0,
         !is.na(VendorNumber)
         ) %>%
  distinct()

  

# -----------------------------
# Clean Purchase Prices
# -----------------------------
nrow(purchase_prices) #--------------- 12261
nrow(distinct(purchase_prices)) #----- 12261

sum(is.na(purchase_prices$VendorNumber)) #--- 0

purchase_prices_clean <- purchase_prices %>% # raws --- 12259
  filter(Price > 0) %>% 
  distinct()




# -----------------------------
# Clean Sales
# -----------------------------
glimpse(sales) #--------------- 12825363
nrow(sales)   #---------------- 12825363
nrow(distinct(sales)) #-------- 12825363

sum(is.na(sales$VendorNo)) #--- 0

sales_clean <- sales %>%
  filter(SalesQuantity > 0, SalesPrice > 0) %>%
  distinct()


# -----------------------------
# Clean Vendor Invoice
# -----------------------------
 glimpse(vendor_invoice)
 nrow(vendor_invoice) #----------- 5543
 nrow(distinct(vendor_invoice)) #- 5543
 
 sum(is.na(vendor_invoice$VendorNumber)) #---- 0
 
 
vendor_invoice_clean <- vendor_invoice %>% 
  filter(!is.na(VendorName),
         Dollars > 0) %>%   #------ 5543
  distinct()


# -----------------------------
# Clean begin Inventory  end
# -----------------------------
glimpse(begin_inventory) #--------------- 206529
nrow(begin_inventory)   #---------------- 206529
nrow(distinct(begin_inventory)) #-------- 206529


begin_inventory %>% #-------- 0
  count(InventoryId) %>%
  filter(n > 1) %>% 
  distinct()

begin_inventory_clean<-begin_inventory %>% #-------- 206527
  filter( Price > 0) %>% 
  distinct()


# -----------------------------
# Clean end Inventory  
# -----------------------------



glimpse(end_inventory) #---------------  224489
nrow(end_inventory)   #----------------  224489
nrow(distinct(end_inventory)) #--------  224489

  
  end_inventory %>%
    count(InventoryId) %>%  #---- 0
    filter(n > 1) %>%
    
 end_inventory_clean <- end_inventory %>%
    filter(Price > 0) %>% 
    distinct()


# -----------------------------
# Save Cleaned Data
# -----------------------------

  
  for (tbl in 
       c("purchases_clean","sales_clean","purchase_prices_clean",
         "vendor_invoice_clean","begin_inventory_clean","end_inventory_clean")){
    write_csv(
      get(tbl), 
      here("data","processed", paste0(tbl,".csv"))
    )
  }
  
  
  
  
  
  
  