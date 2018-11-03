ObsData <- read.csv("/Users/gcgibson/Downloads/RAssign3.ipw.csv")

n <- nrow(ObsData)

summary(ObsData)

table(ObsData[,c('W1', 'W2', 'A')])



### seems like when A=7, W1=3,W2=1 we only have 1 observation

library("nnet")
prob.AW.reg<-multinom(A~ W1+W2, data=ObsData)
prob.AW.pred.matrix<- predict(prob.AW.reg, type="probs")
head(round(prob.AW.pred.matrix, 2))

prob.AW <- rep(NA,n)

prob.AW[ObsData$A==1] <- prob.AW.pred.matrix[ObsData$A==1, "1"]
prob.AW[ObsData$A==2] <- prob.AW.pred.matrix[ObsData$A==2, "2"]
prob.AW[ObsData$A==3] <- prob.AW.pred.matrix[ObsData$A==3, "3"]
prob.AW[ObsData$A==4] <- prob.AW.pred.matrix[ObsData$A==4, "4"]
prob.AW[ObsData$A==5] <- prob.AW.pred.matrix[ObsData$A==5, "5"]
prob.AW[ObsData$A==6] <- prob.AW.pred.matrix[ObsData$A==6, "6"]
prob.AW[ObsData$A==7] <- prob.AW.pred.matrix[ObsData$A==7, "7"]




summary(prob.AW)


wt<- 1/prob.AW
summary(wt)



IPTW<- mean( wt*as.numeric(ObsData$A==7)*ObsData$Y) - mean( wt*as.numeric(ObsData$A==1)*ObsData$Y)



SIPTW <- mean( wt*as.numeric(ObsData$A==7)*ObsData$Y)/mean( wt*as.numeric(ObsData$A==7)) -+ mean( wt*as.numeric(ObsData$A==1)*ObsData$Y)/mean( wt*as.numeric(ObsData$A==1))


tail(cbind(ObsData$A, prob.AW, wt))


IPTW.msm<- glm(Y~A , weights=wt, family='gaussian', data=ObsData )
IPTW.msm$coef


prob.A <- rep(NA,n)
prob.A[ObsData$A==1] <- mean(ObsData$A==1)
prob.A[ObsData$A==2] <- mean(ObsData$A==2)
prob.A[ObsData$A==3] <- mean(ObsData$A==3)
prob.A[ObsData$A==4] <- mean(ObsData$A==4)
prob.A[ObsData$A==5] <- mean(ObsData$A==5)
prob.A[ObsData$A==6] <- mean(ObsData$A==6)
prob.A[ObsData$A==7] <- mean(ObsData$A==7)

wt.MSM <- prob.A/prob.AW


summary(wt)
summary(wt.MSM)

### we can see that the max weight is much smaller in the stabilized weights



SIPTW.msm<- glm(Y~A , weights=wt.MSM, family='gaussian', data=ObsData )
SIPTW.msm$coef


## No the effect of the exposure is slightly greater in the stabilized weights example

set.seed(1)

# The true value of the conditional mean outcome E_0[Y|A,W]
true.meanY.AW <- function(A,W){
  1000 + plogis(W*A)
}
# The true value of propensity score Pr(A=1|W)
true.prob.AW <- function(W){
  0.2 + 0.6*W
}

# A function which returns a data frame with n i.i.d. observations from P_0
gen.data <- function(n){
  W <- rbinom(n, 1, 1/2)
  A <- rbinom(n, 1, true.prob.AW(W=W))
  Y <- 1000 + rbinom(n, 1, true.meanY.AW(A=A,W=W) - 1000)
  return(data.frame(W=W,A=A,Y=Y))
}

# samples size
n<- 1000
# Number of Monte Carlo draws
R <- 2000
# Matrix of estimates from IPTW, modified Horvitz-Thompson, and my.est
est <- matrix(NA,nrow=R,ncol=3)
colnames(est) <- c('IPTW','Modifed HT','my.est')
for(r in 1:R){
  # Generate data with sample size
  ObsData <- gen.data(n)
  W <- ObsData$W
  A <- ObsData$A
  Y <- ObsData$Y
  Y_modified <- Y - 1000
  # True propensity score P_0(A=1|W)
  pscore <- true.prob.AW(W=W)
  # IPTW estimate
  IPTW.est <- mean(A/pscore*Y)
  # Modified Horvitz-Thompson estimate
  HT.est <- mean(A/pscore*Y)/mean(A/pscore)
  # You should replace the NA below with your own estimate
  my.est <-  1000+mean(A/pscore*Y_modified)
  # Put the estimates into the est matrix
  est[r,] <- c(IPTW.est, HT.est, my.est)
}

# Calculate the true value of EE[Y|A=1,W]
truth <- 1/2*( true.meanY.AW(A=1, W=0) + true.meanY.AW(A=1,W=1) )
# note: we know P_0(W=1) = 0.5
truth

# Calculate the estimated bias, variance, and MSE
est.bias <- colMeans(est) - truth
est.var <- apply(est,2,var)
est.mse <- est.bias^2 + est.var

# Only can report estimated bias/variance/MSE
# because only took finitely many Monte Carlo draws (2000)
print('The estimators have (estimated) bias:')
print(est.bias)
print('The estimators have (estimated) variance:')
print(est.var)
print('The estimators have (estimated) MSE:')
print(est.mse)



## Var(X) = E(X^2) = 0^2*1/2 + 1^2*1/2 = .5


## Var(X) = E(X^2) = 0^2*1/2 + 1^2*1/2 = 1000^2*.5

## Can we scale the estimator to have unit variance?


