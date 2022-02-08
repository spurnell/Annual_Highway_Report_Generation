library(tidyverse)
library(naniar)

AHR_Feeder <-  read_csv("R_Feeder_ MAIN_Historical - Main Database.csv")
#https://docs.google.com/spreadsheets/d/1TIVta6GYQMRDmK_XGfSM6FnqZRev-Ez7r-KkIWytRMo/edit?usp=sharing 



#Everything after SD bridges in `R_Feeder_Main` is Calculated 

#Creates "per_X" variables for data viz and other purposes  
#capital
Capital_Disbursements_Per <- function(a) {
  AHR_Feeder <- mutate(AHR_Feeder, Capital_Disbursements_Per_Lm = a / AHR_Feeder$`State Controlled Lane Miles`)
  AHR_Feeder <- mutate(AHR_Feeder, Capital_Disbursements_Per_SHA = a / AHR_Feeder$SHA_Miles)
  AHR_Feeder <- mutate(AHR_Feeder, Capital_Disbursements_Per_VMT = a / AHR_Feeder$Total_VMT)
  return(AHR_Feeder)
}

#maintenence
Maintenence_Disbursements_Per <- function(a) {
  AHR_Feeder <- mutate(AHR_Feeder, Maintenence_Disbursements_Per_Lm = a / AHR_Feeder$`State Controlled Lane Miles`)
  AHR_Feeder <- mutate(AHR_Feeder, Maintenence_Disbursements_Per_SHA = a / AHR_Feeder$SHA_Miles)
  AHR_Feeder <- mutate(AHR_Feeder, Maintenence_Disbursements_Per_VMT = a / AHR_Feeder$Total_VMT)
  return(AHR_Feeder)
}

#admin
Admin_Disbursements_Per <- function(a) {
  AHR_Feeder <- mutate(AHR_Feeder, Admin_Disbursements_Per_Lm = a / AHR_Feeder$`State Controlled Lane Miles`)
  AHR_Feeder <- mutate(AHR_Feeder, Admin_Disbursements_Per_SHA = a / AHR_Feeder$SHA_Miles)
  AHR_Feeder <- mutate(AHR_Feeder, Admin_Disbursements_Per_VMT = a / AHR_Feeder$Total_VMT)
  return(AHR_Feeder)
}

#total
Total_Disbursements_Per <- function(a) {
  AHR_Feeder <- mutate(AHR_Feeder, Total_Disbursements_Per_Lm = a / AHR_Feeder$`State Controlled Lane Miles`)
  AHR_Feeder <- mutate(AHR_Feeder, Total_Disbursements_Per_SHA = a / AHR_Feeder$SHA_Miles)
  AHR_Feeder <- mutate(AHR_Feeder, Total_Disbursements_Per_VMT = a / AHR_Feeder$Total_VMT)
  return(AHR_Feeder)
}



#Write 4 different functions which all calculate cumulative z score and then call them 
#Capital
Cumulative_Capital_z_score <- function(a) {
  Per_lm <- (a / AHR_Feeder$`State Controlled Lane Miles`)
  Per_SHA <- (a / AHR_Feeder$SHA_Miles)
  Per_VMT <- (a / AHR_Feeder$Total_VMT)
  
  zscore1 <- scale(Per_lm, center = TRUE, scale = TRUE)
  zscore2 <- scale(Per_SHA, center = TRUE, scale = TRUE)
  zscore3 <- scale(Per_VMT, center = TRUE, scale = TRUE)
  AHR_Feeder <-  mutate(AHR_Feeder, Cumulative_Capital_Z_score = zscore1+zscore2+zscore3)
  return(AHR_Feeder)
  
}

#Maintenence
Cumulative_Maintenence_z_score <- function(a) {
  Per_lm <- (a / AHR_Feeder$`State Controlled Lane Miles`)
  Per_SHA <- (a / AHR_Feeder$SHA_Miles)
  Per_VMT <- (a / AHR_Feeder$Total_VMT)
  
  zscore1 <- scale(Per_lm, center = TRUE, scale = TRUE)
  zscore2 <- scale(Per_SHA, center = TRUE, scale = TRUE)
  zscore3 <- scale(Per_VMT, center = TRUE, scale = TRUE)
  AHR_Feeder <-  mutate(AHR_Feeder, Cumulative_maintenence_Z_score = zscore1+zscore2+zscore3)
  return(AHR_Feeder)
  
}
#Admin
Cumulative_Admin_z_score <- function(a) {
  Per_lm <- (a / AHR_Feeder$`State Controlled Lane Miles`)
  Per_SHA <- (a / AHR_Feeder$SHA_Miles)
  Per_VMT <- (a / AHR_Feeder$Total_VMT)
  
  zscore1 <- scale(Per_lm, center = TRUE, scale = TRUE)
  zscore2 <- scale(Per_SHA, center = TRUE, scale = TRUE)
  zscore3 <- scale(Per_VMT, center = TRUE, scale = TRUE)
  AHR_Feeder <-  mutate(AHR_Feeder, Cumulative_Admin_Z_score = zscore1+zscore2+zscore3)
  return(AHR_Feeder)
  
}

