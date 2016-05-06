# Author: Danny Vilela
# Date: 27 April 2016
#   This script will serve to clean, validate, and filter the values 
#   that are relevant for the two-way analysis of variance task.

# Define required packages
if (!require("pacman")) install.packages("pacman")
pacman::p_load("car", "dplyr", "ggplot2", "lmtest", "leaps", "sme", "lawstat")

# Read in our Global Terrorism dataset
terror_data_raw <- read.csv("data/raw.csv", header = TRUE)

#######################
## Clean up our data ##
#######################

terror_data_raw$nkill <- as.integer(terror_data_raw$nkill)
terror_data_raw$nwound <- as.integer(terror_data_raw$nwound) 

# Only select columns we're interested in, which for our model means:
#   year:    year of event (to be :time column)
#   target:  the terrorist's main target (categorical)
#   country: the country where terrorism took place (categorical) 
# and for our descriptive report, means:
#   n_kill:          number of victims killed
#   n_wound:         number of victims wounded
#   group_name:      terrorist group name
#   weapon_type:     weapon used in terrorist incident
#   detailed_target: terrorist's detailed target
terror_data <- select(terror_data_raw, year = iyear, target = targtype1_txt, 
                      country = country_txt, n_killed = nkill, n_wounded = nwound,
                      group_name = gname, detailed_target = target1)

# We omit any observations with null values in n_killed
terror_data_no_na <- filter(terror_data, n_killed != is.na(n_killed) & 
                              n_killed > 0)

# Get top 4 terrorist target locations, will be used for categorical predictor
target_filter <- names(sort(summary(terror_data_no_na$target), 
                                 decreasing = TRUE))[1:4]

# Get top 4 terrorist target countries, will be used for categorical predictor
country_filter <- names(sort(summary(terror_data_no_na$country),
                                    decreasing = TRUE))[1:4]

# We only want terrorist incidents where the target location is in the top 3
# and the target country is in the top 4. Hence,
terror_data_filtered <- filter(terror_data_no_na, country %in% country_filter,
                               target %in% target_filter)

# terror_data_filtered$target <- as.character(terror_data_filtered$target)
# terror_data_filtered$country <- as.character(terror_data_filtered$country)
terror_data_filtered$target <- factor(terror_data_filtered$target)
terror_data_filtered$country <- factor(terror_data_filtered$country)

# Determine split points for our dataset
half_len_of_filtered <- as.integer(dim(terror_data_filtered)[1] / 2)
full_len_of_filtered <- as.integer(dim(terror_data_filtered)[1])

# Split our dataset into training and testing subsets
filtered_training <- filter(terror_data_filtered[1:half_len_of_filtered, ])
filtered_testing <- filter(terror_data_filtered[half_len_of_filtered:full_len_of_filtered, ])

######################
## Data exploration ##
######################

# Open device for saving plot
png(filename = "figs/boxplot_killed_vs_targeted.png",
    width = 800, height = 700, units = "px",
    res = 130)

# Set outer margins because R hates me
par(mar = c(11.5, 3, 1, 1))

# Plot boxplots of number killed vs target countries and
# number killed vs targeted locations
boxplot(split(filtered_training$n_killed, target_filter), las = 2)

# Close our PNG filewriter
dev.off()

# Open device for saving plot
png(filename = "figs/boxplot_killed_vs_country.png",
    width = 800, height = 600, units = "px",
    res = 130)

boxplot(split(filtered_training$n_killed, country_filter))

# Close our PNG filewriter
dev.off()

# We see nonconstant variance, so log our n_killed column and store in new col
filtered_training$log.n_killed <- log10(filtered_training$n_killed)
filtered_testing$log.n_killed <- log10(filtered_testing$n_killed)

# Open device for saving plot
png(filename = "figs/logged_boxplot_killed_vs_targeted.png",
    width = 800, height = 1000, units = "px",
    res = 130)

# Set outer margins because, again, R hates me
par(mar = c(11.5, 3, 1, 1))

# Plot boxplots of number killed vs target countries and
# number killed vs targeted locations
boxplot(split(filtered_training$log.n_killed, target_filter), las = 2)

# Close our PNG filewriter
dev.off()

# Open device for saving plot
png(filename = "figs/logged_boxplot_killed_vs_country.png",
    width = 800, height = 1000, units = "px",
    res = 130)

boxplot(split(filtered_training$log.n_killed, country_filter))

# Close our PNG filewriter
dev.off()

#######################
## Fit two-way ANOVA ##
#######################

