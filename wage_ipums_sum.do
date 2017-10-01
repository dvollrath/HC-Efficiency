* Make sure you change directory to where the ipums datafile (ipumsi_0038.dta) is stored

capture log close
log using log_ipums_summ.smcl, replace

********************************************************************
* Bangladesh 2001
********************************************************************

clear
use ipumsi_00038.dta if sample==0502
save Bangladesh00_ipums.dta, replace // save as Bangladesh00 to match RIGA set-up

drop if classwk==000 // drop if not in universe of class of worker
tabulate classwk

label define inddv_lbl 1 "Not working"
label define inddv_lbl 2 "Looking for work", add
label define inddv_lbl 3 "Household work", add
label define inddv_lbl 4 "Agriculture", add
label define inddv_lbl 5 "Industry", add
label define inddv_lbl 6 "Water/electricity/gas", add
label define inddv_lbl 7 "Construction", add
label define inddv_lbl 8 "Transport/communications", add
label define inddv_lbl 9 "Hotel/restaurant", add
label define inddv_lbl 10 "Business", add
label define inddv_lbl 11 "Service", add
label define inddv_lbl 12 "Other", add
label define inddv_lbl 99 "NIU", add
label values ind inddv_lbl

gen ind_dv = .
replace ind_dv = 1 if ind==4
replace ind_dv = 3 if ind==5
replace ind_dv = 4 if ind==6
replace ind_dv = 5 if ind==7
replace ind_dv = 6 if ind==10
replace ind_dv = 7 if ind==8
replace ind_dv = 9 if ind==11

gen sch_dv = .
replace sch_dv = yrschl if yrschl<90

save Bangladesh00_ipums.dta, replace

gen wt_wage = 0
replace wt_wage = wtper if classwk==2 // variable holds person weight for only wage/walary workers
gen wt_self = 0
replace wt_self = wtper if classwk==1 | classwk==3 | classwk==9 // variable holds person weight for non-wage workers

collapse (sum) wt_self wt_wage, by(ind_dv)
rename ind_dv industry
save Bangladesh00_all_work_ind.dta, replace

********************************************************************
* Ecuador 1990
********************************************************************
clear
use ipumsi_00038.dta if sample==2184
save Ecuador95_ipums.dta, replace 

gen ind_dv = .
replace ind_dv = 1 if indgen==10
replace ind_dv = 2 if indgen==20
replace ind_dv = 3 if indgen==30
replace ind_dv = 4 if indgen==40
replace ind_dv = 5 if indgen==50
replace ind_dv = 6 if indgen==60
replace ind_dv = 7 if indgen==80
replace ind_dv = 8 if indgen==90 | indgen==111
replace ind_dv = 9 if indgen==100 | indgen==110 | indgen==112 | indgen==113 | indgen==114 | indgen==120

gen sch_dv = .
replace sch_dv = yrschl if yrschl<90

drop if classwk==000 // drop if not in universe of class of worker

save Ecuador95_ipums.dta, replace 

gen wt_wage = 0
replace wt_wage = wtper if classwk==2 // variable holds person weight for only wage/walary workers
gen wt_self = 0
replace wt_self = wtper if classwk==1 | classwk==3 | classwk==9 // variable holds person weight for non-wage workers

collapse (sum) wt_self wt_wage, by(ind_dv)
rename ind_dv industry
save Ecuador95_all_work_ind.dta, replace

********************************************************************
* Ghana 2000
********************************************************************
clear
use ipumsi_00038.dta if sample==2881
save Ghana98_ipums.dta, replace

gen ind_dv = .
replace ind_dv = 1 if indgen==10
replace ind_dv = 2 if indgen==20
replace ind_dv = 3 if indgen==30
replace ind_dv = 4 if indgen==40
replace ind_dv = 5 if indgen==50
replace ind_dv = 6 if indgen==60
replace ind_dv = 7 if indgen==80
replace ind_dv = 8 if indgen==90 | indgen==111
replace ind_dv = 9 if indgen==100 | indgen==110 | indgen==112 | indgen==113 | indgen==114 | indgen==120

gen sch_dv = .
replace sch_dv = yrschl if yrschl<90

drop if classwk==000 // drop if not in universe of class of worker

save Ghana98_ipums.dta, replace

gen wt_wage = 0
replace wt_wage = wtper if classwk==2 // variable holds person weight for only wage/walary workers
gen wt_self = 0
replace wt_self = wtper if classwk==1 | classwk==3 | classwk==9 // variable holds person weight for non-wage workers

