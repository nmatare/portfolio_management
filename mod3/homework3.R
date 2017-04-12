##############
# Homework 3 #
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
dir 		<- paste("/home/", username, "/Documents/Education/Chicago_Booth/Classes/35120_Portfolio_Management/portfolio_management/mod3", sep = ""); setwd(dir)

tbills <- read.csv("TB_26_16.csv", header = FALSE)
stocks <- read.csv("VWMKT_26_16.csv", header = FALSE)
data <- cbind(tbills, stocks[ ,-1])

data <- as.xts(data[ ,-1], order.by = as.Date(as.character(data[,1]), format = "%Y%m%d"))
colnames(data) <- c("tbills", "stocks")

# 1. Relative performance of stocks and T-bills.

# a)
length(which(data$stocks > data$tbills)) / NROW(data) * 100

# b)
cumreturn <- (data + 1)
kable(t(apply(cumreturn, 2, prod)), digits = 6) # in dollars

# 2. Perfect vs. random market timing.
# a)
perfect <- as.matrix(apply(data, 1, max))
perfect_cumreturn <- (perfect + 1)
prod(perfect_cumreturn)

mean(perfect) # mean return of perfect timing
mean(perfect - data$tbills) / sd(perfect - data$tbills) # sharpe ratio of perfect

mean(data$stocks) # mean return of market
mean(data$stocks - data$tbills)/sd(data$stocks - data$tbills) # sharpe ratio of market

# b)
randomTiming <- function() as.matrix(apply(data, 1, function(x) sample(x, 1)))
simulations <- replicate(1000, randomTiming(), simplify = FALSE) # run 1000 simulations of random timing
	
sim_means <- unlist(lapply(simulations, mean))
sim_sharperatios <- unlist(lapply(simulations, function(x) mean(x - data$tbills) / sd(x - data$tbills)))

ggplot(data = data.frame(means = sim_means)) +
	geom_histogram(aes(means), fill = "darkgrey", alpha = 0.5) + 
	geom_vline(xintercept = mean(data$stocks), color = "red", linetype = 'dashed') +
	labs(title = "Average Returns")
mean(sim_means) # expected return of Claire's random strategy

ggplot(data = data.frame(means = sim_sharperatios)) +
	geom_histogram(aes(sim_sharperatios), fill = "darkgrey", alpha = 0.5) + 
	geom_vline(xintercept = mean(data$stocks - data$tbills)/sd(data$stocks - data$tbills), color = "blue", linetype = 'dashed') +
	labs(title = "Average Sharpe Ratios")
mean(sim_sharperatios) # expected sharpe ratio of Claire's random strategy

# 3. Benefits of imperfect market timing.

# a)
skillTiming <- function() as.matrix(apply(data, 1, function(x) sample(c(max(x), min(x)), prob = c(0.60, 0.40), 1))) # get the 'correct', aka max 60% of time
simulations <- replicate(1000, skillTiming(), simplify = FALSE) # run 1000 simulations of random timing

sim_means <- unlist(lapply(simulations, mean))
sim_sharperatios <- unlist(lapply(simulations, function(x) mean(x - data$tbills) / sd(x - data$tbills)))

ggplot(data = data.frame(means = sim_means)) +
	geom_histogram(aes(means), fill = "darkgrey", alpha = 0.5) + 
	geom_vline(xintercept = mean(data$stocks), color = "red", linetype = 'dashed') +
	labs(title = "Average Returns")
mean(sim_means) # expected return of Claire's skill strategy

ggplot(data = data.frame(means = sim_sharperatios)) +
	geom_histogram(aes(sim_sharperatios), fill = "darkgrey", alpha = 0.5) + 
	geom_vline(xintercept = mean(data$stocks - data$tbills)/sd(data$stocks - data$tbills), color = "blue", linetype = 'dashed') +
	labs(title = "Average Sharpe Ratios")
mean(sim_sharperatios) # expected sharpe ratio of Claire's skill strategy

# b)
mean(sim_means - 0.02) # expected return on Claire's skill strategy minus fees
sim_sharperatios_fees <- unlist(lapply(simulations, function(x) mean(x - data$tbills - 0.02) / sd(x - data$tbills)))
mean(sim_sharperatios_fees) # expected sharpe ratio of Claire's strategy with fees

# 4. Imperfect market timing with different forecasting accuracies.
ns <- rep(50:100) / 100
skillTiming_n <- function(n) as.matrix(apply(data, 1, function(x) sample(c(max(x), min(x)), prob = c(n, 1 - n), 1))) # get the 'correct'
all(skillTiming_n(1.00) == perfect) # sanity check

registerDoMC(detectCores() - 1) 
simulations <- foreach(i = ns) %dopar% { replicate(1000, skillTiming_n(i), simplify = FALSE) } # for each n, run a simulation

sim_means_ns <- unlist(lapply(simulations, function(x) mean(unlist(lapply(x, mean)))))
sim_sharperatios <- unlist(lapply(simulations, function(y) mean(unlist(lapply(y, function(x) mean(x - data$tbills) / sd(x - data$tbills))))))
frame <- cbind.data.frame(ns, sim_means_ns, sim_sharperatios)

# No Fee
ggplot(data = frame) +
	geom_line(aes(x = ns, y = sim_means_ns)) +
	geom_hline(yintercept = mean(data$stocks), color = "red", linetype = 'dashed') +
	labs(title = "Accuracy vs Expected Return (no fee)", x = "Accuracy", y = "Expected Return")

frame$ns[which(frame$sim_means_ns > mean(data$stocks))][1] # minimum level of accuracy

ggplot(data = frame) +
	geom_line(aes(x = ns, y = sim_sharperatios)) +
	geom_hline(yintercept = mean(data$stocks - data$tbills)/sd(data$stocks - data$tbills), color = "blue", linetype = 'dashed') +
	labs(title = "Accuracy vs Sharpe Ratios(no fee)", x = "Accuracy", y = "Sharpe Ratio")

frame$ns[which(frame$sim_sharperatios > mean(data$stocks - data$tbills)/sd(data$stocks - data$tbills))][1] # minimum level of accuracy

# With Fee
sim_means_ns <- unlist(lapply(simulations, function(x) mean(unlist(lapply(x, function(y) y - 0.02)))))
sim_sharperatios <- unlist(lapply(simulations, function(y) mean(unlist(lapply(y, function(x) mean(x - data$tbills - 0.02) / sd(x - data$tbills))))))
frame2 <- cbind.data.frame(ns, sim_means_ns, sim_sharperatios)

ggplot(data = frame2) +
	geom_line(aes(x = ns, y = sim_means_ns)) +
	geom_hline(yintercept = mean(data$stocks), color = "red", linetype = 'dashed') +
	labs(title = "Accuracy vs Expected Return (Fee)", x = "Accuracy", y = "Expected Return")

frame2$ns[which(frame2$sim_means_ns > mean(data$stocks))][1] # minimum level of accuracy

ggplot(data = frame2) +
	geom_line(aes(x = ns, y = sim_sharperatios)) +
	geom_hline(yintercept = mean(data$stocks - data$tbills)/sd(data$stocks - data$tbills), color = "blue", linetype = 'dashed') +
	labs(title = "Accuracy vs Sharpe Ratios (Fee)", x = "Accuracy", y = "Sharpe Ratio")

frame2$ns[which(frame2$sim_sharperatios > mean(data$stocks - data$tbills)/sd(data$stocks - data$tbills))][1] # minimum level of accuracy