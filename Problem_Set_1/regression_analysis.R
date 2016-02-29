# Author: Danny Vilela
# Date: 29 February 2016
#   This script will serve to clean, validate, and filter the values that are
#   relevant for the simple linear regression task.
#

# Define required packages
require(ggplot2)
require(car)

# Read in our NYC SAT dataset
df <- read.csv("SAT_Results.csv", header = TRUE)

# Convert our CSV to a data frame and attach it to our session
df <- data.frame(df)

# Clean our data to get rid of schools who did not report valid results
df <- df[!(df$Num.of.SAT.Test.Takers == 's'),]

# Our columns are read in as type character, so convert to numeric
df$SAT.Critical.Reading.Avg..Score <- as.numeric(as.character(df$SAT.Critical.Reading.Avg..Score))
df$SAT.Writing.Avg..Score <- as.numeric(as.character(df$SAT.Writing.Avg..Score))

# Establish easy references for our x and y axes
x_axis <- df$SAT.Critical.Reading.Avg..Score
y_axis <- df$SAT.Writing.Avg..Score

# Let's look at our data
read_v_write <- ggplot(df) + 
  geom_point(aes(x = x_axis, 
                 y = y_axis)) +
  labs(x = "Critical Reading Score", y = "Writing Average Score") +
  xlim(200, 800) + ylim(200, 800)
read_v_write

# Save our plot
ggsave(read_v_write, filename = "read_v_write.png")

# Explore any outliers in our data
# Click on a point to identify it, the press `esc' to return all points clicked
print("Press the escape key once you're done choosing points to be identified.")
identify(x_axis, y_axis)

# Fit our linear regression model and output the summary statistics
regression <- lm(y_axis ~ x_axis)
summary(regression)

# Perform partial F-test for slope coefficient = 1
linearHypothesis(regression, c(0,1), rhs = 1)

# Function for fitted line plot
regplot.confbands.fun <- function(x, y, confidencelevel= .95, CImean = TRUE, 
                                  PI = TRUE, CIregline = FALSE, legend = FALSE) {
  #### Modified from a function written by Sandra McBride, Duke University
  #### For a simple linear regression line, this function
  #### will plot the line, CI for mean response, prediction intervals, 
  #### and (optionally) a simulataneous CI for the regression line.
  xx <- x[order(x)]
  yy <- y[order(x)]
  lm1 <- lm(yy ~ xx)	
  plot(xx, yy, ylim = c(min(yy), (max(yy) + .2 * max(yy))))
  abline(lm1$coefficients)
  #### calculation of components of intervals ####
  n <- length(yy)
  sx2 <- (var(xx))
  shat <- summary(lm1)$sigma
  s2hat <- shat ^ 2
  SEmuhat <- shat * sqrt( (1/n) + ((xx - mean(xx)) ^ 2)/((n - 1) * sx2) )
  SEpred <- sqrt(s2hat + SEmuhat ^ 2)
  t.quantile <- qt(confidencelevel, lm1$df.residual)
  ####
  if (CImean == TRUE) {
    mean.up <- lm1$fitted + t.quantile*SEmuhat
    mean.down <- lm1$fitted - t.quantile*SEmuhat
    lines(xx, mean.up, lty = 2)
    lines(xx, mean.down, lty = 2)
  }
  if (PI == TRUE) {
    PI.up <- lm1$fitted + t.quantile*SEpred
    PI.down <- lm1$fitted - t.quantile*SEpred
    lines(xx, PI.up, lty = 3)
    lines(xx, PI.down, lty = 3)
  }
  if (CIregline == TRUE) {
    HW <- sqrt(2 * qf(confidencelevel, n - lm1$df.residual, lm1$df.residual)) * SEmuhat
    CIreg.up <- lm1$fitted + HW
    CIreg.down <- lm1$fitted - HW
    lines(xx, CIreg.up, lty = 4)
    lines(xx, CIreg.down, lty = 4)
  }	
  if (legend == TRUE) {
    choices <- c(CImean, PI, CIregline)
    line.type <- c(2,3,4)
    names.line <- c("Pointwise CI for mean resp.", 
                    "Prediction Int.", 
                    "Simultaneous conf. region for entire reg. line")
    legend(max(xx) - (.2 * max(xx)), max(yy) + (.2 * max(yy)), 
           legend = names.line[choices], lty = line.type[choices])
  }
}

# Open png graphics device to save our fitted line plot
png(filename = "fitted_line_plot.png")

# Determine fitted line plot for x_axis and y_axis
regplot.confbands.fun(x_axis, y_axis)

# Close our png graphics device
dev.off()

# Confidence and prediction intervals for new observation
new_read_v_write <- data.frame(x_axis = c(-1.5))

# Calculate confidence and prediction interval
predict(regression, new_read_v_write, interval = c("confidence"))
predict(regression, new_read_v_write, interval = c("prediction"))

# Open png graphics device to save our fitted line plot
png(filename = "fitted_vs_residual.png")

# Plot our fitted values vs residuals
plot(fitted(regression), residuals(new_read_v_write), 
     xlab = "Fitted values", ylab = "Residuals")

# Close our png graphics device
dev.off()

# Open png graphics device to save our fitted line plot
png(filename = "qq.png")

# Generate normal Q-Q plot
qqnorm(residuals(regression))

# Close our png graphics device
dev.off()
