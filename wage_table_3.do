
* Set up the regressions to run - make sure to update the foreach statement if additional regressions included
local reg1 ln_tot_wge_d i.industry 
local reg2 ln_tot_wge_d i.industry edu age age_sq gender 
local reg3 ln_tot_wge_d i.industry edu age age_sq gender i.occupation 
local reg4 ln_tot_wge_d i.industry edu age age_sq gender i.occupation i.occupation#c.edu 

* Set up the parameters for the calculations
local alpha = .3 // Set the elasticity of wages w.r.t. human capital for main results
local alphaalt .1 .2 // Set the alternative elasticities to use for robustness
local alphareg reg2 // Set which specification to use for alternative elasticity calculations
local selfreg reg2 // Set which specification to use for self-employed workers
local gamma = 0 // Sets the fraction of industry effect that is attributed to unmeasured human capital (baseline is zero)
local year = 0 // Set to 1 to weight daily wages by days/year worked (baseline is zero - means using daily wages)

* Open file to contain TeX output for table 3
capture file close f_result
file open f_result using output_tabl_3.txt, write replace

* Load called programs
do wage_rgain.do
do wage_rsample.do
do wage_rwedge.do
do wage_rselfb.do
do wage_rfile.do

* Run overall analysis for each of the following countryYY surveys
foreach countryYY in Albania05 Bulgaria01 Tajikistan03 Bangladesh00 Indonesia00 Nepal03 Vietnam98 ///
	Ecuador95 Guatemala00 Nicaragua98 Nicaragua01 Panama03 Ghana98 Malawi04 Nigeria04 {
	
	rfile, handle(f_result) countryYY(`countryYY') // writes country name to output file, nicely formatted
	
	* Run baseline specifications for columns 1-4
	foreach x in reg1 reg2 reg3 reg4 {
		clear
		use "`countryYY'_job_work.dta" // grab countryYY data
		save "`countryYY'_job_work_temp.dta", replace // save temp version prior to dropping limited industries
		quietly rsample, min(10) // run rsample routine to eliminate industries with less than min observations
		local indnum = r(indnum) // rsample returns the number of industries left with data
		
		* Run the main regression and produce dataset of wedges and HC stocks by industry
		quietly rwedge ``x'', indnum(`indnum') gamma(`gamma') year(`year') // run rwedge to do Mincer regression, find wedges, and ind. HC amounts
			// rwedge generates two new variables - w_wedge_j and h_ij
		
		* Collapse individual level dataset down to industry level, saving wedge, the total HC by industry, avg. HC by industry and total sample weight
		collapse (mean) w_wedge_j h_ij (sum) sum_indweight = indweight sum_h_ij = h_ij [pweight=indweight], by(industry) 
		save "`countryYY'_`x'_work_ind.dta", replace 
		
		* Given dataset of wedges and HC stocks by industry, calculate R
		quietly rgain, alpha(`alpha')
		file write f_result "&" %9.3f (r(R)) // write value of R to output file
	} // end foreach over baseline regressions

	* Run using distribution of self-employed workers
	clear
	use "`countryYY'_`selfreg'_work_ind.dta" // load up specified industry-level data based on "selfreg" regression
	save "`countryYY'_`selfreg'_work_self.dta", replace // save as self-employed data
	sort industry
	capture merge 1:1 industry using "`countryYY'_all_work_ind.dta" // merge in the data on sector breakdowns from IPUMS
	if _rc==0 { // if a merge file exists
		rselfb, ag(1) non(1) alpha(`alpha') // assume SE earn same as wage-workers
		file write f_result "&" %9.3f (r(R)) // write value of R to output file

		rselfb, ag(.1) non(.1) alpha(`alpha') // assume SE earn 10\% of wage workers
		file write f_result "&" %9.3f (r(R)) // write value of R to output file

		rselfb, ag(1) non(.1) alpha(`alpha') // assume SE earn 10\% of wage in non-ag, 100\% in ag.
		file write f_result "&" %9.3f (r(R)) // write value of R to output file
	}
	else {
		file write f_result "& $-$ & $-$ & $-$" // write dash to output file if no matched self-emp data
	}

	* Run using alternative values of alpha
	foreach x of num `alphaalt' { // cycle through the alternative values of alpha
		clear
		use "`countryYY'_`alphareg'_work_ind.dta" // use the specified wage-wedges from `alphareg' regression
		rgain, alpha(`x') // calculate R
		file write f_result "&" %9.3f (r(R)) // write value of R to output file
	} // end foreach over alternative alpha values

	* Clean up
	if "`countryYY'"=="Tajikistan03" | "`countryYY'"=="Vietnam98" | "`countryYY'"=="Panama03" | "`countryYY'"=="Nigeria04" {
		file write f_result "\\ \\" _n // write double latex new lines to file to format nicely
	}
	else {
		file write f_result "\\" _n // write end of line to output file
	}
} // end foreach loop over countryYY

file close f_result // close output file

