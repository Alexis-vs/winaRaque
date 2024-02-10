# NBA scores

.parse_to_date_url <- function(game_date = "2017-12-31") {
  parts <- game_date %>%
    as.character() %>%
    stringr::str_split("\\-") %>%
    purrr::flatten_chr()
  stringr::str_c(parts[2], parts[3], parts[1], sep = "%2F")
}


#' NBA results for a day
#'
#' @param game_date date or character format "%Y-%m-%d"
#'
#' @import stringr purrr glue httr
#' @importFrom jsonlite fromJSON
#'
#' @return results for a day
get_nba_results <- function(game_date){

  headers <- c(
    `Host` = 'stats.nba.com',
    `User-Agent` = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv =72.0) Gecko/20100101 Firefox/72.0',
    `Accept` = 'application/json, text/plain, */*',
    `Accept-Language` = 'en-US,en;q=0.5',
    `Accept-Encoding` = 'gzip, deflate, br',
    `x-nba-stats-origin` = 'stats',
    `x-nba-stats-token` = 'true',
    `Connection` = 'keep-alive',
    `Referer` = 'https =//stats.nba.com/',
    `Pragma` = 'no-cache',
    `Cache-Control` = 'no-cache'
  )

  date <- .parse_to_date_url(game_date = game_date)

  # leagueId=00 is for NBA (10 & 20 for WNBA et GLeague)
  url <- glue::glue("https://stats.nba.com/stats/scoreboardv2/?leagueId=00&gameDate={date}&dayOffset=0") %>%
    as.character()

  res <- httr::GET(url, httr::add_headers(.headers = headers))

  results <- res$content %>%
    rawToChar() %>%
    jsonlite::fromJSON(simplifyVector = T)

  return(results)
}


#' Read winamax odds in parquet files from github repo
#'
#' @description
#' Odds from github actions
#'
#' @param branch branch
#'
#' @return
#' @import httr
#' @importFrom arrow read_parquet
#' @noRd
read_odds_parquet <- function(branch = "main"){

  # install {tzdb} package

  # Odds from github actions : detect parquet files in repo for import
  req <- httr::GET(paste0("https://api.github.com/repos/Alexis-vs/winaRaque/git/trees/", branch, "?recursive=1"))
  httr::stop_for_status(req)
  filelist <- unlist(lapply(httr::content(req)$tree, "[", "path"), use.names = F)
  parquet_files <- grep(".parquet", filelist, value = TRUE, fixed = TRUE)
  parquet_data <- lapply(parquet_files, function(x) arrow::read_parquet(paste("https://raw.githubusercontent.com/Alexis-vs/winaRaque", branch, x, sep = "/")))
  df_match <- do.call("rbind", parquet_data)
  return(df_match)

}


