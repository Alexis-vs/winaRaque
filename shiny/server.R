#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#


shinyServer(function(input, output) {

  # Timer
  autoInvalidate <- reactiveTimer(10000)

  results <- reactiveValues()
  results$df <- data.frame()
  results$text_ggplot <- data.frame()

  # Winamax live scraping + surbet strategy
  observeEvent(autoInvalidate(), {

    #df_live <- get_sport_df(sport = "Tennis", bet_status = "LIVE")
    df_live_sports <- lapply(sports, get_sport_df, bet_status = "LIVE", next_hours = next_hours)
    df_live <- do.call("rbind", df_live_sports) %>%
      drop_na(matchId) %>%
      arrange(time_scrap %>% desc()) %>%
      distinct(matchId, .keep_all = TRUE)
      #ungroup() %>%
      #filter(!is.na(matchId))

    df_live <- df_live %>%
      filter(matchId %in% df_prematch$matchId)

    merge_live_prematch <- merge(df_live,
                                 df_prematch %>% select(matchId, Competitor1_OddPreMatch, Competitor2_OddPreMatch, competitorFavori, competitorOutsider),
                                 by = "matchId")

    if(nrow(merge_live_prematch) > 0){

      results_surbet <- merge_live_prematch %>%
        rowwise() %>%
        mutate(max_prematch = max(Competitor1_OddPreMatch, Competitor2_OddPreMatch)) %>%
        mutate(gain_cote_max_prematch = mise_outsider * max_prematch) %>%
        mutate(mise_surbet = gain_cote_max_prematch / get(paste0("Competitor", competitorFavori, "_OddLive"))) %>%
        mutate(mise_totale = mise_surbet + mise_outsider) %>%
        mutate(surbet = gain_cote_max_prematch - mise_totale) %>%
        mutate(pct_surbet = surbet*100/mise_outsider)

      results$text_ggplot <- results_surbet %>%
        select(title, Competitor1_Name, Competitor2_Name, competitorFavori, mise_surbet) %>%
        mutate(label = paste("mise favori :", round(mise_surbet, 2), "sur", get(paste0("Competitor", competitorFavori, "_Name"))))

      results$df =  rbind(results$df, results_surbet)
    }
  })

  # Prematch table
  output$prematch_table <- renderDataTable(df_prematch %>%
                                             merge(SportsIdName, by.x = "sportId", by.y = "SportId") %>%
                                             filter(Competitor1_Id != "NULL") %>%
                                             select(sportId, SportName, Competitor1_Name, Competitor2_Name, Competitor1_OddPreMatch, Competitor2_OddPreMatch)
                                           )
  #output$prematch_table <- renderDataTable(results$df)

  # Surbet plot
  output$plot <- renderPlot({

    results$df %>%
      ggplot(aes(x = time_scrap, y = pct_surbet)) +
      geom_point() +
      geom_line() +
      geom_hline(yintercept = 0, color = "red") +
      geom_hline(yintercept = c(10,20), linetype = "dashed", color = "red") +
      scale_y_continuous(limits = c(-100, 100)) +
      facet_wrap(~title) +
      geom_text(results$text_ggplot, mapping = aes(x = as.POSIXct(-Inf), y = -Inf, label = label), hjust = -0.1, vjust = -1)

  })

})
