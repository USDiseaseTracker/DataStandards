# This script prepares USDT disease tracking output for measles, pertussis,
# and meningococcus.
# Last updated: 2026-09-28

#### Required libraries ####
library(readr)
library(tidyverse)
library(MMWRweek)
library(lubridate)
library(svDialogs)
library(readxl)

#### Input files ####
input_filepath <- dlg_open(title = "Select your input file")$res
if (is.null(input_filepath) || input_filepath == "") {
  stop("No input file was selected.")
}

df <- if (grepl("\\.csv$", input_filepath, ignore.case = TRUE)) {
  read_csv(input_filepath, show_col_types = FALSE)
} else if (grepl("\\.xlsx$", input_filepath, ignore.case = TRUE)) {
  read_excel(input_filepath)
} else {
  stop("Input file must be .csv or .xlsx")
}

metadata_filepath <- dlg_open(title = "Select the metadata file")$res
if (is.null(metadata_filepath) || metadata_filepath == "") {
  stop("No metadata file was selected.")
}

variables_map <- read_excel(metadata_filepath, sheet = "Variables")
disease_name_map <- read_excel(metadata_filepath, sheet = "disease_name")
geo_name_map <- read_excel(metadata_filepath, sheet = "geo")
suppression_rules <- read_excel(metadata_filepath, sheet = "Suppression")
default_values <- read_excel(metadata_filepath, sheet = "default")

# Keep reporting jurisdiction text lowercase for output filename consistency.
reporting_jurisdiction <- tolower(
  default_values$Input[default_values$USDTField == "reporting_jurisdiction"]
)

#### Initial data cleaning ####

# 1) Rename incoming fields to USDT field names where mappings are available.
name_map <- match(names(df), variables_map$EDSS_name)
names(df)[!is.na(name_map)] <- variables_map$USDTField[name_map[!is.na(name_map)]]

required_columns <- c(
  "Episode date", "disease_names", "age", "age_unit",
  "state", "geo_name", "confirmation_status"
)
missing_columns <- setdiff(required_columns, names(df))
if (length(missing_columns) > 0) {
  stop(paste("Missing required input columns:", paste(missing_columns, collapse = ", ")))
}

# 2) Standardize episode date values before MMWR calculations.
if (inherits(df$`Episode date`, c("POSIXct", "POSIXlt"))) {
  df$`Episode date` <- as.Date(df$`Episode date`)
} else if (!inherits(df$`Episode date`, "Date")) {
  df$`Episode date` <- suppressWarnings(mdy(as.character(df$`Episode date`)))
}

if (all(is.na(df$`Episode date`))) {
  stop("All episode dates are missing or could not be parsed.")
}

# 3) Add reporting period start/end from MMWR year/week.
mmwr_values <- MMWRweek::MMWRweek(df$`Episode date`)
df <- df %>%
  mutate(
    year = mmwr_values$MMWRyear,
    week = mmwr_values$MMWRweek,
    report_period_end = MMWRweek::MMWRweek2Date(year, week, 7),
    report_period_start = report_period_end - days(6)
  )

# 4) Map source disease names to the standardized USDT disease names.
df <- df %>%
  left_join(disease_name_map, by = c("disease_names" = "EDSS_name")) %>%
  mutate(count = 1L)

unmapped_diseases <- df %>%
  filter(is.na(disease_name) & !is.na(disease_names)) %>%
  distinct(disease_names)
if (nrow(unmapped_diseases) > 0) {
  stop(
    paste(
      "Disease name mapping missing for:",
      paste(unmapped_diseases$disease_names, collapse = ", ")
    )
  )
}

# 5) Build age groups used by the reporting output.
df <- df %>%
  mutate(
    age_in_years = case_when(
      str_to_upper(age_unit) == "YEARS" ~ as.numeric(age),
      str_to_upper(age_unit) == "MONTHS" ~ as.numeric(age) / 12,
      str_to_upper(age_unit) == "DAYS" ~ as.numeric(age) / 365,
      TRUE ~ NA_real_
    ),
    age_group = case_when(
      is.na(age_in_years) ~ "unknown",
      age_in_years < 1 ~ "<1 y",
      between(age_in_years, 1, 4.999999) ~ "1-4 y",
      between(age_in_years, 5, 11.999999) ~ "5-11 y",
      between(age_in_years, 12, 18.999999) ~ "12-18 y",
      between(age_in_years, 19, 22.999999) ~ "19-22 y",
      between(age_in_years, 23, 44.999999) ~ "23-44 y",
      between(age_in_years, 45, 64.999999) ~ "45-64 y",
      age_in_years >= 65 ~ ">=65 y"
    ),
    date_type = default_values$Input[default_values$USDTField == "date_type"],
    time_unit = default_values$Input[default_values$USDTField == "time_unit"],
    outcome = "cases"
  )

# geo_name_map is read for metadata completeness and future extensions.
rm(geo_name_map)

