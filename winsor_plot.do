
/*
Copyright 2019 Johannes Fleck; https://github.com/Jo-Fleck

You may use this code for your own work and you may distribute it freely.
No attribution is required. Please leave this notice and the above URL in the
source code. 

Thank you.
*/


clear all
macro drop _all
set more off
set mem 3000m

global graphPath "/Users/main/Documents/GitHubRepos/moment_preserving_winsor/"

* Install winsor package
ssc install winsor, replace

* Create data
set seed 98034
set obs 5000

gen var_in = rgamma(0.2, 3)
* gamma(a,b) random variates, where a is the gamma shape parameter and b the scale parameter
* kurt = b + 6/a


*** Classical Winsorizing
winsor var_in, gen(var_out_win_class) h(300)

quietly sum var_in, d
local kurt_before = round(r(kurtosis),1) // For plot

quietly sum var_out_win_class, d
local kurt_after = round(r(kurtosis),1) // For plot

* Plot results
twoway (histogram var_in, width(1) color(cyan)) ///
       (histogram var_out_win_class, width(1) ///
	   fcolor(none) lcolor(black)), legend(order(1 "Before ({&kappa} = `kurt_before')" 2 "After ({&kappa} = `kurt_after')" )) ///
title("{bf:Classical Winsorizing}") ///
subtitle("-", color(white)) ///
name(winsor_class)


*** Moment Preserving Winsorizing
gen var_out = var_in

quietly sum var_out, d
local i = r(kurtosis)
	local kurt_before = round(r(kurtosis),1) // For plot
local k_l = 1
local k_u = 99
local iter = 0

while `i' > 12 {

	egen var_out_pt_l = pctile(var_in), p(`k_l') 
	egen var_out_pt_u = pctile(var_in), p(`k_u') 
	replace var_out = var_out_pt_l if (var_out < var_out_pt_l) 
	replace var_out = var_out_pt_u if (var_out > var_out_pt_u & var_out <.)
	drop var_out_pt_l var_out_pt_u
	
	quietly sum var_out, d
	local i = r(kurtosis)
		local kurt_after = round(r(kurtosis),1) // For plot
	local k_l = `k_l' + 1
	local k_u = `k_u' - 1
	local iter = `iter' + 1

}

* Plot results
twoway (histogram var_in, width(1) color(cyan)) ///
       (histogram var_out, width(1) ///
	   fcolor(none) lcolor(black)), legend(order(1 "Before ({&kappa} = `kurt_before')" 2 "After ({&kappa} = `kurt_after')" )) ///
title("{bf:Moment Preserving Winsorizing}") ///
subtitle("(# of iterations: `iter')") ///
name(winsor_mompres)


*** Combine graphs
graph combine winsor_class winsor_mompres, col(2) row(1) ///
xsize(10) ysize(4) iscale(1.0) ///
imargin(2 2 2 2)
graph export "$graphPath/winsor_comparison.png", replace
