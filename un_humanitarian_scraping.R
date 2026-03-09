##______________________________________###
#                                         #
#           Web Scrapping                 #
#           Static Page                   #
#           UN Humanitarian               #
#                                         #
##______________________________________###

# Web Scraping with {rvest}-------------------------------

# We want to scrape 
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
pacman::p_load(rvest, dplyr, tidyverse, xml2)



#_________________NOTE__________________


# rvest package -------------

# The {rvest} package has a dependency on the {xml2} package 
# so will install it automatically. 
# Many functions in {rvest} will call {xml2} functions so 
# you do not need to library{xml2} to use {rvest}. 
# However, {xml2} has functions that are not used by {rvest} so 
# you may need to library it to use those functions 
#             e.g, `xml2::write_html()`.

#________________________________________________

# Steps for Scraping Data ---------------

# Once you have identified the elements you want to scrape and the CSS selectors to get them, the next step is to download the web page and scrape the content for those elements.

# We will use {rvest} and {xml2} package functions do three things:
  
# -   Access the web page,
# -   Extract the elements of interest, and,
# -   Convert the extracted elements into a data structure you can manipulate to tidy and clean the data for analysis.

# 1.  **Use `read_html()` to access the HTML document** (from a URL, an HTML file, or an HTML string) to create a copy in memory.
## -   Since `read_html()` is an {xml2} function, the result is a list object with class `xml_document`.

# 2.  **Use `html_element(doc, CSS)` or `html_elements(doc, CSS)` to select the element/elements you want** from the xml_document object with the CSS selectors you have identified.
## -   The result is a list object with class `xml_node` if one element is selected or, `xml_nodeset`, if more than one element is selected.

# 3.  Use the appropriate function to **Extract data from the selected elements**
## -   `html_name(x)`: extract the name of the element(s) (`xml_document`, `xml_node`, or `xml_nodeset`)
## -   `html_attr()` or `html_attrs()`: extract the attribute(s) of the element(s). The result is always a string so may need to be cleaned.
## -   `html_text2()`: extract the text inside the element with browser-style formatting of white space or `html_text()` for original text code formatting (which may look messy).
## -   `html_table()`: extract data structured as an HTML table. It will return a tibble (if one element is selected) or a list of tibbles (when multiple elements are selected).





#__________________________________________________


#Use `read_html()` to Access the Web Page Document.

# Use `read_html()` to create a variable with all the static content from a URL (or file or text).

# -   It's our local copy of the web page document.
# -   It may have embedded Java Script but it does not contain dynamic content such as ads that pop-up or are inserted on the web page.

#_________________________________________

# You can use different strategies for how to extract the elements of interest.

# -   Extract each element individually.
# -   Extract all of the elements at once.
# -   Extract a parent element to get all the children elements.
# -   Some combination of the above.

# Once you have extracted the data from the elements, you can use multiple approaches to tidy and clean the data.

#_________________NOTE__________________

# rvest 1.0.0 renamed a number of functions
# 
# xml_node() & html_node() -> html_element()

# xml_nodes() & html_nodes() -> html_elements()

#______________________________________________

un_html_obj <- read_html("https://www.un.org/en/our-work/deliver-humanitarian-aid")


un_html_obj |>
  class()

# We can use `xml2::write_html()` to save the web page object to a location.
xml2::write_html(un_html_obj, "./data/un_aid_web_page.html")

# -   We can use `read_htm()` to read it in as well from a path instead of a URL.
my_path <- "./data/un_aid_web_page.html"
un_html_obj <- read_html(my_path)


# -   Saving a static web page and reading it in allows us to scrape it without having to access the original site over the internet.
# -   The R object will have class `"xml_document" "xml_node`.

class(un_html_obj)


# The web page R object is an R list where the elements, here `$head` and `$body`, contain pointers to the elements in parts of the document.

#-   The web page document is the top level, single node, for the page so the parent class is `xml_node` instead of `"node_set"`.
#-   We can extract the element name and the attributes as well.


html_name(un_html_obj)
html_attrs(un_html_obj)


# Extract the elements we want from the `xml_document` object we just created.---------

## Use `html_element()` (we only have one element) with the CSS selector we found (`".col-sm-12.grey-well")`.

#-   Insert the CSS selectors as a character string (not a vector) as the value for the `css =` argument.

#    -   The `xpath` argument is not needed if `css =` has a value.

# -   The result will be an object of class `xml_node` since the CSS selects 1 element.


 html_element(un_html_obj, css = ".col-sm-12.grey-well") ->
  un_element_box
class(un_element_box)


# -   `html_name()` shows us the `name` of an element.


html_name(un_element_box)


# -   Here the name is just the HTML tag for a division, `div`.

# Extract the components of interest from the elements------------

# Now that we have an object with the elements of interest, we can extract the content.

# Here we want to extract the text.

# -   Use `html_text2()` to **extract the text from the selected elements** and save as a variable.
# -   The result will be a character vector (here length 4970).


un_box_text <- html_text2(un_element_box)
str_sub(un_box_text, end = 900)
str_length(un_box_text)

# We have "scraped" the data of interest and converted it into a character vector.

# However, as suspected, it is a lot of text with only new line characters to indicate any kind of structure It would take a lot of cleaning to figure this out.

# Instead, let's try selecting individual elements to see if that is better.

#_____________________________________________________


link <- "https://www.un.org/en/our-work/deliver-humanitarian-aid"


# Find the code by httr functions

GET(link) |>
  status_code()


# Find the code by httr2 functions

request(link) |>
  req_perform() |>
  resp_status()


# Both return 403 code
# 403 Forbidden --- The server understood your request, but it is refusing to allow it.
 # To Fix -- Add a User-Agent header

#  library(httr2)

resp <- request(link) |>
  req_user_agent("Mozilla/5.0 (Windows NT 10.0; Win64; x64)") |>
  req_perform()

resp |> resp_status()


# Now the code is 200
# 200 OK --- The request was successful and the page was retrieved.


#______________________________________________________

# 1) Define the target
url <- "https://www.un.org/en/our-work/deliver-humanitarian-aid"



# 2) Attempt to read the page
doc <- read_html(url)

# --- Did read_html() return something parseable? ---

# 3) Check the document object
str_glue("Class Object: ", str_c(class(doc), collapse = "-"))

# 4) Check for a root node
root <- xml2::xml_root(doc)
str_glue("Class Root: ", str_c(class(root), collapse = "-"))

# 5) Check the root node type and name
str_glue("Type Root: ",xml2::xml_type(root))
str_glue("Name Root: ",xml2::xml_name(root))



# - There is a response so there does not appear to be a credential issue.
# - The `doc` is an xml_document with a valid root node.
# - The root node is an HTML element (Name Root: html).
# - The request successfully reached the HTML layer, 
# returned a complete static page, and produced a usable DOM 
# with a valid structure so we can now try to parse to see 
# if the content is the correct page. 