# Get regression model for two-way analysis of variance
log.deaths <- lm(filtered_training$log.n_killed ~ 
               filtered_training$target + filtered_training$country +
               filtered_training$target * filtered_training$country)

# Get summary ANOVA output from model object
anova(log.deaths)

# Get summary regression output from model object
summary(log.deaths)

# Get diagnostic plots of residuals
plot(log.deaths)

# Open device for saving plot
png(filename = "figs/logged_interaction_plot.png",
    width = 2000, height = 600, units = "px",
    res = 130)

# Sigh
par(mar = c(3, 5, 0.5, 11))

# Get the interaction plot that represents our model
interaction.plot(filtered_training$target,
                 filtered_training$country,
                 filtered_training$log.n_killed)

# Close our PNG filewriter
dev.off()

# Remove outliers
outliers <- as.integer(c(757, 3742, 4243))
filtered_training_noutlier <- filtered_training[-outliers, ]

##############################
## Data exploration (again) ##
##############################

# Open device for saving plot
png(filename = "figs/logged_boxplot_killed_vs_targeted_nout.png",
    width = 800, height = 1000, units = "px",
    res = 130)

# Set outer margins because, again, R hates me
par(mar = c(11.5, 3, 1, 1))

# Plot boxplots of number killed vs target countries and
# number killed vs targeted locations
boxplot(split(filtered_training_noutlier$log.n_killed, target_filter), las = 2)

# Close our PNG filewriter
dev.off()

# Open device for saving plot
png(filename = "figs/logged_boxplot_killed_vs_country_nout.png",
    width = 800, height = 1000, units = "px",
    res = 130)

boxplot(split(filtered_training_noutlier$log.n_killed, country_filter))

# Close our PNG filewriter
dev.off()

###############################
## Fit two-way ANOVA (again) ##
###############################

# Get regression model for two-way analysis of variance
log.deaths.nout <- lm(filtered_training_noutlier$log.n_killed ~ 
                        filtered_training_noutlier$target + filtered_training_noutlier$country +
                        filtered_training_noutlier$target * filtered_training_noutlier$country)

# Get summary ANOVA output from model object
anova(log.deaths.nout)

# Get ANOVA model object
anova.log.deaths.nout <- aov(log.deaths.nout)

# Get summary regression output from model object
summary(log.deaths.nout)

# Get diagnostic plots of residuals for our updated dataset
plot(log.deaths.nout)

# Open device for saving plot
png(filename = "figs/logged_interaction_plot_nout.png",
    width = 2000, height = 600, units = "px",
    res = 130)

# Sigh
par(mar = c(3, 5, 0.5, 11))

# Get the interaction plot that represents our model
interaction.plot(filtered_training_noutlier$target,
                 filtered_training_noutlier$country,
                 filtered_training_noutlier$log.n_killed)

# Close our PNG filewriter
dev.off()

# Get standard residuals for our ANOVA model
std.resd <- rstandard(anova.log.deaths.nout)

# Open device for saving plot
png(filename = "figs/logged_boxplot_stdr_vs_targeted_nout.png",
    width = 950, height = 1000, units = "px",
    res = 130)

# Boxplot of standard residuals against :target categorical predictor
boxplot(split(std.resd, filtered_training_noutlier$target))

# Close our PNG filewriter
dev.off()

# Open device for saving plot
png(filename = "figs/logged_boxplot_stdr_vs_country_nout.png",
    width = 800, height = 1000, units = "px",
    res = 130)

# Boxplot of standard residuals against :country categorical predictor
boxplot(split(std.resd, filtered_training_noutlier$country))

# Close our PNG filewriter
dev.off()

###################
## Levene's test ##
###################

levene <- aov(abs(std.resd) ~ filtered_training_noutlier$target
              + filtered_training_noutlier$country
              + filtered_training_noutlier$target * filtered_training_noutlier$country)

Anova(levene, type = 3)

############################
## Weighted Least Squares ##
############################

std.resc <- rstandard(log.deaths)
filtered_training_model <- select(filtered_training, country, target, log.n_killed)

# Note we go back to our :filtered_training dataset
# Get the weights for each subgroup. Hoo boy.
group_sd <- sapply(split(std.resd, list(filtered_training_noutlier$target, filtered_training_noutlier$country)), sd)
weight <- rep(NA, dim(filtered_training_model)[1])

