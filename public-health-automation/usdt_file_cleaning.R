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
suppression_rules <- read_excel(metadata_filepath, sheet = "Suppression")
default_values <- read_excel(metadata_filepath, sheet = "default")

# Keep reporting jurisdiction text lowercase for output filename consistency.
reporting_jurisdiction_value <- default_values$Input[
  default_values$USDTField == "reporting_jurisdiction"
][1]
reporting_jurisdiction <- tolower(reporting_jurisdiction_value)
date_type_value <- default_values$Input[default_values$USDTField == "date_type"][1]
time_unit_value <- default_values$Input[default_values$USDTField == "time_unit"][1]

#### Initial data cleaning ####

# Resolve source columns before field renaming.
episode_date_source_column <- if ("episode_date" %in% names(df)) {
  "episode_date"
} else if ("Episode date" %in% names(df)) {
  "Episode date"
} else {
  stop("Missing required episode date column: episode_date or Episode date")
}

disease_source_column <- if ("disease_names" %in% names(df)) {
  "disease_names"
} else if ("disease_name" %in% names(df)) {
  "disease_name"
} else {
  stop("Missing required disease name column: disease_names or disease_name")
}

source_disease_values <- df[[disease_source_column]]
subtype_source_column <- if ("disease_subtype" %in% names(df)) {
  "disease_subtype"
} else {
  mapped_subtype_source <- variables_map$EDSS_name[
    variables_map$USDTField == "disease_subtype"
  ][1]
  if (!is.na(mapped_subtype_source) && mapped_subtype_source %in% names(df)) {
    mapped_subtype_source
  } else {
    NA_character_
  }
}

# 1) Rename incoming fields to USDT field names where mappings are available.
name_map <- match(names(df), variables_map$EDSS_name)
names(df)[!is.na(name_map)] <- variables_map$USDTField[name_map[!is.na(name_map)]]

# Explicit fallback mapping for subtype if generic rename did not produce it.
if (!"disease_subtype" %in% names(df)) {
  if (!is.na(subtype_source_column) && subtype_source_column %in% names(df)) {
    names(df)[names(df) == subtype_source_column] <- "disease_subtype"
  }
}

required_columns <- c(
  "age", "age_unit",
  "state", "geo_name", "confirmation_status"
)
missing_columns <- setdiff(required_columns, names(df))
if (length(missing_columns) > 0) {
  stop(paste("Missing required input columns:", paste(missing_columns, collapse = ", ")))
}

episode_date_column <- if ("episode_date" %in% names(df)) {
  "episode_date"
} else if (
  !is.na(variables_map$USDTField[match(episode_date_source_column, variables_map$EDSS_name)]) &&
    variables_map$USDTField[match(episode_date_source_column, variables_map$EDSS_name)] %in% names(df)
) {
  variables_map$USDTField[match(episode_date_source_column, variables_map$EDSS_name)]
} else if ("Episode date" %in% names(df)) {
  "Episode date"
} else if (episode_date_source_column %in% names(df)) {
  episode_date_source_column
} else {
  stop("Episode date column was not found after field renaming.")
}

# 2) Standardize episode date values before MMWR calculations.
episode_values <- df[[episode_date_column]]
if (inherits(episode_values, c("POSIXct", "POSIXlt"))) {
  df[[episode_date_column]] <- as.Date(episode_values)
} else if (is.numeric(episode_values)) {
  numeric_date_values <- as.character(episode_values)
  is_yyyymmdd <- grepl("^\\d{8}$", numeric_date_values)
  parsed_dates <- as.Date(rep(NA_character_, length(episode_values)))
  parsed_dates[is_yyyymmdd] <- suppressWarnings(ymd(numeric_date_values[is_yyyymmdd]))
  parsed_dates[!is_yyyymmdd] <- as.Date(episode_values[!is_yyyymmdd], origin = "1899-12-30")
  df[[episode_date_column]] <- parsed_dates
} else if (!inherits(episode_values, "Date")) {
  parsed_character_dates <- suppressWarnings(ymd(as.character(episode_values)))
  missing_character_dates <- is.na(parsed_character_dates) & !is.na(episode_values)
  parsed_character_dates[missing_character_dates] <- suppressWarnings(
    mdy(as.character(episode_values[missing_character_dates]))
  )
  df[[episode_date_column]] <- parsed_character_dates
}

