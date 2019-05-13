
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

* Set folder containing data
global ROOT = "/Users/main/Downloads/Philip_winsorize"

* Load data
use "${ROOT}/data_extended.dta", clear

* Drop missing obs of target variables
drop if var == .

* Duplicate target variable
gen var_out = var

* Keep only first letter of sector (quicker and more robust)
gen nacesection_short = substr(nacesection,1,1)

levelsof year, local(yrs)
levelsof nacesection_short, local(secs)

foreach y in `yrs' {

    foreach s in `secs' {
	
	preserve
	
	keep if year == `y' & nacesection_short == "`s'"
	
	quietly sum var, d
	local i_`y'_`s' = r(kurtosis)
	di `i_`y'_`s''
	
	if `i_`y'_`s'' != . {
	
	local k_l_`y'_`s' = 1
	local k_u_`y'_`s' = 99
	local iter_`y'_`s' = 0
		
		while `i_`y'_`s'' > 3 {

		egen var_out_pt_l = pctile(var), p(`k_l_`y'_`s'') 
		egen var_out_pt_u = pctile(var), p(`k_u_`y'_`s'') 
		replace var_out = var_out_pt_l if (var_out < var_out_pt_l) 
		replace var_out = var_out_pt_u if (var_out > var_out_pt_u & var_out <.)
		drop var_out_pt_l var_out_pt_u
	
		quietly sum var_out, d
		local i_`y'_`s' = r(kurtosis)
		local k_l_`y'_`s' = `k_l_`y'_`s'' + 1
		local k_u_`y'_`s' = `k_u_`y'_`s'' - 1
		local iter_`y'_`s' = `iter_`y'_`s'' + 1
		di `iter_`y'_`s''

			if (`iter_`y'_`s'' > 48) break
		
		}
		
		}
		
		save "${ROOT}/var_`y'_`s'_winsorized.dta", replace
	
	restore
	
    }

}