#' All NBA scores for a day
#'
#' @description
#' Get a dataset with results and odds
#'
#' @param game_date date or character format "%Y-%m-%d"
#' @param pivot_results default to FALSE. Pivot_longer with regex
#' @param only_results raw data from stats.nba.com
#'
#' @import dplyr
#' @importFrom tidyr pivot_longer pivot_wider
#' @importFrom tidyselect starts_with ends_with
#' @importFrom arrow read_parquet
#'
#' @return scores for a day
#' @export
#'
#' @examples
#' \dontrun{
#' get_nba_scores("2023-03-21")
#'
#' # Try pivot_results feature
#' get_nba_scores("2023-03-21", pivot_results = TRUE)
#'
#' # Try with many dates
#' seq_date <- seq.Date(from = as.Date("2023-03-24"),
#'                      to = as.Date("2023-03-27 "),
#'                      by = "day")
#' list_results <- lapply(seq_date, get_nba_scores, pivot_results = TRUE)
#' results <- do.call("rbind", list_results)
#' }
get_nba_scores <- function(game_date, pivot_results = FALSE, only_results = FALSE){

  results <- get_nba_results(game_date)
  scores <- results$resultSets
  scores_df <- scores$rowSet[[2]] %>% data.frame()

  if(nrow(scores_df) == 0){
    #warning(paste("No matches on", game_date, "\n"))
    return(NULL)
  }

  colnames(scores_df) <- scores$headers[[2]]

  if(only_results == TRUE){return(scores_df)}

  # Odds from github actions
  # df_match <- utils::read.csv2("https://raw.githubusercontent.com/Alexis-vs/winaRaque/main/inst/extdata/nba_matchs.csv") %>%
  # dplyr::mutate(dplyr::across(c("matchStart", "time_scrap"), as.POSIXct, tz = "CET", tryFormats = "%Y-%m-%d %H:%M:%OS")) %>%
  # dplyr::mutate(day_match = format(matchStart, tz = "America/Los_Angeles", usetz = TRUE) %>% as.Date())

  df_match <- read_odds_parquet() %>%
    #dplyr::mutate(dplyr::across(c("matchStart", "time_scrap"), as.POSIXct, tz = "CET", tryFormats = "%Y-%m-%d %H:%M:%OS")) %>%
    dplyr::mutate(dplyr::across(c("matchStart", "time_scrap"), ~as.POSIXct(.x, tz = "CET", tryFormats = "%Y-%m-%d %H:%M:%OS"))) %>%
    dplyr::mutate(day_match = format(matchStart, tz = "America/Los_Angeles", usetz = TRUE) %>% as.Date())

  scores_df$TEAM_CITY_NAME <- stringr::str_replace(scores_df$TEAM_CITY_NAME, "LA", "Los Angeles")

  pivot_scores <- scores_df %>%
    dplyr::mutate(name_order = rep(c(2, 1), nrow(scores_df)/2)) %>%
    dplyr::arrange(GAME_ID, name_order) %>%
    dplyr::mutate(TEAM = paste(TEAM_CITY_NAME, TEAM_NAME)) %>%
    dplyr::group_by(GAME_ID) %>%
    dplyr::mutate(WINLOSE = ifelse(PTS == max(PTS), "W", "L"),
                  GAME = paste(TEAM, collapse = " - ")) %>%
    dplyr::ungroup() %>%
    #dplyr::arrange(GAME_SEQUENCE, name_order) %>%
    dplyr::select(GAME, name_order, WINLOSE, tidyselect::starts_with(c("PTS", "FG", "FT", "AST", "REB")), TOV) %>%
    tidyr::pivot_wider(names_from = c("name_order"),
                       names_glue = "Competitor{name_order}_{.value}",
                       values_from = c(WINLOSE, tidyselect::starts_with(c("PTS", "FG", "FT", "AST", "REB")), TOV))

  merge_results <- df_match %>%
    dplyr::filter(day_match == game_date) %>%
    merge(pivot_scores, by.x = "title", by.y = "GAME")

  temp_labels <- c("Name", "Odd", "WINLOSE", "PTS", "FG_PCT", "FG3_PCT", "FT_PCT", "AST", "REB", "TOV")
  labels <- lapply(temp_labels, function(x) paste0("Competitor", 1:2,"_", x))
  labels_select <- do.call("c", labels)

  numeric_labels <- c("PTS", "FG_PCT", "FG3_PCT", "FT_PCT", "AST", "REB", "TOV")

  merge_results <- merge_results %>%
    dplyr::select(day_match,
                  matchId,
                  labels_select) %>%
    dplyr::mutate(dplyr::across(tidyselect::ends_with(numeric_labels), as.numeric))

  if(pivot_results == TRUE){
    merge_results <- merge_results %>%
      tidyr::pivot_longer(-c(day_match, matchId),
                          names_to = c("set", ".value"),
                          names_pattern = "(^[^_]+(?=_))_(.+)") # (.+)_(.+)
  }
  return(merge_results)
}

# Global variables
utils::globalVariables(c("GAME", "GAME_ID", "PTS",
                         "TEAM", "TEAM_CITY_NAME", "TEAM_NAME",
                         "TOV", "WINLOSE", "day_match", "name_order"))
