# Code to prepare `ologit` dataset

library(here)
library(haven)

ologit <- read_dta(here("data-raw", "ologit.dta"))

usethis::use_data(ologit, overwrite = TRUE)
