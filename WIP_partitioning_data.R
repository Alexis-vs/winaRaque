data2022_2023 <- utils::read.csv2("https://raw.githubusercontent.com/Alexis-vs/winaRaque/main/inst/extdata/nba_matchs_end_2022-2023.csv")
data2023_2024 <- utils::read.csv2("https://raw.githubusercontent.com/Alexis-vs/winaRaque/main/inst/extdata/nba_matchs.csv")

data <- rbind(data2022_2023 %>% mutate(season = "2022-2023"),
              data2023_2024 %>% mutate(season = "2023-2024"))

library(arrow)


data %>%
  dplyr::mutate(dplyr::across(c("matchStart", "time_scrap"), ~as.POSIXct(.x, tz = "CET", tryFormats = "%Y-%m-%d %H:%M:%OS"))) %>%
  dplyr::mutate(day_match = format(matchStart, tz = "America/Los_Angeles", usetz = TRUE) %>% as.Date()) %>%
  group_by(season, day_match) %>%
  write_dataset(path = "inst/extdata/nba_matchs/")
data_arrow <- open_dataset("inst/extdata/nba_matchs/", partitioning = c("season", "day_match"))
data_c <- data_arrow %>%
  head() %>%
  collect()


time_scrap <- Sys.time()
json <- get_winamax_json("https://www.winamax.fr/paris-sportifs/sports/2/15/177")
list_match <- json[["matches"]]
df_match <- plyr::rbind.fill(lapply(list_match, function(y){as.data.frame(t(y), stringsAsFactors = FALSE)}))
df_match <- df_match %>%
  as.data.frame()  %>%
  dplyr::rename("Competitor1_Id"   = "competitor1Id",
                "Competitor1_Name" = "competitor1Name",
                "Competitor2_Id"   = "competitor2Id",
                "Competitor2_Name" = "competitor2Name") %>%
  mutate_all(as.character) %>%
  filter(tournamentId == "177") %>%
  select(matchId, mainBetId, title,
         Competitor1_Id, Competitor1_Name,
         Competitor2_Id, Competitor2_Name,
         matchStart) %>%
  mutate_at("matchStart", ~as.POSIXct(as.numeric(.), origin = "1970-01-01", tz = "CET")) %>%
  arrange(matchStart) %>%
  mutate(time_scrap = time_scrap)
# Time filter (matches 12h after job execution)
df_match <- df_match %>%
  filter(matchStart < (Sys.time() + (60*60*30)))
df_match <- df_match %>%
  rowwise() %>%
  mutate(Competitor1_Odd = get_odds(json, mainBetId)[[1]], .after = "Competitor1_Name") %>%
  mutate(Competitor2_Odd = get_odds(json, mainBetId)[[2]], .after = "Competitor2_Name") %>%
  mutate(season = "2023-2024") %>%
  dplyr::mutate(dplyr::across(c("matchStart", "time_scrap"), as.POSIXct, tz = "CET", tryFormats = "%Y-%m-%d %H:%M:%OS")) %>%
  dplyr::mutate(day_match = format(matchStart, tz = "America/Los_Angeles", usetz = TRUE) %>% as.Date())
df_match %>%
  #tidyr::drop_na() %>%
  group_by(season, day_match) %>%
  write_dataset(path = "inst/extdata/nba_matchs/")
