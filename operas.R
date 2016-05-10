# Homework: 
# (1) Nice chapter on data structures in R -- http://adv-r.had.co.nz/Data-structures.html
# (2) Web scraping in R -- http://dicook.github.io/Monash-R/5-Shiny
install.packages("rvest")
library(rvest)
# use this web address as the source of data
src <- read_html("https://operamission.org/handels-operas/")
# the CSS selector '.entry-content' was obtained using selector gadget
# http://selectorgadget.com/
# use only data within the node '.entry-content' from the source of data. this will result in one long string of characters 'txt'
txt <- src %>% html_node(".entry-content") %>% html_text()
# `str` stands for "structure" -- very useful for getting info about your data!
str(txt)
# split on line breaks ("\\\n")
# at this point I have a hard time understanding what's going on because I can't 'look at' the data... any suggestions? 
# has the one long string been split into many strings here?
# what is [[1]] here?
txtVec <- strsplit(txt, "\\\n")[[1]]
# remove empty strings (nchar = count the number of characters)
txtVec <- txtVec[nchar(txtVec) > 0]
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
txtVec[operaIDX] <- paste0("\n", txtVec[operaIDX])
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
