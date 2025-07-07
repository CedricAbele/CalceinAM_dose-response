# References:
#Ritz, C.; Baty, F.; Streibig, J. C.; Gerhard, D. Dose-Response Analysis Using R. PLOS ONE 2015, 10 (12), e0146021. https://doi.org/10.1371/journal.pone.0146021.
#
#install.packages("drc")
#install.packages("multcomp")
#install.packages("sandwich")
#install.packages("lmtest")
#install.packages("ggplot2")
#install.packages("tidyverse")


rm(list = ls())
library(drc)
# read in the data set 
library(readxl)
Results <- read_excel("OECD_immobilisation_TPP.xlsx")

data = Results
cmax <- max(data$conc)

#reshape
library(tidyr)
data.rs <-pivot_longer(data, cols =2:4, names_to ="duration", values_to = "alive")


# calculate the log-logistic model
library(multcomp)
#2h
#daphnia2.m <- drm(`2h`/total ~ conc, weights = total, data = data, fct = LL.2(),  type = "binomial")
#summary(glht(daphnia2.m ))

#24
daphnia24.m <- drm(`24h`/total ~ conc, weights = total, data = data, fct = LL.2(),  type = "binomial")
summary(glht(daphnia24.m ))

#48
daphnia48.m <- drm(`48h`/total ~ conc, weights = total, data = data, fct = LL.2(),  type = "binomial")
summary(glht(daphnia48.m ))


# test for best model
mselect(daphnia48.m, 
        list(LL.2(),LL.3u(),LL.3(),LL.4(), LL.5(), LN.4(), W1.2(),W1.4(),W1.3(), W2.4()))


#calculating EC5/EC10 and EC50
#ED(daphnia2.m , c(5, 10, 50), interval = "delta") 
ED(daphnia24.m , c(5, 10, 50), interval = "delta") 
ED(daphnia48.m , c(5, 10, 50), interval = "delta") 

library(ggplot2)
# new dose levels as support for the line
#newdata2 <- expand.grid(conc=exp(seq(log(0.01), log(cmax), length=50)))
# predictions and confidence intervals
#pm2 <- predict(daphnia2.m , newdata=newdata2, interval="confidence")
# new data with predictions
#newdata2$p <- pm2[,1]
#newdata2$pmin <- pm2[,2]
#newdata2$pmax <- pm2[,3]

# new dose levels as support for the line
newdata24 <- expand.grid(conc=exp(seq(log(0.01), log(cmax), length=50)))
# predictions and confidence intervals
pm24 <- predict(daphnia24.m , newdata=newdata24, interval="confidence")
# new data with predictions
newdata24$p <- pm24[,1]
newdata24$pmin <- pm24[,2]
newdata24$pmax <- pm24[,3]


# new dose levels as support for the line
newdata48 <- expand.grid(conc=exp(seq(log(0.01), log(cmax), length=50)))
# predictions and confidence intervals
pm48 <- predict(daphnia48.m , newdata=newdata48, interval="confidence")
# new data with predictions
newdata48$p <- pm48[,1]
newdata48$pmin <- pm48[,2]
newdata48$pmax <- pm48[,3]



#plot-reshaped
# need to shift conc == 0 a bit up, otherwise there are problems with coord_trans
data.rs$conc0 <- data.rs$conc
data.rs$conc0[data.rs$conc0 == 0] <- 0.01 # moving only concentration 0 to conc 0.5 (log)

# plot
{
  # need to shift conc == 0 a bit up, otherwise there are problems with coord_trans
  data$conc0 <- data$conc
  data$conc0[data$conc0 == 0] <- 0.01 # moving only concentration 0 to conc 0.5 (log)
  
  # plotting the curve
  
  theme_set(theme_bw()) # changes the theme
  dev.new(width = 5000,   # Create new plot window
          height = 5000,
          unit = "px",
          noRStudioGD = TRUE)
  ggplot(data=data, aes(x = conc0, y =`24h`/total, color = '24h', shape = '24h' ), size =3) +
    geom_point(size =3) + #data points
    geom_ribbon(data=newdata24, aes(x=conc, y=p, ymin=pmin, ymax=pmax), alpha=0.2, fill= "blue", colour = NA) + # confidence intervall 
    geom_line(data=newdata24, aes(x=conc, y=p), color = "blue", size = 0.8, linetype = "solid") + 
    ## 24h
    #geom_point(data=data, aes(y =`24h`/total, color = '24h', shape = '24h' ), size =3) + #data points
    #geom_ribbon(data=newdata24, aes(x=conc, y=p, ymin=pmin, ymax=pmax), alpha=0.2, fill ="darkorange1", colour = NA) + # confidence intervall 
    #geom_line(data=newdata24, aes(x=conc, y=p), color = "darkorange1", size = 0.8, linetype = "solid") +
  
    ## 48h
    geom_point(data=data, aes(y =`48h`/total, color = '48h', shape = '48h'), size =3) + #data points
    geom_ribbon(data=newdata48, aes(x=conc, y=p, ymin=pmin, ymax=pmax), alpha=0.2, fill ="darkgreen", colour = NA) + # confidence intervall 
    geom_line(data=newdata48, aes(x=conc, y=p), color = "darkgreen", size = 0.8, linetype = "solid") + # line of model
    
    
     scale_color_manual(name='exposure time',
                       breaks=c( '24h','48h'),
                       values=c('24h'='blue', 
                                '48h'='darkgreen'))+
    scale_shape_manual(name='exposure time',
                       breaks=c( '24h','48h'),
                       values=c( '24h'='triangle',
                                '48h'='square'))+
     scale_x_continuous(trans='log10')+ #logtransformation of x-axis
    
    coord_cartesian(ylim=c(0, 1.1)) + 
    xlab("mg/L") +
    scale_y_continuous(
      
      # Features of the first axis
      name = "mobile / total",
      
      # Add a second axis and specify its features
      breaks=seq(0, 1, 0.2))+
    
    
    theme(
    legend.position = c(.18,.2),
    legend.title = element_text(size=17),
    legend.text = element_text(size=15),
      axis.title.x = element_text(color = "black", size=20),
      axis.text.x = element_text(color = "black", size = 20),
      axis.title.y = element_text(color = "black", size=17),
      axis.text.y.left = element_text(color = "black", size = 20),
      
      
    )
    #geom_text(aes(x= cmax-1000, y= 1.1, label ="24h", family="serif"), size=17)
    
  
  
  
  #coord_cartesian(ylim=c(0, 1.19)) + 
  #scale_y_continuous(breaks=seq(0, 1, 0.2))  # Ticks from 0-1, every 0.2
}



  

            

