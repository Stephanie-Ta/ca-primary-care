library(shiny)
library(tidyverse)
library(bslib)
# note that yukon does not have any age dist data for nurse practitioners

# read in data
data <- read_csv("data/processed/processed_data.csv") |>
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

ui <- fillPage(
  theme = bslib::bs_theme(bootswatch = "flatly"),
  tags$title("Canadian Primary Care Tracker"),
  tags$style(HTML("
  .custom-header {
    padding-top: 20px;
    padding-left: 20px;
    font-size: 32px;
    font-weight: bold;
    color: #2C3E50;
  }
  .custom-subtitle {
    font-size: 18px;
    font-style: italic;
    color: #555;
    padding-left: 20px;
  }
  .custom-padding-right {
    padding-right: 30px;
  }
  .custom-padding-left {
    margin-left: 20px;
  }
  ")),
  h1(div("Canadian Primary Care Tracker", class = "custom-header")), 
  h4(div("Explore the trends and demographics of Canadian primary care workers from 2019-2023!", class = "custom-subtitle")),
  
  
  sidebarLayout(
    sidebarPanel(
      selectInput("selected_profession_type", "Profession Type", 
                  choices = c("All",
                              "Family medicine doctors",
                              "Nurse practitioners"), 
                  selected = "All"),
      selectInput("selected_province_territory", "Province/Territory", 
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
      sliderInput("selected_year", "Year", 
                  min = min(data$year),
                  max = max(data$year), 
                  value = c(min(data$year), max(data$year)),
                  step = 1,
                  sep =''),
      
      width = 3,
      class = "custom-padding-left"
    ),
    
    mainPanel(
      fluidRow(
        column(width = 12,
               card(
                 card_header("Number of Primary Care Providers Per 100,000 Population Over Time"),
                 card_body(plotOutput("lineplot", height = "250px")),
                 full_screen = TRUE, border = TRUE
               )
        )
      ),
      
      #br(),
      
      fluidRow(
        column(width = 6,
               card(
                 card_header("Average Proportion of Primary Care Providers Per Gender"),
                 card_body(plotOutput("genderplot", height = "250px")),
                 full_screen = TRUE, border = TRUE
               )),
        column(width = 6,
               card(
                 card_header("Average Proportion of Primary Care Providers Per Age Group"),
                 card_body(plotOutput("ageplot", height = "250px")),
                 full_screen = TRUE, border = TRUE
               ))
      ),
      
      fluidRow(),
      
      width = 9,
      class = "custom-padding-right"
    )
  ),
  
)

server <- function(input, output, session) {
  output$lineplot <- renderPlot({
    data |>
      # filter profession type
      filter(profession_type == input$selected_profession_type) |>
      # Filter year range
      filter(between(year, input$selected_year[1], input$selected_year[2])) |>
      # Conditionally filter provinces if any are selected
      filter(if (length(input$selected_province_territory) > 0) province_territory %in% input$selected_province_territory else TRUE) |>
      ggplot(aes(x=year, y=count_per_100000, color=province_territory)) +
      geom_line(size = 1) +
      labs(x = "Year",
           y = "Number per 100,000 Population",
           color = "Province/Territory") +
      theme_minimal() +
      ggthemes::scale_color_gdocs()  +
      theme(text = element_text(size = 12.5))
  })
  
  output$genderplot <- renderPlot({
    data |>
      # filter profession type
      filter(profession_type == input$selected_profession_type) |>
      # Filter year range
      filter(between(year, input$selected_year[1], input$selected_year[2])) |>
      # Conditionally filter provinces if any are selected
      filter(if (length(input$selected_province_territory) > 0) province_territory %in% input$selected_province_territory else TRUE) |>
      mutate(year = as.factor(year)) |>
      group_by(year) |>
      summarise(percent_female = mean(percent_female, na.rm = TRUE),
                percent_male = mean(percent_male, na.rm = TRUE)) |>
      pivot_longer(cols = c(percent_female, percent_male), 
                   names_to = "gender", values_to = "percentage") |>
      mutate(gender = factor(gender, levels = c("percent_male", "percent_female"))) |> 
      ggplot(aes(x = year, y = percentage, fill = gender)) +
      geom_bar(stat = "identity") +
      scale_fill_manual(values = c("percent_male" = "#0072B2", "percent_female" = "#E69F00"),
                        labels = c("percent_male" = "Male", "percent_female" = "Female")) + 
      labs(x = "Year", y = "Percentage", fill = "Gender") +
      theme_minimal() +
      theme(text = element_text(size = 12.5))
  })

  output$ageplot <- renderPlot({
    data |>
      # filter profession type
      filter(profession_type == input$selected_profession_type) |>
      # Filter year range
      filter(between(year, input$selected_year[1], input$selected_year[2])) |>
      # Conditionally filter provinces if any are selected
      filter(if (length(input$selected_province_territory) > 0) province_territory %in% input$selected_province_territory else TRUE) |>
      mutate(year = as.factor(year)) |>
      group_by(year) |>
      summarise(percent_age_under_30 = mean(percent_age_under_30, na.rm = TRUE),
                percent_age_30_to_59 = mean(percent_age_30_to_59, na.rm = TRUE),
                percent_age_over_60 = mean(percent_age_over_60, na.rm = TRUE)) |>
      pivot_longer(cols = c(percent_age_under_30, percent_age_30_to_59, percent_age_over_60), 
                   names_to = "age_group", values_to = "percentage") |>
      mutate(age_group = factor(age_group, levels = c("percent_age_over_60", "percent_age_30_to_59", "percent_age_under_30"))) |>
      ggplot(aes(x = year, y = percentage, fill = age_group)) +
      geom_bar(stat = "identity") +
      scale_fill_manual(values = c("percent_age_under_30" = "#72d660", "percent_age_30_to_59" = "#339ff2", "percent_age_over_60" = "#8b29e6"),
                        labels = c("percent_age_under_30" = "Percent Under 30 Years Old", "percent_age_30_to_59" = "Percent Between 30 and 59 Years Old", "percent_age_over_60" = "Percent Over 60 Years Old")) + 
      labs(x = "Year", y = "Percentage", fill = "Age Group") +
      theme_minimal() +
      theme(text = element_text(size = 12.5))
  })
}


shinyApp(ui, server)