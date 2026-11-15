# Install required packages
install.packages("nlme")
install.packages("lme4")
install.packages("piecewiseSEM")
install.packages("QuantPsyc")
install.packages("semEff")
install.packages("ggraph")
install.packages("igraph")
install.packages("tidygraph")

# Piecewise SEM
library(nlme)
library(lme4)
library(piecewiseSEM)
library(QuantPsyc)
library(semEff)
library(ggraph)
library(igraph)
library(tidygraph)
# Autumn only. Set the working directory to 3-PSEM. Other scales use SEM_model_others.R.
Rt <- read.csv(file.path("input -PSEM", "autumn_samples_sem.csv"), header = TRUE)
names(Rt)
# Climate composite
model1 <- lm(SOCD ~  tem + Prcp, Rt)
coefs(model1, standardize = 'scale')
beta_tem <-  summary(model1)$coefficients[2, 1]
beta_Prcp <- summary(model1)$coefficients[3, 1]
QH <- beta_tem  * Rt$tem + beta_Prcp * Rt$Prcp
Rt$QH <- QH
summary(lm(SOCD ~ QH, Rt))
coefs(lm(SOCD ~ QH, Rt))
# Land-surface composite
model2 <- lm(SOCD ~ NDVI + EVI + SAVI, Rt)
coefs(model2, standardize = 'scale')
summary(model2)$coefficients
beta_NDVI <- summary(model2)$coefficients[2, 1]
beta_EVI  <-  summary(model2)$coefficients[3, 1]
beta_SAVI   <-  summary(model2)$coefficients[4, 1]
LD <- beta_NDVI * Rt$NDVI + beta_EVI  * Rt$EVI    + beta_SAVI * Rt$SAVI 
Rt$LD <- LD
summary(lm(SOCD ~ LD, Rt))
coefs(lm(SOCD ~ LD, Rt))
# Topography composite
model3 <- lm(SOCD ~ X9_DEM + X10_Slope + X11_TWI , Rt)
coefs(model3, standardize = 'scale')
beta_X9_DEM <- summary(model3)$coefficients[2, 1]
beta_X10_Slope <-  summary(model3)$coefficients[3, 1]
beta_X11_TWI <- summary(model3)$coefficients[4, 1]
DX<- beta_X9_DEM * Rt$X9_DEM + beta_X10_Slope * Rt$X10_Slope + beta_X11_TWI * Rt$X11_TWI 
Rt$DX <- DX
summary(lm(SOCD ~ DX, Rt))
coefs(lm(SOCD ~ DX, Rt)) 
# Soil composite. Clay is omitted because it had the smallest q value.
model0 <- lm(SOCD ~ X14_PH + X15_TN +  X16_TP + X18_SL + X20_FL  , Rt)
coefs(model0, standardize = 'scale')
beta_X14_PH <-  summary(model0)$coefficients[2, 1]
beta_X15_TN <- summary(model0)$coefficients[3, 1]
beta_X16_TP <- summary(model0)$coefficients[4, 1]
beta_X18_SL <- summary(model0)$coefficients[5, 1]
beta_X20_FL <- summary(model0)$coefficients[6, 1]
Soil <- beta_X14_PH * Rt$X14_PH + beta_X15_TN * Rt$X15_TN + beta_X16_TP * Rt$X16_TP + beta_X18_SL * Rt$X18_SL+ beta_X20_FL * Rt$X20_FL
Rt$Soil  <- Soil 
summary(lm(SOCD ~ Soil , Rt))
coefs(lm(SOCD ~ Soil , Rt))

# Path model
psem1 <- psem(
  lm(QH  ~ DX + X22_LUCC,  na.action = na.omit,
     data = Rt),
  lm(Soil~ DX, na.action = na.omit,
     data = Rt),
  lm(LD ~ DX + QH + X22_LUCC + Soil , na.action = na.omit,
     data = Rt),
  lm(SOCD ~ QH + DX + LD + Soil + X22_LUCC, na.action = na.omit,
     data = Rt)
)

summary(psem1)
# SEM summary
summary(psem1,.progressBar =F)
microbe.psem <- as.psem(psem1)
(new.summary <- summary(microbe.psem, .progressBar = F))
plot(microbe.psem)
AIC(microbe.psem,AIC.type = "dsep")
fisherC(microbe.psem)
BIC(microbe.psem)
summary(microbe.psem,.progressBar = F)
anova(microbe.psem)

