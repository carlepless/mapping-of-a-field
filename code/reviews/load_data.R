# Loading data from WoS plaintext files for reviews
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
wos_list <- list.files(here("data", "raw_data", "reviews"), pattern = "*.txt")

# Load files from list into bibliometrix
wos <- convert2df(
    here("data", "raw_data", "reviews", wos_list),
    dbsource = "wos",
    format = "plaintext"
)

# Number of documents
nrow(wos)

    ## 34,730

# Remove documents with exact same title
wos_deduplicated <- deduplicate(
    wos,
    match_by = "TI",
    method = "exact"
)

# Number of removed documents
nrow(wos) - nrow(wos_deduplicated)

    ## 57

# Remove documents with missing authors, title, or year
biblio <- wos_deduplicated %>%
    filter(!apply(is.na(select(., AU, TI, PY)), 1, any))

# Number of removed documents
nrow(wos_deduplicated) - nrow(biblio)

    ## 0

# Number of final documents
nrow(biblio)

    ## 34,673

# Save to RDS file
saveRDS(biblio, file = here("data", "wrangled_data", "reviews", "biblio.rds"))

# Export to CSV file
write_csv(biblio, here("data", "wrangled_data", "reviews", "biblio.csv"))