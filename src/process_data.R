# author: Stephanie Ta
# date: 2025-03-10
#
# This script reads in the raw data, saves it to data/raw/raw_data.csv,
# processes it to contain the data that is needed in an easier-to-handle format,
# and saves the processed data in data/processed/processed_data.csv
# Usage from the root directory: R src/process_data.R

library(tidyverse)
library(readxl)
library(openxlsx)

read_save_process_province_territory_data <- function(sheet_number, name) {
  raw_province_territory_data <- read.xlsx(
    "data/raw/raw_data.xlsx",
    sheet=sheet_number,
    startRow=2,
    rows=seq(2, 185),
    fillMergedCells = TRUE) |>
    select(1:8)
  
  processed_province_territory_data <- raw_province_territory_data
  
  colnames(processed_province_territory_data) <- c(
    "profession_type",
    "year",
    "count",
    "count_per_100000",
    "percent_female",
    "percent_age_under_30",
    "percent_age_30_to_59",
    "percent_age_over_60") 
  
  processed_province_territory_data <- processed_province_territory_data |>
    filter(profession_type == "Family medicine" |
             profession_type == "Nurse practitioners") |>
    mutate(province_territory = name)
  
  return(processed_province_territory_data)
}

main <- function() {
  # download and save raw data
  url <- "https://www.cihi.ca/sites/default/files/document/health-workforce-canada-2019-2023-overview-data-tables-en.xlsx"
  download.file(url, "data/raw/raw_data.xlsx", mode = "wb")
  raw_data_ <- read_excel("data/raw/raw_data.xlsx", sheet=3, skip=1, n_max=37)
  
  # put together primary care information for each province/territory
  names <- c("Newfoundland and Labrador",
             "Prince Edward Island",
             "Nova Scotia",
             "New Brunswick",
             "Quebec",
             "Ontario",
             "Manitoba",
             "Saskatchewan",
             "Alberta",
             "British Columbia",
             "Yukon",
             "Northwest Territories",
             "Nunavut")
  
  full_data <- tibble(
    profession_type = character(),
    year = integer(),
    count = integer(),
    count_per_100000 = numeric(),
    percent_female = numeric(),
    percent_age_under_30 = numeric(),
    percent_age_30_to_59 = numeric(),
    percent_age_over_60 = numeric(),
    province_territory = character()
  )
  
  for (i in seq_along(names)) {
    sheet_number = i + 3
    
    data = read_save_process_province_territory_data(
      sheet_number=sheet_number,
      name=names[i])
    
    full_data <- rbind(full_data, data)
  }
  
  # add on population data
  population_data <- read.xlsx(
    "data/raw/raw_data.xlsx",
    sheet=17,
    startRow=2,
    rows=seq(2, 15)) |>
    select(1:6)
  
  colnames(population_data) <- c("province_territory", "2019", "2020", "2021", "2022", "2023")
  
  population_data <- population_data |>
    pivot_longer(c("2019", "2020", "2021", "2022", "2023"),
                 names_to="year",
                 values_to = "population") |>
    mutate(year = as.numeric(year))
  
  full_data <- full_join(full_data,
                         population_data,
                         by = join_by(year, province_territory))
  
  # save processed data
  write_csv(full_data, "data/processed/processed_data.csv")
}

source("src/process_data.R")
main()

