import pandas as pd
import networkx as nx
import netwulf as nw

# Load data
nodes = pd.read_csv("/Users/fst208/Documents/GitHub/eufore-wp-1/wrangled_data/reviews/simple_network_nodes.csv")
edges = pd.read_csv("/Users/fst208/Documents/GitHub/eufore-wp-1/wrangled_data/reviews/simple_network_edges.csv")

# Rename columns
edges = edges.rename(columns={"from": "source", "to": "target"})

# Generate network from edgelist
G = nx.from_pandas_edgelist(edges, edge_attr=True)

# Setting config
config = {
    'zoom': 0.6,
    'node_charge': -35,
    'node_gravity': 0.25,
    'link_distance': 30,
    'link_distance_variation': 1,
    'node_collision': True,
    'wiggle_nodes': True,
    'freeze_nodes': False,
    'node_fill_color': '#79aaa0',
    'node_stroke_color': '#000000',
    'node_label_color': '#000000',
    'display_node_labels': False,
    'scale_node_size_by_strength': True,
    'node_size': 50,
    'node_stroke_width': 0.5,
    'node_size_variation': 0.5,
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

# Plot using netwulf
nw.visualize(G, config = config)