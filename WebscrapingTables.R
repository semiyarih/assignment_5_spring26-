



# More Webscraping Retrieving data tables from the 
# internet

#install.packages("rvest")
library(rvest)
library(tidyverse)
library(dplyr)

# example 1

wikiurl <- read_html(
  "https://en.wikipedia.org/wiki/List_of_highest-grossing_films")
datatables <- wikiurl%>%
  html_table(., fill = T)

datatables[[4]] -> dt
dt


# example 2

wikiurl <- read_html(
  "https://www.worldometers.info/world-population/population-by-country/")
datatables1 <- wikiurl%>%
  html_table(., fill = T)

datatables1[[1]] -> dt1
dt1

print(dt1, n = 100)





# example 3   PLAY BALL !!

wikiurl <- read_html("https://www.mlb.com/stats/2019")
baseballdata2019 <- wikiurl%>%
  html_table(., fill = T)

baseballdata2019[[1]] -> BD2019
BD2019
# Let's print all 25 rows
BD2019%>%
  print(n = 25)

# Let's print the mean number of homeruns hit
mean(BD2019$HRHR)

# Let's find a linear model for number at bats vs home runs
lm(ABAB ~ HH, BD2019)

# Let's change the data table to a data frame

BD2019 <- data.frame(baseballdata2019[[1]])
BD2019

# ( the tibble representation is probably better)

# One more for good luck !!   California Dreaming!!

wikiurl <- read_html(
  "https://www.california-demographics.com/cities_by_population")
Californiacities <- wikiurl%>%
  html_table(., fill = T)

Californiacities[[1]] -> ct
ct

# Arrange the cities in alphabetical order and show 
# the first 50 rows

ct%>%
  select(City,Population)%>%
  arrange(City)%>%
  print(n = 50)

