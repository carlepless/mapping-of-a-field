# Loading data from WoS plaintext files for non-reviews
# Date: 19-08-2024
# Author: Carl-Emil Pless

# Clear workspace
rm(list = ls())

# Load necessary libraries
library(here)
library(bibliometrix)
library(synthesisr)
library(tidyverse)

# Generate list of files
wos_list <- list.files(here("data", "raw_data", "non_reviews"), pattern = "*.txt")

# Load files from list into bibliometrix
wos <- convert2df(
    here("data", "raw_data", "non_reviews", wos_list),
    dbsource = "wos",
    format = "plaintext"
)

# Number of documents
nrow(wos)

    ## 236,771

# Remove documents with exact same title
wos_deduplicated <- deduplicate(
    wos,
    match_by = "TI",
    method = "exact"
)

# Number of removed documents
nrow(wos) - nrow(wos_deduplicated)

    ## 210

# Remove documents with missing authors, title, or year
biblio <- wos_deduplicated %>%
    filter(!apply(is.na(select(., AU, TI, PY)), 1, any))
 
# Number of removed documents
nrow(wos_deduplicated) - nrow(biblio)

    ## 0

# Number of final documents
nrow(biblio)

    ## 236,561

# Save to RDS file
saveRDS(biblio, file = here("data", "wrangled_data", "non_reviews", "biblio.rds"))

# Export to CSV file
write_csv(biblio, here("data", "wrangled_data", "non_reviews", "biblio.csv"))