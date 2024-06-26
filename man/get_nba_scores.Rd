% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/nba_scores.R
\name{get_nba_scores}
\alias{get_nba_scores}
\title{All NBA scores for a day}
\usage{
get_nba_scores(game_date, pivot_results = FALSE, only_results = FALSE)
}
\arguments{
\item{game_date}{date or character format "\%Y-\%m-\%d"}

\item{pivot_results}{default to FALSE. Pivot_longer with regex}

\item{only_results}{raw data from stats.nba.com}
}
\value{
scores for a day
}
\description{
Get a dataset with results and odds
}
\examples{
\dontrun{
get_nba_scores("2023-03-21")

# Try pivot_results feature
get_nba_scores("2023-03-21", pivot_results = TRUE)

# Try with many dates
seq_date <- seq.Date(from = as.Date("2023-03-24"),
                     to = as.Date("2023-03-27 "),
                     by = "day")
list_results <- lapply(seq_date, get_nba_scores, pivot_results = TRUE)
results <- do.call("rbind", list_results)
}
}
