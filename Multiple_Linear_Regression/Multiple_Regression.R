# Author: Danny Vilela
# Date: 30 March 2016
#   This script will serve to clean, validate, and filter the values 
#   that are relevant for the multiple linear regression task.
#

# Define required packages
require(car)

###############
## SETUP I/O ##
###############

# Prepare an output file to append all of our text output
# sink("results", append = TRUE, split = TRUE)

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

# If a song is debuting this week, we don't want its :last.week column to be
# the string "NEW", and so we replace it with the value 101
df$last.week[df$last.week == "NEW"] <- 101

# Create new columns in order to track information about the artists behind our songs
df["concurrent.count"] <- 0
df["artist.relevancy"] <- 0

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

## 
# Determine our concurrent_count predictor, which is the number of songs our 
# artist currently has in the top 100 for each top 100 chart entry in our time frame
# * NOTE: this is computationally expensive and requires quite a bit of time. *
##

# Get all unique dates within our time frame
unique_chart_dates <- unique(after_2010$chart.date)

# Determine the number of rows within our original time frame -- will be used
# for iteration count
after_2010_rows <- dim(after_2010)[1]

# For every unique chart date
for (unique_date in unique_chart_dates) {

  print(paste("Working on date", unique_date))

  # Get the hot 100 for our current :unique_date, which is a subset of
  # our time frame dataset; also get the number of rows (which will be 100),
  # but just to keep things general we use dim()
  hot_100 <- after_2010[which(after_2010$chart.date == unique_date),]
  hot_100_rows <- dim(hot_100)[1]

  # Get a vector of unique artists within our hot 100
  unique_artists <- unique(hot_100$artist)

  # Cycle through every artist in that vector
  for (unique_artist in unique_artists) {

    # Get all songs on hot 100 where our :unique_artist is mentioned in artist field
    artists_concurrent_songs <- hot_100[which(grepl(unique_artist, hot_100$artist)),]

    # Get the unique songs based on song title. Then, assign
    # :concurrent_unique_songs to the length of that unique vector.
    # This tells us the number of distinct songs a distinct artist has on the
    # hot 100.
    concurrent_unique_songs <- length(unique(artists_concurrent_songs$title))

    # Write our concurrent value into our hot 100 table's concurrent.count column
    # wherever we find our unique artist mentioned
    hot_100$concurrent.count[grepl(unique_artist, hot_100$artist)] <- concurrent_unique_songs
  }

  # Now that we've populated our hot 100 table with concurrent occurences,
  # it's time to write those values into our time frame data table

  # Cycle through each row in our top 100 (this looks familiar)
  for (row in 1:hot_100_rows) {

    # Isolate and modularize information about our row
    current_row <- hot_100[row,]

    # Cycle through each row in our time frame data table
    for (global_row in 1:after_2010_rows) {

      # Isolate and modularize information about our row
      current_global_row <- after_2010[global_row,]

      # If the date, artist name, and song match up, we write our concurrent count
      # into our time frame's data table and break, because there's no need to
      # keep iterating. Note: we could omit our comparison between song title,
      # but we keep it in because I off-hand think it'll be less expensive
      # to match one song to itself and break than continue and failing this
      # comparison much more often.
      if ((current_row$chart.date == current_global_row$chart.date) && (current_row$artist == current_global_row$artist) && (current_row$title == current_global_row$title)) {
        after_2010[global_row, 12] <- current_row$concurrent.count
        break
      }
    }
  }
}

##
# Determine our artist_relevancy predictor, which is the number of unique
# songs any particular artist debuts into the top 100 over our time frame
##

# Get vector of artists from our time frame data 
# table such that we have no repetitions
unique_artists <- unique(after_2010$artist)

# Cycle through each unique artist
for (unique_artist in unique_artists) {
  
  # print(paste("Working on artist ", unique_artist))
  
  # Identify and isolate all instances where our artist is mentioned as an 
  # artist in a song
  all_artists_songs <- after_2010[which(grepl(unique_artist, after_2010$artist)),]
  
  # Since we will have multiple duplicate songs, make sure we're only looking
  # at unique songs. Then, get the length of that unique song vector and
  # we have the total number of songs that our artist has appeared on within
  # our timeframe. Pretty neat, I have to say.
  unique_songs_released <- length(unique(all_artists_songs$title))
  
  # Write our value stored in unique_songs_released at any location within
  # our data table's artist.relevancy column where that row's artist is the 
  # same as the artist whose song count we just computed.
  after_2010$artist.relevancy[after_2010$artist == unique_artist] <- unique_songs_released
}