invalid_episode_dates <- is.na(df[[episode_date_column]]) &
  !is.na(episode_values) &
  nzchar(trimws(as.character(episode_values)))
if (any(invalid_episode_dates)) {
  stop(
    paste(
      "Some episode dates could not be parsed:",
      sum(invalid_episode_dates),
      "row(s)."
    )
  )
}

if (all(is.na(df[[episode_date_column]]))) {
  stop("All episode dates are missing or could not be parsed.")
}

# 3) Map source disease names to the standardized USDT disease names.
disease_name_map_conflicts <- disease_name_map %>%
  filter(!is.na(EDSS_name), !is.na(disease_name)) %>%
  distinct(EDSS_name, disease_name) %>%
  count(EDSS_name) %>%
  filter(n > 1)

if (nrow(disease_name_map_conflicts) > 0) {
  stop(
    paste(
      "disease_name metadata has conflicting mappings for:",
      paste(disease_name_map_conflicts$EDSS_name, collapse = ", ")
    )
  )
}

disease_name_map <- disease_name_map %>%
  filter(!is.na(EDSS_name), !is.na(disease_name)) %>%
  distinct(EDSS_name, disease_name)

df <- df %>%
  mutate(source_disease_input = source_disease_values) %>%
  left_join(disease_name_map, by = c("source_disease_input" = "EDSS_name")) %>%
  mutate(count = 1L)

unmapped_diseases <- df %>%
  filter(is.na(disease_name) & !is.na(source_disease_input)) %>%
  distinct(disease_source = source_disease_input)
if (nrow(unmapped_diseases) > 0) {
  stop(
    paste(
      "Disease name mapping missing for:",
      paste(unmapped_diseases$disease_source, collapse = ", ")
    )
  )
}

# Meningococcus output requires subtype values from input/metadata mappings.
if (any(df$disease_name == "meningococcus", na.rm = TRUE) &&
    !"disease_subtype" %in% names(df)) {
  stop("Missing required input column for meningococcus processing: disease_subtype")
}
if (any(df$disease_name == "meningococcus", na.rm = TRUE)) {
  meningococcus_subtype_values <- df$disease_subtype[df$disease_name == "meningococcus"]
  if (all(is.na(meningococcus_subtype_values) | !nzchar(trimws(as.character(meningococcus_subtype_values))))) {
    stop("Meningococcus rows are present but subtype values are missing.")
  }
}

# 4) Add reporting period start/end from MMWR year/week.
mmwr_values <- MMWRweek::MMWRweek(df[[episode_date_column]])
df <- df %>%
  mutate(
    year = mmwr_values$MMWRyear,
    week = mmwr_values$MMWRweek,
    report_period_end = MMWRweek::MMWRweek2Date(year, week, 7),
    report_period_start = report_period_end - days(6)
  )

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
      age_in_years < 0 ~ "unknown",
      age_in_years < 1 ~ "<1 y",
      age_in_years >= 1 & age_in_years < 5 ~ "1-4 y",
      age_in_years >= 5 & age_in_years < 12 ~ "5-11 y",
      age_in_years >= 12 & age_in_years < 19 ~ "12-18 y",
      age_in_years >= 19 & age_in_years < 23 ~ "19-22 y",
      age_in_years >= 23 & age_in_years < 45 ~ "23-44 y",
      age_in_years >= 45 & age_in_years < 65 ~ "45-64 y",
      age_in_years >= 65 ~ ">=65 y"
    ),
    date_type = date_type_value,
    time_unit = time_unit_value,
    outcome = "cases"
  )

