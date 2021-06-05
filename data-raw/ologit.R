# Code to prepare `ologit` dataset

library(here)
library(haven)
library(dplyr)
library(magrittr)

ologit <- read_dta(here("data-raw", "ologit.dta")) %>%
  mutate(apply=factor(apply, labels=c("unlikely", "somewhat likely", "very likely")),
         pared=factor(pared, labels=c("0", "1")),
         public=factor(public, labels=c("0", "1")))

usethis::use_data(ologit, overwrite = TRUE)

