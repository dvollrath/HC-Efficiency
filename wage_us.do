* Evaluate the reallocation gains for U.S. using CPS march extract from NBER

* Set the four common regressions to use for estimates of R
local reg1 ln_tot_wge_d i.industry 
local reg2 ln_tot_wge_d i.industry edu age age_sq sex 
local reg3 ln_tot_wge_d i.industry edu age age_sq sex i.occupation 
local reg4 ln_tot_wge_d i.industry edu age age_sq sex i.occupation i.occupation#c.edu

* Set up the parameters for the calculations
local alpha = .3 // Set the elasticity of wages w.r.t. human capital
local gamma = 0 // Sets the fraction of industry effect that is attributed to unmeasured human capital (baseline is zero)
local week = 1 // Set to 1 to use weekly earnings, set to 0 to use hourly earnings

* Load programs used 
do wage_rgain.do
do wage_rsample.do
do wage_rwedge.do
do wage_rselfb.do
do wage_rfile.do

* Set-up and start process
clear
use "morg00.dta"
save "morg00_work.dta", replace
capture log close
log using "log_us_R.smcl", replace

keep if lfsr94==1 // keep obs only if "Employed - at work"

quietly {
* Recode new industry and occupation variables to match what's used for RIGA datasets
gen industry = .
replace industry = 1 if dind==1 | dind==2 | dind==46 // Agriculture, Forestry, Fisheries
replace industry = 2 if dind==3 // Mining
replace industry = 3 if dind>=5 & dind<=28 // Manufacturing
replace industry = 4 if dind==31 // Utilities
replace industry = 5 if dind==4 // Construction
replace industry = 6 if dind==32 | dind==33 // Commerce (wholesale and retail trade)
replace industry = 7 if dind==29 | dind==30 // Transport and communications
replace industry = 8 if dind==34 | dind==35 // Finance and real estate
replace industry = 9 if dind>=36 & dind<=45 // Services
keep if industry~=.

gen occupation = .
replace occupation = 1 if docc80==1 | docc80==2 | docc80==3 // Senior officials, managers
replace occupation = 2 if docc80>=4 & docc80<=12 // Professionals
replace occupation = 3 if docc80==13 | docc80==14 | docc80==15 // Technicians
replace occupation = 4 if docc80>=21 & docc80<=26 // Clerks
replace occupation = 5 if (docc80>=16 & docc80<=20) | (docc80>=27 & docc80<=32) // Sales and service workers
replace occupation = 6 if docc80==43 // Skilled ag and fishery workers
replace occupation = 7 if docc80==33 | docc80==34 // Craft and related trade workers
replace occupation = 8 if docc80>=36 & docc80<=39 // Plant and machine operators
replace occupation = 9 if docc80==40 | docc80==41 | docc80==42 | docc80==44 | docc80==45 // Elementary laborers
replace occupation = 10 if docc80==46 // Armed forces
keep if occupation~=.

* Recode grade completed into years of education
gen edu = .
replace edu = 1 if grade92 == 31 // Less than 1st
replace edu = 4 if grade92 == 32 // Up to fourth
replace edu = 6 if grade92 == 33 // Up to 6th
replace edu = 8 if grade92 == 34 // Up to 8th
replace edu = 9 if grade92 == 35 // 9th
replace edu =10 if grade92 == 36 // 10th
replace edu =11 if grade92 == 37 // 11th
replace edu =12 if grade92 == 38 | grade92==39 // 12th no diploma or HS grad or GED
replace edu =13 if grade92 == 40 // Some college but no degree
replace edu =14 if grade92 == 41 | grade92==42 // Associates degree
replace edu =16 if grade92 ==43 // Bachelors
replace edu =18 if grade92 ==44 // Masters
replace edu =19 if grade92 ==45 // Prof degree
replace edu =21 if grade92 ==46 // PhD
keep if edu~=.

* Create vars to match RIGA organization - none is crucial for anything that follows
gen hh = hhid
gen indid = lineno 
gen job = 1

gen indweight = 1 // set individual sample weight
if `week' == 1 {
	gen tot_wge_d = earnwke // use weekly earnings
}
else {
	gen tot_wge_d = earnwke/uhourse // divide by weekly hours to get hourly earnings
}
gen ln_tot_wge_d = ln(tot_wge_d) // create log of hourly wage
gen age_sq = age^2 // squared term for Mincerian regression

keep if tot_wge_d ~= . // drop if no wage data
keep if age ~=. // drop if no age data
keep if sex ~=. // drop if no gender data
} // end quietly

save "morg00_work.dta", replace // save off modified file
local indnum = 9 // plenty of observations in each industry for the U.S.

foreach x in reg1 reg2 reg3 reg4 { // Loop through all four regressions, calculating R for each
	clear
	use "morg00_work.dta" // grab U.S. individual level data
	save "morg00_work_temp.dta", replace // save temp version prior to dropping limited industries

	quietly rwedge ``x'', indnum(`indnum') gamma(`gamma')  // run rwedge to do Mincer regression, find wedges, and ind. HC amounts
	// rwedge generates two new variables - w_wedge_j and h_ij
		
	* Collapse individual level dataset down to industry level, saving wedge, the total HC by industry, avg. HC by industry and total sample weight
	collapse (mean) w_wedge_j h_ij (sum) sum_indweight = indweight sum_h_ij = h_ij [pweight=indweight], by(industry) 
	save "morg00_work_ind.dta", replace 
		
	* Given dataset of wedges and HC stocks by industry, calculate R
	quietly rgain, alpha(`alpha')
	display as text "``x''"
	display as text "Optimal/Actual productivity: " as result r(R)

}

capture log close
