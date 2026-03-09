##_____________________________###
#                                #
#  Web Scrapping             #
#                                #
##_____________________________###

# Web Scraping with {rvest}-------------------------------

# We want to scrape one page from IMDB top 100 movies of all time.
#  You need to instal _____selectorgadget chrome extension________

# It gives you the CSS tag for different element on web pages.
# You need that to web scraping element from the webpage.

## HTML (Hypertext Markup Language) ------
# It is a text-based approach to describing how content 
# contained within an HTML file is structured. 
# This markup tells a web browser how to display text,
# images and other forms of multimedia on a webpage.
##_____ Example ______##
#            <p>Hello World</p>

#          HTML cannot be used in a CSS file.
#___________________________________________________________


## CSS (Cascading Style Sheets) -------- 
# Like HTML, CSS is not a programming language.
# It's not a markup language either. CSS is a style sheet
# language. CSS is what you use to selectively style 
# HTML elements.
##_____ Example ______##
#            header{ background-color: green;
#          CSS can be used in an HTML file.
##___________________________________________________________

### What is difference between HTML and CSS?-----
# HTML is a markup language used to create static web pages
# and web applications. CSS is a style sheet language
# responsible for the presentation of documents written
# in a markup language.


# Install and load the packages
# rvest for scraping and dplyr for piping

  if (!require("pacman")) install.packages("pacman")

# Load contributed packages with pacman
pacman::p_load(rvest, httr2, dplyr, tidyverse, xml2)



#_________________NOTE__________________
#_________________NOTE__________________

# rvest 1.0.0 renamed a number of functions
# 
# xml_node() & html_node() -> html_element()

# xml_nodes() & html_nodes() -> html_elements()

##__________________________________
##__________________________________
##__________________________________

# Several quick checks to confirm if you can access the IMDb HTML layer.

# SCRAPE From One Page ------------------------------------

# Now we are going to make a new variable for the link

link <- "https://www.imdb.com/list/ls055592025/"

page <- read_html(link)  # it gets HTML code from web page


# We recived an error . That suggest that the instructure of the page has been changed. 
# One of the challange we are facing with scraping is the instructure page will change frequently.
# So the code you wrote before may not working, so you need to the adjustment

# The question is now how to fix the issue? -------

## Fix the updated page -----------------
# Now the page stucture has been changed and as you saw the last year code did not work
# How to fix?
link <- "https://www.imdb.com/list/ls055592025/"

# Find the code by httr functions

GET(link) |>
  status_code()


# Find the code by httr2 functions. ( This is a new package, so we will use this instead of httr)

request(link) |>
  req_perform() |>
  resp_status()

# Both return 202, which means
## 202 Accepted → The request was received, but it has not been completed yet.


## To fix, we add a browser called header ------------

#    library(httr2)

resp <- request(link) |>
  req_user_agent("Mozilla/5.0 (Windows NT 10.0; Win64; x64)") |>
  req_headers(`Accept-Language` = "en-US,en;q=0.9") |>
  req_perform()

resp |> resp_status()

# Now the code is 200
# 200 OK --- The request was successful and the page was retrieved.

# Start Scraping -----------------------

## Step 1: Read the html file------

page <- resp |> 
  resp_body_string() |> 
  read_html()
# We called it page
page

# Check its class

page |>
  class()

## Step 2: Create columns (scrape Vectors of interest) -----

# Let us scrape "name",  "rating", "meta score", "cast",
#                "director", and "synopsis"

#          Create the columns
###________________________________
                             ### name ------------
###________________________________
#__________________ 1.  NAME ________________________________________
# First create the name- Which is the title of the movie



#__________________________________________
# You need the tag for the title
     # here is where the "selectorgadget" becomes useful
                    # click on the selector gadget icon on top of page (IMBD.com)
                    # now if you move moues around on the window,
#                   # you will see different boxes start to select/highlite
#                   # we select a title. By clicking on it. It will be turn green
                    #You'll see a lot of thing s turnyellow
#                   # Since we only want the title then we deselect the one that we don't need 
#                   # by clicking on it. Then it turns out red

#                   # Then you will see all titles on that page is yellow. 
#                   # You need to check each time to make sure what you need is selected

#                   # we know there are 100 movies on this webpage. If you look at the bottom of
                    # the apge you see on the box on bottom it says
                    #  '.lister-item-header a.`  `clear(100)`  which indicates it has selected 100 titles

#                   # The tag that we are looking for is on the first thing at bottom of the page
#                   # You need to copy the tag
                    #       .lister-item-header a
                    # paste it inside the html_elements()

name <- page %>% html_elements(".ipc-title-link-wrapper .ipc-title__text") %>% 
  html_text()

name


# html_elements() ---> select parts of the documents using CSS selectors. This will give
# the HTML source code pull out the actual elements that we want to grab

# html_text() select the text part of the element, (This is what you need)
#________________________________
 
