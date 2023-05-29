#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinydashboard)

dashboardPage(
  dashboardHeader(title = "winaRaque"),
  dashboardSidebar(sidebarMenu(
    menuItem("Live", tabName = "live", icon = icon("dashboard")),
    menuItem("Cotes prematch", tabName = "prematch", icon = icon("th"))),
    actionLink(inputId = "info_mise",
               label = paste("Mise outsider :", mise_outsider, "euro"),
               icon = icon("info"))
  ),
  dashboardBody(
    tabItems(
      # First tab content
      tabItem(tabName = "live",
              box(plotOutput("plot", height = "800px"),
                  width = 12)),

      # Second tab content
      tabItem(tabName = "prematch",
              fluidRow(
                column(12, dataTableOutput('prematch_table')))
      )
    )
  )
)