# Save our data! We just did a heck of a lot of work.
write.csv(after_2010, "calculated_songs.csv")

###################
## DATA ANALYSIS ##
###################

# Open device for saving grid of plots
png(filename = "pairs.png")

# Plot all pairs 
pairs(~overall.peak + last.week + peak + weeks.on.chart +
      entry.position + artist.relevancy, data = after_2010,
      main = "Simple Scatterplot Matrix")

# Close our PNG filewriter
dev.off()

# Open device for saving plot
png(filename = "weeks_v_overall_peak.png")

# Plot relationship between a song's weeks on the chart versus 
# its current peak position
plot(after_2010$weeks.on.chart, after_2010$overall.peak, 
     xlab = "Number of weeks on chart", ylab = "Overall peak")

# Close our PNG filewriter
dev.off()

# Determine correlation values between each of our predictors
# Output to standard output
cor(cbind(after_2010$overall.peak, after_2010$last.week, after_2010$peak, after_2010$weeks.on.chart, after_2010$entry.position, after_2010$artist.relevancy))

# Determine regression influence
prediction_a <- lm(after_2010$overall.peak ~ after_2010$last.week + after_2010$peak + after_2010$weeks.on.chart + after_2010$entry.position + after_2010$artist.relevancy)

# Output summary statistics for our linear regression
summary(prediction_a)

library(car)
vif(prediction_a)

##
# Perform best subsets using the leaps() function with different methods
##
library(leaps)
leaps(cbind(after_2010$last.week, after_2010$peak, after_2010$weeks.on.chart, after_2010$entry.position, after_2010$artist.relevancy), after_2010$overall.peak, nbest = 2)
leaps(cbind(after_2010$last.week, after_2010$peak, after_2010$weeks.on.chart, after_2010$entry.position, after_2010$artist.relevancy), after_2010$overall.peak, nbest = 2, method = "adjr2")
leaps(cbind(after_2010$last.week, after_2010$peak, after_2010$weeks.on.chart, after_2010$entry.position, after_2010$artist.relevancy), after_2010$overall.peak, nbest = 2, method = "r2")

library(MASS)

##
# Determine AIC (Akaike information criterion)
##

extractAIC(lm(after_2010$overall.peak ~ 1))
extractAIC(lm(after_2010$overall.peak ~ after_2010$last.week))
extractAIC(lm(after_2010$overall.peak ~ after_2010$last.week + after_2010$peak))
extractAIC(lm(after_2010$overall.peak ~ after_2010$last.week + after_2010$peak + after_2010$weeks.on.chart))
extractAIC(lm(after_2010$overall.peak ~ after_2010$last.week + after_2010$peak + after_2010$weeks.on.chart + after_2010$entry.position))
extractAIC(lm(after_2010$overall.peak ~ after_2010$last.week + after_2010$peak + after_2010$weeks.on.chart + after_2010$entry.position + after_2010$artist.relevancy))

##
# Determine AIC_c (Akaike information criterion -- corrected)
##

n <- length(after_2010$overall.peak)
n <- dim(after_2010$overall.peak)[1]

extractAIC(lm(after_2010$overall.peak ~ 1)) + 2 * 2 * 3 / (n - 3)
extractAIC(lm(after_2010$overall.peak ~ after_2010$last.week)) + 2 * 3 * 4 / (n - 4)
extractAIC(lm(after_2010$overall.peak ~ after_2010$last.week + after_2010$peak)) + 2 * 4 * 5 / (n - 5)
extractAIC(lm(after_2010$overall.peak ~ after_2010$last.week + after_2010$peak + after_2010$weeks.on.chart)) + 2 * 5 * 6 / (n - 6)
extractAIC(lm(after_2010$overall.peak ~ after_2010$last.week + after_2010$peak + after_2010$weeks.on.chart + after_2010$entry.position)) + 2 * 6 * 7 / (n - 7)
extractAIC(lm(after_2010$overall.peak ~ after_2010$last.week + after_2010$peak + after_2010$weeks.on.chart + after_2010$entry.position + after_2010$artist.relevancy)) + 2 * 7 * 8 / (n - 8)