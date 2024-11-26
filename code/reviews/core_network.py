import pandas as pd
import networkx as nx
import netwulf as nw
import numpy as np

# Load csv file
adjacency_upper = pd.read_csv("/Users/fst208/Documents/GitHub/eufore-wp-1/data/wrangled_data/reviews/core_adjacency.csv", index_col=0)

# View the first few rows of the dataframe
print(adjacency_upper.head())

# Convert upper triangular matrix to symmetric matrix
adjacency_symmetric = adjacency_upper + adjacency_upper.T - np.diag(adjacency_upper.values.diagonal())

# View the first few rows of the dataframe
print(adjacency_symmetric.head())

# Generate network from symmetric adjacency matrix
G = nx.from_pandas_adjacency(adjacency_symmetric)

# Number of nodes
print(G.number_of_nodes())

# Number of edges
print(G.number_of_edges())

# Cluster using factions routine
partition = nx.community.greedy_modularity_communities(G)

# Number of communities
print(len(partition))

# Set community as a node attribute
community_dict = {}
for community_id, community in enumerate(partition):
    for node in community:
        community_dict[node] = community_id

nx.set_node_attributes(G, community_dict, 'community')

# Verify the community attribute
print(nx.get_node_attributes(G, 'community'))

config = {
    `zoom`: 2,
    'node_collision': True,
    'wiggle_nodes': True,
    'freeze_nodes': False,
    'node_fill_color': '#79aaa0',
    'node_stroke_color': '#000000',
    'node_label_color': '#000000',
    'display_node_labels': False,
    'scale_node_size_by_strength': True,
    'node_size': 10,
    'node_stroke_width': 0.5,
    'link_color': '#f8766d',
    'link_width': 1,
    'link_alpha': 0.5,
    'link_width_variation': 1,
    'display_singleton_nodes': True,
    'min_link_weight_percentile': 0,
    'max_link_weight_percentile': 1,
    'stroke_color': '#000000',
    'stroke_width': 0.35
}

# Filter the Graph to visualize with node groups determined by the 'community' attribute
new_G = nw.get_filtered_network(G, node_group_key='community')
nw.visualize(new_G, config = config)