collapse (sum) wt_self wt_wage, by(ind_dv)
rename ind_dv industry
save Ghana98_all_work_ind.dta, replace

********************************************************************
* Indonesia 2000
********************************************************************
clear
use ipumsi_00038.dta if sample==3607
save Indonesia00_ipums.dta, replace

gen sch_dv = .
replace sch_dv = 3 if edattan==1
replace sch_dv = 6 if edattan==2
replace sch_dv = 12 if edattan==3
replace sch_dv = 16 if edattan==4

gen ind_dv = .
replace ind_dv = 1 if ind==1 | ind==2 | ind==3 | ind==4 | ind==5
replace ind_dv = 3 if ind==6
replace ind_dv = 6 if ind==7
replace ind_dv = 7 if ind==9
replace ind_dv = 9 if ind==8

drop if classwk==000 // drop if not in universe of class of worker

save Indonesia00_ipums.dta, replace

gen wt_wage = 0
replace wt_wage = wtper if classwk==2 // variable holds person weight for only wage/walary workers
gen wt_self = 0
replace wt_self = wtper if classwk==1 | classwk==3 | classwk==9 // variable holds person weight for non-wage workers

collapse (sum) wt_self wt_wage, by(ind_dv)
rename ind_dv industry
save Indonesia00_all_work_ind.dta, replace

********************************************************************
* Malawi 2008
********************************************************************
clear
use ipumsi_00038.dta if sample==4543
save Malawi04_ipums.dta, replace

gen ind_dv = .
replace ind_dv = 1 if indgen==10
replace ind_dv = 2 if indgen==20
replace ind_dv = 3 if indgen==30
replace ind_dv = 4 if indgen==40
replace ind_dv = 5 if indgen==50
replace ind_dv = 6 if indgen==60
replace ind_dv = 7 if indgen==80
replace ind_dv = 8 if indgen==90 | indgen==111
replace ind_dv = 9 if indgen==100 | indgen==110 | indgen==112 | indgen==113 | indgen==114 | indgen==120

gen sch_dv = .
replace sch_dv = yrschl if yrschl<90

drop if classwk==000 // drop if not in universe of class of worker

save Malawi04_ipums.dta, replace

gen wt_wage = 0
replace wt_wage = wtper if classwk==2 // variable holds person weight for only wage/walary workers
gen wt_self = 0
replace wt_self = wtper if classwk==1 | classwk==3 | classwk==9 // variable holds person weight for non-wage workers

collapse (sum) wt_self wt_wage, by(ind_dv)
rename ind_dv industry
save Malawi04_all_work_ind.dta, replace

********************************************************************
* Nepal 2001
********************************************************************
clear
use ipumsi_00038.dta if sample==5241
save Nepal03_ipums.dta, replace

gen ind_dv = .
replace ind_dv = 1 if indgen==10
replace ind_dv = 2 if indgen==20
replace ind_dv = 3 if indgen==30
replace ind_dv = 4 if indgen==40
replace ind_dv = 5 if indgen==50
replace ind_dv = 6 if indgen==60
replace ind_dv = 7 if indgen==80
replace ind_dv = 8 if indgen==90 | indgen==111
replace ind_dv = 9 if indgen==100 | indgen==110 | indgen==112 | indgen==113 | indgen==114 | indgen==120

gen sch_dv = .
replace sch_dv = yrschl if yrschl<90

drop if classwk==000 // drop if not in universe of class of worker

save Nepal03_ipums.dta, replace

gen wt_wage = 0
replace wt_wage = wtper if classwk==2 // variable holds person weight for only wage/walary workers
gen wt_self = 0
replace wt_self = wtper if classwk==1 | classwk==3 | classwk==9 // variable holds person weight for non-wage workers

collapse (sum) wt_self wt_wage, by(ind_dv)
rename ind_dv industry
save Nepal03_all_work_ind.dta, replace

********************************************************************
* Nicaragua 1995
********************************************************************
clear
use ipumsi_00038.dta if sample==5582
save Nicaragua98_ipums.dta, replace

gen ind_dv = .
replace ind_dv = 1 if indgen==10
replace ind_dv = 2 if indgen==20
replace ind_dv = 3 if indgen==30
replace ind_dv = 4 if indgen==40
replace ind_dv = 5 if indgen==50
replace ind_dv = 6 if indgen==60
replace ind_dv = 7 if indgen==80
replace ind_dv = 8 if indgen==90 | indgen==111
replace ind_dv = 9 if indgen==100 | indgen==110 | indgen==112 | indgen==113 | indgen==114 | indgen==120

