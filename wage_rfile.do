
capture program drop rfile
program define rfile
	syntax , [handle(string) countryYY(string)]

	local country = reverse(substr(reverse("`countryYY'"),3,.)) // get country name
	local date = substr("`countryYY'",-2,2) // get year
	local dnum = real("`date'") // put year in numeric format
	
	if `dnum'>50 {
		local c_format = "`country'" + " (19" + "`date'" + ")" // build formatted country (year)
	}
	else {
		local c_format = "`country'" + " (20" + "`date'" + ")" // build formatted country (year)	
	}
	
	file write `handle' "`c_format'" 

end

