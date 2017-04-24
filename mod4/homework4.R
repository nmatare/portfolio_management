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

# Data Preperation
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
			apply(data[ ,c(2, 6, 10, 14, 18, 22)],2, as.numeric), 
			order.by = as.Date(as.character(data[ ,1]), format = "%Y%m%d")
		)
colnames(data) <- c("tbills", "XOM","PG", "PFE", "INTC", "WMT")

# Analysis
.getPortfolio <- function(data, portfolio, round_returns = FALSE, identity = FALSE, CAPM = FALSE, BAYES = FALSE){

	rfree  = data$tbills # risk free returns
	rtrns  = data[ ,-grep("tbills", colnames(data))] # expected returns
	ertrns = apply(rtrns, 2, function(x) as.vector(x) - as.vector(rfree)) # rtrns - rfree

	N = NCOL(ertrns) # number of assets
	i = rep(1, N) # necessary column of ones for MVP
	T = NROW(ertrns) # number or periods
	Vhat = cov(rtrns) # covariance of expected returns
	Ehat = apply(ertrns, 2, mean) # expectation of returns

	if(round_returns) 
		Ehat = round(Ehat, 2) # round to 2 decimal places	

	if(CAPM) 
		Ehat = c(0.6, 0.7, 1.2, 0.9, 1.2) * 0.005 # estimates based upon CAPM

	if(portfolio == "tangency"){ # tangency portfolio weights	
		weight = solve(Vhat, Ehat) / sum(solve(Vhat, Ehat)) # no identity matrix
		if(identity)
			weight = solve(Vhat, Ehat) / (Ehat %*% solve(Vhat, Ehat) * 100) # with identity matrix
	}

	if(portfolio == "mvp"){ # min var portfolio weights
		weight = solve(Vhat, i) / sum(solve(Vhat, i)) # lay calculation
		if(identity)
			weight = solve(Vhat, i) / (i %*% solve(Vhat, i)) # w/ identity matrix
	}

	if(BAYES){
		Ehat = (0.5 * Ehat) + (0.5 * c(0.6, 0.7, 1.2, 0.9, 1.2 * 0.005)) # layman bayesian estimate
		D = mean(diag(Vhat)) * diag(NCOL(Vhat)) # average of diagnonal * identity matrix
		Vb = 0.5 * Vhat + 0.5 * D # average of two matrices	
		weight = solve(Vb, Ehat) / sum(solve(Vb, Ehat)) # no longer have to invert matrix
	}

	portfolio_rtrn = Ehat %*% weight # E * w'
	portfolio_var  = weight %*% Vhat %*% weight # w' * V * w

	out = data.frame(E_rtrn = portfolio_rtrn, E_var = portfolio_var, t(weight))
	return(list(out, Ehat, Vhat))
}

Ehat = getPortfolio(data, portfolio = "tangency")[[2]]
Vhat = getPortfolio(data, portfolio = "tangency")[[3]]

kable(t(Ehat), digits = 4)
kable(Vhat, digits = 4)

out = getPortfolio(data, portfolio = "tangency")[[1]]
kable(out, digits = 4)

out = getPortfolio(data, portfolio = "mvp")[[1]]
kable(out, digits = 4)

out = getPortfolio(data, portfolio = "tangency", round_returns = TRUE)[[1]]
kable(out, digits = 4)

out = getPortfolio(data, portfolio = "tangency", identity = TRUE)[[1]]
kable(out, digits = 4)

out = getPortfolio(data, portfolio = "tangency", identity = TRUE, round_returns = TRUE)[[1]]
kable(out, digits = 4)

out = getPortfolio(data, portfolio = "tangency", CAPM = FALSE)[[1]]
kable(out, digits = 4)

out = getPortfolio(data, portfolio = "tangency", BAYES = TRUE)[[1]]
kable(out, digits = 4)


runStrategy <- function(data, init_period = 5,  ...){

	ep = endpoints(data, on = "months")

	result <- list()
	k <- 0; while(TRUE){

		period_end = ep[(1 + init_period * 12) + (k * 12)] # augment the data by period(k)
		if(period_end == tail(ep, 1)) break # end run

		data_insample = data[1:period_end]
		data_outsample = data[ep[(1 + init_period * 12) + (1 + k * 12)]:ep[(1 + 6 * 12) + (k * 12)]]
		
		forecast_weights = getPortfolio(data_insample, ... = ...)[[1]][-(1:2)] # get weights
		real_returns = data_outsample[ ,-grep("tbills", colnames(data_outsample))] # actual returns
		period_returns = real_returns %*% t(forecast_weights)

		result[[k + 1]] <- period_returns # store the returns for period k
		k <- k + 1
	}

	portfolio_returns = do.call(rbind, result)
	riskfree = data$tbills[-(1:(init_period * 12))] # first 60 periods is init training

	sharpe_ratio = mean(portfolio_returns - riskfree) / sd(portfolio_returns - riskfree) # sharpe ratio
	mean_return = mean(portfolio_returns)
	out = data.frame(mean_return, sharpe_ratio)
	return(out)	
}

base = runStrategy(data, portfolio = "tangency")
identity = runStrategy(data, portfolio = "tangency", identity = TRUE)
capm = runStrategy(data, portfolio = "tangency", CAPM = TRUE)
bayes = runStrategy(data, portfolio = "tangency", BAYES = TRUE)

out <- rbind(base, identity, capm, bayes)
rownames(out) <- c("Base", "Identity", "CAPM", "Bayes")
kable(t(out), digits = 6)