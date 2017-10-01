
capture program drop rgain
program define rgain, rclass
	syntax , [alpha(real 0.3)]

quietly {
		capture drop wedge_j O_alpha_j O_obs_j perc_h_ij perc_h_ij_opt
		replace w_wedge_j = w_wedge_j // scale down wedges to avoid hitting storage issues
		summ w_wedge_j [aweight=sum_h_ij] // get weighted average of all industry coeffcients
		gen wedge_j = w_wedge_j/r(mean) // find wage-wedge alone by dividing through by average w*wedge
		replace sum_h_ij = sum_h_ij // scale down the HC stock size to avoid hitting storage issues
		gen O_alpha_j = w_wedge_j^(1/`alpha')*sum_h_ij/(1-`alpha')^(1/`alpha') // get productivity term Omega (raised to 1/alpha power)
		summ O_alpha_j
		local O_sum = r(sum)^`alpha' // take sum of productivity terms and take to alpha power - this is maximum productivity
		gen O_obs_j = O_alpha_j/wedge_j^(1/`alpha') // divide through O_alpha_j by the wedge_j
		summ O_obs_j
		local O_obs_sum = r(sum)^`alpha' // take sum of observed productivity/wedge terms to alpha - this is observed productivity
		return scalar R = `O_sum'/`O_obs_sum' // return the value of R
		summ sum_h_ij // get summary of hc stocks
		gen perc_h_ij = sum_h_ij/r(sum) // get percentage allocation of human capital
		gen perc_h_ij_opt = O_alpha_j/`O_sum'^(1/`alpha') // get optimal allocation of human capital
} // end quietly 
end
