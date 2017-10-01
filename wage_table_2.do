* Make sure you change directory to where all data files are stored

* Set up regressions to use for table 2 and figures - switch to more detailed regression to control for HC
local reg1 ln_tot_wge_d i.industry
local reg4 ln_tot_wge_d i.industry edu age age_sq gender i.occupation i.occupation#c.edu
local name reg1 // name is used in the figure files to identify which regression was used

graph set eps fontface Times // for nice-looking figures

* Load called programs
do wage_rgain.do
do wage_rsample.do
do wage_rwedge.do
do wage_rfile.do

foreach name in reg1 reg4 { // Do this code for both types of regressions
	* Open output files
	capture file close f_wage
	file open f_wage using output_`name'_avg_table.txt, write replace
	capture file close f_share
	file open f_share using output_`name'_share_table.txt, write replace
	capture file close f_figure
	file open f_figure using output_figure_table.txt, write replace

	* Counter for countryYY
	local k = 1
	
	* Look through all countries to calculate their average wages by sector
	foreach countryYY in Albania05 Bulgaria01 Tajikistan03 Bangladesh00 Indonesia00 Nepal03 Vietnam98 ///
		Ecuador95 Guatemala00 Nicaragua98 Nicaragua01 Panama03 Ghana98 Malawi04 Nigeria04 {

		rfile, handle(f_wage) countryYY(`countryYY') // writes country name to output file, nicely formatted
		rfile, handle(f_share) countryYY(`countryYY') // writes country name to output file, nicely formatted
	
		* Clear and open that country's file
		clear
		use "`countryYY'_job_work.dta"
		save "`countryYY'_job_work_temp.dta", replace // save temp version prior to dropping limited industries

		quietly rsample, min(10) // run rsample routine to eliminate industries with less than min observations	
		tab industry, nofreq matrow(N) // Summarize industry data	
		scalar indnum=r(r) // Grab count of remaining number of industries

		quietly reg ``name'' [pweight=indweight] if industry>0 // baseline regression
		mat Mwork = e(b) // Grab the coefficients
		mat Mcoef = Mwork[1,1..indnum] // set up matrix of only the industry dummies
		
  	  	* Calculate the wage relative to average (as opposed to the log differences)
    	quietly tabulate industry, matcell(Mfreq) matrow(Mid)	// Get the frequencies of industry (X) and identifiers (A)
		mat Mshare = Mfreq/_N // Save off the sector shares
		mat Mj = J(indnum,1,1) 
		mat Mtrue = Mcoef' - Mj*Mshare'*Mcoef' // "True" dummies are estimates (including 0) minus the weighted sum
		mata : st_matrix("Mexp", exp(st_matrix("Mtrue"))) // exponentiate the Mavg elements to get wage rel to average
	
		* Write out table of sector wages - allowing for fact that not all countries have all sectors observed
		local i = 1
		local j = 1
		while `i'<=9 { // while loop over all ten possible industries
			if el(Mid,`j',1) == `i' { // if country has industry data matching index i, then write
				file write f_wage "&" %9.2f (el(Mexp,`j',1)) // write the average wage to entry in latex wage table
				file write f_share "&" %9.1f (100*el(Mshare,`j',1)) // write sector share to entry in latex share table
				file write f_figure "`countryYY'," (`i') "," (el(Mexp,`j',1)) "," (el(Mshare,`j',1)) "," (`k') _n // write data for use in figures
				local i = `i' + 1
				local j = `j' + 1
			}
			else { // if country doesn't have industry data matching index i, then put in blank to table, skip ahead
				file write f_wage "& $-$" // write a dash to entry in latex wage table
				file write f_share "& $-$" // write a dash to entry in latex share table
				local i = `i' + 1			
			}
		} // end while loop
	
		* Write end of lines to latex filfes	
		if "`countryYY'"=="Tajikistan03" | "`countryYY'"=="Vietnam98" | "`countryYY'"=="Panama03" {
			file write f_wage "\\ \\" _n // write double latex new lines to file to format nicely
			file write f_share "\\ \\" _n // write double latex new lines to file to format nicely
		}
		else {
			file write f_wage "\\" _n // write end of line to output file
			file write f_share "\\" _n // write end of line to output file
		}
		* Iterate
		local k = `k' + 1
	} // end foreach loop for countryYY

	file close f_wage
	file close f_share
	file close f_figure

	* Use the resulting f_figure file from above to load up all countries data on average wages and produce figures
	clear
	insheet using output_figure_table.txt, comma
	rename v1 country
	rename v2 industry
	rename v3 rel_wage
	rename v4 sec_share
	rename v5 order
	egen c_id = group(country) // Create unique ID for each country
	replace country = "Nicaragua(98)98" if country=="Nicaragua98"
	replace country = "Nicaragua(01)01" if country=="Nicaragua01"
	gen c_name = reverse(substr(reverse(country),3,.)) // Grab only the country name from the country ID's

	* Graph of the sector wage dummies, by country
	graph box rel_wage, over(industry, /// 
		relabel(1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Utilities" 5 "Construction" 6 "Commerce" /// 
		7 "Transportation" 8 "Finance" 9 "Services" 10 "Miscellaneous") label(angle(45) ticks)) /// 
		yline(1, lpattern(dash)) ytitle("Sector Wages Relative to Baseline") graphregion(color(white))
	graph export output_`name'_sec_fig.eps, replace as(eps) 

	reshape wide rel_wage sec_share, i(country) j(industry) // Flip data to be by industry, not by country

	* Graph percent wage terms, by country
	scatter rel_wage1 rel_wage2 rel_wage3 rel_wage4 rel_wage5 rel_wage6 rel_wage7 rel_wage8 rel_wage9 order, ///
		xlabel(1 "Albania" 2 "Bulgaria" 3 "Tajikistan" 4 "Bangladesh" 5 "Indonesia" 6 "Nepal" 7 "Vietnam" ///
		8 "Ecuador" 9 "Guatemala" 10 "Nicarag. (98)" 11 "Nicarag. (01)" 12 "Panama" 13 "Ghana" 14 "Malawi" 15 "Nigeria", /// 
		angle(45)) xtitle("") ///
		ytitle("Sector Wages Relative to Baseline") yline(1, lpattern(dash)) ///
		msymbol(O D T S Oh Dh Th Sh X) legend( label(1 "Agriculture") label(2 "Mining") label(3 "Manufacturing") ///
		label(4 "Utilities") label(5 "Construction") label(6 "Commerce") label(7 "Transport") label(8 "Finance") ///
		label(9 "Services") cols(3)) graphregion(color(white))
	graph export output_`name'_country_fig.eps, replace as(eps)

} // end foreach statement over regressions
