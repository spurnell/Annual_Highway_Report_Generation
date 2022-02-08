library(tidyverse)

#HM74 <- read.csv("/Users/spencepurnell/Downloads/hm74_r - Base_Sheet (2).csv")

HM74 <- read.csv("/Users/spencepurnell/Downloads/hm_74_working_r - R.csv")

#Google Sheet: https://docs.google.com/spreadsheets/d/1ywMthCc0k64lx9FRwZcYoDxkIIUl4ChWND2b4hpi5JQ/edit#gid=649441673 

HM74 <- as.data.frame(HM74_1)

#Convert Appropriate Metrics to Numeric
HM74$Total_Miles <- as.numeric(gsub(",","", HM74$Total_Miles))

#Creates new True/False Coolumn for duplicate variables where TRUE = DUPLICATE 
HM74 <- HM74 %>% 
  group_by(City) %>%
  mutate(duplicate.flag = n() > 1) %>% 
  ungroup()  

#Creates df of duplictes 
HM74_Duplicates <- HM74 %>%
  filter(duplicate.flag == TRUE)

#Puts duplicates into one row to JOIN with ACS - make sure you know pivot_wider
HM74_Duplicates <- HM74_Duplicates %>%
  group_by(City) %>%
  mutate(rn = row_number()) %>%
  pivot_wider(id_cols = City, values_from = c(Key.State, Total_Miles), names_from = rn) 

#Add Total State Miles
HM74_Duplicates <- HM74_Duplicates %>%
  mutate(Total_Apportion_Miles = sum(Total_Miles_1, Total_Miles_2, Total_Miles_3, Total_Miles_4, Total_Miles_5, na.rm = TRUE))

#This is where you bring in the ACS and INRIX Data

ACS.Base <- read.csv("/Users/spencepurnell/Downloads/ACS_Raw_base - R.csv")

#Google Sheet: https://docs.google.com/spreadsheets/d/1impXZifliPe73TkoyPDISvELAWUM1srKPsM-lV-tZkI/edit#gid=1438594743 

INRIX.Base <- read.csv("/Users/spencepurnell/Downloads/Initial_Inrix - R.csv")

#Google Sheet: https://docs.google.com/spreadsheets/d/1iGi8MEgpkEXnKOqE7I6IqT8Vd5GJ3cL6Sj0WPapj18Q/edit#gid=559796889

AX_Joined <- full_join(ACS.Base, INRIX.Base, by = "City")

Final_Join <- full_join(AX_Joined, HM74_Duplicates, by = "City")

#The code starts to mess up after here and is just generally very poorly written code lol. Consider the rest a guide and not something exactly to replicate 

#Add key state miles - If City is in a single state, it uses the total.commuter (which beccause it is a single state it doesn't need adjusting)
Final_Join <-  Final_Join %>% #I couldn't get the following is.na to work for some reason but the basic idea is above
  mutate(Key_state1_adj_commuters = is.na(Final_Join$Total_Miles_1), Total.Commuters, ((Final_Join$Total_Miles_1/Total_Apportion_Miles)*Total.Commuters)) %>%
  mutate(Key_state2_adj_commuters = (Total_Miles_2/Total_Apportion_Miles)*Total.Commuters, na.rm = TRUE) %>%
  mutate(Key_state3_adj_commuters = (Total_Miles_3/Total_Apportion_Miles)*Total.Commuters, na.rm = TRUE) %>%
  mutate(Key_state4_adj_commuters = (Total_Miles_4/Total_Apportion_Miles)*Total.Commuters, na.rm = TRUE) %>%
  mutate(Key_state5_adj_commuters = (Total_Miles_5/Total_Apportion_Miles)*Total.Commuters, na.rm = TRUE) 
  
#Turn factors to characters (R sometimes converts them to factors I'm not sure why)
Final_Join <- Final_Join %>% mutate_if(is.factor, as.character)

#T for Testing (Unnecessary step but I forgot to remove this and am now too lazy to fix it all the way lol)
Final_Join_T <- Final_Join

#Creates master state key  - includes cities that are not multi-state 
Final_Join$Key.State_1 <-  ifelse(is.na(Final_Join$Key.State_1), Final_Join$State.x, as.character(Final_Join$Key.State_1))

#Creates adjusted INRIX number based on adjusted auto commuters 
Final_Join_T <- Final_Join_T %>% 
  mutate(INRIX_Hours_State1 = Hours.in.Congestion*Key_state1_adj_commuters) %>%
  mutate(INRIX_Hours_State2 = Hours.in.Congestion*Key_state2_adj_commuters) %>%
  mutate(INRIX_Hours_State3 = Hours.in.Congestion*Key_state3_adj_commuters) %>% 
  mutate(INRIX_Hours_State4 = Hours.in.Congestion*Key_state4_adj_commuters) %>% 
  mutate(INRIX_Hours_State5 = Hours.in.Congestion*Key_state5_adj_commuters)

