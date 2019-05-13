# Moment Preserving Winsorizing in Stata

The process of adjusting extreme realizations ('outliers') of a variable is called _winsorizing_. It is commonly implemented by one of two approaches:
- setting a lower and upper percentile and replacing all extreme realizations with the values of those percentiles
- setting a number (percentage) of extreme values to be replaced by their neighbors which are closer to the variable's mean

In Stata, the SSC packages `winsor` and `winsor2` allow to perform winsorizing variables as described above.

However, this way of winsorizing variables alters their moments while it sometimes can be necessary to maintain them. In other words, the winsorizing procedure should continue only as long as boundary conditions of the moments are respected.

Yet, the two Stata packages mentioned above do not provide this feature.

As an illustration of the difference, consider their effects on the [kurtosis](https://en.wikipedia.org/wiki/Kurtosis), i.e. the fourth standardized moment, of a [gamma distribution](https://en.wikipedia.org/wiki/Gamma_distribution). This distribution has two parameters (a,b) and its kurtosis is given as

<img src="https://latex.codecogs.com/svg.latex?\Large&space;\kappa=b+6/a" />

Figures below illustrate the two different approaches on a variable created from 5000 random draws from the pdf of a gamma distribution. The lhs has been created with `winsor` and the rhs graph with the do file `TEST` in this repository. 

It conducts a modified winsorizing procedure which aims to allow controlling for the effect of the winsorizing procedure on the moments. It does so by using an iterative approach: start with 99 and 1 percentile. winsorize and compute kurtosis. if still below certain value (three in example), update lower bound and upper bound by 1 percentil increment.
