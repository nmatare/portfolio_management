##############
# Homework 4 #
##############

########
# Load Config Files
########

options("width" = 250)
options(scipen  = 999)
options(digits  = 003)

library(xts); library(zoo); library(e1071); 
library(ggplot2); library(knitr); library(gridExtra)
library(reshape2); library(foreach); library(doMC)

set.seed(666) # the devils seed

username 	<- Sys.info()[["user"]]
dir 		<- paste("/home/", username, "/Documents/Education/Chicago_Booth/Classes/35120_Portfolio_Management/portfolio_management/mod4", sep = ""); setwd(dir)

tbills <- read.csv("TB_7301_1612.csv", header = TRUE, stringsAsFactors = FALSE)
stocks <- read.csv("STOCK_RETS.csv", header = TRUE, stringsAsFactors = FALSE)[ ,-1]

data <- cbind(	
			tbills, 
			stocks[stocks$COMNAM == "EXXON MOBIL CORP" | stocks$COMNAM == "EXXON CORP", ], 
			stocks[stocks$TICKER == "PG", ],
			stocks[stocks$TICKER == "PFE", ],
			stocks[stocks$TICKER == "INTC", ],
			stocks[stocks$TICKER == "WMT", ]
		)

data <- as.xts(
			apply(data[ ,c(2, 6,10,14, 18, 22)],2, as.numeric), 
			order.by = as.Date(as.character(data[ ,1]), format = "%Y%m%d")
		)
colnames(data) <- c("tbills", "XOM","PG", "PFE", "INTC", "WMT")

# 1. Estimating E and V by the sample estimates.