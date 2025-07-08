# Title: Dose-Response Analysis of OECD Immobilisation Data for TPP

# Description: This script performs dose-response analysis on OECD immobilisation
#              data for Triphenyl phosphate (TPP) using the 'drc' package.
#              It fits log-logistic models, calculates ECx values, and generates
#              a dose-response plot.

# References:
# Ritz, C.; Baty, F.; Streibig, J. C.; Gerhard, D. Dose-Response Analysis Using R.
# PLOS ONE 2015, 10 (12), e0146021. https://doi.org/10.1371/journal.pone.0146021.

# 1. Setup and Data Loading ----------------------------------------------------


library(drc)
library(readxl)
library(tidyr)
library(ggplot2)
library(multcomp) 

# Read in the data set
Results <- read_excel("OECD_TPP.xlsx")
data <- Results
cmax <- max(data$conc)

# Reshape data (if needed for other analysis, but not directly used in the current plot)
data.rs <- pivot_longer(data, cols = 2:4, names_to = "duration", values_to = "alive")

# Calculate the log-logistic models
daphnia24.m <- drm(`24h`/total ~ conc, weights = total, data = data, fct = LL.2(), type = "binomial")
summary(glht(daphnia24.m)) # This line requires the 'multcomp' package

daphnia48.m <- drm(`48h`/total ~ conc, weights = total, data = data, fct = LL.2(), type = "binomial")
summary(glht(daphnia48.m)) # This line requires the 'multcomp' package

# Test for best model
mselect(daphnia48.m,
        list(LL.2(), LL.3u(), LL.3(), LL.4(), LL.5(), LN.4(), W1.2(), W1.4(), W1.3(), W2.4()))

# Calculating EC5/EC10 and EC50
ED(daphnia24.m, c(5, 10, 50), interval = "delta")
ED(daphnia48.m, c(5, 10, 50), interval = "delta")

# Prepare new dose levels for predictions and confidence intervals
newdata24 <- expand.grid(conc = exp(seq(log(0.01), log(cmax), length = 50)))
pm24 <- predict(daphnia24.m, newdata = newdata24, interval = "confidence")
newdata24$p <- pm24[, 1]
newdata24$pmin <- pm24[, 2]
newdata24$pmax <- pm24[, 3]

newdata48 <- expand.grid(conc = exp(seq(log(0.01), log(cmax), length = 50)))
pm48 <- predict(daphnia48.m, newdata = newdata48, interval = "confidence")
newdata48$p <- pm48[, 1]
newdata48$pmin <- pm48[, 2]
newdata48$pmax <- pm48[, 3]

# Plotting
# Adjust concentration == 0 for log transformation on the plot
data$conc0 <- data$conc
data$conc0[data$conc0 == 0] <- 0.01

theme_set(theme_bw()) # Changes the theme
dev.new(width = 5000, height = 5000, unit = "px", noRStudioGD = TRUE) # Create new plot window

ggplot(data = data, aes(x = conc0)) +
  # 24h data points, ribbon, and line
  geom_point(aes(y = `24h`/total, color = '24h', shape = '24h'), size = 3) +
  geom_ribbon(data = newdata24, aes(x = conc, y = p, ymin = pmin, ymax = pmax), alpha = 0.2, fill = "blue", colour = NA) +
  geom_line(data = newdata24, aes(x = conc, y = p), color = "blue", size = 0.8, linetype = "solid") +
  
  # 48h data points, ribbon, and line
  geom_point(aes(y = `48h`/total, color = '48h', shape = '48h'), size = 3) +
  geom_ribbon(data = newdata48, aes(x = conc, y = p, ymin = pmin, ymax = pmax), alpha = 0.2, fill = "darkgreen", colour = NA) +
  geom_line(data = newdata48, aes(x = conc, y = p), color = "darkgreen", size = 0.8, linetype = "solid") +
  
  scale_color_manual(name = 'exposure time',
                     breaks = c('24h', '48h'),
                     values = c('24h' = 'blue', '48h' = 'darkgreen')) +
  scale_shape_manual(name = 'exposure time',
                     breaks = c('24h', '48h'),
                     values = c('24h' = 'triangle', '48h' = 'square')) +
  scale_x_continuous(trans = 'log10') + # Log transformation of x-axis
  coord_cartesian(ylim = c(0, 1.1)) +
  xlab("mg/L") +
  scale_y_continuous(name = "mobile / total", breaks = seq(0, 1, 0.2)) +
  theme(
    legend.position = c(.18, .2),
    legend.title = element_text(size = 17),
    legend.text = element_text(size = 15),
    axis.title.x = element_text(color = "black", size = 20),
    axis.text.x = element_text(color = "black", size = 20),
    axis.title.y = element_text(color = "black", size = 17),
    axis.text.y.left = element_text(color = "black", size = 20)
  )

