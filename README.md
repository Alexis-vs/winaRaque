
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

You can get NBA results for a day.

``` r
library(winaRaque)

get_nba_scores("2023-01-21")
#>          GAME_DATE_EST GAME_SEQUENCE    GAME_ID    TEAM_ID TEAM_ABBREVIATION
#> 1  2023-01-21T00:00:00             1 0022200692 1610612738               BOS
#> 2  2023-01-21T00:00:00             1 0022200692 1610612761               TOR
#> 3  2023-01-21T00:00:00             2 0022200693 1610612753               ORL
#> 4  2023-01-21T00:00:00             2 0022200693 1610612764               WAS
#> 5  2023-01-21T00:00:00             3 0022200694 1610612766               CHA
#> 6  2023-01-21T00:00:00             3 0022200694 1610612737               ATL
#> 7  2023-01-21T00:00:00             4 0022200695 1610612749               MIL
#> 8  2023-01-21T00:00:00             4 0022200695 1610612739               CLE
#> 9  2023-01-21T00:00:00             5 0022200696 1610612745               HOU
#> 10 2023-01-21T00:00:00             5 0022200696 1610612750               MIN
#> 11 2023-01-21T00:00:00             6 0022200697 1610612754               IND
#> 12 2023-01-21T00:00:00             6 0022200697 1610612756               PHX
#> 13 2023-01-21T00:00:00             7 0022200698 1610612755               PHI
#> 14 2023-01-21T00:00:00             7 0022200698 1610612758               SAC
#>    TEAM_CITY_NAME    TEAM_NAME TEAM_WINS_LOSSES PTS_QTR1 PTS_QTR2 PTS_QTR3
#> 1          Boston      Celtics            35-12       26       24       31
#> 2         Toronto      Raptors            20-27       27       30       28
#> 3         Orlando        Magic            17-29       26       31       34
#> 4      Washington      Wizards            20-26       37       33       30
#> 5       Charlotte      Hornets            13-34       25       24       36
#> 6         Atlanta        Hawks            24-23       31       34       28
#> 7       Milwaukee        Bucks            29-17       26       21       34
#> 8       Cleveland    Cavaliers            29-19       23       27       36
#> 9         Houston      Rockets            10-36       26       26       32
#> 10      Minnesota Timberwolves            24-24       26       24       37
#> 11        Indiana       Pacers            23-25       27       30       26
#> 12        Phoenix         Suns            23-24       29       30       28
#> 13   Philadelphia        76ers            30-16       27       37       38
#> 14     Sacramento        Kings            26-19       35       39       22
#>    PTS_QTR4 PTS_OT1 PTS_OT2 PTS_OT3 PTS_OT4 PTS_OT5 PTS_OT6 PTS_OT7 PTS_OT8
#> 1        25       0       0       0       0       0       0       0       0
#> 2        19       0       0       0       0       0       0       0       0
#> 3        27       0       0       0       0       0       0       0       0
#> 4        38       0       0       0       0       0       0       0       0
#> 5        37       0       0       0       0       0       0       0       0
#> 6        25       0       0       0       0       0       0       0       0
#> 7        21       0       0       0       0       0       0       0       0
#> 8        28       0       0       0       0       0       0       0       0
#> 9        20       0       0       0       0       0       0       0       0
#> 10       26       0       0       0       0       0       0       0       0
#> 11       24       0       0       0       0       0       0       0       0
#> 12       25       0       0       0       0       0       0       0       0
#> 13       27       0       0       0       0       0       0       0       0
#> 14       31       0       0       0       0       0       0       0       0
#>    PTS_OT9 PTS_OT10 PTS FG_PCT FT_PCT FG3_PCT AST REB TOV
#> 1        0        0 106  0.447  0.933   0.457  25  41  15
#> 2        0        0 104  0.535  0.714   0.368  24  41  14
#> 3        0        0 118  0.467  0.833   0.412  24  41  10
#> 4        0        0 138  0.537   0.72   0.529  34  46   8
#> 5        0        0 122  0.506  0.864   0.382  28  36  12
#> 6        0        0 118  0.542   0.85    0.44  24  40  16
#> 7        0        0 102  0.453  0.909   0.359  24  36  14
#> 8        0        0 114  0.558  0.647   0.318  33  41   9
#> 9        0        0 104  0.481  0.576   0.375  24  56  21
#> 10       0        0 113  0.458  0.833   0.415  20  30  11
#> 11       0        0 107  0.375  0.846   0.351  22  48  14
#> 12       0        0 112  0.418  0.686   0.387  27  55  15
#> 13       0        0 129  0.527  0.826   0.429  27  46  15
#> 14       0        0 127  0.548  0.759   0.394  28  29   8
```

## Data collect

A workflow run everyday to get all NBA odds for the night. The results
are in `inst/extdata`. An other workflow run every morning to collect
odds for shiny app.

## Shiny

Shiny app to explore ‘surbet’ variations during games of 1/2 sports
(tennis, basketball, baseball). Run the Shiny app with `app.R`.