# India
weight[(filtered_training_model$country == "India") & (filtered_training_model$target == "Government (General)")] <- 1 / group_sd["Government (General).India"] ^ 2
weight[(filtered_training_model$country == "India") & (filtered_training_model$target == "Military)")] <- 1 / group_sd["Military.India"] ^ 2
weight[(filtered_training_model$country == "India") & (filtered_training_model$target == "Police")] <- 1 / group_sd["Police.India"] ^ 2
weight[(filtered_training_model$country == "India") & (filtered_training_model$target == "Private Citizens & Property")] <- 1 / group_sd["Private Citizens & Property.India"] ^ 2

# Colombia
weight[(filtered_training_model$country == "Colombia") & (filtered_training_model$target == "Government (General)")] <- 1 / group_sd["Government (General).Colombia"] ^ 2
weight[(filtered_training_model$country == "Colombia") & (filtered_training_model$target == "Military)")] <- 1 / group_sd["Military.Colombia"] ^ 2
weight[(filtered_training_model$country == "Colombia") & (filtered_training_model$target == "Police")] <- 1 / group_sd["Police.Colombia"] ^ 2
weight[(filtered_training_model$country == "Colombia") & (filtered_training_model$target == "Private Citizens & Property")] <- 1 / group_sd["Private Citizens & Property.Colombia"] ^ 2

# Iraq
weight[(filtered_training_model$country == "Iraq") & (filtered_training_model$target == "Government (General)")] <- 1 / group_sd["Government (General).Iraq"] ^ 2
weight[(filtered_training_model$country == "Iraq") & (filtered_training_model$target == "Military)")] <- 1 / group_sd["Military.Iraq"] ^ 2
weight[(filtered_training_model$country == "Iraq") & (filtered_training_model$target == "Police")] <- 1 / group_sd["Police.Iraq"] ^ 2
weight[(filtered_training_model$country == "Iraq") & (filtered_training_model$target == "Private Citizens & Property")] <- 1 / group_sd["Private Citizens & Property.Iraq"] ^ 2

# Pakistan
weight[(filtered_training_model$country == "Pakistan") & (filtered_training_model$target == "Government (General)")] <- 1 / group_sd["Government (General).Pakistan"] ^ 2
weight[(filtered_training_model$country == "Pakistan") & (filtered_training_model$target == "Military)")] <- 1 / group_sd["Military.Pakistan"] ^ 2
weight[(filtered_training_model$country == "Pakistan") & (filtered_training_model$target == "Police")] <- 1 / group_sd["Police.Pakistan"] ^ 2
weight[(filtered_training_model$country == "Pakistan") & (filtered_training_model$target == "Private Citizens & Property")] <- 1 / group_sd["Private Citizens & Property.Pakistan"] ^ 2

filtered_training_model_w <- aov(filtered_training_model$log.n_killed ~ 
                             filtered_training_model$target + filtered_training_model$country + 
                             filtered_training_model$target * filtered_training_model$country,
                           weight = weight)

Anova(filtered_training_model_w, type = 3)

m <- aov(filtered_training_model_w)

summary(lm(filtered_training_model$log.n_killed ~ 
             filtered_training_model$target + filtered_training_model$country + 
             filtered_training_model$target * filtered_training_model$country, weights = weight))

###############################
## Fit ANOVA (again (again)) ##
###############################

# Get diagnostic plots of residuals for our updated dataset
plot(filtered_training_model_w)

# Open device for saving plot
png(filename = "figs/logged_interaction_plot_wls.png",
    width = 2000, height = 600, units = "px",
    res = 130)

# Sigh
par(mar = c(3, 5, 0.5, 11))

# Get the interaction plot that represents our model
interaction.plot(filtered_training_model$target,
                 filtered_training_model$country,
                 filtered_training_model$log.n_killed)

# Close our PNG filewriter
dev.off()

# Get standard residuals for our ANOVA model
std.resd <- rstandard(filtered_training_model_w)

# Open device for saving plot
png(filename = "figs/logged_boxplot_stdr_vs_targeted_wls.png",
    width = 950, height = 1000, units = "px",
    res = 130)

# Boxplot of standard residuals against :target categorical predictor
boxplot(split(std.resd, filtered_training_model$target))

# Close our PNG filewriter
dev.off()

# Open device for saving plot
png(filename = "figs/logged_boxplot_stdr_vs_country_wls.png",
    width = 800, height = 1000, units = "px",
    res = 130)

# Boxplot of standard residuals against :country categorical predictor
boxplot(split(std.resd, filtered_training_model$country))

# Close our PNG filewriter
dev.off()