create_totals <- function(data, disease_subtype_col = "total") {
  # Output contract: publish county totals and state-level age-group totals.
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
      geo_name = reporting_jurisdiction_value,
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
  ) %>%
  # Normalize source subtypes so all meningococcus aggregates use the same rules.
  mutate(
    disease_subtype_upper = str_to_upper(coalesce(disease_subtype, "")),
    disease_subtype = case_when(
      str_detect(disease_subtype_upper, "^(SEROGROUP|GROUP)[\\s:\\-]*ACWY\\s*$|^\\s*ACWY\\s*$") ~ "ACWY",
      str_detect(disease_subtype_upper, "^(SEROGROUP|GROUP)[\\s:\\-]*B(\\b|\\s*[,/;&].*)|^\\s*B\\s*$") ~ "B",
      str_detect(disease_subtype_upper, "^(SEROGROUP|GROUP)[\\s:\\-]*A(\\b|\\s*[,/;&].*)|^\\s*A\\s*$") ~ "A",
      str_detect(disease_subtype_upper, "^(SEROGROUP|GROUP)[\\s:\\-]*Y(\\b|\\s*[,/;&].*)|^\\s*Y\\s*$") ~ "Y",
      str_detect(disease_subtype_upper, "^(SEROGROUP|GROUP)[\\s:\\-]*C(\\b|\\s*[,/;&].*)|^\\s*C\\s*$") ~ "C",
      str_detect(disease_subtype_upper, "^(SEROGROUP|GROUP)[\\s:\\-]*W(\\b|\\s*[,/;&].*)|^\\s*W\\s*$") ~ "W",
      str_detect(disease_subtype_upper, "NON-GROUPABLE") ~ "nongroupable",
      str_detect(disease_subtype_upper, "UNABLE") ~ "nongroupable",
      str_detect(disease_subtype_upper, "UNKNOWN|OTHER") ~ "unknown",
      TRUE ~ "unknown"
    )
  ) %>%
  select(-disease_subtype_upper)

meningococcus_county_totals <- meningococcus_dat %>%
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
    disease_subtype = "total"
  )

meningococcus_age_totals <- meningococcus_dat %>%
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
    geo_name = reporting_jurisdiction_value,
    disease_subtype = "total"
  )

meningococcus_totals <- bind_rows(meningococcus_age_totals, meningococcus_county_totals)

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
    geo_name = reporting_jurisdiction_value,
    age_group = "total"
  )

meningococcus_final <- bind_rows(meningococcus_subtype_totals, meningococcus_totals)

# Apply suppression thresholds by geo unit to county totals.
suppression_threshold_col <- c("suppression_count", "threshold", "count")[
  c("suppression_count", "threshold", "count") %in% names(suppression_rules)
][1]

if (length(suppression_threshold_col) == 0 || is.na(suppression_threshold_col)) {
  stop("Suppression sheet must include one of: suppression_count, threshold, or count.")
}

duplicate_suppression_geo_units <- suppression_rules %>%
  filter(!is.na(geo_unit), !is.na(.data[[suppression_threshold_col]])) %>%
  distinct(geo_unit, .data[[suppression_threshold_col]]) %>%
  count(geo_unit) %>%
  filter(n > 1)

if (nrow(duplicate_suppression_geo_units) > 0) {
  stop(
    paste(
      "Suppression sheet has duplicate threshold rows for geo_unit:",
      paste(duplicate_suppression_geo_units$geo_unit, collapse = ", ")
    )
  )
}

suppression_thresholds <- suppression_rules %>%
  transmute(
    geo_unit = geo_unit,
    suppression_count = .data[[suppression_threshold_col]]
  ) %>%
  distinct() %>%
  filter(!is.na(geo_unit), !is.na(suppression_count))

meningococcus_final <- meningococcus_final %>%
  left_join(suppression_thresholds, by = "geo_unit") %>%
  mutate(
    geo_name = case_when(
      geo_unit == "county" & !is.na(suppression_count) & count < suppression_count ~ "unspecified",
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
output_dir <- dlg_dir(title = "Select the folder where the file should output")$res

if (is.null(output_dir) || output_dir == "") {
  stop("No output folder was selected.")
}
if (!dir.exists(output_dir)) {
  stop("Selected output folder does not exist or is not accessible.")
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
