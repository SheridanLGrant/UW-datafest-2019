# Exploring "big" US Census data
# Your name here
# 4/3/2019


# Packages (install.packages() if you don't have them)
library(tidyverse)
library(data.table)


# Memory limit, CPUs
memory.limit()
memory.limit(16000)


# Import Data

## TODO: what happens if not enough memory?

repo_url <- 'https://archive.ics.uci.edu/ml/machine-learning-databases/census1990-mld/'
data_str <- 'USCensus1990.data.txt'
data_raw_str <- 'USCensus1990raw.data.txt'
t1 <- Sys.time()
if (!exists(data_str)) {
  census <- str_c(repo_url, data_str) %>% read_csv()
}
t2 <- Sys.time()
cat('Prepared data read time with readr:', t2-t1, 'mins')
t3 <- Sys.time()
if (!exists(data_str)) {
  census_raw <- str_c(repo_url, data_raw_str) %>% read_tsv()  # lol good luck
}
t4 <- Sys.time()
cat('Raw data read time with readr:', t4-t3)

n <- dim(census)[1]

## TODO: read random subset of observations
t5 <- Sys.time()
census_raw_file <- file(str_c(repo_url, data_raw_str), open = 'r')
p <- length(str_split(readLines(census_raw_file, n = 1), '\t')[[1]])
close(census_raw_file)
census_raw_file <- file(str_c(repo_url, data_raw_str), open = 'r')
n_samp <- floor(n/100)
census_raw <- matrix(nrow = n_samp, ncol = p)
ind_samp <- sample(n, n_samp)
i <- 1
j <- 1
while(length(currentLine <- readLines(census_raw_file, n = 1)) > 0) {
  if (i %in% ind_samp) {
    census_raw[j,] <- str_split(currentLine, '\t')[[1]]
    j <- j+1
  }
  i <- i+1
  if (i %% 1000 == 0) print(i)
}
t6 <- Sys.time()
cat('Raw data subsample manual read time:', t6-t5, 'mins')
write_csv(census_raw, 'C:/Users/Sheridongle/Desktop/census_raw.csv')


# Data.table, fread, sorting
t7 <- Sys.time()
census <- fread(str_c(repo_url, data_str))
t8 <- Sys.time()
cat('Prepared data read time with data.table:', t8-t7, 'seconds')


# Wide-to-long format


# dplyr


# Challenge questions: counting complex subsets by group, etc.
