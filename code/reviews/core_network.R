# Core network
# Date: 20-08-2024
# Author: Carl-Emil Pless

# Clear workspace
rm(list = ls())

# Load necessary libraries
library(here)
library(igraph)
library(tidyverse)
library(htmlwidgets)
library(visNetwork)
library(webshot)
library(viridis)

# Set seed for reproducibility
set.seed(42)

# Load csv data
upper_triangular <- read.csv(here("data", "wrangled_data", "reviews", "core_adjacency.csv"), row.names = 1)

# Add a space instead of a "." in the row and column names
rownames(upper_triangular) <- gsub("\\.", " ", rownames(upper_triangular))
colnames(upper_triangular) <- gsub("\\.", " ", colnames(upper_triangular))

# Convert upper triangular matrix to symmetric matrix
adjacency_matrix <- as.matrix(upper_triangular)
adjacency_symmetric <- adjacency_matrix + t(adjacency_matrix) - diag(diag(adjacency_matrix))

# Filter edges with weight less than 30
adjacency_symmetric[adjacency_symmetric < 30] <- 0

# Generate igraph object from adjacency matrix
G <- graph_from_adjacency_matrix(adjacency_symmetric, mode = "undirected", weighted = TRUE)

# Remove self-loops
G <- delete_edges(G, which(E(G) %>% ends(G, .) %>% apply(1, function(x) x[1] == x[2])))

# Cluster the core network
communities <- cluster_louvain(G)
V(G)$community <- communities$membership

# Calculate the degree of each node in the original network
node_degrees <- degree(G)

# Identify the top 15 nodes with the highest degrees
top_15_nodes <- names(sort(node_degrees, decreasing = TRUE))[1:15]

# Define a new color palette for communities using viridis
community_colors <- viridis(length(unique(V(G)$community)), option = "plasma")

# Convert the graph to data frames for visNetwork
edges_vis <- igraph::as_data_frame(G, what = "edges")
nodes_vis <- data.frame(
    id = V(G)$name,
    group = V(G)$community,
    label = ifelse(V(G)$name %in% top_15_nodes, V(G)$name, ""), # Add labels only to top 15 nodes
    value = node_degrees[V(G)$name], # Use node degree for size
    color = community_colors[V(G)$community], # Node color based on community
    borderWidth = 2, # Node border width
    borderWidthSelected = 2, # Node border width when selected
    color.border = "#000000", # Node stroke color
    font.size = ifelse(V(G)$name %in% top_15_nodes, 100, 0), # Set font size for top 15 nodes
    font.color = "#000000" # Label color
)

# Adjust node size scaling based on original network degrees
nodes_vis$value <- nodes_vis$value / max(node_degrees) * 60 + 15 # Increase scaling to separate nodes more

# Scale edge widths according to weight and set opacity
edges_vis <- edges_vis %>%
    mutate(
        width = weight / max(edges_vis$weight) * 40, # Increase edge width scaling
        color = rgb(248 / 255, 118 / 255, 109 / 255, 0.25) # Set edge color with opacity
    )

# Adjust font size scaling based on original network degrees
nodes_vis$font.size <- nodes_vis$value / max(node_degrees) * 40 + 25 # Scale font size with node degree

# Create a visNetwork plot with modified physics and degree-based font size
vis_network <- visNetwork(nodes = nodes_vis, edges = edges_vis) %>%
    visNodes(
        shape = "dot",
        scaling = list(min = 5, max = 100), # Adjust size scaling
        shadow = TRUE,
        font = list(size = nodes_vis$font.size, color = "#000000") # Scale font size based on degree
    ) %>%
    visEdges(
        color = list(color = rgb(248 / 255, 118 / 255, 109 / 255, 0.5)), # No edge highlighting on click
        width = "width" # Scale edge widths by weight
    ) %>%
    visOptions(
        highlightNearest = FALSE, # Disable node highlighting on hover or click
        nodesIdSelection = FALSE # Remove node selection on click
    ) %>%
    visPhysics(
        solver = "barnesHut", # A force-directed solver
        stabilization = list(enabled = TRUE, iterations = 200), # Faster stabilization, fewer jumps
        barnesHut = list(
            gravitationalConstant = -3000, # Reduce gravity to allow nodes to spread out more
            centralGravity = 0.2, # Keep nodes centered but less tightly
            springLength = 300, # Increase distance between connected nodes
            springConstant = 0.02 # Keep stiffness low to avoid too much movement
        )
    )

# Show network
vis_network

# Save with visSave
visSave(vis_network, file = here("results", "reviews", "core_network.html"), selfcontained = TRUE)