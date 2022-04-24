#1. reading csv
getwd()
options(repos = list(CRAN="http://cran.rstudio.com/"))
install.packages("tidyverse")
library(tidyverse)
stormdata <- read.csv("C:\\Users\\Amanda\\Downloads\\StormEvents_details-ftp_v1.0_d1994_c20210803.csv")

#2. limit dataframe
variables <- c("BEGIN_YEARMONTH", "BEGIN_DAY", "BEGIN_TIME", "END_YEARMONTH", "END_TIME", "EPISODE_ID", "EVENT_ID", "STATE", "STATE_FIPS", "CZ_NAME",
"CZ_TYPE", "CZ_FIPS", "EVENT_TYPE", "DATA_SOURCE", "BEGIN_LAT", "BEGIN_LON", "END_LAT", "END_LON")
stormsubset <- stormdata[variables]
head(stormsubset)

#3. arrange data by beginning year and month
arrange(stormsubset,BEGIN_YEARMONTH)

#4. change to title case
library(stringr)
stormsubset$state_title_case = str_to_title(stormsubset$STATE)
stormsubset$CZ_title_case = str_to_title(stormsubset$CZ_NAME)
head(stormsubset)

#5. Limit CZ type and remove column
stormsubset2 <- filter(stormsubset, CZ_TYPE=="C")
head(stormsubset2)
stormsubset3 <- select(stormsubset2,-CZ_TYPE)
head(stormsubset3)

#6. Uniting FIPS columns
stormsubset3$STATE_FIPS2 <- str_pad(stormsubset3$STATE_FIPS, width=3, side = "left", pad = "0")
head(stormsubset3)
stormsubset4 <- select(stormsubset3, -STATE_FIPS)
stormsubset5 <- unite(stormsubset4, col='fips', c('STATE_FIPS2','CZ_FIPS'), sep = "", remove = TRUE)
head(stormsubset5)

#7. rename to lowercase
rename_all(stormsubset5, tolower)
head(stormsubset5)

#8. state data in R
data("state")
us_state_info <- data.frame(state=state.name, region=state.region, area=state.area)
head(us_state_info)

#9. number of events per state
state_reference<-data.frame(table(stormsubset5$STATE))
head(state_reference)
state_reference1<-rename(state_reference, c("state"="Var1"))
us_state_info1<-mutate_all(us_state_info, toupper)
head(us_state_info1)
head(state_reference1)
merged <- merge(x=state_reference1,y=us_state_info1,by.x="state", by.y="state")
view(merged)
head(merged)

#10. Final Plot!
library(ggplot2)
storm_plot1 <- ggplot(merged, aes(x=area, y=Freq)) +
  geom_point(aes(color = region)) +
  labs(x = "Land Area (Square Miles)",
       y = "# of Storm Events in 1994")
storm_plot1