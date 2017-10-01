
capture program drop rwedge
program define rwedge, rclass
	syntax varlist(min=2 max=30 fv), [indnum(real 10) gamma(real 0) year(real 0)]

quietly {
	* Begin by sorting data and cleaning up
	sort industry hh indid job
	capture drop w_wedge_j h_ij
	
	* Set up weighting variables for time - default is to use daily wages
	tempvar work_daysmonth
	tempvar work_months
	gen `work_daysmonth' = 1
	gen `work_months' = 1
	if `year'==1 {
		replace `work_daysmonth' = tot_daysmonth
		replace `work_months' = tot_months
	}

	* Run the regression specified in the command line and capture industry dummies
	reg `varlist' [pweight=indweight] if industry>0
	mat indwork = e(b) // collect all slope estimates from regression
	mat indcoef = indwork[1,1..`indnum'] // save off only the industry coefficients
	mat score delta_j = indcoef // assign each individual their industry coefficient to variable delta_j
	gen w_wedge_j = exp((1-`gamma')*delta_j + _b[_cons])/1000 // add the constant term into each individual industry coefficient to get w*wedge
	gen h_ij = `work_daysmonth'*`work_months'*exp(ln_tot_wge_d - ln(w_wedge_j))/1000 // find each individual HC by subtracting off industry coefficient
		// Both w_wedge_j and h_ij are scaled down by 1000 just to avoid calculation issues
* End quietly	
}
end