#Total
Cumulative_Total_z_score <- function(a) {
  Per_lm <- (a / AHR_Feeder$`State Controlled Lane Miles`)
  Per_SHA <- (a / AHR_Feeder$SHA_Miles)
  Per_VMT <- (a / AHR_Feeder$Total_VMT)
  
  zscore1 <- scale(Per_lm, center = TRUE, scale = TRUE)
  zscore2 <- scale(Per_SHA, center = TRUE, scale = TRUE)
  zscore3 <- scale(Per_VMT, center = TRUE, scale = TRUE)
  AHR_Feeder <-  mutate(AHR_Feeder, Cumulative_Total_Z_score = zscore1+zscore2+zscore3)
  return(AHR_Feeder)
  
}

#run "per" function first and then z score function right after for each in order for each - capital, maintenence, admin
#This keeps the database more organized for publishing 

#capital
AHR_Feeder <- Capital_Disbursements_Per(AHR_Feeder$`Capital Disbursements`)
AHR_Feeder <- Cumulative_Capital_z_score(AHR_Feeder$`Capital Disbursements`)

#maintenence
AHR_Feeder <- Maintenence_Disbursements_Per(AHR_Feeder$`Maintenence Disbursements`)
AHR_Feeder <- Cumulative_Maintenence_z_score(AHR_Feeder$`Maintenence Disbursements`)

#admin
AHR_Feeder <- Admin_Disbursements_Per(AHR_Feeder$`Administrative Disbursements`)
AHR_Feeder <- Cumulative_Admin_z_score(AHR_Feeder$`Administrative Disbursements`)

#Total
AHR_Feeder <- Total_Disbursements_Per(AHR_Feeder$`Total Disbursements`)
AHR_Feeder <- Cumulative_Total_z_score(AHR_Feeder$`Total Disbursements`)



#Road Conditions 
#Rural, IRI 170 
AHR_Feeder <- mutate(AHR_Feeder, Rural_Int_Condition_170 = AHR_Feeder$`Rural Interstate Poor Condition, Number of Miles, IRI > 170` / AHR_Feeder$`Rural Interstate Total Miles Measured`) 

#Urban, IRI 170 
AHR_Feeder <- mutate(AHR_Feeder, Urban_Int_Poor_Condition_170 = AHR_Feeder$`Urban Interstate Poor Condition Miles, IRI > 170` / AHR_Feeder$`Urban Interstate Total Reported`)

#Rural, OPA 220 
AHR_Feeder <- mutate(AHR_Feeder, Rural_OPA_Cond_220 = AHR_Feeder$`Rural Other Principal Arterial Poor Condition Miles, IRI> 220` / AHR_Feeder$`Rural Other Principal Arterial, Total`)

#Urban, OPA 220 
AHR_Feeder <- mutate(AHR_Feeder, Urban_OPA_Cond_220 = AHR_Feeder$`Urban Other Principal Arterial, Miles less than <220` / AHR_Feeder$`Urban Other Principal Arterial, Total`)

#Bridges
#Deficient only
AHR_Feeder <- mutate(AHR_Feeder, Percent_Def_Bridges = AHR_Feeder$`Deficient Bridges` / AHR_Feeder$`Highway Bridges`)

#Structurally Deficient (new term)
AHR_Feeder <- mutate(AHR_Feeder, Percent_SD_Bridges = AHR_Feeder$`Structurally Deficient Bridges` / AHR_Feeder$`Highway Bridges`)


#Fatalities per VMT 
#Total
AHR_Feeder <- mutate(AHR_Feeder, Total_Fatilities_Per_VMT = (AHR_Feeder$`Total Fatalities` / AHR_Feeder$Total_VMT) * 1000)

#Rural F-VMT
AHR_Feeder <- mutate(AHR_Feeder, Rural_Fatalities_Per_VMT = (AHR_Feeder$`Rural - I - OFE - OPA - Total Fatalities` / AHR_Feeder$`Rural VMT`) * 1000)

#Urban F-VMT
AHR_Feeder <-  mutate(AHR_Feeder, Urban_Fatalities_Per_VMT = (AHR_Feeder$`Urban - I - OFE - OPA Total Fatalities` / AHR_Feeder$`Urban VMT`) * 1000 )

AHR_final <- write.table(AHR_Feeder)


remove(AHR_Final_App_Data, AHR_final)


write.table(AHR_Feeder, file = "AHR_Final_App_Data.csv")