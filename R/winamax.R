#' Get json in winamax source code
#'
#' @param url winamax url
#' @param ... other options to implement (categoryId, etc...)
#'
#' @import rvest
#' @import xml2
#' @import jsonlite
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

  outcomes <- json[["bets"]][[as.character(bet_id)]]$outcomes
  odds <- json[["odds"]][as.character(outcomes)]
  return(odds)
}
