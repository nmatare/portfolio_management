##############
# Class Notes #
##############

########
# Load Config Files
########

options("width" = 250)
options(scipen  = 999)
options(digits  = 003)

library(xts); library(zoo); library(e1071); library(ggplot2); library(knitr)

set.seed(666) # the devils seed

username <- Sys.info()[["user"]]
dir <- paste("/home/", username, "/Documents/Education/Chicago_Booth/Classes/35120_Portfolio_Management/portfolio_management/mod1", sep = "")
setwd(dir)

getReturns <- function(name){
				returns <- read.csv(name, skip = 4, sep = "\t", header = FALSE)
				
				if(name == 'returns_annual.txt') 
					returns <- as.xts(returns[ ,-1], order.by = as.Date(as.character(returns[,1]), format = "%Y"))
				else 
					returns <- as.xts(returns[ ,-1], order.by = as.Date(as.character(returns[,1]), format = "%Y%m%d"))
				
				colnames(returns) <- c("SP500_rtrn", "BOND_rtrn")
				return(returns)
}

daily <- getReturns('returns_daily.txt')
monthly <- getReturns('returns_monthly.txt')
annually <- getReturns('returns_annual.txt')

