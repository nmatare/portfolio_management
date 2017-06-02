##############
# Homework 10 #
##############

########
# Load Config Files
########

options("width" = 250)
options(scipen  = 999)
options(digits  = 003)

library(xts); library(zoo); library(e1071); library(R.matlab)
library(ggplot2); library(knitr); library(gridExtra); library(Hmisc)
library(reshape2); library(foreach); library(doMC)

set.seed(666) # the devils seed

username 	<- Sys.info()[["user"]]
dir 		<- paste("/home/", username, "/Documents/Education/Chicago_Booth/Classes/35120_Portfolio_Management/portfolio_management/mod10", sep = ""); setwd(dir)

data <- read.csv("sp500_daily.csv", header = TRUE)
data <- as.xts(data[ ,-1], order.by = as.Date(as.character(data[,1]), format = "%Y%m%d"))

# init parameters 

startdate 		<- 19940301
moneyness 		<- 0.80
beg_capital 	<- 50 # start with 50M in capital
target_return 	<- 0.04 
sp_volatility 	<- sd(data$sprtrn)
tbill_return 	<- 0.0001


computeOptionPrice <- function(S, K, T, rf = tbill_return, sigma = sp_volatility){
	# Implementation of theBlack-Scholes Option Value
	# S is the price of the stock
	# K is the strike price
	# rf is the risk free rate
	# T is the time
	# sigma is the implied s&p volatility
	d1 <- (log(S/K)+(rf+sigma^2/2)*T)/(sigma*sqrt(T))
	d2 <- d1 - sigma * sqrt(T)

	call <- S*pnorm(d1) - K*exp(-rf*T)*pnorm(d2)
	put <- call + K*exp(-T*rf) - S 
	# put <- K*exp(-rf*T) * pnorm(-d2) - S*pnorm(-d1) # alternative way of doing same calc

	return(list(bs_call = call, bs_put = put))
}


ledger <- data
runStrategy <- function(ledger = data, ...){

	# cut ledger based upon startdate
	start_date  <- as.Date(as.character(startdate), format = "%Y%m%d")
	ledger 		<- ledger[which(index(ledger) == start_date):NROW(ledger)]

	ledger$bs_put 		<- NA
	ledger$capital 		<- NA
	ledger$N 			<- NA
	ledger$returns 		<- NA
	ledger$compensation <- NA
	ledger$sp500return  <- NA

	monthly_eps <- endpoints(ledger, on = "months")[-1]
	daily_eps 	<- endpoints(ledger, on = "days")[-1]

	# init portfolio
	stock_price  = first(ledger)$spindx
	strike_price = first(ledger)$spindx * moneyness
	first_put <- computeOptionPrice(
					S = stock_price,
					K = strike_price,
					T = 60
				)$bs_put

	num_puts 	= target_return * beg_capital / as.numeric(first_put) # number of puts needed for target return
	new_capital = beg_capital * (1 + target_return); # targeted return

	# record first events
	coredata(ledger)[1, 'capital']  <- new_capital
	coredata(ledger)[1, 'bs_put']  	<- first_put
	coredata(ledger)[1, 'N'] 		<- num_puts

	# start loop
	k <- 1; while(new_capital > 0){

		ep 				<- 	daily_eps[1 + k] # daily endpoint
		if(is.na(ep)) 		break

		period_before 	<- last(index(ledger[1:ep]), 2)[1]
		period_date 	<- last(index(ledger[1:ep]), 2)[2]

		old_capital <- as.numeric(ledger[period_before]$capital) # starting capital
		new_capital = old_capital * (1 + tbill_return) # appreciated interest

		if(period_date %in% index(ledger[monthly_eps])){ # do at end of each month

			print(paste("Exercising options at the end of month:", period_date))

			# write off old options
			stock_price  = ledger[period_date]$spindx # get current price level
			bs_put <- computeOptionPrice(
					S = as.numeric(stock_price),
					K = as.numeric(strike_price), # comes from init strike price or 30 days ago strike price
					T = 30
				)$bs_put

			bs_cost <- bs_put * num_puts # number of puts wrote in last period
			new_capital = new_capital - bs_cost # update capital after puts are written off

			# write new options
			strike_price = ledger[period_date]$spindx * moneyness # get current strike price
			bs_put <- computeOptionPrice(
					S = as.numeric(stock_price),
					K = as.numeric(strike_price), 
					T = 60
				)$bs_put

			num_puts = target_return * as.numeric(new_capital) / as.numeric(bs_put) # number of puts needed for target return
			new_capital = new_capital * (1 + target_return);

			# record option price and number
			coredata(ledger)[index(ledger) == period_date][3] <- bs_put
			coredata(ledger)[index(ledger) == period_date][5] <- num_puts

			# compute compensation and metrics
			rtrn 		= (new_capital - old_capital) / old_capital
			coredata(ledger)[index(ledger) == period_date][6] <- rtrn

			compensation = (0.02 / 12 + 0.20 * max(rtrn - 21 * tbill_return, 0)) * old_capital
			new_capital  = new_capital - compensation

			# record capital and others
			coredata(ledger)[index(ledger) == period_date][7] <- compensation
		}

		coredata(ledger)[index(ledger) == period_date][4] <- new_capital
		k <- k + 1
	}

	print("Ran out of money!")
	return(ledger)
}

runStrategy(
	startdate = 19940301,
	moneyness = 0.80,
	beg_capital = 50, 
	target_return = 0.04,
	sp_volatility = sd(data$sprtrn),
	tbill_return = 0.0001
)

getSharpeRatio <- function