###________________________________
         ##### How to find elements without Selector Gadget?-----
###________________________________

# If we want to find this without gadget selector
# 1. Write click on the webpage, selct "inspect: 
# move curser on  till you see the title being highlited
# select the element that is shown. You may need to do some adjustment

page |>
  html_elements(".ipc-title__text") |>
  html_text() ->
  title

title

# As you can see the last two entries are extra and they are not part of the names.
# They must be removed

title[-c(length(p)-1, length(p))] ->
  title

title

#_______________________________

###________________________________
                              ### year ----- 
###________________________________

year <- page %>%    
  html_elements(".dli-title-metadata-item:nth-child(1)") %>%
  html_text() 

year


parse_number(year)

###________________________________
                              ### rate ------
###________________________________
rate <- page %>%    
  html_elements(".dli-ratings-container") %>%
  html_text() 

rate
# It returns something like
#                     "9.2 (2.2M)Rate"
# But we want only the number part, 
# so if you parse it numericaly it will return what you were looking for
#_____________
# For example
x <- c("9.2 (2.2M)Rate", "8.5 (1.5M)Rate")
x     # it returns ------- "9.2 (2.2M)Rate" "8.5 (1.5M)Rate"


 parse_number(x)    # It returns ------  9.2 8.5

#_____________

rate %>% 
  parse_number() ->
  rate

rate


###________________________________
                             ### meta_score ------
###________________________________

meta_score <- page %>% 
  html_elements(".metacritic-score-box") %>%
  html_text()

meta_score

###________________________________
                              ###  cast -----------
###________________________________

cast <- page %>% 
  html_nodes("span+ span .title-description-credit .ipc-link--base") %>%     
  html_text()

cast

#### There is a one issue with number or rows -----
# We re getting 75 rows because each star is extracted separately. 
# What you want is to group every 3 stars into one row (one movie).

#### THERE ARE TWO WAYS TO HANDLE THIS ------
##### METHOD 1 by tidyverse -----
cast_group <- tibble(
  movie = rep(name, each = 3),
  cast = cast
) %>%
  group_by(movie) %>%
  mutate(star_id = row_number()) %>%
  pivot_wider(names_from = star_id, values_from = cast,
              names_prefix = "star") |>
  ungroup()

cast_group

# The column movie has been repeated here, so we need to remove it

cast_group <- cast_group |>
  select(- movie)

cast_group


##### METHOD 2 by base R packages -------

cast_df <- as.data.frame(matrix(cast, ncol = 3, byrow = TRUE))
# it creates 3 columns of size 25

colnames(cast_df) <- c("star_1", "star_2", "star_3")

cast_df

### It Seems taking care of the problem with base R is easier than with tidyverse.

###________________________________
                                ### director ------
###________________________________

director <- page %>% 
  html_nodes("span:nth-child(1) .ipc-link--base") %>%     
  html_text()

director

#### There is an issue some movies have more than one director------
## Unlike the cast, you cannot assume a fixed number of directors (like 3).
## So the matrix() trick will not work here.


#### One easy approach-----
# You mau want to check the page quicly and find which movies have more than one directors
# movies 8 has 3 directors
# Movie 19 has 2 directors and the rest have 1

# Number of directors per movie
directors_per_movie <- rep(1, 25)  # start with 1 per movie
directors_per_movie[8] <- 3        # movie 8 has 3 directors
directors_per_movie[19] <- 2       # movie 19 has 2 directors

# Split the flat director vector into a list per movie
directors_list <- split(director, rep(1:25, times = directors_per_movie))

# Create tibble: one row per movie, all directors in one cell
director_group <- tibble(
  directors = map_chr(directors_list, ~ paste(.x, collapse = ", ")
                      )
)



director_group


#### Another approach-----
# We may to select only main director, go to the movie has the more than one
#  director and deselect them

one_director <- page %>% 
  html_nodes("span:nth-child(1) .chvWbP+ .title-description-credit .ipc-link--base") %>%     
  html_text()

one_director

## I will both of the methods is the final tibble for you to comapre.

###________________________________
                              ### Synopsis ------
###________________________________

synopsis <- page %>% 
  html_nodes(".title-description-plot-container .ipc-html-content-inner-div") %>%     
  html_text()

synopsis


## Step 3: Create the data frame ---------------------
top_movies <- tibble(name, 
                     year, rate, 
                     meta_score, 
                     director_group,
                     one_director,
                     cast_df,
                     synopsis)

glimpse(top_movies)

## Step 4: Convert the variables to appropriate types ------
top_movies %>% 
  mutate(
    year = parse_number(year),   # since it is only year so numeric value is good
    meta_score = parse_number(meta_score)
         ) ->
  top_movies



View(top_movies)
head(top_movies)

## Step 4: Saved the file ---------
# Save the file
write.csv(top_movies, "./data/top_movies.csv")



