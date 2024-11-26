# Plotting the centrality trends of keywords over time (reviews)
# Date: 04-10-2024
# Author: Carl-Emil Pless

# Clear workspace
rm(list = ls())

# Load necessary libraries
library(here)
library(tidyverse)
library(bibliometrix)
library(igraph)
library(ggrepel)
library(patchwork)

# Source functions
source(here("code", "procs", "eigen_centrality_year.R"))

# Load data
biblio <- readRDS(here("data", "wrangled_data", "reviews", "biblio.rds"))

# Filter out publications without Keywords plus
biblio <- biblio %>%
    filter(!is.na(ID))

# Determine the most central keywords from 2000 to 2022
years <- 2000:2022
centrality_results <- eigen_centrality_year(years, biblio)

# Calculate average centrality across years for each keyword
centrality_avg <- centrality_results %>%
    group_by(Keyword) %>%
    summarize(Avg_Centrality = mean(Centrality)) %>%
    arrange(desc(-Avg_Centrality))

# Merge average centrality with centrality results
centrality_results <- centrality_results %>%
    left_join(centrality_avg, by = "Keyword")

# Sort keywords by average centrality
centrality_results$Keyword <- factor(centrality_results$Keyword, levels = centrality_avg$Keyword)

# Create the heatmap plot
heatmap_plot <- ggplot(centrality_results, aes(x = Year, y = Keyword, fill = Centrality)) +
    geom_tile(color = "white") +
    scale_fill_gradientn(
        colors = c("#f7fcf5", "#c7e9c0", "#00441b"),
        values = c(0, 0.3, 1),
        limits = c(0, 1),
        breaks = seq(0, 1, by = 0.1)
    ) +
    labs(title = "Keyword Centrality Over Time", x = "Year", y = "Keyword") +
    theme_classic() +
    theme(legend.position = "bottom") +
    guides(fill = guide_colorbar(title = NULL, barwidth = unit(20, "lines")))

# Create the bar plot for average centrality
bar_plot <- ggplot(centrality_avg, aes(x = reorder(Keyword, Avg_Centrality), y = Avg_Centrality, fill = Avg_Centrality)) +
    geom_bar(stat = "identity") +
    geom_text(aes(label = round(Avg_Centrality, 2)), hjust = -0.1, size = 3.5) +
    coord_flip() +
    scale_y_continuous(limits = c(0, 1), expand = c(0, 0)) +
    scale_fill_gradientn(
        colors = c("#f7fcf5", "#c7e9c0", "#00441b"),
        values = c(0, 0.3, 1),
        limits = c(0, 1),
        breaks = seq(0, 1, by = 0.1),
        guide = "none"
    ) +
    labs(title = "Average Centrality of Keywords", x = "", y = "Average Centrality") +
    theme_classic() +
    theme(axis.title.y = element_blank(), axis.text.y = element_blank(), axis.ticks.y = element_blank(), legend.position = "none")

# Combine the plots using patchwork
combined_plot <- (heatmap_plot + bar_plot) + 
    plot_layout(ncol = 2, widths = c(3, 2), guides = "collect") & 
    theme(legend.position = "bottom")

# Print the combined plot
print(combined_plot)

# Save plot as JPEG
ggsave(
    here("results", "figures", "centrality_trends_reviews.jpg")
)