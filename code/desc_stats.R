# Generate table of descriptive statistics for reviews and SLRs
# Date: 28-08-2024
# Author: Carl-Emil Pless

# Clear workspace
rm(list = ls())

# Load necessary libraries
library(here)
library(tidyverse)
library(bibliometrix)

# Load data
slrs <- readRDS(here("data", "wrangled_data", "slrs", "biblio.rds"))
reviews <- readRDS(here("data", "wrangled_data", "reviews", "biblio.rds"))
non_reviews <- readRDS(here("data", "wrangled_data", "non_reviews", "biblio.rds"))

# Run biblioAnalysis on each type
slrs <- biblioAnalysis(slrs, sep = ";")
reviews <- biblioAnalysis(reviews, sep = ";")
non_reviews <- biblioAnalysis(non_reviews, sep = ";")

# Extract descriptive statistics from each types summary
summary_slrs <- summary(slrs)
summary_reviews <- summary(reviews)
summary_non_reviews <- summary(non_reviews)
