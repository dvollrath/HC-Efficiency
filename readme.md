## The Efficiency of Human Capital Distributions in Developing Countries
Dietz Vollrath, University of Houston

### Data
The RIGA files are available from the [World Bank](http://www.fao.org/economic/riga/riga-database/en/). The IPUMS files are available from [IPUMS International](https://international.ipums.org/international/). The March CPS data for the US was downloaded from the [NBER](http://www.nber.org/cps/).

As the data is all public, and to facilitate replication, the original files I used are all posted [here](http://hc-efficiency.s3-website.us-east-2.amazonaws.com). 

The code is written assuming the data files are located in the same folder, so you will need to save the individual data files to the same folder as the code.

### Setup
The first two are setup - they take in the raw data and produce necessary files. Only need to run once.

1. wage_setup.do: This takes the raw RIGA data received and sets up working files named CountryYY_job_work.dta. These have only records for jobs, have several new variables created, and label several other vatiables.
    
2. wage_ipums_sum.do: This pulls in IPUMS census datafiles, renames and recodes certain variables, and then collapses this to an industry-level dataset that lists the number of self-employed and wage-workers in each industry. This is what is used in wage_table_3.do to get the full distribution of workers.

### Calculations
The next are the actual programs to do the calculations and produce tables and figures. They depend on the files from 1 and 2 .  

1. wage_table_2.do: This reads in the country files and produces table 2 (wages relative to average) and table A.5 (percent wage workers by sector). It also produces figures 1 through 4, showing wages relative to average wages in various formats.

2. wage_table_3.do: This is the main program for the paper. It reads through country files and produces table 3. It calculates the baseline results in columns 1 to 4, then incorporates self-employed data for columns 5 to 7, and then uses alternative values of alpha for column 8 and 9.
    
3. wage_table_appx.do: This produces appendix tables A.1 through A.4, which show the results from the Mincerian regressions underlying the results.

4. wage_fig_5.do: This produces figure 5, which shows how the gains from reallocation drop as you increase the role of unobserved human capital

5. wage_us.do: This calculates the values of R for the U.S using CPS data, results are found in table 3. This isn't all automatic, you have to rerun several times under different parameter values to replicate all the results.

### Called programs
Each of the previous programs calls sub-routines that calculate various quantities or modify files in some way. These are

1. wage_rwedge.do: This uses the individual-level data, runs a Mincerian regression that you pass to it, and produces estimates of the wage-wedge for each industry as well as individual-level estimates of human capital. You have to tell it how many industrys there are, what percent of the dummy variable should be used as unobserved HC, and whether to use yearly or daily data
    
2. wage_rgain.do: This uses industry-level data that has wedges and HC stocks. Using these, it calculates the productivity levels for each industry, and then calculates the implied gain from removing the wage-wedges.
    
3. wage_rselfb.do: This uses industry-level data that has appended to it the overall share of workers in each sector. Using this new distribution of workers, it calls rgain and recalculates the gain from removing wage-wedges. You have to pass it the ratio of earnings of agricultural self-employed workers relative to ag. wage-workers, and a similar ratio for non-ag workers.
    
4. wage_rsample.do: This routine clears out individuals with missing data, drops all individuals in a given industry if that industry has too few observations, and returns the number of industries left. 
    
5. wage_rfile.do: This writes a nicely formatted name of the country and year to a specified output file
