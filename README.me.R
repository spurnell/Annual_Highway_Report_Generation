#These are the steps taken to generate the proprietary calculated metrics

Live Google doc is here: https://docs.google.com/document/d/1YNnyzyfAGULTi-MvvRZwMsKbVyFbpPnn1VAJt4QY0vs/edit

Capital Disbursement Data for 2018 does not appear to be released (03/31/2020)  

Process: 

Collect FHWA ‘Base Variables’ - https://www.fhwa.dot.gov/policyinformation/statistics.cfm 
Order alphabetically by state and 
remove Washington, DC and Puerto Rico 
Aggregate Base Variables into Google Sheet called “R_Feeder”
This “feeds” the data into R from the Google sheet 
Access R_Feeder using ‘range_read’ from package ‘GoogleSheets4” 
Create ‘Calculated Variables’ from base variables using R
Using cbind and rbind to join any dataframes created in calculation 
Construct master dataframe 
Setwd to Annual Highway Folder 
Using “write.table” save the master dataframe to local machine 
Upload file to appropriate Google Drive and Dropbox folders. 


Bridge data is a year behind? https://www.fhwa.dot.gov/bridge/nbi/no10/fccount17.cfm 

Base variables - Used as base to create “Calculated Variables” (Excluding congestion)
Total Mileage Under Control
SHA Miles
Lane Miles
Capital and Bridge Disbursements
Maintenance Distributions 
Administrative Distributions
Total Distributions 
IRI Road Condition 
Total Reported miles
Rural Interstate
ROPA
Urban Interstate
UOPA
Count of “Poor” Miles
>170 Rural Interstate
>220 ROPA
>170 Urban Interstate
>220 UOPA
Urban VMT  (I-OFE-OPA)
Rural VMT (I-OFE-OPA)
Total VMT 
Count of Total Bridges
Count of SD Bridges 
Fatalities 
Rural Facilities (I-OFE-OPA)
Urban Fatalities (I-OFE-OPA)


Calculated Variables - Proprietary calculations using “Base Variables” 
Disbursements per Miles, Lane Miles, and VMT  
Capital 
Maintenance
Administration 
Total
For all Four  - /Miles+Lane Miles+ Total VMT - See notes 
Road Condition
% Rural interstate in poor condition
>170 IRI Rural Interstate / Total Rural Interstate
% Urban interstate in poor condition
>170 IRI Urban Interstate / Total Urban Interstate
% ROPA in poor condition 
>220 ROPA / Total ROPA
% UOPA in poor condition 
> UOPA / Toal UOPA 
Urban Congestion - See notes 
Simplified Steps:
Get number of auto commuters per city
Some cities are split between states - must apportion commuters properly using Daily Vehicles Miles Traveled (DVMT)
Identify cities without Inrix congestion data
Impute Inrix values to cities without Inrix Data
Calculate Average Inrix (Hours Lost in Congestion) Data Per State 
https://inrix.com/scorecard/
Structurally Deficient Bridges 
Count SD Bridges / Total Bridges 
Fatalities 
Total Fatalities per VMT 
Total Fatalities / VMT 
Rural Fatality Rate
Rural Fatalities / Rural VMT 
Urban Fatality Rate 
Urban Fatalities / Urban VMT 
FOR ALL VARIABLES 











	
Old email about the concept of congestion rankings and how to get them:

Spence;
 
This is complicated, so some background.  This is the 4th urban congestion metric used in the last 8 years:
 
 
1. In 2010 and before, we used V/C (volume/capacity) ratios for Urban Interstate LM.  Data came from HM-42 and is no longer published by FHWY.
 
2. From 2011-2013, we used % Fwy LM Congested.  Data came from TTI's Urban Mobility Report.
 
3. In 2014, we changed from a congested mileage metric to one that focused on the commuter, one which we felt would resonate more with the report readers.  This metric, Annual Hrs of Delay per Auto Commuter also came from the UMR.
 
4. Last year we changed metrics again following the decision not to publish the UMR annually.  We selected the Peak Hours in Congestion metric from the INRIX Scorecard.  (The notes at the bottom of the INRIX scorecard indicate this year's column "Hours Spent in Congestion" is the same as last year's "Peak Hours in Congestion.")
 
The decision to use this INRIX dataset creates some problems. 
1. When we chose this metric, we decided to consider urban congestion as a problem that affected only the metropolitan areas (pops over 50k).  Congestion in micropolitan areas (pops of 5-50k) and rural areas was excluded from consideration.
 
2. In the various data tables used in our calculations, cities, urban areas and metropolitan areas are not the same geographies; we try to use ratio measures for these areas to reduce the impacts of any differences.
 
3. There were 240 US cities in last year's INRIX report; this year's may have more.  (I cannot access the report with my home e-mail address, so I can only see what’s on the website.) Of these 240, many are either micropolitan areas or sub-areas within a metropolitan area, rather than metropolitan areas themselves.  So we need to reduce this 240 by eliminating the micro areas and sub-areas and keeping only the metro areas.
 
4. The 240 INRIX cities are a subset of the over 500 metro areas in the US, so we’ll need to extend the INRIX data for the ‘surviving’ metro cities to the rest of the metros in the country.
 
5. The 240 INRIX cities also include cities that extend into 2 or more states.  Since the Highway Report compares states, we need to partition these cities by state, assuming that the INRIX congestion data is uniform throughout the city (i.e. the 91 hrs spent in congestion in NYC is the same for the portions of the city in NY, NJ and CT).
 
