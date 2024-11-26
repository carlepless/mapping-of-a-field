# Keyword co-occurrence network (simple)
# Date: 20-08-2024
# Author: Carl-Emil Pless

# Clear workspace
rm(list = ls())

# Load necessary libraries
library(here)
library(igraph)
library(tidyverse)
library(bibliometrix)

# Load data
reviews <- readRDS(here("data", "wrangled_data", "reviews", "biblio.rds"))

# Filter out publications without Keywords plus
data <- reviews %>%
    filter(!is.na(ID))

# Generate a simple keyword co-occurrence network
adj <- biblioNetwork(data, analysis = "co-occurrences", network = "keywords", sep = ";")

# Generate a simple igraph object
G <- graph_from_adjacency_matrix(adj, mode = "undirected", weighted = TRUE)

# Number of nodes
vcount(G)

# Number of edges
ecount(G)

# Transform igraph object to data frame of nodes and edges
nodes <- data.frame(id = V(G)$name)
edges <- as.data.frame(as_edgelist(G))
colnames(edges) <- c("from", "to")
edges$weight <- E(G)$weight # Add edge weights

# Export to csv
write.csv(nodes, here("wrangled_data", "reviews", "simple_network_nodes.csv"), row.names = FALSE)
write.csv(edges, here("wrangled_data", "reviews", "simple_network_edges.csv"), row.names = FALSE)
