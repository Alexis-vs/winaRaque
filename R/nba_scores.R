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


#' All NBA scores for a day
#'
#' @param game_date date or character format "%Y-%m-%d"
#'
#' @return scores for a day
#' @export
#'
#' @examples
#' get_nba_scores("2023-03-21")
get_nba_scores <- function(game_date){

  results <- get_nba_results(game_date)
  scores <- results$resultSets
  scores_df <- scores$rowSet[[2]] %>% data.frame()
  colnames(scores_df) <- scores$headers[[2]]

  return(scores_df)
}
