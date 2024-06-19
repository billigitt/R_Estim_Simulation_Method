library(epitrix)
library(dplyr)

directory_path <- "../../../../EpiEstim/R/"

# List all the R script files within the directory
files <- list.files(path = directory_path, pattern = "\\.R$", full.names = TRUE)

# Source each R script file in the directory
for (file in files) {
  source(file)
}


## Incidence
inc1 <- c(2, 3, 10, 28, 18, 21, 20, 7, 11) # 9 weeks
inc2 <- c(9, 15, 23, 17, 6, 11, 16, 40, 43, 67, 53, 42, 44, 28, 13, 2, 5, 8, 4) # 19 weeks 
inc3 <- c(23, 65, 48, 20, 6, 4, 5, 4, 1, 5, 5) # 11 weeks

## Serial interval
mean_si <- 3.95
sd_si <- 1.51

# Time windows for Rt estimates
start1 <- seq(from = 8, by = 7, length.out = length(inc1)-1)
end1 <- seq(from = 14, by = 7, length.out = length(inc1)-1)

start2 <- seq(from = 8, by = 7, length.out = length(inc2)-1)
end2 <- seq(from = 14, by = 7, length.out = length(inc2)-1)

start3 <- seq(from = 8, by = 7, length.out = length(inc3)-1)
end3 <- seq(from = 14, by = 7, length.out = length(inc3)-1)

## Rt estimates (starting on the first day of second aggregation window i.e. day 8)

Rt1 <- estimate_R(incid = inc1,
                  method = "parametric_si",
                  config = make_config(mean_si = mean_si,
                                       std_si = sd_si,
                                       t_start = start1,
                                       t_end = end1),
                  dt = 7L, # aggregation of data
                  dt_out = 7L) # sliding windows used to smooth estimates

# Reconstructed daily incidence
# Note: R cant be estimated for the first week, so days 1-7 aren't reconstructed. Incidence
# for days 1-7 here is just the naive split of the weekly count over 7 days. 
Rt1$I

# Complete R estimate result
Rt1$R

# R estimates now plotted over each week (instead of just t_end)
plot(Rt1, "R")

# to look at 90% credible intervals specifically you'd look at:
Rt1_90CI <- Rt1$R %>% select(t_start, t_end, `Mean(R)`, `Quantile.0.05(R)`, `Quantile.0.95(R)`)
Rt1_90CI$week <- seq(from = 2, length.out = nrow(Rt1_90CI))
Rt1_90CI <- Rt1_90CI[, c(6, 1:5)]

## The same for both other datasets:

## SECOND DATASET
Rt2 <- estimate_R(incid = inc2,
                  method = "parametric_si",
                  config = make_config(mean_si = mean_si,
                                       std_si = sd_si,
                                       t_start = start2,
                                       t_end = end2),
                  dt = 7L, 
                  dt_out = 7L) 

Rt2$I
Rt2$R
plot(Rt2, "R")
Rt2_90CI <- Rt2$R %>% select(t_start, t_end, `Mean(R)`, `Quantile.0.05(R)`, `Quantile.0.95(R)`)
Rt2_90CI$week <- seq(from = 2, length.out = nrow(Rt2_90CI))
Rt2_90CI <- Rt2_90CI[, c(6, 1:5)]

## THIRD DATASET
Rt3 <- estimate_R(incid = inc3,
                  method = "parametric_si",
                  config = make_config(mean_si = mean_si,
                                       std_si = sd_si,
                                       t_start = start3,
                                       t_end = end3),
                  dt = 7L, 
                  dt_out = 7L) 

Rt3$I
Rt3$R
plot(Rt3, "R")
Rt3_90CI <- Rt3$R %>% select(t_start, t_end, `Mean(R)`, `Quantile.0.05(R)`, `Quantile.0.95(R)`)
Rt3_90CI$week <- seq(from = 2, length.out = nrow(Rt3_90CI))
Rt3_90CI <- Rt3_90CI[, c(6, 1:5)]


# Create csv files from results
write.csv(Rt1_90CI, file = "~/Desktop/Rt1_90CI_nooverlap.csv", row.names = FALSE)
write.csv(Rt2_90CI, file = "~/Desktop/Rt2_90CI_nooverlap.csv", row.names = FALSE)
write.csv(Rt3_90CI, file = "~/Desktop/Rt3_90CI_nooverlap.csv", row.names = FALSE)


# How fast?

system.time(estimate_R(incid = inc1,
                       method = "parametric_si",
                       config = make_config(mean_si = mean_si,
                                            std_si = sd_si,
                                            t_start = start1,
                                            t_end = end1),
                       dt = 7L, # aggregation of data
                       dt_out = 7L)) # sliding windows used to smooth estimates)

system.time(estimate_R(incid = inc2,
                  method = "parametric_si",
                  config = make_config(mean_si = mean_si,
                                       std_si = sd_si,
                                       t_start = start2,
                                       t_end = end2),
                  dt = 7L, 
                  dt_out = 7L))

system.time(estimate_R(incid = inc3,
                  method = "parametric_si",
                  config = make_config(mean_si = mean_si,
                                       std_si = sd_si,
                                       t_start = start3,
                                       t_end = end3),
                  dt = 7L, 
                  dt_out = 7L))


