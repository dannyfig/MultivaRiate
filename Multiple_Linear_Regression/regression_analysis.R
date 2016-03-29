# Author: Danny Vilela
# Date: 30 March 2016
#   This script will serve to clean, validate, and filter the values 
#   that are relevant for the multiple linear regression task.
#

# Define required packages
require(ggplot2)
require(car)

###############
## SETUP I/O ##
###############

# Prepare an output file to append all of our text output
sink("results", append = TRUE, split = TRUE)

## Read in our songs text file with pipes as delimiters
song_data <- read.delim("songs.txt", sep = "|")

## Contain our 11-feature text data in a data frame
data_frame <- data.frame(song_data)

## Write our data frame to an easy-to-use CSV
write.csv(data_frame, file = "songs.csv")

# Read our song data into a data frame
df <- read.csv("songs.csv", head = TRUE)

# Convert our CSV to a data frame and attach it to our session's scope
df <- data.frame(df)

###################################
## DATA VALIDATION / CLEANING UP ##
###################################

# Remove unnecessary "X" column
df$X <- NULL

# Only look at songs from 2010 and onwards 
# Note: chart.date column format is YYYYMMDD -- as a single integer
after_2010 <- data.frame(df[(df$chart.date > 20100000),])

# Generate sample CSV file
write.csv(after_2010, file = "songs_after_2010.csv")

# Keep all other decades separate
# after_2000_before_2010 <- df[(df$chart.date > 20000000 & df$chart.date < 20100000),]
# after_1990_before_2000 <- df[(df$chart.date > 19900000 & df$chart.date < 20000000),]
# after_1980_before_1990 <- df[(df$chart.date > 19800000 & df$chart.date < 19900000),]
# after_1970_before_1980 <- df[(df$chart.date > 19700000 & df$chart.date < 19800000),]
# after_1960_before_1970 <- df[(df$chart.date > 19700000 & df$chart.date < 19800000),]
# after_1950_before_1960 <- df[(df$chart.date > 19700000 & df$chart.date < 19800000),]
# after_1940_before_1950 <- df[(df$chart.date > 19700000 & df$chart.date < 19800000),]

#########################
## FEATURE ENGINEERING ##
#########################

# Create new column, "artist.appearances"


