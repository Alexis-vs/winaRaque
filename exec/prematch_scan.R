install.packages("tidyr")
library(tidyr)
library(dplyr)
library(rvest)
library(xml2)
library(jsonlite)
library(winaRaque)

next_hours = 20
sports = c("Basketball", "Tennis", "Baseball")


df_prematch_sports <- lapply(sports, get_sport_df, bet_status = "PREMATCH", next_hours = next_hours)
df_prematch <- do.call("rbind", df_prematch_sports)

df_prematch <- df_prematch %>%
  tidyr::drop_na(matchId) %>%
  dplyr::rowwise() %>%
  dplyr::mutate(competitorFavori   = substr(names(.)[c(8,11)][which.min(c_across(c(Competitor1_OddPreMatch, Competitor2_OddPreMatch)))],11,11),
                competitorOutsider = substr(names(.)[c(8,11)][which.max(c_across(c(Competitor1_OddPreMatch, Competitor2_OddPreMatch)))],11,11))

saveRDS(df_prematch,
        file = file.path("shiny","prematch_scan.rds"))
