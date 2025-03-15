library(shiny)
library(tidyverse)
# note that yukon does not have any age dist data for nurse practitioners

# read in data
data <- read_csv("../data/processed/processed_data.csv") |>
  mutate(
    profession_type = as.factor(profession_type),
    province_territory = as.factor(province_territory),
    year = as.numeric(year),
    count = as.numeric(count),
    count_per_100000 = as.numeric(count_per_100000),
    percent_male = as.numeric(percent_male),
    percent_female = as.numeric(percent_female),
    percent_age_under_30 = as.numeric(percent_age_under_30),
    percent_age_30_to_59 = as.numeric(percent_age_30_to_59),
    percent_age_over_60 = as.numeric(percent_age_over_60),
  )




ui <- fluidPage(
  
  titlePanel(("Canadian Primary Care Tracker")),
  h4("Explore the trends and demographics of Canadian primary care workers from 2019-2023!"),
  
  sidebarLayout(
    sidebarPanel(

      selectInput("profession_type", "Profession Type", 
                  choices = c("All",
                              "Family medicine doctors",
                              "Nurse practitioners"), 
                  selected = "All"),
      selectInput("province_territory", "Province/Territory", 
                  choices = c("Alberta",
                              "British Columbia",
                              "Manitoba",
                              "New Brunswick",
                              "Newfoundland and Labrador",
                              "Northwest Territories",
                              "Nova Scotia",
                              "Nunavut",
                              "Ontario",
                              "Prince Edward Island",
                              "Quebec",
                              "Saskatchewan",
                              "Yukon"), 
                  multiple = TRUE),
      sliderInput("year", "Year", 
                  min = min(data$year),
                  max = max(data$year), 
                  value = c(min(data$year), max(data$year)),
                  step = 1,
                  sep =''),
      
      #style = "height: 575px; overflow-y: auto;"
    ),
    mainPanel()
  ),
  
)

server <- function(input, output, session) {
}
shinyApp(ui, server)