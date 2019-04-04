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
repo_url <- 'https://archive.ics.uci.edu/ml/machine-learning-databases/census1990-mld/'
data_str <- 'USCensus1990.data.txt'
data_raw_str <- 'USCensus1990raw.data.txt'

## Read with readr
t1 <- Sys.time()
if (!exists(census)) {
  census <- str_c(repo_url, data_str) %>% read_csv()
}
t2 <- Sys.time()
cat('Prepared data read time with readr:', t2-t1, 'mins')

t3 <- Sys.time()
if (!exists(census_raw)) {
  census_raw <- str_c(repo_url, data_raw_str) %>% read_tsv()  # lol good luck
}
t4 <- Sys.time()
cat('Raw data read time with readr:', t4-t3)

n <- dim(census)[1]

## Read manually when data is huge
t5 <- Sys.time()
census_raw_file <- file(str_c(repo_url, data_raw_str), open = 'r')
p <- length(str_split(readLines(census_raw_file, n = 1), '\t')[[1]])
close(census_raw_file)
census_raw_file <- file(str_c(repo_url, data_raw_str), open = 'r')
n_samp <- floor(n/100)  # What is a reasonable figure here? Why?
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
census_dt <- fread(str_c(repo_url, data_str))
t8 <- Sys.time()
cat('Prepared data read time with data.table:', t8-t7, 'seconds')  # WOW, right?


# Wide-to-long format

## Local easy example: job interview data
job_data_wide <- data.frame(candidate_id = 1:20,
                            interviewer1 = sample(5, 20, replace = T),
                            interviewer2 = sample(5, 20, replace = T),
                            interviewer3 = sample(5, 20, replace = T))
head(job_data_wide)
job_data_wide <- as_tibble(job_data_wide)
head(job_data_wide)
job_data_long <- job_data_wide %>% gather(key = interviewer,
                                          value = score,
                                          interviewer1:interviewer3)
job_data_long %>% spread(key = interviewer,
                         value = score)  # When would you want to do this?
## More challenging vignette: 
## https://rstudio-pubs-static.s3.amazonaws.com/282405_e280f5f0073544d7be417cde893d78d0.html


# dplyr
# We're barely scratching the surface of dplyr. Cheat sheets are your friend:
# https://www.rstudio.com/wp-content/uploads/2015/02/data-wrangling-cheatsheet.pdf

## Summarizing
job_data_long %>% summarize(avg_score = mean(score))  # unhelpful

job_data_long %>% count(score)  # helpful
job_data_long %>% count(score) %>% select(n) %>% chisq.test()  # Piping works everywhere!

## Filtering, grouping, and selecting
job_data_long %>% filter(interviewer == 'interviewer1')

job_data_long %>% 
  group_by(candidate_id) %>%
  summarize(avg_score = mean(score))  # grouping helped!

job_data_long %>% 
  group_by(candidate_id) %>%
  summarize(avg_score = mean(score)) %>%
  select(avg_score) %>% qqnorm()  # tibbles are lists of tibbles; data.frames are lists of vectors

job_data_long %>% 
  group_by(candidate_id) %>%
  summarize(avg_score = mean(score)) %>%
  pull(avg_score) %>% qqnorm()  # pull gets the vector, so this one doesn't crash

(job_data_long %>% 
  group_by(candidate_id) %>%
  summarize(avg_score = mean(score)) %>%
  select(avg_score))[[1]] %>% qqnorm()  # can also use [[1]] but it's ugly

job_data_long %>%
  group_by(candidate_id) %>%
  count(score)  # rouping hurt! 

## Refactoring
job_data_long$score <- as_factor(job_data_long$score)  # tidyverse not always great
job_data_long$score <- as.factor(job_data_long$score)  # R sometimes great
job_data_long$score[job_data_long$score == 1] <- 'Terrible'  # R not always great
job_data_long$score[is.na(job_data_long$score)] <- 1  # TODO: tidyverse-ify
job_data_long$score <- job_data_long$score %>% recode(`1` = 'Terrible',
                                                      `2` = 'Bad',
                                                      `3` = 'Okay',
                                                      `4` = 'Good',
                                                      `5` = 'Amazing')  # tidyverse sometimes great

job_data_long$interviewer <- job_data_long$interviewer %>% recode('interviewer1' = 1,
                                                                  'interviewer2' = 2,
                                                                  'interviewer3' = 3)


# Challenge Questions

## data munging

### Rewrite the line of code commented "TODO: tidyverse-ify" using tidyverse
### syntax instead of base R

### Using https://archive.ics.uci.edu/ml/machine-learning-databases/census1990-mld/
### determine the fraction of people 40 and older who speak fluent English

## long/wide

### Using the following hospital data, determine the average number of days patients
### suffering from injury or poisoning spent in the hospital in each year from 1993-1998.
### Also, make a chart showing the proportion of hospital bed usage for each of the 19
### care types (including "not reported") aggregated over all years observed. If you need
### help, see
### https://rstudio-pubs-static.s3.amazonaws.com/282405_e280f5f0073544d7be417cde893d78d0.html
hospital <- read_csv("http://www.mm-c.me/mdsi/hospitals93to98.csv")

## prediction

### The "dPoverty" variable in the census data has 3 levels: 0, 1, and 2. Go to
### https://archive.ics.uci.edu/ml/machine-learning-databases/census1990-mld/
### and determine which of the 3 levels should be ignored, which indicates poverty,
### and which indicates not-poverty (You can also figure it out just by looking at
### the data itself!). Drop the appropriate value from the data, then set aside a
### randomly selected 10% of the census data for testing. Using the remainder, build
### a model that discriminates between poverty and non-poverty, and test it on the test
### set, and let me know what classification accuracy you get. Winner may get a prize!
### Hint: no one is forcing you to use ALL the available training data.
