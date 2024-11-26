# Mapping of a Field
## A systematic review of reviews of forestry and the forest-based sector in Europe

## Overview
This repository contains the code for the bibliometric components of the project "Mapping of a Field: A systematic review of reviews of forestry and the forest-based sector in Europe".

## Repository Structure
The repository contains the following files and directories:

- `code/`: This directory contains all the scripts used for data processing and analysis.
- `data/`: This directory contains all the raw and processed data. Please note that this is available upon request and is not included in the repository for other purposes than to provide an overview of the structure.
- `results/`: This directory contains the final results of the data analysis.
- `README.md`: This file provides an overview of the project and its structure.

Whenever appropriate, the folders are split into subfolders according to whatever dataset is used. So, the subfolders are named after the three datasets used:

1. `non-reviews/`: Contains scripts and/or data related to the non-review articles described in the paper.
2. `reviews/`: Contains scripts and/or data related to the review articles described in the paper.
3. `slrs/`: Contains scripts and/or data related to the systematic literature reviews described in the paper.

For scripts and/or data that uses multiple datasets, the scripts and/or data are placed in the root of the folder or in a relevant subfolder, i.e. `results/figures/`.

## How to Use
1. Clone the repository:
    ```bash
    git clone https://github.com/carlepless/mapping-of-a-field.git
    ```
2. Navigate to the project directory:
    ```bash
    cd mapping-of-a-field
    ```
3. Run the code in the relevant directories to process and analyze the data.

### Requirements
The process above requires the full `data` directory, which is available upon request. The code is written in Python and R, and the following packages are required:

#### `R` Packages
```r
# R packages
library(here)
library(igraph)
library(tidyverse)
library(bibliometrix)
library(htmlwidgets)
library(visNetwork)
library(webshot)
library(ggrepel)
library(patchwork)
library(scales)
library(synthesisr)
```

#### `Python` Packages
```python
# Python packages
import pandas as pd
import networkx as nx
import netwulf as nw
import numpy as np
```

## Contact
For any questions or inquiries, please contact [Carl-Emil Pless](mailto:cep@ifro.ku.dk).

**[Carl-Emil Pless](https://ifro.ku.dk/english/staff/staffenvironment/?pure=en/persons/528207)** \
P.hD. Fellow

**University of Copenhagen** \
Department of Food and Resource Economics \
Section for Environment and Natural Resources \
Rolighedsvej 23, 1958 Frederiksberg C, Gammel Bygning, stuen

[cep@ifro.ku.dk](mailto:cep@ifro.ku.dk)
