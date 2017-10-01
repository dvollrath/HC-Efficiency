
capture program drop rselfb
program define rselfb, rclass
	syntax , [ag(real 1) non(real 1) alpha(real 0.3)]

	tempvar base_sum_h_ij
	gen `base_sum_h_ij' = sum_h_ij // capture the baseline HC distribution
	replace sum_h_ij = wt_wage*h_ij + `non'*h_ij*wt_self if industry~=1 // calc non-ag HC stock
	replace sum_h_ij = wt_wage*h_ij + `ag'*h_ij*wt_self  if industry==1 // cala ag HC stock
	rgain, alpha(`alpha') // calculate the gain from reallocation
	return scalar R = r(R)
	replace sum_h_ij = `base_sum_h_ij' // put original HC distribution back

*	replace w_wedge_j = (wt_wage*w_base_j + `non'*wt_self*w_base_j)/(wt_wage + wt_self) if industry>1
*	replace w_wedge_j = (wt_wage*w_base_j + `ag'*wt_self*w_base_j)/(wt_wage + wt_self) if industry==1

end

