install.packages("GD") 
library(GD) 
testdata <- read.csv(file.path("input data for OPGD", "annual_samples_opgd.csv"), header = TRUE)  
discmethod <- c("equal","natural","quantile","geometric","sd")  
discitv <- c(3:6)
ndvigdm <- gdm(Y ~ X1 + X2 + X3 + X4 + X5 + X6 + X7 + X8 + X9 + X10 + X11 + X12 + X13 + X14 + X15 + X16 + X17 + X18 + X19 + X20 + X21 + X22 + X23 + X24,
               continuous_variable = c("X1","X2","X3","X4","X5","X6","X7","X8","X9","X10","X11","X12","X13","X14","X15","X16","X17","X18","X19","X20","X21","X22","X23","X24"),
               data = testdata,
               discmethod = discmethod, discitv = discitv)
ndvigdm

# windows(width = 12, height = 10) 
# plot(ndvigdm$Factor.detector)
# 
# windows(width = 12, height = 10)
# plot(ndvigdm$Risk.mean)
# 
# windows(width = 12, height = 10)
# plot(ndvigdm$Risk.detector)
# 
# windows(width = 12, height = 10)
# plot(ndvigdm$Interaction.detector)
# 
# windows(width = 12, height = 10)
# plot(ndvigdm$Ecological.detector)