6. Since the Highway Report is by state, we need to weight the various city metrics so that a single state metric can be reached.
 
So what to do first.  After much trial and error, I followed the procedures in the report development guide.
1. The DVMT data for multi-state urbanized areas (from HM-74) are apportioned by state and the percentages of the DVMT in each state are calculated based on total reported DVMT. (This is independent of any of the other tables.  I rolled up the HM-74 tabs A-H into one long table; deleted all columns but the Unreported, Interstate Total Reported, OFE Total Reported, OPA Total reported and MA Total Reported; and summed these four columns to get total DVMT. I copied this to another tab and then identified all those urbanized areas that were in two or more states.  I deleted the single state UAs.  For each of the remaining multi-state UAs, I summed the DVMT from the state portions, and using this sum as the denominator, I calculated the percentage of the DVMT that fell in each state.)
 
2. The American Community Survey (S0802) table is cleaned and culled to show for each metropolitan area just the ‘Workers 16 years and over’ by the three commuting modes ‘Car, truck, or van -- drove alone;’ ‘Car, truck, or van – carpooled;’ and, ‘Public transportation (excluding taxicab).’   (Here I was trying to get the number of auto commuters so I could weight the city totals and then roll them up by state.  As it turned out, I used the cleaned and culled table as my base table.  S0802 has many columns and I used only the first four: city, commuting means, estimate/margin of error, and workers 16 and over.  Each city has eight rows four each for the estimates and for the margin of error.  In step 1, I deleted all the columns after the first four.  In step 2, I deleted the margins of error rows.  In step 3, I transposed the data so that I had one row per city with five columns: city, total workers 16+, drove alone, carpooled and public transportation.  I calculated total auto commuters by summing the drove alone and carpooled columns, assuming that the average carpool occupancy was 2.2 persons.  (There was a citation for this in the last report.)  So now I had the number of auto commuters for weighting purposes.)
 
3. Using American Community Survey data as the base table, the INRIX city data are linked to the ACS metro areas. Many of the 240 INRIX cities are either micropolitan areas (populations below 50,000) or are included with one or more other INRIX cities in a single metropolitan area. (We use only the largest INRIX city available to represent each metro area and exclude the smaller cities in the metro areas, as well as the micropolitan areas.) (This is a tedious process as numerous data manipulations are needed. I split city-state name columns into city and state columns, I added several additional state columns for use with the multi-state cities, and I added several percentage columns to be used with the multi-state cities (percentage of the DVMT in each state).  It’s also tedious matching the INRIX city data to the ACS (S0802) metro data, especially as some of the INRIX cities will not match up because they are micro areas and sub-areas.)
 
4. The DVMT percentages for the multi-state cities are now linked to the base table. (I added these to the percentage columns created above.)
 
5. The “Peak Hours Spent in Congestion” metric is calculated for each non-INRIX metro based on national averages of groupings of the numbers of auto commuters. (We use national averages rather than state averages because the number of data points for the individual states are most often inadequate for a good average.) The metric is then weighted by the number of auto commuters. (Here I sorted the spreadsheet by INRIX metric (Peak Hrs Spent in Congestion), which puts all the non-INRIX cities at the bottom.  I then sorted the top and bottom of the spread sheet separately by auto-commuters, which puts the larger of each type (INRIX or non-INRIX at the head of their section.  I then separated the INRIX cities into several somewhat arbitrary groupings based on auto commuters (1-2M, 900-1000K, 8-900K, 6-800K, 5-600K, 4-500K, 3-400K, 2-300K, 150-200K, 100-150K, 75-100K, 50-75K, 0-50K), calculated the average INRIX metric for the cities in each group, and then assigned those values to the non-INRIX cities in the same group. TIP: I also used different color fonts for the two groups to help differentiate them when sorted together.  Once I had the INRIX metric for each city, I sorted by state and added two columns: “INRIX PH in Cong x Auto Cmtr X Pct” and “Adjusted Auto Commuters”.  The first I filled as noted with the Pct being the percentage of DVMT in each state, which for most cities is 1.00. The second I filled with auto commuters x pct.)
 
6. An MS Excel pivot table is used to sum the “Weighted Peak Hours Spent in Congestion” metric and the “Auto Commuters” totals by state. Finally, the former is divided by the latter to get the state’s Peak Hours Spent in Congestion figure.
 
7. Enter data into master spreadsheet.
 
I hope this helps. I'm also attaching two Excel docs: one shows the ACS calcs and the other the congestion calcs.  They are somewhat jumbled as I was figuring this out as I went, so there are several worksheets that are not really needed.  I hope you can follow what I've done.  If not, let me know.
 


02/02/2022 

Where I messed up was not tracking code closely enough from apportioning Miles in HM-74 to to Joining it with ACS and INRIX data.  

We also decided to stop using the process in step 5 above 

I then separated the INRIX cities into several somewhat arbitrary groupings based on auto commuters (1-2M, 900-1000K, 8-900K, 6-800K, 5-600K, 4-500K, 3-400K, 2-300K, 150-200K, 100-150K, 75-100K, 50-75K, 0-50K), calculated the average INRIX metric for the cities in each group, and then assigned those values to the non-INRIX cities in the same group.) 


We are now using the state average instead of this size grouping. Ideally this year we would use the state average and then weight is based on the size somehow.  Reminder that this is used to impute Inrix values to all the cities in the ACS database so we can calculate hours lost in congestion per state.


