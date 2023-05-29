## code to prepare `SportsIdName` dataset goes here

json <- get_winamax_json("https://www.winamax.fr/paris-sportifs")

sportsId <- names(json$sports)
sportsName <- sapply(json$sports, '[[', 1)

SportsIdName <- data.frame(SportId = sportsId,
                           SportName = sportsName,
                           row.names = NULL)

usethis::use_data(SportsIdName, overwrite = TRUE)
