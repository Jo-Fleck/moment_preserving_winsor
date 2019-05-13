# Moment Preserving Winsorizing in Stata

Adjusting extreme realizations ('outliers') of a variable is called _winsorizing_. It is commonly implemented by one of two approaches:
- set a lower and upper percentile and replace all extreme realizations with the values of those percentiles
- set a number of extreme values to be replaced by their neighbors which are closer to the variable's mean

In Stata, the SSC packages `winsor` and `winsor2` allow to perform winsorizing variables as described above.

**Winsorizing variables in this way changes the values of their moments**. However, it is sometimes necessary to maintain them. In other words, the winsorizing procedure should respect boundary conditions on the variables' moments.

Yet, the two Stata packages mentioned above do not provide this feature.

As an illustration, consider the [kurtosis](https://en.wikipedia.org/wiki/Kurtosis), i.e. the fourth standardized moment, of a variable following a [gamma distribution](https://en.wikipedia.org/wiki/Gamma_distribution). Note that this distribution has two parameters (a,b) and its kurtosis is given as

<img src="https://latex.codecogs.com/svg.latex?\Large&space;\kappa=b+6/a" />

The panel below shows a variable created from 5000 random draws from the pdf of a gamma distribution before and after winsorizing. The left figure has been created with Stata's `winsor` and the right one with `TEST.do`. 

It conducts a modified winsorizing procedure which aims to allow controlling for the effect of the winsorizing procedure on the moments. It does so by using an iterative approach: start with 99 and 1 percentile. winsorize and compute kurtosis. if still below certain value (three in example), update lower bound and upper bound by 1 percentil increment.
