## Example script for applying EpiEstim to weekly data

# Latest version of EpiEstim
devtools::install_github("mrc-ide/EpiEstim")

# Packages
library(EpiEstim)
library(incidence)
library(projections)
library(dplyr)

weekly_inc_matrix <- as.matrix(unname(read.csv("lowIncidenceExperiments.csv", header = FALSE)))
meansMatrix <- matrix(0, nrow = 1000, ncol = 10)
lowMatrix <- meansMatrix
upMatrix <- lowMatrix

start <- Sys.time()

for (i in 1:12){

print(i)
weekly_inc <- weekly_inc_matrix[i,]
SI <- read.csv("dailySerialNew.csv", header = FALSE)
SI2 <- SI/sum(SI)
SI2 <- as.numeric(t(SI2))

# Estimate R
method <- "non_parametric_si"
config <- make_config(list(si_distr = SI2))

weekly_res <- estimate_R(incid = weekly_inc,
                         dt = 7L, # length of aggregation windows
                         dt_out = 7L, # sliding window length
                         iter = 100L, # number of iterations (10 by default)
                         config = config,
                         method = method)


# Take the output from days 8-14, 15-21, 22-28, etc ??

RVals <- weekly_res$R$`Mean(R)`
meanVals <- c(RVals[1], RVals[8], RVals[15], RVals[22], RVals[29], RVals[36], RVals[43], RVals[50], RVals[57], RVals[64])
RVals <- weekly_res$R$`Quantile.0.025(R)`
lowerVals <- c(RVals[1], RVals[8], RVals[15], RVals[22], RVals[29], RVals[36], RVals[43], RVals[50], RVals[57], RVals[64])
RVals <- weekly_res$R$`Quantile.0.975(R)`
upperVals <- c(RVals[1], RVals[8], RVals[15], RVals[22], RVals[29], RVals[36], RVals[43], RVals[50], RVals[57], RVals[64])

meansMatrix[i, ] <- meanVals[1:10]
lowMatrix[i, ] <- lowerVals[1:10]
upMatrix[i, ] <- upperVals[1:10]


}

end <- Sys.time()
elapsed <- end-start
print(elapsed)

write.csv(meansMatrix, "meanNashEstimateLowInc.csv")
write.csv(lowMatrix, "lowerNashEstimateLowInc.csv")
write.csv(upMatrix, "upperNashEstimateLowInc.csv")