#Aggregates INRIX Hours by state total 
INRIX.State.1 <- mutate(aggregate(Final_Join_T$INRIX_Hours_State1, by=list(Category=Final_Join_T$Key.State_1), FUN=sum, na.rm = TRUE)) 
INRIX.State.2 <- mutate(aggregate(Final_Join_T$INRIX_Hours_State2, by=list(Category=Final_Join_T$Key.State_2), FUN=sum, na.rm = TRUE)) 
INRIX.State.3 <- mutate(aggregate(Final_Join_T$INRIX_Hours_State3, by=list(Category=Final_Join_T$Key.State_3), FUN=sum, na.rm = TRUE)) 
INRIX.State.4 <- mutate(aggregate(Final_Join_T$INRIX_Hours_State4, by=list(Category=Final_Join_T$Key.State_4), FUN=sum, na.rm = TRUE)) 
INRIX.State.5 <- mutate(aggregate(Final_Join_T$INRIX_Hours_State5, by=list(Category=Final_Join_T$Key.State_5), FUN=sum, na.rm = TRUE)) 

#Aggregates adjusted auto commuters by state total 
Key.State.1.Totals <- mutate(aggregate(Final_Join_T$Key_state1_adj_commuters, by=list(Category=Final_Join_T$Key.State_1), FUN=sum, na.rm = TRUE)) 
Key.State.2.Totals <-  mutate(aggregate(Final_Join_T$Key_state2_adj_commuters, by=list(Category=Final_Join_T$Key.State_2), FUN=sum, na.rm = TRUE)) 
key.State.3.Totals <-  mutate(aggregate(Final_Join_T$Key_state3_adj_commuters, by=list(Category=Final_Join_T$Key.State_3), FUN=sum, na.rm = TRUE)) 
key.State.4.Totals <-  mutate(aggregate(Final_Join_T$Key_state4_adj_commuters, by=list(Category=Final_Join_T$Key.State_4), FUN=sum, na.rm = TRUE)) 
key.State.5.Totals <-  mutate(aggregate(Final_Join_T$Key_state5_adj_commuters, by=list(Category=Final_Join_T$Key.State_5), FUN=sum, na.rm = TRUE)) 

#Assigning INRIX Valeues to non-INRIX
Final_Join_T <- Final_Join_T %>% 
  mutate(Has_INRIX = ifelse(is.na(Final_Join_T$Hours.in.Congestion), TRUE, FALSE))

#Creates state average of INRIX 
X_Key.State.Averages <- Final_Join_T %>% 
  group_by(State.y) %>% 
  summarize(m=mean(Hours.in.Congestion))

#rename for joining 
X_Key.State.Averages <- X_Key.State.Averages %>% 
  rename(Key.State_1= State.y)

#Assign state averages back to cities 
INH_Final_Join_T <- full_join(Final_Join_T, X_Key.State.Averages, by = "Key.State_1")

#average commuter per state - used to create each cities ratio size to state average 
State_commuter_average <- INH_Final_Join_T %>% 
 group_by(Key.State_1) %>%
  summarize(m=mean(Total.Commuters))

#Joins average commuter data back to table 
XINH_Final_Join_T <- full_join(INH_Final_Join_T, State_commuter_average, by="Key.State_1")

#Creates each cities ratio to state's average total commuters 
XINH_Final_Join_T <- XINH_Final_Join_T %>%  
  mutate(Total.Commuters.Ratio = Total.Commuters/m.y)

#Creates Total INRIX hours per state 
XINH_Final_Join_T$INRIX_Hours_State1 <- XINH_Final_Join_T$Hours.in.Congestion * XINH_Final_Join_T$Key_state1_adj_commuters
XINH_Final_Join_T$INRIX_Hours_State2 <- XINH_Final_Join_T$Hours.in.Congestion * XINH_Final_Join_T$Key_state2_adj_commuters
XINH_Final_Join_T$INRIX_Hours_State3 <- XINH_Final_Join_T$Hours.in.Congestion * XINH_Final_Join_T$Key_state3_adj_commuters
XINH_Final_Join_T$INRIX_Hours_State4 <- XINH_Final_Join_T$Hours.in.Congestion * XINH_Final_Join_T$Key_state4_adj_commuters
XINH_Final_Join_T$INRIX_Hours_State5 <- XINH_Final_Join_T$Hours.in.Congestion * XINH_Final_Join_T$Key_state5_adj_commuters


#create df of total INRIX Hours 
X_State_Totals_INRIX_1 <- aggregate(XINH_Final_Join_T$INRIX_Hours_State1, by=list(Key.State_1=XINH_Final_Join_T$Key.State_1), FUN = sum, na.rm=TRUE)
X_State_Totals_INRIX_2 <- aggregate(XINH_Final_Join_T$INRIX_Hours_State2, by=list(Key.State_2=XINH_Final_Join_T$Key.State_2), FUN = sum, na.rm=TRUE)
X_State_Totals_INRIX_3 <- aggregate(XINH_Final_Join_T$INRIX_Hours_State3, by=list(Key.State_3=XINH_Final_Join_T$Key.State_3), FUN = sum, na.rm=TRUE)  
X_State_Totals_INRIX_4 <- aggregate(XINH_Final_Join_T$INRIX_Hours_State4, by=list(Key.State_1=XINH_Final_Join_T$Key.State_4), FUN = sum, na.rm=TRUE)
X_State_Totals_INRIX_5 <- aggregate(XINH_Final_Join_T$INRIX_Hours_State5, by=list(Key.State_1=XINH_Final_Join_T$Key.State_5), FUN = sum, na.rm=TRUE)

#Export the file with Total Inrix Hours lost in Congestion and attach to main database however you want 





