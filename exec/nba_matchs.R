# Script for github actions to get nba matchs everyday with odds ---------------

library(dplyr)
library(rvest)
library(xml2)
library(jsonlite)

json <- get_winamax_json("https://www.winamax.fr/paris-sportifs/sports/2/15/177")

time_scrap <- Sys.time()
json <- get_winamax_json("https://www.winamax.fr/paris-sportifs/sports/2/15/177")

list_match <- json[["matches"]]

df_match <- plyr::rbind.fill(lapply(list_match, function(y){as.data.frame(t(y), stringsAsFactors = FALSE)}))

df_match <- df_match %>%
  as.data.frame() %>%
  mutate_all(as.character) %>%
  filter(tournamentId == "177") %>%
  select(matchId,mainBetId,title,competitor1Id,competitor1Name,competitor2Id,competitor2Name,matchStart) %>%
  mutate_at("matchStart", ~as.POSIXct(as.numeric(.), origin = "1970-01-01", tz = "CET")) %>%
  arrange(matchStart) %>%
  mutate(time_scrap = time_scrap)

# Time filter
df_match <- df_match %>%
  filter(matchStart < (Sys.time()+(60*60*12)))

# Add odds
df_match <- df_match %>%
  rowwise() %>%
  mutate(competitor1Odd = get_odds(json, mainBetId)[[1]], .after = "competitor1Name") %>%
  mutate(competitor2Odd = get_odds(json, mainBetId)[[2]], .after = "competitor2Name")

data_path <- file.path("inst/extdata/")

if(file.exists(file.path(data_path,"nba_matchs.csv"))){

  print(getwd())
  read.csv2(file.path(data_path,"nba_matchs.csv")) %>%
    mutate_at(.vars = c("matchStart","time_scrap"), as.POSIXct, tz = "CET", tryFormats = "%Y-%m-%d %H:%M:%OS") %>%
    rbind(df_match) %>%
    write.csv2(file.path(data_path,"nba_matchs.csv"),
               row.names = FALSE)
} else {

  df_match %>%
    write.csv2("nba_matchs.csv",
               row.names = FALSE)
}
