# ----------------------------------------------------
# Shiny app

# Packages
library(shiny)
library(shinydashboard)
library(shinyWidgets)
library(dplyr)
library(tidyr)
library(rvest)
library(xml2)
library(jsonlite)
library(ggplot2)
devtools::load_all()

# Inputs
mise_outsider = 5
next_hours = 12
sports = c("Basketball", "Baseball", "Tennis")

# Source - get prematch_scan.rds from github actions
system("git pull")
df_prematch <- readRDS(file = file.path("shiny", "prematch_scan.rds")) %>%
  distinct(matchId, .keep_all = TRUE)

# Run the application
shiny::runApp(appDir = "shiny")
