# This script is designed to create a dataset for the disease tracking report for measles, meningococcus, and pertussis
#Last updated: 2026-07-17
#v3 update to meningococcus code so ACWY is seperated out appropriately.
#v4 was updated to include changing character date to date and including 4 year olds in 1-4 category
#V5 updated code for age days; forced on case matching
#########################################PRE-STEP##################################################################
#Ensure the following packages are installed on your local machine. This only needs to occur once:
install.packages("tidyverse", "svDialogs", "readr", "MMWRweek","lubridate", "readxl","plyr","dplyr", "sqldf")
#######################################Start Here##################################################################
#### Open R Libraries ####
{
{library(readr)
library(tidyverse)
library(MMWRweek)
library(lubridate)
library(svDialogs)
library(readxl)
library(plyr)
library(dplyr)
library(sqldf)
}

#### Input File ####

  #Select input file
input.filepath <- dlg_open(title = "Select your input file")$res

  #import file to 'df' into the system. there is NO CODE for if the tab in an excel is not the first tab.
if (grepl("\\.csv$", input.filepath, ignore.case = TRUE)) {
  df <- read_csv(input.filepath)
  
} else if (grepl("\\.xlsx$", input.filepath, ignore.case = TRUE)) {
  df <- read_excel(input.filepath)
  
} else {
  stop("File must be .csv or .xlsx")
}

#Initial Data cleaning---------------------------------------------------------
# 1. Import mapping file
{metadata <- dlg_open(title = "Select the metadata file")$res
Variables <-read_excel(metadata, sheet = "Variables")
Disease.Name <- read_excel(metadata, sheet = "disease_name")
Geo.name <- read_excel(metadata, sheet = "geo")
Suppression <- read_excel(metadata, sheet = "Suppression")
default <- read_excel(metadata, sheet = "default")
jx <- tolower(default$Input[
    default$USDTField=="reporting_jurisdiction"
      ])
}
  
# 2. Modify field names to standard USDT names
name_map<- match(names(df), Variables$EDSS_name)
names(df)[!is.na(name_map)]<- Variables$USDTField[name_map[!is.na(name_map)]]
##added
if(is.character(df$`Episode date`)==TRUE) {
 df$`Episode date`<- as.Date(df$`Episode date`, format = "%m/%d/%Y")
}
  
# 3. add MMWR start and end date for each row

df <- df %>%
  mutate(year = MMWRweek::MMWRweek(`Episode date`)$MMWRyear,
         week = MMWRweek::MMWRweek(`Episode date`)$MMWRweek) %>%
  mutate(report_period_end = MMWRweek::MMWRweek2Date(year, week, 7)) %>%
  mutate(report_period_start = report_period_end - days(6))
# 4. Update disease name
df <- merge(df, Disease.Name, by.x = "disease_names", by.y = "EDSS_name", all.x = TRUE)
#if disease_name contains a NA, stop working is.na(df$disease_name)
df$count <-1

# 5. add age groups
df <- df %>%
    mutate(
      age_in_years = case_when(
          toupper(age_unit) =="YEARS"  ~age,
          toupper(age_unit) == "MONTHS" ~age /12,
          toupper(age_unit) =="DAYS" ~ age/365,
          TRUE ~ NA_real_))

df <- df %>%
    mutate(
      age_group = case_when(
    age_in_years <1 ~"<1 y",
    age_in_years > .99 & age_in_years <5 ~"1-4 y",
    age_in_years > 4 & age_in_years <12 ~"5-11 y",
    age_in_years > 11 & age_in_years <19 ~"12-18 y",
    age_in_years > 18 & age_in_years <23 ~"19-22 y",
    age_in_years > 22 & age_in_years <45 ~ "23-44 y",
    age_in_years > 44 & age_in_years <65 ~"45-64 y",
    age_in_years > 64  ~">=65 y",
    is.na(age_in_years) == TRUE ~"unknown"
      ) 
    )
#Add additional values
{
df$date_type <-default$Input[
  default$USDTField=="date_type"
  ]
df$time_unit <-default$Input[
  default$USDTField=="time_unit"
]
df$outcome <- "cases"
}

  
# MEASLES DATA ------------------------------------------------------------

measles_dat <- subset(df, df$disease_name=="measles",
                      select = c("report_period_start", "report_period_end", "date_type","time_unit", "disease_name", "state", 
                                 "geo_name", "age_group", "confirmation_status", "outcome","count"))

#Create county totals
group_string <-"SELECT report_period_start,report_period_end, date_type
, time_unit, disease_name,state AS reporting_jurisdiction,state, 'county' AS geo_unit, geo_name, 'total' AS age_group
, 'total' AS disease_subtype, confirmation_status, outcome, sum(count) AS count
FROM measles_dat md
WHERE 1=1
GROUP BY report_period_start,report_period_end, disease_name,state, geo_name, confirmation_status"
measles_dat_weekly <-sqldf(group_string) 

#Create age group totals
{group_string <-"SELECT report_period_start,report_period_end,  date_type
, time_unit, disease_name,state AS reporting_jurisdiction,state, 'state' AS geo_unit, 'MN' AS geo_name, age_group
, 'total' AS disease_subtype, confirmation_status, outcome, sum(count) AS count
FROM measles_dat md
WHERE 1=1
GROUP BY report_period_start,report_period_end, disease_name,state, age_group, confirmation_status"
#combine measles data
Measles_final <-rbind(sqldf(group_string), measles_dat_weekly)
rm(measles_dat, measles_dat_weekly)
}

# Pertussis DATA ---------------------------------------
pertussis_dat <- subset(df, df$disease_name=="pertussis",
                        select = c("report_period_start", "report_period_end", "date_type","time_unit", "disease_name", "state", 
                                   "geo_name", "age_group", "confirmation_status", "outcome","count"))

#Create county totals
{group_string <-"SELECT report_period_start,report_period_end, date_type
, time_unit, disease_name,state AS reporting_jurisdiction,state, 'county' AS geo_unit, geo_name, 'total' AS age_group
, 'total' AS disease_subtype, confirmation_status, outcome, sum(count) AS count
FROM pertussis_dat pert
WHERE 1=1
GROUP BY report_period_start,report_period_end, disease_name,state, geo_name, confirmation_status"
pertussis_dat_weekly <-sqldf(group_string) 

#Create age group totals
group_string <-"SELECT report_period_start,report_period_end, date_type
, time_unit, disease_name,state AS reporting_jurisdiction,state, 'state' AS geo_unit, 'MN' AS geo_name, age_group
, 'total' AS disease_subtype, confirmation_status, outcome, sum(count) AS count
FROM pertussis_dat pert
WHERE 1=1
GROUP BY report_period_start,report_period_end, disease_name,state, age_group, confirmation_status"
pertussis_final <-rbind(sqldf(group_string),pertussis_dat_weekly)
rm(pertussis_dat, pertussis_dat_weekly)
}

# meningococcus DATA ---------------------------------------
 
meningococcus_dat <- subset(df, df$disease_name=="meningococcus",
                            select = c("report_period_start", "report_period_end", "date_type","time_unit", "disease_name", "state", 
                                       "geo_name", "age_group","disease_subtype", "confirmation_status", "outcome","count"))

#create County data
{group_string <-"SELECT report_period_start,report_period_end, date_type
, time_unit, disease_name,state AS reporting_jurisdiction,state, 'county' AS geo_unit, geo_name, 'total' AS age_group
, 'total' AS disease_subtype, confirmation_status, outcome, sum(count) AS count
FROM meningococcus_dat 
WHERE 1=1
GROUP BY report_period_start,report_period_end, disease_name,state, geo_name, confirmation_status"
meningococcus_dat_weekly <-sqldf(group_string) 

#Create age group totals
group_string <-"SELECT report_period_start,report_period_end, date_type
, time_unit, disease_name,state AS reporting_jurisdiction,state, 'state' AS geo_unit, 'MN' AS geo_name, age_group
, 'total' AS disease_subtype, confirmation_status, outcome, sum(count) AS count
FROM meningococcus_dat
WHERE 1=1
GROUP BY report_period_start,report_period_end, disease_name,state, age_group, confirmation_status"
meningococcus_dat_weekly<-rbind(sqldf(group_string),meningococcus_dat_weekly)

#Create Subtype totals
meningococcus_dat <- meningococcus_dat %>%
mutate(disease_subtype1 = case_when(
  grepl("SEROGROUP B", toupper(disease_subtype)) ~ "B",
  grepl("SEROGROUP A", toupper(disease_subtype)) ~ "A",
  grepl("SEROGROUP Y", toupper(disease_subtype)) ~ "Y",
  grepl("SEROGROUP C", toupper(disease_subtype))~ "C",
  grepl("SEROGROUP W", toupper(disease_subtype))~ "W",
  grepl("Unknown|Other", disease_subtype) ~ "unknown",
  grepl("NON-GROUPABLE", toupper(disease_subtype)) ~ "nongroupable",
  grepl("UNABLE", toupper(disease_subtype)) ~ "nongroupable",
  TRUE ~ "unknown"
))
group_string <-"SELECT report_period_start,report_period_end, date_type
, time_unit, disease_name,state AS reporting_jurisdiction,state, 'state' AS geo_unit, 'MN' AS geo_name, 'total' AS age_group
, disease_subtype1 AS disease_subtype, confirmation_status, outcome, sum(count) AS count
FROM meningococcus_dat
WHERE 1=1
GROUP BY report_period_start,report_period_end, disease_name,state, disease_subtype1, confirmation_status"
meningococcus_dat_weekly<-rbind(sqldf(group_string),meningococcus_dat_weekly)
}
#County suppression

meningococcus_dat_weekly <- meningococcus_dat_weekly %>%
    mutate(geo_name = case_when(
      (geo_unit==Suppression$geo_unit & count < Suppression$count)~ "unspecified",
      TRUE ~ geo_name
    ))
group_string <-"SELECT report_period_start,report_period_end,  date_type
, time_unit, disease_name, reporting_jurisdiction,state, geo_unit,  geo_name, age_group
, disease_subtype, confirmation_status, outcome, sum(count) AS count
FROM meningococcus_dat_weekly
WHERE 1=1
GROUP BY report_period_start,report_period_end, disease_name,state, geo_unit, geo_name,age_group, disease_subtype, confirmation_status"
meningococcus_dat_weekly<-sqldf(group_string)
rm(meningococcus_dat)

#To uncomment out, highlight selected code sections and then: ctrl+Shift+c
# # varicella DATA ---------------------------------------
# ped_flu_dat <- subset(df, df$disease_name=="pediatric flu mortality",
#                         select = c("report_period_start", "report_period_end", "date_type","time_unit", "disease_name", "state", 
#                                    "geo_name", "age_group", "confirmation_status", "outcome","count"))
# 
# #Create county totals
# {group_string <-"SELECT report_period_start,report_period_end, date_type
# , time_unit, disease_name,state AS reporting_jurisdiction,state, 'county' AS geo_unit, geo_name, 'total' AS age_group
# , 'total' AS disease_subtype, confirmation_status, outcome, sum(count) AS count
# FROM ped_flu_dat
# WHERE 1=1
# GROUP BY report_period_start,report_period_end, disease_name,state, geo_name, confirmation_status"
#   ped_flu_dat_weekly <-sqldf(group_string) 
#   
#   #Create age group totals
#   group_string <-"SELECT report_period_start,report_period_end, date_type
# , time_unit, disease_name,state AS reporting_jurisdiction,state, 'state' AS geo_unit, 'MN' AS geo_name, age_group
# , 'total' AS disease_subtype, confirmation_status, outcome, sum(count) AS count
# FROM ped_flu_dat
# WHERE 1=1
# GROUP BY report_period_start,report_period_end, disease_name,state, age_group, confirmation_status"
#   ped_flu_final <-rbind(sqldf(group_string),ped_flu_dat_weekly)
#   rm(ped_flu_dat, ped_flu_dat_weekly)
# }
# # varicella DATA ---------------------------------------
# varicella_dat <- subset(df, df$disease_name=="varicella",
#                    select = c("report_period_start", "report_period_end", "date_type","time_unit", "disease_name", "state", 
#                               "geo_name", "age_group", "confirmation_status", "outcome","count"))
# 
# #Create county totals
# {group_string <-"SELECT report_period_start,report_period_end, date_type
# , time_unit, disease_name,state AS reporting_jurisdiction,state, 'county' AS geo_unit, geo_name, 'total' AS age_group
# , 'total' AS disease_subtype, confirmation_status, outcome, sum(count) AS count
# FROM varicella_dat
# WHERE 1=1
# GROUP BY report_period_start,report_period_end, disease_name,state, geo_name, confirmation_status"
#   varicella_dat_weekly <-sqldf(group_string) 
#   
#   #Create age group totals
#   group_string <-"SELECT report_period_start,report_period_end, date_type
# , time_unit, disease_name,state AS reporting_jurisdiction,state, 'state' AS geo_unit, 'MN' AS geo_name, age_group
# , 'total' AS disease_subtype, confirmation_status, outcome, sum(count) AS count
# FROM varicella_dat
# WHERE 1=1
# GROUP BY report_period_start,report_period_end, disease_name,state, age_group, confirmation_status"
#   varicella_final <-rbind(sqldf(group_string),varicella_dat_weekly)
#   rm(varicella_dat, varicella_dat_weekly)
# }
# # mpox DATA ---------------------------------------
# mpox_dat <- subset(df, df$disease_name=="mpox",
#                     select = c("report_period_start", "report_period_end", "date_type","time_unit", "disease_name", "state", 
#                                "geo_name", "age_group", "confirmation_status", "outcome","count"))
# 
# #Create county totals
# {group_string <-"SELECT report_period_start,report_period_end, date_type
# , time_unit, disease_name,state AS reporting_jurisdiction,state, 'county' AS geo_unit, geo_name, 'total' AS age_group
# , 'total' AS disease_subtype, confirmation_status, outcome, sum(count) AS count
# FROM mpox_dat
# WHERE 1=1
# GROUP BY report_period_start,report_period_end, disease_name,state, geo_name, confirmation_status"
#   mpox_dat_weekly <-sqldf(group_string) 
#   
#   #Create age group totals
#   group_string <-"SELECT report_period_start,report_period_end, date_type
# , time_unit, disease_name,state AS reporting_jurisdiction,state, 'state' AS geo_unit, 'MN' AS geo_name, age_group
# , 'total' AS disease_subtype, confirmation_status, outcome, sum(count) AS count
# FROM mpox_dat
# WHERE 1=1
# GROUP BY report_period_start,report_period_end, disease_name,state, age_group, confirmation_status"
#   mpox_final <-rbind(sqldf(group_string),mpox_dat_weekly)
#   rm(mpox_dat, mpox_dat_weekly)
# }
# # Mumps DATA ---------------------------------------
# mumps_dat <- subset(df, df$disease_name=="mumps",
#                        select = c("report_period_start", "report_period_end", "date_type","time_unit", "disease_name", "state", 
#                                   "geo_name", "age_group", "confirmation_status", "outcome","count"))
# 
# #Create county totals
# {group_string <-"SELECT report_period_start,report_period_end, date_type
# , time_unit, disease_name,state AS reporting_jurisdiction,state, 'county' AS geo_unit, geo_name, 'total' AS age_group
# , 'total' AS disease_subtype, confirmation_status, outcome, sum(count) AS count
# FROM mumps_dat
# WHERE 1=1
# GROUP BY report_period_start,report_period_end, disease_name,state, geo_name, confirmation_status"
#  mumps_dat_weekly <-sqldf(group_string) 
#   
#   #Create age group totals
#   group_string <-"SELECT report_period_start,report_period_end, date_type
# , time_unit, disease_name,state AS reporting_jurisdiction,state, 'state' AS geo_unit, 'MN' AS geo_name, age_group
# , 'total' AS disease_subtype, confirmation_status, outcome, sum(count) AS count
# FROM mumps_dat
# WHERE 1=1
# GROUP BY report_period_start,report_period_end, disease_name,state, age_group, confirmation_status"
#   mumps_final <-rbind(sqldf(group_string),mumps_dat_weekly)
#   rm(mumps_dat, mumps_dat_weekly)
# }
# # Hep A DATA ---------------------------------------
# HAV_dat <- subset(df, df$disease_name=="hepatitis a",
#                         select = c("report_period_start", "report_period_end", "date_type","time_unit", "disease_name", "state", 
#                                    "geo_name", "age_group", "confirmation_status", "outcome","count"))
# 
# #Create county totals
# {group_string <-"SELECT report_period_start,report_period_end, date_type
# , time_unit, disease_name,state AS reporting_jurisdiction,state, 'county' AS geo_unit, geo_name, 'total' AS age_group
# , 'total' AS disease_subtype, confirmation_status, outcome, sum(count) AS count
# FROM HAV_dat
# WHERE 1=1
# GROUP BY report_period_start,report_period_end, disease_name,state, geo_name, confirmation_status"
#   HAV_dat_weekly <-sqldf(group_string) 
#   
#   #Create age group totals
#   group_string <-"SELECT report_period_start,report_period_end, date_type
# , time_unit, disease_name,state AS reporting_jurisdiction,state, 'state' AS geo_unit, 'MN' AS geo_name, age_group
# , 'total' AS disease_subtype, confirmation_status, outcome, sum(count) AS count
# FROM HAV_dat
# WHERE 1=1
# GROUP BY report_period_start,report_period_end, disease_name,state, age_group, confirmation_status"
#   HAV_final <-rbind(sqldf(group_string),HAV_dat_weekly)
#   rm(HAV_dat, HAV_dat_weekly)
# }
# # Hep b, acute DATA ---------------------------------------
# HBV_dat <- subset(df, df$disease_name=="acute hepatitis b",
#                   select = c("report_period_start", "report_period_end", "date_type","time_unit", "disease_name", "state", 
#                              "geo_name", "age_group", "confirmation_status", "outcome","count"))
# 
# #Create county totals
# {group_string <-"SELECT report_period_start,report_period_end, date_type
# , time_unit, disease_name,state AS reporting_jurisdiction,state, 'county' AS geo_unit, geo_name, 'total' AS age_group
# , 'total' AS disease_subtype, confirmation_status, outcome, sum(count) AS count
# FROM HBV_dat
# WHERE 1=1
# GROUP BY report_period_start,report_period_end, disease_name,state, geo_name, confirmation_status"
#   HBV_dat_weekly <-sqldf(group_string) 
#   
#   #Create age group totals
#   group_string <-"SELECT report_period_start,report_period_end, date_type
# , time_unit, disease_name,state AS reporting_jurisdiction,state, 'state' AS geo_unit, 'MN' AS geo_name, age_group
# , 'total' AS disease_subtype, confirmation_status, outcome, sum(count) AS count
# FROM HBV_dat
# WHERE 1=1
# GROUP BY report_period_start,report_period_end, disease_name,state, age_group, confirmation_status"
#   HBV_final <-rbind(sqldf(group_string),HBV_dat_weekly)
#   rm(HBV_dat, HBV_dat_weekly)
# }
# # Hep b, perinatal DATA ---------------------------------------
# HBV_peri_dat <- subset(df, df$disease_name=="perinatal hepatitis b",
#                   select = c("report_period_start", "report_period_end", "date_type","time_unit", "disease_name", "state", 
#                              "geo_name", "age_group", "confirmation_status", "outcome","count"))
# 
# #Create county totals
# {group_string <-"SELECT report_period_start,report_period_end, date_type
# , time_unit, disease_name,state AS reporting_jurisdiction,state, 'county' AS geo_unit, geo_name, 'total' AS age_group
# , 'total' AS disease_subtype, confirmation_status, outcome, sum(count) AS count
# FROM HBV_peri_dat
# WHERE 1=1
# GROUP BY report_period_start,report_period_end, disease_name,state, geo_name, confirmation_status"
#   HBV_peri_dat_weekly <-sqldf(group_string) 
#   
#   #Create age group totals
#   group_string <-"SELECT report_period_start,report_period_end, date_type
# , time_unit, disease_name,state AS reporting_jurisdiction,state, 'state' AS geo_unit, 'MN' AS geo_name, age_group
# , 'total' AS disease_subtype, confirmation_status, outcome, sum(count) AS count
# FROM HBV_peri_dat
# WHERE 1=1
# GROUP BY report_period_start,report_period_end, disease_name,state, age_group, confirmation_status"
#   HBV_peri_final <-rbind(sqldf(group_string),HBV_peri_dat_weekly)
#   rm(HBV_peri_dat, HBV_peri_dat_weekly)
# }
###Creates USDT Output file
final <- rbind(pertussis_final,Measles_final,meningococcus_dat_weekly)
##order by date
final <-final[order(final$report_period_start),]

#Generates the output file name and location
{ Output <-paste("disease_tracking_report_", jx, "_",Sys.Date(), ".csv", sep = "")
  #Select output file path and name  
  output.dir <- paste0(dlg_dir(title = "Select the folder where the file should output")$res, "/")
  usdt_Output<- paste(output.dir,Output, sep = "")
  
  for(i in dlg_message(message = paste0("Is this the file name you want to use: ", Output), "yesno")$res){
    if (i=="yes") usdt_Output
    else if (i=="no") {Output<-dlg_input(message = "Enter desired file name (with file extension)", default=Output)$res
    usdt_Output<- paste(output.dir,Output, sep = "")} 
  }
  csvFileName<- paste(output.dir,Output, sep = "")
  write.csv(final, file =csvFileName, na= "", row.names = FALSE)
}
}
####End####
