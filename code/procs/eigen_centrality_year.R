#' Calculate Eigenvector Centrality for Each Year
#'
#' This function calculates the eigenvector centrality for each year passed to it and stores the results in a data frame.
#' It also stores the centrality for all years if a keyword is in the top 10 at any point.
#'
#' @param years A vector of years for which to calculate the centrality.
#' @param biblio A data frame containing bibliometric data.
#'
#' @return A data frame with the centrality measures for each year. Each row includes the year, keyword, and centrality score.
#'
#' @details The function filters the bibliometric data for each year, generates an adjacency matrix based on keyword co-occurrences, 
#' creates an igraph object, calculates the eigenvector centrality, and stores the top 10 central nodes for each year in a data frame.
#' It also keeps track of all keywords that have ever been in the top 10 and calculates their centrality for all years.
#'
#' @examples
#' \dontrun{
#' # Example usage
#' years <- 2000:2003
#' centrality_results <- eigen_centrality_year(years, biblio)
#' print(centrality_results)
#' }
#'
#' @import dplyr
#' @import bibliometrix
#' @import igraph
#' @export
eigen_centrality_year <- function(years, biblio) {
    results <- data.frame()
    top_keywords <- c()

    for (year in years) {
        # Filter data for the given year
        biblio_year <- biblio %>%
            filter(PY == year)

        # Generate adjacency matrix
        adj <- biblioNetwork(biblio_year, analysis = "co-occurrences", network = "keywords", sep = ";")

        # Generate igraph object
        G <- graph_from_adjacency_matrix(adj, mode = "undirected", weighted = TRUE)

        # Calculate eigenvector centrality
        centrality <- centr_eigen(G)$vector

        # Extract node names from the graph
        node_names <- V(G)$name

        # Assign names to centrality values
        names(centrality) <- node_names

        # Get the 10 most central nodes with their names
        top_nodes <- head(sort(centrality, decreasing = TRUE), 10)

        # Update the list of top keywords
        top_keywords <- unique(c(top_keywords, names(top_nodes)))

        # Create a data frame for the current year without row names
        year_df <- data.frame(Year = year, Keyword = names(top_nodes), Centrality = top_nodes, row.names = NULL)

        # Append the current year's data to the results data frame
        results <- rbind(results, year_df)
    }

    # Calculate centrality for all years for the top keywords
    all_years_results <- data.frame()
    for (year in years) {
        # Filter data for the given year
        biblio_year <- biblio %>%
            filter(PY == year)

        # Generate adjacency matrix
        adj <- biblioNetwork(biblio_year, analysis = "co-occurrences", network = "keywords", sep = ";")

        # Generate igraph object
        G <- graph_from_adjacency_matrix(adj, mode = "undirected", weighted = TRUE)

        # Calculate eigenvector centrality
        centrality <- centr_eigen(G)$vector

        # Extract node names from the graph
        node_names <- V(G)$name

        # Assign names to centrality values
        names(centrality) <- node_names

        # Filter centrality values for the top keywords
        top_keywords_centrality <- centrality[names(centrality) %in% top_keywords]

        # Create a data frame for the current year without row names
        year_df <- data.frame(Year = year, Keyword = names(top_keywords_centrality), Centrality = top_keywords_centrality, row.names = NULL)

        # Append the current year's data to the all years results data frame
        all_years_results <- rbind(all_years_results, year_df)
    }

    return(all_years_results)
}