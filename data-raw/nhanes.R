## code to prepare `nhanes` dataset
library(tidyverse)
library(here)
library(haven)
library(janitor)
#library(skimr)

# Read in raw data

# Raw data files downloaded from https://wwwn.cdc.gov/nchs/nhanes/Search/DataPage.aspx?Component=Demographics&CycleBeginYear=2011
# Select fields used in UCLA workshop https://stats.idre.ucla.edu/r/seminars/survey-data-analysis-with-r/

# Read in demographic data
dem <- as_tibble(read_xpt(here("data-raw", "DEMO_G.stx"))) %>%
  select(c("SEQN", "RIDAGEYR", "RIAGENDR", "DMDMARTL", "DMDEDUC2",
           "DMDBORN4", "SDMVPSU", "SDMVSTRA", "WTINT2YR")) %>%
  # Recode RIAGENDER as 0=male, 1=female
  mutate(female = RIAGENDR-1,
         DMDBORN4 = na_if(na_if(DMDBORN4, 99),77)) %>%
  mutate(DMDBORN4 = ifelse(DMDBORN4==2, 0, DMDBORN4)) %>%
  clean_names()

# Read in health data
health <- as_tibble(read_xpt(here("data-raw", "HSQ_G.stx"))) %>%
  select(c("SEQN", "HSQ496", "HSQ571", "HSD010")) %>%
  mutate(HSQ496 = na_if(na_if(HSQ496, 99),77),
         HSQ571 = HSQ571-1) %>%
  clean_names()

# Read in physical activity data
phy <- as_tibble(read_xpt(here("data-raw", "PAQ_G.stx"))) %>%
  select(c("SEQN", "PAD630", "PAD675", "PAQ665", "PAD680")) %>%
  # Recode 9999 as NA
  mutate(PAD630 = na_if(PAD630, 9999),
         PAD680 = na_if(na_if(PAD680, 9999),7777)) %>%
  clean_names()

# Skim data to verify total count, missing, ranges, etc.
#skim(dem)
#skim(health)
#skim(phy)

# Join the data
nhanes <- left_join(left_join(dem, health, by="seqn"), phy, by="seqn")

usethis::use_data(nhanes, overwrite = TRUE)
