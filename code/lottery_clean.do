/*
This file cleans data on lottery choice 
*/

* Import lottery data
insheet using "${raw_data}/data_101131_lott_choices.csv", clear

* Drop impersonal sessions
drop if session == 2

* Aggregate data to obtin number of safe choices per group
sort session group_nb part, stable
by session group_nb part: egen group_lott = sum(gr)
by session group_nb part: egen lott_1 = sum(s1)
by session group_nb part: egen lott_2 = sum(s2)
by session group_nb part: egen lott_3 = sum(s3)
by session group_nb part: egen lott_4 = sum(s4)
by session group_nb part: egen lott_5 = sum(s5)

by session group_nb part: egen ind_lott_1 = sum(ind1) if session == 9
by session group_nb part: egen ind_lott_2 = sum(ind2) if session == 9
by session group_nb part: egen ind_lott_3 = sum(ind3) if session == 9
by session group_nb part: egen ind_lott_4 = sum(ind4) if session == 9
by session group_nb part: egen ind_lott_5 = sum(ind5) if session == 9

* Drop variables not used
keep lott* ind_lott* g_memb* group_lott session group_nb part

* Drop duplicates on group session level
duplicates drop session group_nb part, force

* Generate median
egen median = rowpctile(lott*), p(50)

* Generate ordering
egen first = rowmin(lott_*)
egen fifth = rowmax(lott_*)
egen third = rowpctile(lott_*), p(50)
egen second = rowpctile(lott_*), p(25)
egen fourth = rowpctile(lott_*), p(75)

* Create session and part combined variable for ease in fixed effect model
egen session_phase = group(session part)

save "${data}/group_lottery.dta", replace

preserve

	keep lott_1 ind_lott_1 g_memb_1 session part group_nb group_lot ///
	first second third fourth fifth
	rename lott_1 lott
	rename ind_lott_1 ind_lott
	rename g_memb_1 g_memb

	save "${data}/ind_lottery.dta", replace
restore

forval num = 2/5 {
	preserve
		keep lott_`num' ind_lott_`num' g_memb_`num' session part group_nb group_lott ///
		first second third fourth fifth
		rename lott_`num' lott
		rename ind_lott_`num' ind_lott
		rename g_memb_`num' g_memb

		append using "${data}/ind_lottery.dta"
		save "${data}/ind_lottery.dta", replace
	restore
}
clear

use ${data}/ind_lottery.dta

* Create variables indicating relative position in group
forval num = 1/5 {
	gen p`num' = 0
}

* Case with no ties
replace p1 = 1 if lott == first & lott != second & ///
	lott != third & lott != fourth & ///
	lott != fifth
replace p2 = 1 if lott != first & lott == second & ///
	lott != third & lott != fourth & ///
	lott != fifth
replace p3 = 1 if lott != first & lott != second & ///
	lott == third & lott != fourth & ///
	lott != fifth
replace p4 = 1 if lott != first & lott != second & ///
	lott != third & lott == fourth & ///
	lott != fifth
replace p5 = 1 if lott != first & lott != second & ///
	lott != third & lott != fourth & ///
	lott == fifth

* Case where first 2, second and third, third and fourth, or last 2 offers are tied
forval num = 1/2{
	replace p`num' = 1/2 if lott == first & ///
	lott == second & lott != third & ///
	lott != fourth & lott != fifth
}
forval num = 2/3{
	replace p`num' = 1/2 if lott != first & ///
	lott == second & lott == third & ///
	lott != fourth & lott != fifth
}
forval num = 3/4{
	replace p`num' = 1/2 if lott != first & ///
	lott != second & lott == third & ///
	lott == fourth & lott != fifth
}
forval num = 4/5{
	replace p`num' = 1/2 if lott != first & ///
	lott != second & lott != third & ///
	lott == fourth & lott == fifth
}

* Case where first 3, middle 3, or last 3 offers are tied
forval num = 1/3{
	replace p`num' = 1/3 if lott == first & ///
	lott == second & lott == third & ///
	lott != fourth & lott != fifth
}
forval num = 2/4{
	replace p`num' = 1/3 if lott != first & ///
	lott == second & lott == third & ///
	lott == fourth & lott != fifth
}
forval num = 3/5{
	replace p`num' = 1/3 if lott != first & ///
	lott != second & lott == third & ///
	lott == fourth & lott == fifth
}

* Case where first 4 or last 4 offers are tied
forval num = 1/4{
	replace p`num' = 1/4 if lott == first & ///
	lott == second & lott == third & ///
	lott == fourth & lott != fifth
}
forval num = 2/5{
	replace p`num' = 1/4 if lott != first & ///
	lott == second & lott == third & ///
	lott == fourth & lott == fifth
}
* Case where all 5 offers are tied
forval num = 1/5 {
	replace p`num' = 1/5 if lott == first & ///
	lott == second & lott == third & ///
	lott == fourth & lott == fifth
}

gen lott_diff = abs(group_lott - lott)
egen subject = group(session g_memb)

* Clean data to extract decision in previous phase for Table 5 and 6

* Generate difference between group and individual lottery

* Generate interaction terms of difference between individual and group interacted
* with dummy indicating relative position 
gen diff = group_lott - lott

gen d1 = (lott == first)
gen d2 = (lott == second)
gen d3 = (lott == third)
gen d4 = (lott == fourth)
gen d5 = (lott == fifth)

foreach var in d1 d2 d3 d4 d5 {
	gen int_`var'_diff = `var' * diff
}

foreach var in lott diff int_d1_diff int_d2_diff int_d3_diff int_d4_diff int_d5_diff {
	gen phase1 = `var' if part == 1
	gen phase2 = `var' if part == 2
	
	sort g_memb session group_nb part 
	by g_memb session: egen phase1_`var' = max(phase1)
	replace phase1_`var' = . if part != 2
	by g_memb session: egen phase2_`var' = max(phase2)
	replace phase2_`var' = . if part != 3
	
	drop phase1 phase2
	
	gen previous_`var' = .
	replace previous_`var' = phase1_`var' if part == 2
	replace previous_`var' = phase2_`var' if part == 3
}

save ${data}/ind_lottery.dta, replace
reg lott previous_lott previous_diff, cluster(session)
reg lott previous_lott previous_int*, cluster(session)


