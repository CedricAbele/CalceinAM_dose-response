# References:
# Ritz, C.; Baty, F.; Streibig, J. C.; Gerhard, D. Dose-Response Analysis Using R. PLOS ONE 2015, 10 (12), e0146021. https://doi.org/10.1371/journal.pone.0146021.


# Load necessary libraries for data handling, dose-response modeling, and plotting.
library(readxl)   # For reading Excel files.
library(drc)      # For dose-response curve analysis.
library(ggplot2)  # For creating high-quality plots.


# Read the raw experimental data from an Excel file.
Results <- read_excel("CA_immobilisation_TPP.xlsx")

# Assign the loaded data to a variable 'data' for easier manipulation.
data <- Results
# Calculate minimum concentration, slightly shifting 0 for log transformation compatibility.
cmin <- min(data$conc) + 0.1
# Calculate maximum concentration.
cmax <- max(data$conc)
# Remove rows with any missing values from the dataset.
data <- na.omit(data)
# Calculate the average 'Green' signal at the highest concentration, used as a lower limit.
lowerlimit <- mean(data$Green[data$conc == cmax])
# Calculate the average 'Green' signal at zero concentration, used for scaling plots.
coeff <- mean(data$Green[data$conc == 0])

# Display the first few rows of the processed data.
head(data)

# --- Acute Toxicity Analysis ---
# Fit a 2-parameter log-logistic model (LL.2) for acute toxicity data (binomial type).
daphnia_acute.m <- drm(alive/total ~ conc, weights = total, data = data, fct = LL.2(), type = "binomial")
# Summarize the model, including parameter estimates and standard errors.
summary(daphnia_acute.m) 

# Calculate Effective Concentrations (EC) at 5%, 10%, and 50% for acute toxicity.
ED(daphnia_acute.m, c(5, 10, 50), interval = "delta")

# Generate new concentration data for smooth curve plotting.
newdata_acute <- expand.grid(conc = exp(seq(log(cmin), log(cmax), length = 100)))
# Predict response and confidence intervals for the new data using the acute toxicity model.
pm_acute <- predict(daphnia_acute.m, newdata = newdata_acute, interval = "confidence")

# Add predicted values and confidence intervals to the new data frame.
newdata_acute$p <- pm_acute[, 1]
newdata_acute$pmin <- pm_acute[, 2]
newdata_acute$pmax <- pm_acute[, 3]

# --- Calcein Fluorescence Intensity Analysis ---
# Fit a 4-parameter log-logistic model (LL.4) for Calcein data (continuous type).
# The 'bottom' parameter is fixed to the pre-calculated 'lowerlimit'( signal in the dead control).
daphnia_Calcein.m <- drm(Green ~ conc, data = data, fct = LL.4(fixed = c(NA, lowerlimit, NA, NA)), type = "continuous")
# Summarize the model for the calcein signal.
summary(daphnia_Calcein.m) 


# Calculate Effective Concentrations (EC) at 5%, 10%, and 50% for Calcein fluporescence data.
ED(daphnia_Calcein.m, c(5, 10, 50), interval = "delta")

# Generate new concentration data for smooth curve plotting for Calcein signal.
newdata_JC1 <- expand.grid(conc = exp(seq(log(cmin), log(cmax), length = 1000)))
# Predict response and confidence intervals for the new data using the Calcein model.
pm_JC1 <- predict(daphnia_Calcein.m, newdata = newdata_JC1, interval = "confidence")

# Add predicted values and confidence intervals to the new data frame for Calcein.
newdata_JC1$p <- pm_JC1[, 1]
newdata_JC1$pmin <- pm_JC1[, 2]
newdata_JC1$pmax <- pm_JC1[, 3]

# --- Plotting the Concentration-Response Curves ---
# Adjust concentrations for plotting on a log scale (shift 0 values).
data$conc0 <- data$conc + 0.1

# Set the default ggplot2 theme to black and white.
theme_set(theme_bw())

# Create the base ggplot object 
ggplot(data, aes(x = conc0, y = alive / total)) +
  # Add scatter points for acute toxicity data.
  geom_point(size = 3, color = "black") +
  # Add a confidence ribbon for the acute toxicity model.
  geom_ribbon(data = newdata_acute, aes(x = conc, y = p, ymin = pmin, ymax = pmax), alpha = 0.2, fill = "black") +
  # Add the fitted line for the acute toxicity model.
  geom_line(data = newdata_acute, aes(x = conc, y = p), color = "black", linewidth = 0.8, linetype = "solid") +
  # Add scatter points for Calcein data (scaled by 'coeff').
  geom_point(aes(y = Green / coeff), color = "green4", size = 3, shape = "diamond") +
  # Add a confidence ribbon for the Calcein model (scaled).
  geom_ribbon(data = newdata_JC1, aes(x = conc, y = p / coeff, ymin = pmin / coeff, ymax = pmax / coeff), alpha = 0.2, fill = "green4") +
  # Add the fitted line for the Calcein model (scaled).
  geom_line(data = newdata_JC1, aes(x = conc, y = p / coeff), color = "green4", linewidth = 0.8, linetype = "solid") +
  # Set the x-axis to a logarithmic scale.
  scale_x_continuous(trans = 'log10') +
  # Set the y-axis limits.
  coord_cartesian(ylim = c(0, 1.19)) +
  # Set the x-axis label.
  xlab("Triphenyl phosphate (mg/L)") +

  scale_y_continuous(
    name = "mobile / total", 
    sec.axis = sec_axis(~. * coeff, name = "Calcein (green)"), 
    breaks = seq(0, 1, 0.2) # Breaks for the y-axis
  ) +
  # Customize theme elements (axis titles and text appearance).
  theme(
    axis.title.x = element_text(color = "black", size = 17),
    axis.text.x = element_text(color = "black", size = 15),
    axis.title.y = element_text(color = "black", size = 17),
    axis.title.y.right = element_text(color = "green4", size = 17),
    axis.text.y.left = element_text(color = "black", size = 15),
    axis.text.y.right = element_text(color = "green4", size = 15)
  ) 

