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
    mutate(province_territory = name,
           count = as.numeric(gsub("[^0-9.]", "", count)),
           count_per_100000 = as.numeric(gsub("[^0-9.]", "", count_per_100000))
           ) |>
    mutate(profession_type = case_when(profession_type == "Family medicine" ~ "Family medicine doctors",
                                       TRUE ~ profession_type ))
  
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
    profession_type = factor(),
    year = numeric(),
    count = numeric(),
    count_per_100000 = numeric(),
    percent_female = numeric(),
    percent_age_under_30 = numeric(),
    percent_age_30_to_59 = numeric(),
    percent_age_over_60 = numeric(),
    province_territory = factor()
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
  
  
  # make summary data
  full_data <- full_data |>
    mutate(
      profession_type = as.factor(profession_type),
      province_territory = as.factor(province_territory),
      year = as.numeric(year),
      count = as.numeric(count),
      count_per_100000 = as.numeric(count_per_100000),
      percent_female = as.numeric(percent_female),
      percent_age_under_30 = as.numeric(percent_age_under_30),
      percent_age_30_to_59 = as.numeric(percent_age_30_to_59),
      percent_age_over_60 = as.numeric(percent_age_over_60),
    )
  
  summary_data <- full_data |>
    mutate(count_female_per_100000 = count_per_100000 * percent_female / 100,
           count_age_under_30_per_100000 = count_per_100000 * percent_age_under_30 / 100,
           count_age_30_to_59_per_100000 = count_per_100000 * percent_age_30_to_59 / 100,
           count_age_over_60_per_100000 = count_per_100000 * percent_age_over_60 / 100) |>
    group_by(year, province_territory) |>
    summarize(
      count = sum(count, na.rm = TRUE),
      count_per_100000 = sum(count_per_100000, na.rm = TRUE),
      percent_female = ifelse(count_per_100000 == 0, 0, sum(count_female_per_100000, na.rm = TRUE) / count_per_100000 * 100),
      percent_age_under_30 = ifelse(count_per_100000 == 0, 0, sum(count_age_under_30_per_100000, na.rm = TRUE) / count_per_100000 * 100),
      percent_age_30_to_59 = ifelse(count_per_100000 == 0, 0, sum(count_age_30_to_59_per_100000, na.rm = TRUE) / count_per_100000 * 100),
      percent_age_over_60 = ifelse(count_per_100000 == 0, 0, sum(count_age_over_60_per_100000, na.rm = TRUE) / count_per_100000 * 100),
      population = mean(population, na.rm = TRUE)
    ) |>
    mutate(profession_type = "All")
  
  # add summary data to processed data
  data_with_summary <- bind_rows(full_data, summary_data)
  data_with_summary <- data_with_summary |>
    mutate(percent_male = 100 - percent_female)
  
  # save processed data
  write_csv(data_with_summary, "data/processed/processed_data.csv")
  
}

source("src/process_data.R")
main()

