
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

* Create data
set seed 98034
set obs 5000

gen var_in = rgamma(0.2, 3)
* gamma(a,b) random variates, where a is the gamma shape parameter and b the scale parameter
* kurt = b + 6/a

gen var_out = var_in

quietly sum var_out, d
local i = r(kurtosis)
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
	local k_l = `k_l' + 1
	local k_u = `k_u' - 1
	local iter = `iter' + 1

}
