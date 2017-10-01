* Set the regression to use for analysis
local reg ln_tot_wge_d i.industry edu age age_sq gender i.occupation i.occupation#c.edu 
local alpha = .3 // set the elasticity of wage w.r.t. HC
local year = 0 // set to 1 to weight daily wages by days/year
local names Albania05 Bulgaria01 Tajikistan03 Bangladesh00 Indonesia00 Nepal03 Vietnam98 ///
			Ecuador95 Guatemala00 Nicaragua98 Nicaragua01 Panama03 Ghana98 Malawi04 Nigeria04

graph set eps fontface Times

mat M_results = J(100,1,0) // set up initial results matrix

cd /Users/dietz/Dropbox/AgLabor/riga

* Load used programs
do wage_rgain.do
do wage_rsample.do
do wage_rwedge.do

foreach countryYY in `names'  {
	* Clear and open that country's file
	clear
	use "`countryYY'_job_work.dta"
	save "`countryYY'_job_work_temp.dta", replace // save temp version prior to dropping limited industries
	
	* Run rsample to strip out industries and occupations with less than min (usually 10) observations
	rsample, min(10)
	local indnum = r(indnum) // capture number of industries
	save "`countryYY'_job_work_temp.dta", replace // save temp version again after dropping
	
	* Set up the temporary results matrix
	mat R = J(100,1,0)

	* Cycle through the bseff command to get R values for different percents of industry effects
	local i = 1
	while `i'<=100 {
		local gamma = `i'/100
		clear
		use "`countryYY'_job_work_temp.dta" // pull in work file to re-estimate wedges with different gamma values
		quietly rwedge `reg', indnum(`indnum') gamma(`gamma') year(`year') // get wedges
		quietly collapse (mean) w_wedge_j h_ij (sum) sum_indweight = indweight sum_h_ij = h_ij [pweight=indweight], by(industry) 
			// roll up results to summarize
		quietly rgain, alpha(`alpha') // calculate R given rolled-up file
		mat R[`i',1] = r(R) // save off R to results matrix
		local i = `i' + 1 // iterate percentage by 1 percent each time through
	}
	matrix M_results = M_results,R // roll up the current country results to the overall results
* End foreach country
}

* Produce figure showing R against gamma for four countries
clear
matrix colnames M_results = Percent `names' // set matrix column names using countryYY information
svmat M_results, names(col) // pull matrix of results into a dataset
replace Percent = _n/100 // percents in decimal form

line Ghana98 Percent, clcolor(black) clpattern(dash) || line Ecuador95 Percent, clcolor(gray) || /// 
	line Tajikistan03 Percent, clcolor(black) || line Nigeria04 Percent, clpattern(shortdash) clcolor(black) /// 
	ylabel(1 (.05) 1.15, angle(0) format(%4.2f)) ytitle("Reallocation ratio (R)") xtitle("Unmeasured human capital share ({&gamma})") /// 
	xlabel(0 (.1) 1, format(%3.1f)) legend(label(1 "Ghana") label(2 "Ecuador") label(3 "Tajikistan") label(4 "Nigeria")) ///
	graphregion(color(white))
cd /Users/dietz/Dropbox/AgLabor
graph export wage_fig_gamma.eps, replace as(eps)
cd /Users/dietz/Dropbox/AgLabor/riga
