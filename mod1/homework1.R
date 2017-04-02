##############
# Homework 1 #
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
dir <- paste("/home/", username, "/Documents/Education/Chicago_Booth/Classes/35120_Portfolio_Management/homework1", sep = "")
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

getStats <- function(DF){
				stock <- DF$SP500_rtrn
				bond <- DF$BOND_rtrn

				stats <- data.frame(

							stock = c(	mean = mean(stock), 
										var = var(stock), 
										sd = sd(stock), 
										skew = skewness(stock), 
										kurt = kurtosis(stock)
									),

							bond  = c(	mean = mean(bond), 
										var = var(bond), 
										sd = sd(bond), 
										skew = skewness(bond), 
										kurt = kurtosis(bond)
									)

				)

				shape <- c(cov = cov(stock, bond), cor = cor(stock, bond))
				return(list(stats = stats, shape = shape))
}

kable(getStats(daily)$stats, digits = 4, caption = "Daily")
kable(t(getStats(daily)$shape), digits = 6)

kable(getStats(monthly)$stats, digits = 4, caption = "Monthly")
kable(t(getStats(monthly)$shape), digits = 6)

kable(getStats(annually)$stats, digits = 4, caption = "Annually")
kable(t(getStats(annually)$shape), digits = 6)


ggplot(data = daily) +
	geom_histogram(aes(SP500_rtrn), fill = "blue", color = "green", alpha = 0.5) +
	geom_histogram(aes(BOND_rtrn), fill = "red", color = "red", alpha = 0.5)

ggplot(data = monthly) +
	geom_histogram(aes(SP500_rtrn), fill = "blue", color = "green", alpha = 0.5) +
	geom_histogram(aes(BOND_rtrn), fill = "red", color = "red", alpha = 0.5)

ggplot(data = annually) +
	geom_histogram(aes(SP500_rtrn), fill = "blue", color = "green", alpha = 0.5) +
	geom_histogram(aes(BOND_rtrn), fill = "red", color = "red", alpha = 0.5)


getADVStats <- function(DF){
				stock <- DF$SP500_rtrn
				bond <- DF$BOND_rtrn

				error <- qnorm(0.975) * sd(stock) / sqrt(NROW(stock))
				CI_1 <- c(lower = mean(stock) - error, upper = mean(stock) + error)

				stock_30 <- na.omit(rollapply(stock, width = 30, mean))
				error_30 <- qnorm(0.975) * sd(stock_30) / sqrt(NROW(stock_30))
				CI_30 <- c(lower = mean(stock_30) - error_30, upper = mean(stock_30) + error_30)

				return(data.frame(period_1 = CI_1, period_30 = CI_30))

}

kable(getADVStats(daily), digits = 6, caption = "Daily")
kable(getADVStats(monthly), digits = 6, caption = "Monthly")
kable(getADVStats(annually), digits = 6, caption = "Annually")


getABSshortfall <- function(DF){
				stock <- DF$SP500_rtrn
				bond <- DF$BOND_rtrn

				ks <- c(-0.20, -0.10, 0, 0.10, 0.20)
				out <- matrix(NA, 5, 2, dimnames = list(ks, c("stock", "bond")))

				for(k in 1:NROW(out)){
					p <- as.numeric(rownames(out)[k])
					out[k, 1] <- pnorm(p, mean = mean(stock), sd = sd(stock))
					out[k, 2] <- pnorm(p, mean = mean(bond), sd = sd(bond))
				}

				return(out)
}

kable(getABSshortfall(daily), digits = 6, caption = "Daily")
kable(getABSshortfall(monthly), digits = 6, caption = "Monthly")
kable(getABSshortfall(annually), digits = 6, caption = "Annually")

getStockBondProb <- function(DF){
				stock <- DF$SP500_rtrn
				bond <- DF$BOND_rtrn

				num_times <- length(which(stock < bond)) # number of times stock return is lower than bond return
				prob <- num_times / NROW(DF) # number of times event happened over number of observations

				return(prob)
}

c(Daily = getStockBondProb(daily))
c(Monthly = getStockBondProb(monthly))
c(Annually = getStockBondProb(annually))
