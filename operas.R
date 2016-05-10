# Homework: 
# (1) Nice chapter on data structures in R -- http://adv-r.had.co.nz/Data-structures.html
# (2) Web scraping in R -- http://dicook.github.io/Monash-R/5-Shiny
# (3) Git/Github/RStudio -- http://r-pkgs.had.co.nz/git.html
install.packages("rvest")
library(rvest)
# use this web address as the source of data
src <- read_html("https://operamission.org/handels-operas/")
# the CSS selector '.entry-content' was obtained using selector gadget
# http://selectorgadget.com/
# use only data within the node '.entry-content' from the source of data. this will result in one long string of characters 'txt'
nodez <- html_nodes(src, ".entry-content p")
# sapply is like lapply, but will coerce the list to a character vector
txtVec <- sapply(nodez, html_text)
str(txtVec)

# BTW, the above can be written a bit more elegantly:
# txtVec <- read_html("https://operamission.org/handels-operas/") %>%
#   html_nodes(".entry-content p") %>%
#   sapply(html_text)

# remove everything before the line starting with 'HWV 1:' ("HWV 1:" minus 1)
# what exactly is ^ in grep? how would you request any string that *includes* "HWV 1:"?
idx <- grep("^HWV 1:", txtVec) - 1
# seq = generate a sequence
# can't remember how '-' is working here...
txtVec <- txtVec[seq(-1, -idx)]
# identify strings with opera names
# find anything that starts with 'HWV' followed by numbers and (possibly) letters followed by a colon
# whats is [-1] here?
operaIDX <- grep("^HWV [0-9]+[a-z]?:", txtVec)[-1]
# paste together at line breaks '\n"
# what is the benefit of using paste0 here? not sure what the alternative (paste) would look like
txtVec[operaIDX] <- paste("\n", txtVec[operaIDX], sep = "")

# create a list where each element is a character vector with info for a particular opera
# split the string into a list of strings and separate them by tabs '\t'
ops <- strsplit(paste(txtVec, collapse = "\t"), "\\\n")[[1]]
# lapply(x) = return a list of the same length as x
# I don't really get what's going on in this following line...
operas <- lapply(ops, function(op) {strsplit(op, "\\\t")[[1]]})
# check out a particular opera
operas[[1]]
operas[[11]]
# yikes
# sapply(x) = return a vector of the same length as x...?
sapply(operas, length)

library(RNeo4j)
# TODO: put in a link to the graph here
graph <- startGraph("")

for (i in seq_along(operas)) {
  op <- operas[[i]]
  # title should always be the 1st element in the character vector for this opera
  title <- op[1]
  notes <- op[grep("^[nN]ote[s]?:", op)]
  createNode(graph, "Opera", title = title, notes = notes)
}


# how to transform a record into a neo4j node with attributes?
# title - everything after the colon in the first value of the list, may include info about the version
# notes - begins with "Notes:" OR sometimes the value following that one
# sometimes notes are actually about a specific run
# HWV - everything before the colon in the first value of the list
# HG - between "HG edition:" and ";"
# HHA -  everything after "HHA edition:"
# date of completion (fuzzy dates need to be captured)
# how to capture info about a libretto based on an earlier libretto?
# opera 10 (Terpsicore) is actually a ballet... needs to be a different type of node
# how to pull out characters & create nodes for those? performers? composers? librettists? runs? borrowings?
