
<!-- README.md is generated from README.Rmd. Please edit that file -->

# winaRaque

<!-- badges: start -->

[![R-CMD-check](https://github.com/Alexis-vs/winaRaque/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/Alexis-vs/winaRaque/actions/workflows/R-CMD-check.yaml)
[![Scrape NBA
matchs](https://github.com/Alexis-vs/winaRaque/actions/workflows/nba_matchs_scrap.yml/badge.svg)](https://github.com/Alexis-vs/winaRaque/actions/workflows/nba_matchs_scrap.yml)
<!-- badges: end -->

The goal of winaRaque is to explore sport data and make analysis with
sport betting odds. The first analyzes will be done through the NBA.

## Installation

You can install the development version of winaRaque from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("Alexis-vs/winaRaque")
```

## Example

You can get NBA results with 1/2 odds for a day.

``` r
library(winaRaque)

get_nba_scores("2023-03-23", pivot_results = TRUE)
#> # A tibble: 8 × 13
#>   day_match  matchId set   Name    Odd WINLOSE   PTS FG_PCT FG3_PCT FT_PCT   AST
#>   <date>       <int> <chr> <chr> <dbl> <chr>   <dbl>  <dbl>   <dbl>  <dbl> <dbl>
#> 1 2023-03-23  3.54e7 Comp… Broo…  2.4  L         114  0.481   0.353  0.889    24
#> 2 2023-03-23  3.54e7 Comp… Clev…  1.56 W         116  0.472   0.375  0.769    24
#> 3 2023-03-23  3.54e7 Comp… Los …  1.56 W         127  0.56    0.486  0.75     34
#> 4 2023-03-23  3.54e7 Comp… Okla…  2.4  L         105  0.441   0.333  0.909    24
#> 5 2023-03-23  3.54e7 Comp… New …  1.25 L         115  0.459   0.324  0.933    26
#> 6 2023-03-23  3.54e7 Comp… Char…  3.9  W          96  0.458   0.243  0.688    24
#> 7 2023-03-23  3.54e7 Comp… Orla…  2.35 W         111  0.46    0.406  0.857    25
#> 8 2023-03-23  3.54e7 Comp… New …  1.58 L         106  0.42    0.3    0.769    26
#> # ℹ 2 more variables: REB <dbl>, TOV <dbl>
```

## Small data visualization

``` r
# the workflow has been taking the odds since 2023-03-20
seq_date <- seq.Date(from = as.Date("2023-03-19"),
                     to = as.Date("2023-04-05"),
                     by = "day")
list_results <- lapply(seq_date, get_nba_scores, pivot_results = TRUE)
results <- do.call("rbind", list_results)
```

``` r
library(ggplot2)
library(dplyr)

results %>%
  ggplot(aes(x = Name, y = Odd, color = WINLOSE)) +
  geom_boxplot() +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5)) +
  ggtitle("Odds distribution according to result", subtitle = "by teams")
```

<img src="man/figures/README-unnamed-chunk-3-1.png" width="100%" />

## Data collect

A workflow run everyday to get all NBA odds for the night (currently
stopped because no NBA matchs). The results are in `inst/extdata`.  
An other workflow run every morning to collect odds for shiny app.

## Shiny

Shiny app to explore ‘surbet’ variations during games of 1/2 sports
(tennis, basketball, baseball). Run the Shiny app with `app.R`.