create_totals <- function(data, disease_subtype_col = "total") {
  county_totals <- data %>%
    group_by(
      report_period_start,
      report_period_end,
      date_type,
      time_unit,
      disease_name,
      state,
      geo_name,
      confirmation_status,
      outcome
    ) %>%
    summarise(count = sum(count), .groups = "drop") %>%
    mutate(
      reporting_jurisdiction = state,
      geo_unit = "county",
      age_group = "total",
      disease_subtype = disease_subtype_col
    )

  age_totals <- data %>%
    group_by(
      report_period_start,
      report_period_end,
      date_type,
      time_unit,
      disease_name,
      state,
      age_group,
      confirmation_status,
      outcome
    ) %>%
    summarise(count = sum(count), .groups = "drop") %>%
    mutate(
      reporting_jurisdiction = state,
      geo_unit = "state",
      geo_name = "MN",
      disease_subtype = disease_subtype_col
    )

  bind_rows(age_totals, county_totals)
}

#### Disease-specific outputs ####

measles_dat <- df %>%
  filter(disease_name == "measles") %>%
  select(
    report_period_start, report_period_end, date_type, time_unit, disease_name,
    state, geo_name, age_group, confirmation_status, outcome, count
  )
measles_final <- create_totals(measles_dat)

pertussis_dat <- df %>%
  filter(disease_name == "pertussis") %>%
  select(
    report_period_start, report_period_end, date_type, time_unit, disease_name,
    state, geo_name, age_group, confirmation_status, outcome, count
  )
pertussis_final <- create_totals(pertussis_dat)

meningococcus_dat <- df %>%
  filter(disease_name == "meningococcus") %>%
  select(
    report_period_start, report_period_end, date_type, time_unit, disease_name,
    state, geo_name, age_group, disease_subtype, confirmation_status, outcome,
    count
  )

meningococcus_totals <- create_totals(meningococcus_dat)

# Normalize source subtypes so grouped subtype output is stable and case-insensitive.
meningococcus_dat <- meningococcus_dat %>%
  mutate(
    disease_subtype = case_when(
      str_detect(str_to_upper(disease_subtype), "SEROGROUP B") ~ "B",
      str_detect(str_to_upper(disease_subtype), "SEROGROUP A") ~ "A",
      str_detect(str_to_upper(disease_subtype), "SEROGROUP Y") ~ "Y",
      str_detect(str_to_upper(disease_subtype), "SEROGROUP C") ~ "C",
      str_detect(str_to_upper(disease_subtype), "SEROGROUP W") ~ "W",
      str_detect(str_to_upper(disease_subtype), "NON-GROUPABLE") ~ "nongroupable",
      str_detect(str_to_upper(disease_subtype), "UNABLE") ~ "nongroupable",
      str_detect(str_to_upper(disease_subtype), "UNKNOWN|OTHER") ~ "unknown",
      TRUE ~ "unknown"
    )
  )

meningococcus_subtype_totals <- meningococcus_dat %>%
  group_by(
    report_period_start,
    report_period_end,
    date_type,
    time_unit,
    disease_name,
    state,
    disease_subtype,
    confirmation_status,
    outcome
  ) %>%
  summarise(count = sum(count), .groups = "drop") %>%
  mutate(
    reporting_jurisdiction = state,
    geo_unit = "state",
    geo_name = "MN",
    age_group = "total"
  )

meningococcus_final <- bind_rows(meningococcus_subtype_totals, meningococcus_totals)

# Apply suppression thresholds by geo unit to county totals.
suppression_thresholds <- suppression_rules %>%
  select(geo_unit, count) %>%
  distinct() %>%
  rename(suppression_count = count)

meningococcus_final <- meningococcus_final %>%
  left_join(suppression_thresholds, by = "geo_unit") %>%
  mutate(
    geo_name = case_when(
      !is.na(suppression_count) & count < suppression_count ~ "unspecified",
      TRUE ~ geo_name
    )
  ) %>%
  select(-suppression_count) %>%
  group_by(
    report_period_start,
    report_period_end,
    date_type,
    time_unit,
    disease_name,
    reporting_jurisdiction,
    state,
    geo_unit,
    geo_name,
    age_group,
    disease_subtype,
    confirmation_status,
    outcome
  ) %>%
  summarise(count = sum(count), .groups = "drop")

#### Final output ####
final <- bind_rows(pertussis_final, measles_final, meningococcus_final) %>%
  arrange(report_period_start)

output_filename <- paste0(
  "disease_tracking_report_",
  reporting_jurisdiction,
  "_",
  Sys.Date(),
  ".csv"
)
output_dir <- paste0(dlg_dir(title = "Select the folder where the file should output")$res, "/")

if (is.null(output_dir) || output_dir == "/") {
  stop("No output folder was selected.")
}

confirm_name <- dlg_message(
  message = paste0("Is this the file name you want to use: ", output_filename),
  type = "yesno"
)$res

if (!identical(confirm_name, "yes")) {
  output_filename <- dlg_input(
    message = "Enter desired file name (with file extension)",
    default = output_filename
  )$res
}

if (is.null(output_filename) || output_filename == "") {
  stop("No output file name was provided.")
}

write.csv(final, file = file.path(output_dir, output_filename), na = "", row.names = FALSE)
