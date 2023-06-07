# Script for github actions to get nba matches everyday with odds ---------------

library(dplyr)
library(rvest)
library(xml2)
library(jsonlite)
library(winaRaque)
#devtools::load_all()

time_scrap <- Sys.time()
json <- get_winamax_json("https://www.winamax.fr/paris-sportifs/sports/2/15/10561")

list_match <- json[["matches"]]

df_match <- plyr::rbind.fill(lapply(list_match, function(y){as.data.frame(t(y), stringsAsFactors = FALSE)}))

df_match <- df_match %>%
  as.data.frame() %>%
  mutate_all(as.character) %>%
  filter(tournamentId == "10561") %>%
  select(matchId, mainBetId, title,
         Competitor1_Id, Competitor1_Name,
         Competitor2_Id, Competitor2_Name,
         matchStart) %>%
  mutate_at("matchStart", ~as.POSIXct(as.numeric(.), origin = "1970-01-01", tz = "CET")) %>%
  arrange(matchStart) %>%
  mutate(time_scrap = time_scrap)

# Time filter (matches 12h after job execution)
df_match <- df_match %>%
  filter(matchStart < (Sys.time()+(60*60*12)))

# Add odds in csv if there are NBA games
if(nrow(df_match) > 0){

  df_match <- df_match %>%
    rowwise() %>%
    mutate(Competitor1_Odd = get_odds(json, mainBetId)[[1]], .after = "Competitor1_Name") %>%
    mutate(Competitor2_Odd = get_odds(json, mainBetId)[[2]], .after = "Competitor2_Name")

  data_path <- file.path("inst/extdata/")

  if(file.exists(file.path(data_path, "nba_matchs.csv"))){
    read.csv2(file.path(data_path, "nba_matchs.csv")) %>%
      mutate_at(.vars = c("matchStart", "time_scrap"), as.POSIXct, tz = "CET", tryFormats = "%Y-%m-%d %H:%M:%OS") %>%
      rbind(df_match) %>%
      arrange(matchStart, matchId, time_scrap %>% desc()) %>%
      distinct(matchId, mainBetId, matchStart, .keep_all = TRUE) %>%
      write.csv2(file.path(data_path, "nba_matchs.csv"),
                 row.names = FALSE)
  } else {
    df_match %>%
      write.csv2("nba_matchs.csv",
                 row.names = FALSE)
  }
}


# # join odds/scores
#
# data_path <- file.path("inst/extdata/")
# df_match <- read.csv2(file.path(data_path, "nba_matchs.csv")) %>%
#   mutate_at(.vars = c("matchStart", "time_scrap"), as.POSIXct, tz = "CET", tryFormats = "%Y-%m-%d %H:%M:%OS") %>%
#   mutate(day_match = format(matchStart, tz = "America/Los_Angeles",usetz = TRUE) %>% as.Date())
#
# min_date <- df_match$day_match %>% min()
# max_date <- df_match$day_match %>% max()
#
# scores <- get_nba_scores(game_date = min_date)
