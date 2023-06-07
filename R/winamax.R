#' Get json in winamax source code
#'
#' @param url winamax url
#' @param ... other options to implement (categoryId, etc...)
#'
#' @import rvest
#' @import xml2
#' @importFrom jsonlite fromJSON
#'
#' @return json file
#' @export
#'
#' @examples
#' library(rvest)
#' library(xml2)
#' library(jsonlite)
#'
#' json <- get_winamax_json("https://www.winamax.fr/paris-sportifs/sports/2/15/177")
get_winamax_json <- function(url, ...){

  pg <- rvest::read_html(url)

  links <- rvest::html_nodes(pg, "script")
  link_text <- links[12]
  text <- xml2::xml_text(link_text)

  # see json in the source code
  # substr(text,1,200)
  # substrRight(text,50)

  json_text <- substr(text, 23, (nchar(text)-1))
  json <- jsonlite::fromJSON(json_text)

  return(json)
}


#' Get odds from bet id
#'
#' @param json json file containing the desired odds according to the bet id.
#' @param bet_id MainbetId
#'
#' @return Odds
#' @export
get_odds <- function(json, bet_id){

  if(bet_id=="NULL"){
    return(c(NA, NA))
  }else{
  outcomes <- json[["bets"]][[as.character(bet_id)]]$outcomes
  odds <- json[["odds"]][as.character(outcomes)]
  return(odds)
  }
}



#' Get all odds for selected sports
#'
#' @param sport Sports list between "Tennis", "Basketball", and "Baseball".
#'   Others sports are not yet implemented.
#' @param bet_status "PREMATCH" or "LIVE"
#' @param next_hours next_hours
#'
#' @importFrom rlang is_empty
#' @importFrom plyr rbind.fill
#' @import dplyr
#'
#' @return Odds for selected sports.
#' @export
#'
#' @examples
#' library(rvest)
#' library(xml2)
#' library(jsonlite)
#'
#' # Tennis bets for next 3 hours:
#' get_sport_df(sport = "Tennis", bet_status = "PREMATCH", next_hours = 3)
get_sport_df <- function(sport, bet_status, next_hours = 24){

  # SportsIdName <- read.csv2("inst/extdata/SportsIdName.csv") # ecrire un autre wrapper ?
  SportId <- SportsIdName$SportId[SportsIdName$SportName == sport]
  if(rlang::is_empty(SportId)) stop('write correct sport')

  url <- paste0("https://www.winamax.fr/paris-sportifs/sports/", SportId)

  time_scrap <- Sys.time()
  json <- get_winamax_json(url)

  list_match <- json[["matches"]]

  df_match <- plyr::rbind.fill(lapply(list_match, function(y){as.data.frame(t(y), stringsAsFactors = FALSE)}))

  df_match <- df_match %>%
    as.data.frame()  %>%
    dplyr::rename("Competitor1_Id" = "competitor1Id",
                  "Competitor1_Name" = "competitor1Name",
                  "Competitor2_Id" = "competitor2Id",
                  "Competitor2_Name" = "competitor2Name") %>%
    dplyr::mutate_all(as.character) %>%
    dplyr::filter(sportId %in% c("2", "3", "5")) %>%
    dplyr::select(matchId, status, mainBetId, sportId, title, Competitor1_Id, Competitor1_Name, Competitor2_Id, Competitor2_Name, matchStart) %>%
    dplyr::mutate_at("matchStart", ~as.POSIXct(as.numeric(.), origin = "1970-01-01", tz = "CET")) %>%
    dplyr::arrange(matchStart) %>%
    dplyr::mutate(time_scrap = time_scrap)

  # Time filter
  df_match <- df_match %>%
    dplyr::filter(matchStart < (Sys.time() + (60 * 60 * next_hours)))

  df_match <- df_match %>%
    dplyr::filter(status == bet_status)

  if(nrow(df_match) == 0L) {
    warning("No bet")
    return(NA)
  }

  if(bet_status == "PREMATCH"){

    df_match <- df_match %>%
      dplyr::rowwise() %>%
      dplyr::mutate(Competitor1_OddPreMatch = get_odds(json, mainBetId)[[1]], .after = "Competitor1_Name") %>%
      dplyr::mutate(Competitor2_OddPreMatch = get_odds(json, mainBetId)[[2]], .after = "Competitor2_Name")

  }else if(bet_status == "LIVE"){

    df_match <- df_match %>%
      dplyr::rowwise() %>%
      dplyr::mutate(Competitor1_OddLive = get_odds(json, mainBetId)[[1]], .after = "Competitor1_Name") %>%
      dplyr::mutate(Competitor2_OddLive = get_odds(json, mainBetId)[[2]], .after = "Competitor2_Name")
  }

  return(df_match)
}


# Global variables
utils::globalVariables(c("SportsIdName",
                         "Competitor1_Id", "Competitor1_Name",
                         "Competitor2_Id", "Competitor2_Name",
                         "mainBetId", "matchId", "matchStart",
                         "sportId", "status", "title"))
