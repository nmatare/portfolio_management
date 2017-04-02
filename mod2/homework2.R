##############
# Homework 2 #
##############

########
# Load Config Files
########

options("width" = 250)
options(scipen  = 999)
options(digits  = 003)

library(xts); library(zoo); library(e1071); library(ggplot2); library(knitr); library(gridExtra)

set.seed(666) # the devils seed

username 	<- Sys.info()[["user"]]
dir 		<- paste("/home/", username, "/Documents/Education/Chicago_Booth/Classes/35120_Portfolio_Management/portfolio_management/mod2", sep = "")
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

daily 			<- getReturns('returns_daily.txt')
monthly 		<- getReturns('returns_monthly.txt')
annually 		<- getReturns('returns_annual.txt')

# Notes
# This is the same thing
# 1 - pnorm(q = (0.05 - mean(annually$SP500_rtrn)) / sd(annually$SP500_rtrn), mean = 0, sd = 1, lower.tail = TRUE)
# pnorm(q = (0.05 - mean(annually$SP500_rtrn)) / sd(annually$SP500_rtrn), mean = 0, sd = 1, lower.tail = FALSE)

# Question 1 and 2

makeAbsShortfall <- function(returns, title, sim_obs = 10000){
	
	makeZScore <- function(x){

		rtrn_mean <- mean(x) 
		rtrn_sd <- sd(x)
		z_scores <- seq(
					from = rtrn_mean - 2 * rtrn_sd, 
					to = rtrn_mean + 2 * rtrn_sd,
					by = 4 * rtrn_sd / 100)
		return(z_scores)	
	}

	# Question 1; compute Prob(z < Z) via pnorm
	rtrn_zscore <- makeZScore(returns)
	pvalues <- pnorm(rtrn_zscore, mean = mean(returns), sd = sd(returns))

	# Draw from standard normal; compute Prob(z < Z) via pnorm
	simulation <- rnorm(sim_obs, mean = mean(simulation), sd = sd(simulation))
	sim_zscore <- makeZScore(simulation)
	pvalues_sim <- pnorm(sim_zscore, mean = mean(simulation), sd = sd(simulation))
	
	# Bootstrap; compute Prob(z < Z) via pnorm
	bootstrap <- sample(x = matrix(returns), size = sim_obs, replace = TRUE)
	bootstrap_zscore <- makeZScore(bootstrap)
	pvalues_bootstrap <- pnorm(bootstrap_zscore, mean = mean(bootstrap), sd = sd(bootstrap))
	
	frame <- data.frame(pValue = pvalues, Actual = rtrn_zscore, Bootstrap = bootstrap_zscore, Simulation = sim_zscore)

	p1 <- ggplot(melt(frame, id = "pValue")) +
			geom_line(aes(x = value, y = pValue, colour = variable)) +
			xlab(NULL) +
			ylab(NULL) +
  			theme(axis.title.y = element_blank(), axis.text.y = element_blank(), axis.ticks.y = element_blank()) +
			scale_colour_manual(values = c("salmon", "darkgrey", "black"), guide = guide_legend(title = NULL))

	p2 <- ggplot(melt(frame[,-4], id = "pValue")) +
			geom_line(aes(x = value, y = pValue, colour = variable)) +
			xlab(NULL) +
			ylab("Probability Density") +
			scale_colour_manual(values = c("salmon", "darkgrey"), guide = guide_legend(title = NULL)) +
			theme(legend.position = "none")

	p_out <- grid.arrange(p2, p1, ncol = 2, top = title, bottom = "Absolute Shortfall Probability")
	detail <- rbind(head(frame, 3), tail(frame, 3))
	return(list(plot = p_out, detail = detail))
}

# Stocks

stock_daily_answer <- makeAbsShortfall(daily$SP500_rtrn, title = "Daily Shortfall (Stock)")
kable(stock_daily_answer$detail, digits = 6, caption = "Daily")

stock_monthly_answer <- makeAbsShortfall(monthly$SP500_rtrn, title = "Monthly Shortfall (Stock)")
kable(stock_monthly_answer$detail, digits = 6, caption = "Monthly")

stock_annually_answer <- makeAbsShortfall(annually$SP500_rtrn, title = "Annual Shortfall (Stock)")
kable(stock_annually_answer$detail, digits = 6, caption = "Annually")

# Bonds

bond_daily_answer <- makeAbsShortfall(daily$BOND_rtrn, title = "Daily Shortfall (Bonds)")
kable(bond_daily_answer$detail, digits = 6, caption = "Daily")

bond_monthly_answer <- makeAbsShortfall(monthly$BOND_rtrn, title = "Monthly Shortfall (Bonds)")
kable(bond_monthly_answer$detail, digits = 6, caption = "Monthly")

bond_annually_answer <- makeAbsShortfall(annually$BOND_rtrn, title = "Annual Shortfall (Bonds)")
kable(stock_annually_answer$detail, digits = 6, caption = "Annually")

# Question 3, 4, and 5

K <- 0.20
T <- 5
R <- matrix(anuually$SP500_rtrn) 
r <- log(1 + R)
mu <- mean(r)
sigma2 <- var(r)
ElnVT <- T * mu
VarlnVT <- T * sigma2


q <- (log(K) - T * mu) / (sqrt(T) * sqrt(sigma2))
pnorm(q)
pnorm(log(K), mean = mu * T, sd = sqrt(sigma2) * sqrt(T))




pnorm(log(K), mean = mu * T, sd = sqrt(sigma2) * sqrt(T))

log(K)

# 1 - pnorm(q = (0.05 - mean(annually$SP500_rtrn)) / sd(annually$SP500_rtrn), mean = 0, sd = 1, lower.tail = TRUE)