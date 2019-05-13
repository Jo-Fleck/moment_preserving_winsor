# Moment Preserving Winsorizing in Stata

Adjusting extreme realizations ('outliers') of a variable is called _winsorizing_. It is commonly implemented by one of two approaches:
- set a lower and upper percentile and replace all extreme realizations with the values of those percentiles
- set a number of extreme values to be replaced by their neighbors which are closer to the variable's mean

In Stata, the SSC packages `winsor` and `winsor2` allow to perform winsorizing variables as described above.

**Winsorizing variables in this way changes the values of their moments**. However, it is sometimes necessary to maintain them. In other words, the winsorizing procedure should respect boundary conditions on the variables' moments.

Yet, the two Stata packages mentioned above do not provide this feature.

As an illustration, the panel below shows a variable created from 5000 random draws from the pdf of a [gamma distribution](https://en.wikipedia.org/wiki/Gamma_distribution) before and after winsorizing. It also displays the corresponding [kurtosis](https://en.wikipedia.org/wiki/Kurtosis).

![Winsor Comparison](winsor_comparison.png)

The left figure has been created with Stata's `winsor` and the right one with `winsor_moment_preserving.do`. This do file conducts a modified winsorizing procedure which allows controlling for the stability of the kurtosis. In this example, it has been set to remain close to 12.  

`winsor_moment_preserving.do` follows an iterative approach:
1. set upper bound on the kurtosis: _kappa_upper_ (12)
2. set initial lower and upper percentiles (1 and 99)
3. winsorize the variable
4. compute the kurtosis of the winsorized variable 
  - if below _kappa_upper_: update lower bound and upper percentiles by 1 increment and return to step 3.
  - if equal or above _kappa_upper_: exit
5. report number of iterations
