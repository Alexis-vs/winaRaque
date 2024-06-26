# Script for github actions to get nba matches everyday with odds ---------------

library(dplyr)
library(rvest)
library(xml2)
library(jsonlite)
library(arrow)
library(winaRaque)
#devtools::load_all()

time_scrap <- Sys.time()
json <- get_winamax_json("https://www.winamax.fr/paris-sportifs/sports/2/15/177")

list_match <- json[["matches"]]

df_match <- plyr::rbind.fill(lapply(list_match, function(y){as.data.frame(t(y), stringsAsFactors = FALSE)}))

df_match <- df_match %>%
  as.data.frame()  %>%
  dplyr::rename("Competitor1_Id" = "competitor1Id",
                "Competitor1_Name" = "competitor1Name",
                "Competitor2_Id" = "competitor2Id",
                "Competitor2_Name" = "competitor2Name") %>%
  mutate_all(as.character) %>%
  filter(tournamentId == "177") %>%
  select(matchId, mainBetId, title,
         Competitor1_Id, Competitor1_Name,
         Competitor2_Id, Competitor2_Name,
         matchStart) %>%
  mutate_at("matchStart", ~as.POSIXct(as.numeric(.), origin = "1970-01-01", tz = "CET")) %>%
  arrange(matchStart) %>%
  mutate(time_scrap = time_scrap,
         day_match = format(matchStart, tz = "America/Los_Angeles", usetz = TRUE) %>% as.Date(),
         season = "2023-2024")

# Time filter (matches 12h after job execution)
df_match <- df_match %>%
  filter(matchStart < (Sys.time() + (60*60*12)))

# Add odds in csv if there are NBA games
if(nrow(df_match) > 0){

  df_match <- df_match %>%
    rowwise() %>%
    mutate(Competitor1_Odd = get_odds(json, mainBetId)[[1]], .after = "Competitor1_Name") %>%
    mutate(Competitor2_Odd = get_odds(json, mainBetId)[[2]], .after = "Competitor2_Name")

  data_path <- file.path("inst/extdata/")

  # if(file.exists(file.path(data_path, "nba_matchs.csv"))){
  #   read.csv2(file.path(data_path, "nba_matchs.csv")) %>%
  #     mutate_at(.vars = c("matchStart", "time_scrap"), as.POSIXct, tz = "CET", tryFormats = "%Y-%m-%d %H:%M:%OS") %>%
  #     rbind(df_match) %>%
  #     arrange(time_scrap %>% desc()) %>%
  #     distinct(matchId, mainBetId, .keep_all = TRUE) %>%
  #     arrange(matchStart, matchId) %>%
  #     write.csv2(file.path(data_path, "nba_matchs.csv"),
  #                row.names = FALSE)
  # } else {
  #   df_match %>%
  #     write.csv2(file.path(data_path, "nba_matchs.csv"),
  #                row.names = FALSE)
  # }

  open_dataset(sources = file.path(data_path, "nba_matchs/"), partitioning = c("season")) %>%
    collect() %>%
   # mutate_at(.vars = c("matchStart", "time_scrap"), as.POSIXct, tz = "CET", tryFormats = "%Y-%m-%d %H:%M:%OS") %>%
    rbind(df_match) %>%
    arrange(time_scrap %>% desc()) %>%
    distinct(matchId, mainBetId, .keep_all = TRUE) %>%
    arrange(matchStart, matchId) %>%
    group_by(season) %>%
    write_dataset(path = file.path(data_path, "nba_matchs/"))
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
