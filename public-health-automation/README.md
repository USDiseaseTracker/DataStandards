# Public Health Automation Files

This directory contains code for public health agencies (PHAs) to automate clean up and formatting to the U.S. Disease Tracker (USDT) Standard.

## Available Code

### R

The R code takes an input file, modifies field names, cleans the data, and exports. This code utilizes a metadata file to map the input file header names to the appropriate USDT format and file naming convention. The R code is set up to allow users to select input files and output locations without modifying the code.

#### Initial R Setup

   These steps need to be completed prior to initial use of the R code.
   1. Open up the Metadata file
   2. Download and install RStudio
   a. RStudio Basics can be found here:
   3. Open up usdt_file_cleaning.R
    <br>
##### 1. Open up the Metadata file
 - **Variable tab:** Fill in the column, EDSS_name, with the column header that best aligns from the PHA's input file. If you do not have an input column that matches, leave the EDSS_name cell blank. EXCEPTION: 'Episode date' is not a USDT variable. However, if your jursidiction includes only one date field that then needs to be translated to MMWR start and end dates, place the column header for the date field here in the EDSS_name column.
  - **disease_name tab:** Fill in the column, EDSS_name with the disease names that will be a part of your USDT file submission that best aligns from the PHA's input file. If you do not have an input column that matches, leave the EDSS_name column blank. If new conditions are added, copy over the the exact acceptable text for the disease and confirmation status as new rows.
  - **Suppression tab:** to add suppression, fill in the columns as followed:
     -  **Disease:** copy the disease name that is **required for the USDT import file.** DO NOT use the disease name from your surveillance system
     -   **geo_unit:** For county suppression, type 'county' in to indicate that the suppression is only at the county level, else leave blank.
     -   **count:** Only place a numeric value here. The value should be the value placed behind a 'less than' symbol. For example, if suppression needs to be a < 5, place the number 5 here.
  -  **geo tab:** Fill in the column,  EDDS_name, with the geographical names that will be used in the PHA input file. In the column, USDT_Geo_Name, input the correct value of the geographical name provided to the USDT Team in your original metadata file. If you are mapping multiple counties to a region, place each county name in it's own row and repeat the region name in the USDT_Geo_Name column for each row.
  - **default tab:** Fill in the column,  input, with the necessary information. Use the column, description_of_USDTField, to identify the appropriate value.

##### 2. Download and install R Studio
   RStudio https://posit.co/downloads
   Check with your agency if this is available through a localized software center

##### 3. Open up usdt_file_cleaning.R

   Once RStudio is installed, open up the file and run the first line of code "install.packages("tidyverse", "svDialogs", "readr", "MMWRweek","lubridate", "readxl","plyr","dplyr", "sqldf")" This will install all required libraries that will allow the R code to run appropriately.
