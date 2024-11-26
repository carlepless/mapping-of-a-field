# Scientific production over time
# Date: 19-08-2024
# Author: Carl-Emil Pless

# Clear workspace
rm(list = ls())

# Load necessary libraries
library(here)
library(tidyverse)
library(bibliometrix)
library(scales)

# Load data
non_reviews <- readRDS(here("data", "wrangled_data", "non_reviews", "biblio.rds"))
reviews <- readRDS(here("data", "wrangled_data", "reviews", "biblio.rds"))
slrs <- readRDS(here("data", "wrangled_data", "slrs", "biblio.rds"))

# Combine data with review identifier
non_reviews$review <- "All"
reviews$review <- "Reviews"
slrs$review <- "Systematic literature reviews"
data <- bind_rows(non_reviews, reviews, slrs)

# Find min and max of PY
min(data$PY)
max(data$PY)

# Plot histogram of publications over time split by review status
data %>%
    filter(PY < 2023) %>%
    ggplot(aes(x = PY, fill = review)) +
    geom_histogram(binwidth = 1, color = "black") +
    labs(
        x = "Year (from 1907-2022)",
        y = "Number of publications"
    ) +
    theme_classic() +
    guides(fill = guide_legend(title = NULL)) +
    theme(
        legend.position = "bottom",
        legend.direction = "horizontal"
    )

# Save plot as JPEG
ggsave(
    here("results", "figures", "production.jpg"),
    width = 10,
    height = 8
)

# Find yearly growth rate of scientific production
growth_rate <- data %>%
    filter(PY < 2023) %>%
    group_by(PY, review) %>%
    summarise(n = n()) %>%
    arrange(PY) %>%
    group_by(review) %>%
    mutate(
        previous_year_n = lag(n),
        growth_rate = (n - previous_year_n) / previous_year_n * 100
    ) %>%
    filter(!is.na(growth_rate)) # Remove NA values resulting from lag

# Plot growth rate over time
growth_rate %>%
    filter(PY %in% 1975:2022) %>%
    ggplot(aes(x = PY, y = growth_rate, color = review)) +
    geom_point(size = 2) +
    geom_smooth(method = "loess", se = FALSE) +  # Add smoothing function
    geom_hline(yintercept = 0, linetype = "dashed", color = "black") +  # Add dashed line at 0
    labs(
        x = "Year (from 1975-2022)",
        y = "Growth rate (%)"
    ) +
    theme_classic() +
    guides(color = guide_legend(title = NULL)) +
    theme(
        legend.position = "bottom",
        legend.direction = "horizontal"
    )

# Save plot as JPEG
ggsave(
    here("results", "figures", "growth_rate.jpg"),
    width = 10,
    height = 8
)

# Combine data for faceting
combined_data <- data %>%
    filter(PY %in% 1975:2022) %>%
    group_by(PY, review) %>%
    summarise(n = n()) %>%
    mutate(metric = "a. Number of publications", value = n) %>%
    select(PY, review, metric, value) %>%
    bind_rows(
        growth_rate %>%
            filter(PY %in% 1975:2022) %>%
            mutate(metric = "b. Growth rate (%)", value = growth_rate) %>%
            select(PY, review, metric, value)
    )

# Reorder the metric factor to switch the order of the plots
combined_data$metric <- factor(combined_data$metric, levels = c("a. Number of publications", "b. Growth rate (%)"))

# Plot combined data with faceting
combined_data %>%
    ggplot(aes(x = PY, y = value, fill = review)) +
    geom_col(position = "dodge", alpha = 0.2) + # Histogram-like bar plot
    geom_smooth(method = "loess", se = FALSE, aes(group = review, color = review)) + # Smoothing function
    geom_hline(data = combined_data %>% filter(metric == "b. Growth rate (%)"),
               aes(yintercept = 0), linetype = "dashed", color = "black") +  # Add dashed line at 0 for growth rate
    facet_wrap(~metric, scales = "free_y", ncol = 1) + # Stack facets vertically
    labs(
        x = "Year (from 1975 to 2022)",
        y = NULL
    ) +
    theme_classic() +
    guides(
        fill = guide_legend(title = ""),
        color = guide_legend(title = "")
    ) +
    scale_y_continuous(
        expand = expansion(mult = c(0, 0.05)),
        breaks = function(x) {
            if (any(grepl("b. Growth rate (%)", combined_data$metric))) {
                seq(min(x), max(x), by = 10) # Adjust the interval as needed
            } else {
                scales::pretty_breaks(n = 10)(x) # More natural breaks for number of publications
            }
        },
        labels = function(x) {
            if (any(grepl("b. Growth rate (%)", combined_data$metric))) {
                scales::percent(x / 100)
            } else {
                x
            }
        }
    ) + # Start y-axis at 0 with a small expansion at the top and add percentage sign to growth rate
    theme(
        legend.position = "bottom",
        legend.direction = "horizontal",
        strip.text = element_text(size = 14) # Increase the size of the facet titles
    )

# Save plot as JPEG
ggsave(
    here("results", "figures", "production_growth.jpg"),
    width = 10,
    height = 8
)

# Calculate the share of SLRs of all papers in 2022
data %>%
    filter(PY == 2022) %>%
    group_by(review) %>%
    summarise(n = n()) %>%
    mutate(share = n / sum(n) * 100)
