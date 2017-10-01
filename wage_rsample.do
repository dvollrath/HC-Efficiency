capture program drop rsample
program define rsample, rclass
	syntax , [min(real 10)]
	
	* Strip out industries and occupations with fewer than 10 observations
	sort industry indid
	tempvar ind_count
	by industry: egen `ind_count' = count(indid) // Find count of individuals in each industry
	drop if `ind_count'<`min' //drop industries with fewer than 10 observations
	drop if industry==0 // drop if no industry information
	sort occupation indid
	tempvar occ_count
	by occupation: egen `occ_count' = count(indid) // Find count of individuals in an occupation
	drop if `occ_count'<`min' // drop occupations with fewer than 10 observations
	tabulate industry, nofreq matrow(N)
	local indcount = r(r)
	return scalar indnum = `indcount'
end
