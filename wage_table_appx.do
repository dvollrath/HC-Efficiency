* Regressions to use for table 4 - need to set base levels to keep things consistent for estout command
local reg1 ln_tot_wge_d b1.industry
local reg2 ln_tot_wge_d b1.industry edu age age_sq gender
local reg3 ln_tot_wge_d b1.industry edu age age_sq gender b1.occupation
local reg4 ln_tot_wge_d b1.industry edu age age_sq gender b1.occupation b1.occupation#c.edu

local alpha = .3 // Set the elasticity of wages w.r.t. human capital for main results
local gamma = 0 // Sets the fraction of industry effect that is attributed to unmeasured human capital (baseline is zero)
local year = 0 // Set to 1 to weight daily wages by days/year worked (baseline is zero - means using daily wages)

* Run to load the rsample program
do wage_rsample.do
do wage_rgain.do
do wage_rwedge.do
do wage_rfile.do

foreach x in reg1 reg2 reg3 reg4 {
	estimates drop _all

	capture file close f_alloc
	file open f_alloc using output_table_`x'_opt.txt, write replace
	capture file close f_actual
	file open f_actual using output_table_`x'_act.txt, write replace

	* Look through all countries to calculate their average wages by sector
	foreach countryYY in Albania05 Bulgaria01 Tajikistan03 Bangladesh00 Indonesia00 Nepal03 Vietnam98 { 
		clear
		use "`countryYY'_job_work.dta"
		save "`countryYY'_job_work_temp.dta", replace // save temp version prior to dropping limited industries
		local country = reverse(substr(reverse("`countryYY'"),3,.))

		quietly rsample, min(10) // run rsample routine to eliminate industries with less than min observations
		local indnum = r(indnum)

		quietly reg ``x'' [pweight=indweight] if industry>0 // baseline regression
		estimates store `country'
		quietly testparm i.industry // test for equality of all industry dummies
		quietly estadd scalar Find = r(F) // add F-stat from test to stored estimates
		quietly estadd scalar pind = r(p) // add p-value of F-test to stored estimates

		* Run the main regression and produce dataset of wedges and HC stocks by industry
		quietly rwedge ``x'', indnum(`indnum') gamma(`gamma') year(`year') // run rwedge to do Mincer regression, find wedges, and ind. HC amounts
			// rwedge generates two new variables - w_wedge_j and h_ij
		
		* Collapse individual level dataset down to industry level, saving wedge, the total HC by industry, avg. HC by industry and total sample weight
		collapse (mean) w_wedge_j h_ij (sum) sum_indweight = indweight sum_h_ij = h_ij [pweight=indweight], by(industry) 
		save "`countryYY'_`x'_work_ind.dta", replace
		
		* Given dataset of wedges and HC stocks by industry, calculate R
		quietly rgain, alpha(`alpha')
		rfile, handle(f_alloc) countryYY(`countryYY')
		rfile, handle(f_actual) countryYY(`countryYY')
		local j = 1
		local i = 1
		while `i'<=9 { // cycle through all industry's
			if industry[`j'] == `i' {
				file write f_alloc "&" %4.1f (100*perc_h_ij_opt[`j'])
				file write f_actual "&" %4.1f (100*perc_h_ij[`j'])
				local i=`i'+1
				local j=`j'+1
			}
			else {
				file write f_alloc "& $-$" 
				file write f_actual "& $-$" 
				local i = `i'+1
			}
		}

		if "`countryYY'"=="Tajikistan03" | "`countryYY'"=="Vietnam98" | "`countryYY'"=="Panama03" {
			file write f_alloc "\\ \\" _n // write double latex new lines to file to format nicely
			file write f_actual "\\ \\" _n // write double latex new lines to file to format nicely
		}
		else {
			file write f_alloc "\\" _n // write end of line to output file
			file write f_actual "\\" _n // write end of line to output file
		}

	} // end foreach countryYY loop
	
	esttab _all using output_`x'_mincer_A.tex, replace label nostar title(Mincerian Regressions\label{tab`x'A}) ///
		varlabel(2.industry Mining 3.industry Manufacturing 4.industry Utilities 5.industry Construction /// 
		6.industry Commerce 7.industry Transportation 8.industry Finance 9.industry Services 10.industry Miscellanesous Find F-statistic pind p-value) ///
		keep(2.industry 3.industry 4.industry 5.industry 6.industry 7.industry 8.industry 9.industry 10.industry) ///
		scalars("Find Joint F-stat" "pind Joint p-value") mtitles nonotes fragment se sfmt(%9.2f %9.3f) b(%9.3f)

	estimates drop _all
	foreach countryYY in Ecuador95 Guatemala00 Nicaragua98 Nicaragua01 Panama03 Ghana98 Malawi04 Nigeria04 {
		clear
		use "`countryYY'_job_work.dta"
		save "`countryYY'_job_work_temp.dta", replace // save temp version prior to dropping limited industries
		local country = reverse(substr(reverse("`countryYY'"),3,.))

		quietly rsample, min(10) // run rsample routine to eliminate industries with less than min observations

		quietly reg ``x'' [pweight=indweight] if industry>0 // baseline regression
		estimates store `country'
		quietly testparm i.industry // test for equality of all industry dummies
		quietly estadd scalar Find = r(F) // add F-stat from test to stored estimates
		quietly estadd scalar pind = r(p) // add p-value of F-test to stored estimates	
		
		* Run the main regression and produce dataset of wedges and HC stocks by industry
		quietly rwedge ``x'', indnum(`indnum') gamma(`gamma') year(`year') // run rwedge to do Mincer regression, find wedges, and ind. HC amounts
			// rwedge generates two new variables - w_wedge_j and h_ij
		
		* Collapse individual level dataset down to industry level, saving wedge, the total HC by industry, avg. HC by industry and total sample weight
		collapse (mean) w_wedge_j h_ij (sum) sum_indweight = indweight sum_h_ij = h_ij [pweight=indweight], by(industry) 
		save "`countryYY'_`x'_work_ind.dta", replace
		
		* Given dataset of wedges and HC stocks by industry, calculate R
		quietly rgain, alpha(`alpha')
		rfile, handle(f_alloc) countryYY(`countryYY')
		rfile, handle(f_actual) countryYY(`countryYY')
		local j = 1
		local i = 1
		while `i'<=9 { // cycle through all industry's
			if industry[`j'] == `i' {
				file write f_alloc "&" %4.1f (100*perc_h_ij_opt[`j'])
				file write f_actual "&" %4.1f (100*perc_h_ij[`j'])
				local i=`i'+1
				local j=`j'+1
			}
			else {
				file write f_alloc "& $-$" 
				file write f_actual "& $-$" 
				local i = `i'+1
			}
		}

		if "`countryYY'"=="Tajikistan03" | "`countryYY'"=="Vietnam98" | "`countryYY'"=="Panama03" {
			file write f_alloc "\\ \\" _n // write double latex new lines to file to format nicely
			file write f_actual "\\ \\" _n // write double latex new lines to file to format nicely
		}
		else {
			file write f_alloc "\\" _n // write end of line to output file
			file write f_actual "\\" _n // write end of line to output file
		}

	} // end foreach countryYY loop
	
	esttab _all using output_`x'_mincer_B.tex, replace label nostar title(Mincerian Regressions\label{tab`x'B}) ///
		varlabel(2.industry Mining 3.industry Manufacturing 4.industry Utilities 5.industry Construction /// 
		6.industry Commerce 7.industry Transportation 8.industry Finance 9.industry Services 10.industry Miscellanesous Find F-statistic pind p-value) ///
		keep(2.industry 3.industry 4.industry 5.industry 6.industry 7.industry 8.industry 9.industry 10.industry) ///
		scalars("Find Joint F-stat" "pind Joint p-value") mtitles nonotes fragment se sfmt(%9.2f %9.3f) b(%9.3f)

} // end foreach regression loop

capture file close f_alloc
capture file close f_actual
