##############
# Homework 2 #
##############

########
# Load Config Files
########

options("width" = 250)
options(scipen  = 999)
options(digits  = 003)

library(xts); library(zoo); library(e1071); 
library(ggplot2); library(knitr); library(gridExtra)
library(reshape2)

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

# Part B
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
	simulation <- rnorm(sim_obs) # draw from standard normal
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

# Question 3
probReturn <- function(R, K = 1.20, T = 5){ # remeber to add 1 to K because of cum return
	R <- matrix(R)
	r <- log(1 + R) # turn return series into cum return
	mu <- mean(r)
	sigma2 <- var(r)

	# Prob Vt < K
	1 - pnorm(log(K), mean = mu * T, sd = sqrt(sigma2) * sqrt(T))

	# formulaic approach; Prob(z < ln(K) - Tu / sqrt(T) *(sigma))
	Z <- (log(K) - T * mu) / (sqrt(T) * sqrt(sigma2))
	out <- as.numeric(1 - pnorm(Z))
	return(out)
}

makeTable <- function(parent_function){

	out <- cbind.data.frame(
			stocks = rbind(
				eval(parent_function(R = annually$SP500_rtrn)),
				eval(parent_function(R = monthly$SP500_rtrn)),
				eval(parent_function(R = daily$SP500_rtrn))
				),

			bonds = rbind(
				eval(parent_function(R = annually$BOND_rtrn)),
				eval(parent_function(R = monthly$BOND_rtrn)),
				eval(parent_function(R = daily$BOND_rtrn))),
			row.names = c("Annually", "Monthly", "Daily")
	)

	out <- kable(out, digits = 6)
	return(out)
}

makeTable(probReturn)

# Question 4
simKnownDist <- function(R, K = 1.20, T = 5, sim_obs = 10000){

	R_sims <- replicate(sim_obs, rnorm(T, mean = mean(R), sd = sd(R))) # sim_obs (n) draws from standard normal(given known params) for T periods
	
	Vt <- apply(R_sims, 2, function(x) prod(x + 1)) # prod return series; each simulation addes 1 (because of cum) then is n1 X n2 x n3 x nn
	Vt_log <- apply(R_sims, 2, function(x) exp(sum(log(x + 1)))) # from log'ed return series; now logged so it is the sum
	stopifnot(all.equal(Vt, Vt_log))

	prob_Vt_greater_than_K <- length(which(Vt_log > K)) / sim_obs # objective; since question asks for log_normal
	return(prob_Vt_greater_than_K)
}

makeTable(simKnownDist)

# Question 5
simBootstrap <- function(R, K = 1.20, T = 5, sim_obs = 10000){

	R_sims <- replicate(sim_obs, sample(R, T), simplify = FALSE) # sim_obs (n) draws from data(bootstrap, given that returns are i.i.d) for T periods
	
	Vt <- lapply(R_sims, function(x) prod(x + 1)) # prod return series; each simulation addes 1 (because of cum) then is n1 X n2 x n3 x nn
	Vt_log <- lapply(R_sims, function(x) exp(sum(log(x + 1)))) # from log'ed return series; now logged so it is the sum
	stopifnot(all.equal(Vt, Vt_log))

	prob_Vt_greater_than_K <- length(which(Vt_log > K)) / sim_obs # objective; since question asks for log_normal
	return(prob_Vt_greater_than_K)
}

makeTable(simBootstrap)

# Question 6
stock.VS.bonds.Analytical <- function(Ra, Rb, T = 30, sim_obs = 10000){

	Ra <- matrix(Ra)
		ra <- log(1 + Ra) # turn return series into cum return
		mu_a <- mean(ra)
		sigma2_a <- var(ra)

	Rb <- matrix(Rb)
		rb <- log(1 + Rb)
		mu_b <- mean(rb)
		sigma2_b <- var(rb)

	rho <- cor(Ra, Rb) # rho; not used
	E_delta <- T * (mu_a - mu_b)
	sigma2_delta <- T * (sigma2_a - sigma2_b)

	# Prob(z < Z)
	Z <- -E_delta / sqrt(sigma2_delta)
	out <- pnorm(Z)
	return(out)
}

