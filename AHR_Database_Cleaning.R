install.packages("visdat")
install.packages("naniar")
library(visdat)
library(naniar)
library(tidyverse)

#https://docs.google.com/spreadsheets/d/1TIVta6GYQMRDmK_XGfSM6FnqZRev-Ez7r-KkIWytRMo/edit?usp=sharing

#Filter to current year 

#This is a great tool to visualize what's missing and wrong in the initial dataset dump 
vis_dat(AHR_Feeder)
vis_miss(AHR_Feeder)


#replace missing with n/a
AHR_Feeder <- naniar::replace_with_na_all(AHR_Feeder, condition = ~ .x == "n/a")
AHR_Feeder <- naniar::replace_with_na_all(AHR_Feeder, condition = ~ .x == "na")
AHR_Feeder <- naniar::replace_with_na_all(AHR_Feeder, condition = ~ .x == "-")


#Make appropriate columns numeric
cols.num <- c("Rural Other Principal Arterial Poor Condition Miles, IRI> 220", 
              "Rural Other Principal Arterial, Total", 
              "Urban Interstate Poor Condition Miles, IRI > 170", 
              "Urban Interstate Total Reported", 
              "Urban Other Principal Arterial, Miles less than <220", 
              "Urban Other Principal Arterial, Total",
              "Urban - I - OFE - OPA Total Fatalities",
              "Rural Interstate Poor Condition, Number of Miles, IRI > 170",
              "Rural Interstate Total Miles Measured")
AHR_Feeder[cols.num] <- sapply(AHR_Feeder[cols.num], as.numeric, na.rm = TRUE)

#Check column classes
sapply(AHR_Feeder, class)
