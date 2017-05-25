##############
# Homework 8 #
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
dir 		<- paste("/home/", username, "/Documents/Education/Chicago_Booth/Classes/35120_Portfolio_Management/portfolio_management/mod8", sep = ""); setwd(dir)

fund_holding <- read.table("fund_holding.txt", header = FALSE)
fund_holding <- as.xts(fund_holding[ ,-1], order.by = as.Date(paste0(as.character(fund_holding[,1]), '01'), format='%Y%m%d'))
fund_holding <- cbind(market_weight = fund_holding[ ,1], tbill_weight = 1 - fund_holding[ ,1])

fund_factors <- read.table("ff_factors_192607_201612.txt", header = TRUE)
fund_factors <- as.xts(fund_factors[ ,-1], order.by = as.Date(paste0(as.character(fund_factors[,1]), '01'), format='%Y%m%d')) / 100

data <- na.omit(cbind(fund_factors, fund_holding)) # only evaluate manager performance

# B.1
data$unconditional_alpha <- ((data$Mkt.RF + data$RF) * data$market_weight) + (data$RF * data$tbill_weight)
data$y <- data$unconditional_alpha - data$RF

data <- cbind(tbills, stocks[ ,-1])

data$Mkt.RF * data$market_weight
data$RF * data$tbill_weight

# B.2

rets  <- t(readMat("rets_hwk7.mat")$rets)[-1, ] # -99 are NA values
rets[rets == -99] <- NA
colnames(rets) <- c("Date", paste("Fund", rep(1:(dim(rets)[2] - 1))))
rets <- as.data.table(rets)

flows <- t(readMat("flows_hwk7.mat")$flows)[-1, ] # first one is fund identifier
flows[flows == -99] <- NA
colnames(flows) <- c("Date", paste("Fund", rep(1:(dim(flows)[2] - 1))))
flows <- as.data.table(flows)

EVAL_performance_to_flow <- function(year, graph = FALSE, ...){

	data <- transpose(rbind(rets[Date == year], flows[Date == year + 1]))
	colnames(data) <- c("returns", "inflows")
	data <- na.omit(data[-1, ]) # remove year and remove NAs

	data <- data[order(returns, decreasing = TRUE)]
	data[ ,group_interval := cut_number(returns, n = 10)]
	data[, decile := as.integer(group_interval)]
	data[ ,avg_returns := mean(returns), by = group_interval]
	data[ ,avg_flows := mean(inflows), by = group_interval]

	data_per_decile <- data[!duplicated(avg_returns)]
	linear <- lm(avg_flows ~ avg_returns + I(avg_returns ^ 2), data = data_per_decile)

	data_per_decile[ ,hat_avg_flows := linear$fitted][ ,c("returns", "inflows") := NULL]

	estimates <- rbind(
					alpha_hat = summary(linear)$coefficients[,'Estimate'][1], 
					beta_hat = summary(linear)$coefficients[,'Estimate'][2], 
					charlie_hat = summary(linear)$coefficients[,'Estimate'][3],

					alpha_se  = summary(linear)$coefficients[,'Std. Error'][1], 
					beta_se  = summary(linear)$coefficients[,'Std. Error'][2], 
					charlie_se  = summary(linear)$coefficients[,'Std. Error'][3]
				); colnames(estimates) <- year

	data <- merge(data, data_per_decile)

	if(graph){

		p <- ggplot(data = data, aes(group_interval, group = 1)) + 
				geom_point(aes(y = avg_flows), color = "black") + 
				geom_line(aes(y = avg_flows)) +
				geom_line(aes(y = hat_avg_flows), color = "darkgrey", linetype = "dotted", size = 1.3) +
				ggtitle(paste("Performance(", year, ") to Fund Flows(", year + 1, ")", sep = "")) +
				labs(x = "Performance Deciles", y = "Average Fund Flow (t+1)") 
		print(p)
	}

	return(list(data = data_per_decile, estimates = estimates))
}

out <- EVAL_performance_to_flow(year = 1992, graph = TRUE)

kable(out$data, digits = 4, caption = "Average: Returns, Flows, Fitted Values by Decile")
kable(t(out$estimates), digits = 4, caption = "Coefficients and Standard Errors")


years <- as.numeric(unlist(rets[,'Date'][-11])) # remove 2002
performance <- lapply(years, EVAL_performance_to_flow)

getStatSignif <- function(coef, ...){

	FM_alpha_hat <- do.call(sum, lapply(performance, function(x) x$estimates[paste(coef, "_hat", sep = ""),])) / 10
	FM_alpha_se  <- sd(unlist(lapply(performance, function(x) x$estimates[paste(coef, "_se", sep = ""),]))) / sqrt(10)
	summary_stat <- cbind(FM_alpha_hat, FM_alpha_se)
	colnames(summary_stat) <- NULL; rownames(summary_stat) <- coef
	return(summary_stat)
}

coefs <- c("alpha", "beta", "charlie")
coef_stats <- t(sapply(coefs, getStatSignif))
colnames(coef_stats) <- c("Estimate", "Standard Error")
kable(coef_stats, digits = 4, caption = "Fama-MacBeth Estimates")

total_summary <- do.call(rbind, lapply(performance, function(x) x$data))
total_summary[ ,total_avg_flow := mean(avg_flows), by = decile]
summary_data <- total_summary[!duplicated(decile)]

ggplot(data = summary_data, aes(group_interval, group = 1)) + 
	geom_point(aes(y = total_avg_flow), color = "black") + 
	geom_line(aes(y = total_avg_flow)) +
	ggtitle("Total Average Performance to Flow") +
	labs(x = "Performance Deciles *estimates", y = "Average Fund Flow (t+1)") 


# B.3