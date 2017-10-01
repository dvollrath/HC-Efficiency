* Set up job files for use in analysis
* Change directory to where all data files are stored
cd /Users/dietz/dropbox/aglabor/replicate

* Loop through all country surveys to set up and recode datasets.
foreach ccyy in Albania05 Bulgaria01 Tajikistan03 Bangladesh00 Indonesia00 Nepal03 Vietnam98 ///
	Ecuador95 Guatemala00 Nicaragua98 Nicaragua01 Panama03 Ghana98 Malawi04 Nigeria04 {

	use `ccyy'_IND_WGEJOB.dta

	* Drop variables - capture the return code 
	capture: drop id 
	capture: drop age_sq 
	capture: drop p_wge_all
	capture: drop ind_lim 
	capture: drop occ_lim 
	capture: drop industry 
	capture: drop job_prim 
	capture: drop ln_tot_wge_d 
	capture: drop freq_dur 
	capture: drop _merge

	* Set log file for capturing summary statistics and results
	capture log close
	log using log_`ccyy'_setup.smcl, replace

	* First, many observations are not working (children,elderly,etc.) Table them to see totals
	table job
	count

	* Merge the individual level data on education, age, etc..
	merge m:1 hh indid using `ccyy'_IND_HCCHAR.dta
	drop _merge
	merge m:1 hh indid using `ccyy'_IND_ADMIN.dta

	* Check for observations that are missing HC or ADMIN data - drop if no job or missing job code
	count if edu==.
	count if urban==.
	drop if edu==.
	drop if job==0 | job==.

	* Generate a unique ID for each individual - not necessary
	* gen id = hh*100 + indid
	gen id = 0

	gen age_sq = age^2

	* Check for jobs that are listed as being in 2 industries
	gen p_wge_all = p_wge_m1+p_wge_m2+p_wge_m3+p_wge_m4+p_wge_m5+p_wge_m6+p_wge_m7+p_wge_m8+p_wge_m9+p_wge_m10
	table p_wge_all
	drop if p_wge_all>1

	* Generate a single variable for the limited industry variables used by RIGA
	* (Note that I am pushing Misc industry into services)
	gen ind_lim = 0
	replace ind_lim=1 if p_wge_m1==1  /* Agriculture */
	replace ind_lim=2 if p_wge_m3==1  /* Manufacturing */
	replace ind_lim=3 if p_wge_m5==1  /* Construction */
	replace ind_lim=4 if p_wge_m6==1 | p_wge_m7==1 | p_wge_m8==1  /*Commerce; Trans,Storage,Comm; Fin and RE */
	replace ind_lim=5 if p_wge_m9==1 | p_wge_m10==1  /* Services; Miscellaneous */
	replace ind_lim=6 if p_wge_m2==1 | p_wge_m4==1   /* Mining and Utility */

	* Generate a single variable for industry, using full RIGA industry definitions
	gen industry=0
	replace industry=1 if p_wge_m1==1 /* Agriculture */
	replace industry=2 if p_wge_m2==1 /* Mining */
	replace industry=3 if p_wge_m3==1 /* Manufacturing */
	replace industry=4 if p_wge_m4==1 /* Utilities */
	replace industry=5 if p_wge_m5==1 /* Construction */
	replace industry=6 if p_wge_m6==1 /* Commerce */
	replace industry=7 if p_wge_m7==1 /* Transportation */
	replace industry=8 if p_wge_m8==1 /* Finance and Real Estate */
	replace industry=9 if p_wge_m9==1 /* Services */
	replace industry=10 if p_wge_m10==1 /* Miscellaneous */

	* Simplify the job variable into binary. 1 == primary job, 2 == 2nd, 3rd, 4th job
	gen job_prim = 0
	replace job_prim = 1 if job==1
	replace job_prim = 2 if job>1

	* Generate a limited occupation variable to increase cell sizes - my own categories
	gen occ_lim = 0
	replace occ_lim = 1 if occupation==1 | occupation==4 | occupation==8 /* Managers; Clerks; Plant + Machine */
	replace occ_lim = 2 if occupation==2 | occupation==3  /* Professionals; Technicians */
	replace occ_lim = 3 if occupation==5  /* Service, Markets */
	replace occ_lim = 4 if occupation==6 | occupation==9  | occupation==10 | occupation==11 /* Skilled Ag; Elementary; Armed; Other */
	replace occ_lim = 5 if occupation==7  /* Crafts and Related */

	* Get daily wage in logs
	gen ln_tot_wge_d = ln(tot_wge_d)

	* Generate a variable for categories of duration (FY/PY) and frequency (FT/PT)
	gen freq_dur = 0
	replace freq_dur = 1 if fyft==1 /* Full year and full time */
	replace freq_dur = 2 if fypt==1 /* Full year and part time */
	replace freq_dur = 3 if pyft==1 /* Part year and full time */
	replace freq_dur = 4 if pypt==1 /* Part year and part time */

	* Check for indweight variable - if none, set up so each obs is equally weighted
	capture summ indweight
	if _rc==111 { // variable not found
		gen indweight=1 // make each individual equally-weighted. This should only affect Bulgaria
	}
	
	* Label Variables and Save dataset
	label variable id "HH + INDID"
	label variable age_sq "Age squared"
	label variable p_wge_all "Sum of participation variables"
	label variable ind_lim "Industry, limited definition"
	label variable industry "Industry, full definition"
	label variable job_prim "=1 for prim job, =2 for other"
	label variable occ_lim "Occupation, limited definition"
	label variable ln_tot_wge_d "Log of daily wage"
	label variable freq_dur "Code for year/time of work"
	label define freqdur 1 "Full year, full time" 2 "Full year, part time" 3 "Part year, full time" 4 "Part year, part time", replace
	label values freq_dur freqdur
	label define ind 1 "Ag" 2 "Mine" 3 "Man" 4 "Util" 5 "Cons" 6 "Comm" 7 "Trans" 8 "Fin" 9 "Svc" 10 "Misc", replace
	label define indlim 1 "Ag" 2 "Man" 3 "Cons" 4 "CmTran" 5 "Svc" 6 "MinU" 7 "Misc"
	label define occlim 1 "Manage, Clerk, Plant" 2 "Prof, Tech" 3 "Service, Mark" 4 "Skill Ag, Elem, Other" 5 "Crafts", replace
	label values industry ind
	label values ind_lim indlim
	label values occ_lim occlim

	* Save dataset
	save `ccyy'_job_work.dta, replace

	log close

} // end foreach loop over countrys

* Special setup for Panama. Several utility-sector workers have ridiculously high wages relative to other utility workers (100x)
* This appears to be an error from RIGA in calculating daily wages. The days/month and monthly wages are realistic.
	clear
	use Panama03_job_work.dta
	replace tot_wge_d = tot_wge_m/tot_daysmonth if industry==4 // recalculate daily wages for utility workers
	replace ln_tot_wge_d = ln(tot_wge_d) if industry==4 // reset log daily wages
	save Panama03_job_work.dta, replace
	
* Special setup for Nigeria. There are 46 agricultural workers who have typical monthly wages, but report 
* only working .06 or .09 days per month. This gives them daily wages way out of proportion to any others
* Drop them - without accurate days/month cannot calculate accurate daily wage
	clear
	use Nigeria04_job_work.dta
	drop if industry==1 & tot_daysmonth<1
	save Nigeria04_job_work.dta
