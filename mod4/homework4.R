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
			apply(data[ ,c(2, 6, 10, 14, 18, 22)],2, as.numeric), 
			order.by = as.Date(as.character(data[ ,1]), format = "%Y%m%d")
		)
colnames(data) <- c("tbills", "XOM","PG", "PFE", "INTC", "WMT")

# 1. Estimating E and V by the sample estimates.

E = coredata(data)[ ,-1]
V = 


N = 30;                   #  % number of assets
T = 1200;               #      % number of months
rho = 0.6;                #  % return correlation across assets
e = 0.01;                 #  % expected excess returns, monthly
sigma = 0.01;             # % standard deviation of returns, monthly

E = rep(e, N) # true expected return
V = sigma ^ 2 * (diag(N) + matrix(rho, N, N) - diag(N) * rho) # identity matrix

R = e + replicate(N, rnorm(T)) %*% chol(V) # say returns are from normal dist given correlation
Ehat = apply(R, 2, mean) # get expected mean of asset
Vhat = cov(R) # estimated correlation

# tangency portfolio weights
true_weight = solve(V, E) / (E %*% solve(V, E) * 100) # slide 9: wMVP = (V^-1)i / i`(V^-1)i'
estimate_weight = solve(Vhat, Ehat) / (Ehat %*% solve(Vhat, Ehat) * 100)

solve(Vhat, Ehat) / (Ehat %*% solve(Vhat, Ehat) * 100)

# minimum variance portfolio weights

i = rep(1, N) # necessary column of ones for MVP
wMVP = solve(V, i) / (i %*% solve(V, i))

(inv(V) * ones(2, 1)) / (ones(1,2) * inv(V) * ones(2, 1)) #mvp

getPortfolio <- function(data, portfolio, round_returns = FALSE, CAPM = FALSE, 
						 BAYES_lay = FALSE, BAYES_real = FALSE){

	rfree  = data$tbills # risk free returns
	rtrns  = data[,-grep("tbills", colnames(data))] # expected returns
	ertrns = apply(rtrns, 2, function(x) as.vector(x) - as.vector(rfree)) # rtrns - rfree

	N = NCOL(ertrns) # number of assets
	i = rep(1, N) # necessary column of ones for MVP
	T = NROW(ertrns) # number or periods
	Vhat = cov(rtrns) # covariance of expected returns
	Ehat = apply(ertrns, 2, mean) # expectation of returns

	# identify matrix ??
	# avgsig2 = mean(diag(V1));
	# V3 = 0.5*V1+0.5*avgsig2*   eye(size(V1));

	# rho = mean(diag(Vhat))
	# Vidn = sigma ^ 2 * (diag(N) + matrix(rho, N, N) - diag(N) * rho) # identity matrix

	# 0.5 * Vhat + 0.5 * rho * diag(dim(Vhat))

	if(CAPM) Ehat = c(0.6, 0.7, 1.2, 0.9, 1.2) * 0.005 # estimates based upon CAPM

	if(BAYES_lay){
		Ehat = (0.5 * Ehat) + (0.5 * c(0.6, 0.7, 1.2, 0.9, 1.2 * 0.005)) # layman bayesian estimate
		D = mean(diag(Vhat)) * diag(NCOL(Vhat)) # average of diagnonal * identity matrix
		Vhat = 0.5 * Vhat + 0.5 * D # average of two matrices	
	}

	if(round_returns) Ehat = round(Ehat, 2) # round to 2 decimal places	

	if(portfolio == "tangency") 
		weight = solve(Vhat, Ehat) / (Ehat %*% solve(Vhat, Ehat) * 100) # tangency portfolio weights

	if(portfolio == "mvp") 
		weight = solve(Vhat, i) / (i %*% solve(Vhat, i)) # min var portfolio weights

	portfolio_rtrn = Ehat %*% weight # E * w'
	portfolio_var = weight %*% Vhat %*% weight # w' * V * w

	out = data.frame(E_rtrn = portfolio_rtrn, E_var = portfolio_var, t(weight))
	return(out)
}

