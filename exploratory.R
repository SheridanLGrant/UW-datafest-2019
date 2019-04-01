# Exploring "big" US Census data
# Your name here
# 4/3/2019


# Packages (install.packages() if you don't have them)
library(tidyverse)


# Import Data
repo_url <- 'https://archive.ics.uci.edu/ml/machine-learning-databases/census1990-mld/'
data_str <- 'USCensus1990.data.txt'
data_raw_str <- 'USCensus1990raw.data.txt'
if (!exists(data_str)) {
  census <- str_c(repo_url, data_str) %>% read_csv()
}
if (!exists(data_str)) {
  census_raw <- str_c(repo_url, data_raw_str) %>% read_csv()
}