makeTable2 <- function(parent_function, ...){
	
	out <- rbind.data.frame(
				eval(parent_function(
					Ra = daily$SP500_rtrn, 
					Rb = daily$BOND_rtrn,
					... = ...
				)),
				eval(parent_function(
					Ra = monthly$SP500_rtrn, 
					Rb = monthly$BOND_rtrn,
					... = ...
				)),
				eval(parent_function(
					Ra = annually$SP500_rtrn, 
					Rb = annually$BOND_rtrn, 
					... = ...
				))
			)
	colnames(out) <- paste("T = ", ..., sep = "")
	rownames(out) <- c("Daily", "Monthly", "Annually")
	out <- kable(out, digits = 6)
	return(out)
}

makeTable2(stock.VS.bonds.Analytical, T = 5)
makeTable2(stock.VS.bonds.Analytical, T = 30)
makeTable2(stock.VS.bonds.Analytical, T = 100)

# Question 7
stock.VS.bonds.Bootstrap <- function(Ra, Rb, T = 30, sim_obs = 10000){

	sample_indices <- replicate(sim_obs, sample(index(Ra), T), simplify = FALSE) # sim_obs (n) draws from data(bootstrap, given that returns are i.i.d) for T periods
	
	sim_samples <- lapply(sample_indices, function(x) cbind(Ra[x], Rb[x])) # get the difference in returns across sim_obs (n) observations
	sim_cumreturns <- lapply(sim_samples, function(x) c(prod(x$SP500_rtrn + 1), prod(x$BOND_rtrn + 1))) # now get the cum return across all universies

	prob_Vs_greater_than_Vb <- length(which(unlist(lapply(sim_cumreturns, function(x) x[1] < x[2])))) / sim_obs # 
	return(prob_Vs_greater_than_Vb)
}

out <- cbind(
	stock.VS.bonds.Bootstrap(Ra = daily$SP500_rtrn, Rb = daily$BOND_rtrn),
	stock.VS.bonds.Bootstrap(Ra = monthly$SP500_rtrn, Rb = monthly$BOND_rtrn),
	stock.VS.bonds.Bootstrap(Ra = annually$SP500_rtrn, Rb = annually$BOND_rtrn))

rownames(out) <- "T = 30"
kable(t(rbind(c("Daily", "Monthly", "Annually"), out)),  digits = 6)

# Part C
# Question 1 
mu <- 0.10
sigma2 <- 0.2
T <- 50 - 35

car <- 1e5
target <- 1e6
savings <- 5e5 - car

Z <- (log(target / savings) - T * mu) / (sqrt(T) * sqrt(sigma2))
pnorm(Z) # probability of less than target amount: we cannot afford any of the cars

# Question 2
b_mu <- 0.003
b_sigma2 <- 0.015
b_sigma2 <- 0.3

# Part A
T <- 10 * 12 # in months
rf_mu <- 0.003
rf_sigma2 <- 0 # risk free

Z <- sqrt(T) * (rf_mu - b_mu) / sqrt(b_sigma2)
1 - pnorm(Z)

# Part B
# Generally, as the length of the time horizon grows(T), 
# the probability that the risk free asset will outperform the risky asset decreases; that is, the probability goes to zero.
# However, here rf_mu = b_mu, thus the result is indepedent of the time horizon.
# And Again for volatility, because rf_mu = b_mu,  the numeritor becomes 0, cancels out the numeriator, and makes the operation indepedent of the time horizon 

# Question 3
# TO DO

# Question 4
# TO DO

# Question 5
# Part A
# No I do not agree with Bill Gross. Assuming returns are i.i.d. (But not necessarily normal). By pure statistical chance alone, we would expect
# to observe a "long-run" average of high returns from stocks. That is, we could be observing returns on the right side of the 
# distribution without calling into question any of our underlying assumptions. What would be flawed however, would be to state, that now the market must 
# overcorrect and start 'drawing' returns from the left side of the mean of the distribution. This is statistically unsound. Certainly we may 
# begin to observe more negative returns from stocks; but as our homework discussed this noise will be washed out in the long run as we converge to a 
# probability of one. 

# Part B
# While "pure intellictual fraud" is a bit too harsh, I do argee with Nassim that the heuristic is misleading. It certainly mispresentes overall risk.
# I believe that managers should use it as one metric, or one tool in their tool box to get a snapshot of their risk exposure. Releing soley on the metric
# is folly; and one, instead, should use a dashboard of risk assessment tools.

