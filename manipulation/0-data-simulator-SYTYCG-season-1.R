rm(list=ls(all=TRUE)) #Clear the memory of variables from previous run. This is not called by knitr, because it's above the first chunk.

###################################################.
####   So You Think You Can Graph - Season 1   ####
###################################################.

# ---- load-sources ------------------------------------------------------------


# ---- load-packages -----------------------------------------------------------
library("magrittr")
requireNamespace("readr")
requireNamespace("dplyr")
requireNamespace("testit")
requireNamespace("checkmate")


# ---- declare-globals ---------------------------------------------------------


# ---- load-data ---------------------------------------------------------------


# ---- tweak-data --------------------------------------------------------------




### Simulate Data for SYTYCD Season 1
## Simulate two groups of 80 participants
## Group 1 = (hypothetical) students who studied cramming at the end (Massed Study Style)
## Group 2 = (hypothetical) students who studied throughout the unit (Spaced Study Style)
##
## Simulate 4 effects sizes (0, .3, .5, .8)
## Retain and store two .csv files
##    File 1 = parameters of the simulation (graph number, effect size, N, observed effect size)
##    File 2 = data from all of the simulations

# Set Random Seed
set.seed(90210)

#Load required packages
require(lsr)

#Set directory
# setwd("C:/Users/jkwitt/Dropbox/InfoVis/Graph Contest") # use project properties instead

#Set parameters of the simulations
effectSizes <- c(0,.3, .5, .8)   # 4 effect sizes
N <- 80                          # Number of participants per group
numReps <- 10                    # Number of repetitions for each effect size
numGraphs <- 4 * 10              # Number of total graphs = 4 effect sizes * 10 repetitions


# Data frame to save graph parameters and link them to graph numbers to be used for analysis later
cn <- c("graphNum","effectSize","N","actualES")
saveParams <- as.data.frame(matrix(NA,ncol=length(cn),nrow=numGraphs))
colnames(saveParams) <- cn

# Data frame to save simulated data - this will be used to create graphs for the contest
cn <- c("graphNum", "group","val")
saveData <- as.data.frame(matrix(NA,ncol=length(cn),nrow=1))  #creates a dummy row to be deleted later
colnames(saveData) <- cn
rm(cn)
graphNum <- 0


for (i in 1:length(effectSizes)) {
  for (j in 1:numReps) {

      mean1 <- 50
      sdPooled <- sqrt((10^2 + 10^2) / 2)
      mean2 <- mean1 + (effectSizes[i] * sdPooled)

      #get data until effect size matches desired effectsize
      testIT <- 0
      while (testIT == 0) {
        group1 <- rnorm(N,mean1,10)
        group2 <- rnorm(N,mean2,10)
      
        #test effect size
        actD <- cohensD(group1, group2)
      
        if (round(actD * 10) == (effectSizes[i]*10)) {
          testIT <- 1
        }
      } #end while
      
      #SAVE PARAMS
      graphNum <- graphNum + 1
      saveParams[graphNum,] <- NA
      saveParams$graphNum[graphNum] <- graphNum
      saveParams$effectSize[graphNum] <- effectSizes[i]
      saveParams$N[graphNum] <- N
      saveParams$actualES[graphNum] <- round(actD,4)

      #SAVE Data
      saveEm <- data.frame(
        graphNum = rep(graphNum,N*2),
        group = c(rep("Massed",N), rep("Spaced",N)),
        val = c(group1, group2)
      )
      saveData <- rbind(saveData, saveEm)

      ############# INSERT CODE TO CREATE GRAPH HERE  ############################
    
  } # end for j reps
} # end for i effect size

saveData <- saveData[-1,]  #exclude the dummy row that was used as a place holder

saveData$group <- as.factor(saveData$group)

# ---- save-to-disk -------------------------------------
# write.csv(saveParams,"saveParams_SYTYCG_Season1.csv")
# write.csv(saveData,"saveData_SYTYCG_Season1.csv")
# re-write in tidyverse
path_save_folder <- "./data-unshared/derived/"
saveData   %>% readr::write_csv(paste0(path_save_folder,"saveData_SYTYCG_Season1.csv"))
saveParams %>% readr::write_csv(paste0(path_save_folder,"saveParams_SYTYCG_Season1.csv"))