gen sch_dv = .
replace sch_dv = yrschl if yrschl<90

drop if classwk==000 // drop if not in universe of class of worker

save Nicaragua98_ipums.dta, replace

gen wt_wage = 0
replace wt_wage = wtper if classwk==2 // variable holds person weight for only wage/walary workers
gen wt_self = 0
replace wt_self = wtper if classwk==1 | classwk==3 | classwk==9 // variable holds person weight for non-wage workers

collapse (sum) wt_self wt_wage, by(ind_dv)
rename ind_dv industry
save Nicaragua98_all_work_ind.dta, replace

********************************************************************
* Nicaragua 2005
********************************************************************
clear
use ipumsi_00038.dta if sample==5583
save Nicaragua01_ipums.dta, replace

gen ind_dv = .
replace ind_dv = 1 if indgen==10
replace ind_dv = 2 if indgen==20
replace ind_dv = 3 if indgen==30
replace ind_dv = 4 if indgen==40
replace ind_dv = 5 if indgen==50
replace ind_dv = 6 if indgen==60
replace ind_dv = 7 if indgen==80
replace ind_dv = 8 if indgen==90 | indgen==111
replace ind_dv = 9 if indgen==100 | indgen==110 | indgen==112 | indgen==113 | indgen==114 | indgen==120

gen sch_dv = .
replace sch_dv = yrschl if yrschl<90

drop if classwk==000 // drop if not in universe of class of worker

save Nicaragua01_ipums.dta, replace

gen wt_wage = 0
replace wt_wage = wtper if classwk==2 // variable holds person weight for only wage/walary workers
gen wt_self = 0
replace wt_self = wtper if classwk==1 | classwk==3 | classwk==9 // variable holds person weight for non-wage workers

collapse (sum) wt_self wt_wage, by(ind_dv)
rename ind_dv industry
save Nicaragua01_all_work_ind.dta, replace

********************************************************************
* Panama 2000
********************************************************************
clear
use ipumsi_00038.dta if sample==5915
save Panama03_ipums.dta, replace

gen ind_dv = .
replace ind_dv = 1 if indgen==10
replace ind_dv = 2 if indgen==20
replace ind_dv = 3 if indgen==30
replace ind_dv = 4 if indgen==40
replace ind_dv = 5 if indgen==50
replace ind_dv = 6 if indgen==60
replace ind_dv = 7 if indgen==80
replace ind_dv = 8 if indgen==90 | indgen==111
replace ind_dv = 9 if indgen==100 | indgen==110 | indgen==112 | indgen==113 | indgen==114 | indgen==120

gen sch_dv = .
replace sch_dv = yrschl if yrschl<90

drop if classwk==000 // drop if not in universe of class of worker

save Panama03_ipums.dta, replace

gen wt_wage = 0
replace wt_wage = wtper if classwk==2 // variable holds person weight for only wage/walary workers
gen wt_self = 0
replace wt_self = wtper if classwk==1 | classwk==3 | classwk==9 // variable holds person weight for non-wage workers

collapse (sum) wt_self wt_wage, by(ind_dv)
rename ind_dv industry
save Panama03_all_work_ind.dta, replace

********************************************************************
* Vietnam 2009
********************************************************************
clear
use ipumsi_00038.dta if sample==7043
save vietnam98_ipums.dta, replace

gen ind_dv = .
replace ind_dv = 1 if indgen==10
replace ind_dv = 2 if indgen==20
replace ind_dv = 3 if indgen==30
replace ind_dv = 4 if indgen==40
replace ind_dv = 5 if indgen==50
replace ind_dv = 6 if indgen==60
replace ind_dv = 7 if indgen==80
replace ind_dv = 8 if indgen==90 | indgen==111
replace ind_dv = 9 if indgen==100 | indgen==110 | indgen==112 | indgen==113 | indgen==114 | indgen==120

gen sch_dv = .
replace sch_dv = yrschl if yrschl<90

drop if classwk==000 // drop if not in universe of class of worker

save vietnam98_ipums.dta, replace

gen wt_wage = 0
replace wt_wage = wtper if classwk==2 // variable holds person weight for only wage/walary workers
gen wt_self = 0
replace wt_self = wtper if classwk==1 | classwk==3 | classwk==9 // variable holds person weight for non-wage workers

collapse (sum) wt_self wt_wage, by(ind_dv)
rename ind_dv industry
save Vietnam98_all_work_ind.dta, replace

log close
