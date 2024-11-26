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
library(htmlwidgets)
library(visNetwork)
library(webshot)

# Set seed for reproducibility
set.seed(42)

# Load data
reviews <- readRDS(here("data", "wrangled_data", "reviews", "biblio.rds"))

# Filter out publications without Keywords plus
data <- reviews %>%
    filter(!is.na(ID))

# Generate a simple keyword co-occurrence network
adj <- biblioNetwork(data, analysis = "co-occurrences", network = "keywords", sep = ";")

# Generate a simple igraph object
G <- graph_from_adjacency_matrix(adj, mode = "undirected", weighted = TRUE)

# Remove self-loops
G <- delete.edges(G, which(E(G) %>% ends(G, .) %>% apply(1, function(x) x[1] == x[2])))

# Cluster the network
communities <- cluster_louvain(G)
V(G)$community <- communities$membership

# Convert igraph object to data frame for visNetwork
edges <- igraph::as_data_frame(G, what = "edges")

# Calculate the degree of each node in the original network
node_degrees <- degree(G)

# Extract the most central community
most_central_community <- which.max(sapply(unique(V(G)$community), function(c) sum(degree(G, v = which(V(G)$community == c)))))

# Extract the most central community subgraph
most_central_subgraph <- induced_subgraph(G, which(V(G)$community == most_central_community))

# Calculate the degree of each node in the most central subgraph
node_degrees_subgraph <- degree(most_central_subgraph)

# Select the top 50 nodes by degree within the subgraph
top_50_nodes <- order(node_degrees_subgraph, decreasing = TRUE)[1:50]

# Create a subgraph with these nodes
top_50_subgraph <- induced_subgraph(most_central_subgraph, top_50_nodes)

# Convert the top 50 subgraph to data frames for visNetwork
edges_vis <- igraph::as_data_frame(top_50_subgraph, what = "edges")
nodes_vis <- data.frame(
    id = V(top_50_subgraph)$name,
    group = V(top_50_subgraph)$community,
    label = V(top_50_subgraph)$name, # Add labels to nodes
    value = node_degrees[V(top_50_subgraph)$name], # Use node degree from the original network for size
    color = "#79aaa0", # Node color
    borderWidth = 2, # Node border width
    borderWidthSelected = 2, # Node border width when selected
    color.border = "#000000", # Node stroke color
    font.size = 40, # Font size for labels
    font.color = "#000000" # Label color
)

# Adjust node size scaling based on original network degrees
nodes_vis$value <- nodes_vis$value / max(node_degrees) * 50 + 10 # Scale node sizes

# Scale edge widths according to weight and set opacity
edges_vis <- edges_vis %>%
    mutate(
        width = weight / max(edges_vis$weight) * 30, # Scale width by weight
        color = rgb(248 / 255, 118 / 255, 109 / 255, 0.25) # Set edge color with opacity
    )

# Create a visNetwork plot with specific layout options
vis_network <- visNetwork(nodes = nodes_vis, edges = edges_vis) %>%
    visNodes(
        shape = "dot", scaling = list(min = 5, max = 50), # Adjust size scaling
        color = list(background = "#79aaa0", border = "#000000"),
        shadow = TRUE, font = list(size = 18, color = "#000000")
    ) %>% # Node color, shadow, and label size
    visEdges(
        color = list(color = rgb(248 / 255, 118 / 255, 109 / 255, 0.5), highlight = rgb(248 / 255, 118 / 255, 109 / 255, 0.7)),
        width = "width" # Scale edge widths by weight
    ) %>%
    visOptions(highlightNearest = TRUE, nodesIdSelection = TRUE) %>%
    visIgraphLayout(layout = "layout_with_fr", randomSeed = 42) %>% # Force-directed layout
    visLayout(randomSeed = 42) # Random seed for layout reproducibility

# Show network
vis_network

# Save with visSave
visSave(vis_network, file = here("results", "reviews", "central_subgraph.html"), selfcontained = TRUE)

# Check and print the number of nodes and edges in the graph
vcount(top_50_subgraph)
ecount(top_50_subgraph)

# Identify three random smaller communities
community_sizes <- table(V(G)$community)

# Identify communities 22-26
selected_communities <- 22:26

# Extract the nodes from these communities
selected_nodes <- unlist(lapply(selected_communities, function(c) which(V(G)$community == c)))

# Create a subgraph with these nodes
selected_subgraph <- induced_subgraph(G, selected_nodes)

# Convert the selected subgraph to data frames for visNetwork
edges_vis <- igraph::as_data_frame(selected_subgraph, what = "edges")
nodes_vis <- data.frame(
    id = V(selected_subgraph)$name,
    group = V(selected_subgraph)$community,
    value = node_degrees[V(selected_subgraph)$name], # Use node degree from the original network for size
    color = "#79aaa0", # Node color
    borderWidth = 2, # Node border width
    borderWidthSelected = 2, # Node border width when selected
    color.border = "#000000", # Node stroke color
    font.color = "#000000" # Label color
)

# Adjust node size scaling based on original network degrees
nodes_vis$value <- nodes_vis$value / max(node_degrees) * 50 + 10 # Scale node sizes

# Scale edge widths according to weight and set opacity
edges_vis <- edges_vis %>%
    mutate(
        width = weight / max(edges_vis$weight) * 10, # Scale width by weight
        color = rgb(248 / 255, 118 / 255, 109 / 255, 0.25) # Set edge color with opacity
    )

# Create a visNetwork plot with specific layout options
vis_network <- visNetwork(nodes = nodes_vis, edges = edges_vis) %>%
    visNodes(
        shape = "dot", scaling = list(min = 5, max = 50), # Adjust size scaling
        color = list(background = "#79aaa0", border = "#000000"),
        shadow = TRUE, font = list(size = 18, color = "#000000")
    ) %>% # Node color, shadow, and label size
    visEdges(
        color = list(color = rgb(248 / 255, 118 / 255, 109 / 255, 0.5), highlight = rgb(248 / 255, 118 / 255, 109 / 255, 0.7)),
        width = "width" # Scale edge widths by weight
    ) %>%
    visOptions(highlightNearest = TRUE, nodesIdSelection = TRUE) %>%
    visIgraphLayout(layout = "layout_with_fr", randomSeed = 42) %>% # Force-directed layout
    visLayout(randomSeed = 42) # Random seed for layout reproducibility

# Show network
vis_network

# Save with visSave
visSave(vis_network, file = here("results", "reviews", "non_central_subgraph.html"), selfcontained = TRUE)

# Check and print the number of nodes and edges in the graph
vcount(selected_subgraph)
ecount(selected_subgraph)
