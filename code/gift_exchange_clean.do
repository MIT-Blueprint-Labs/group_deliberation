/* 
This file cleans data on gift exchange 
*/

* Import trust data
insheet using "${raw_data}/data_101131_trust_choices.csv", clear

* Drop impersonal sessions 
drop if session == 2

* Sum normalized group median offers
egen median = rowpctile(g_ind_offer*), p(50)
gen normal_median = median - first_offer
sum normal_median

* Normalize group offers by first offers
rename group group_offer_abs
gen group_offer = group_offer_abs - first_offer

* Generate lowest to highest offers
egen first_abs = rowmin(g_ind_offer*)
egen fifth_abs = rowmax(g_ind_offer*)
egen third_abs = rowpctile(g_ind_offer*), p(50)
egen second_abs = rowpctile(g_ind_offer*), p(25)
egen fourth_abs = rowpctile(g_ind_offer*), p(75)

* Normalize individual offers by first offers
foreach offer in first second third fourth fifth {
	gen `offer' = `offer'_abs - first_offer
}


* Generate group phase categorical variable
egen session_phase = group(session part)
tab session_phase, gen(session_phase_)


save "${data}/group_offer.dta", replace

* Sum normalized individual reciprocate offers
preserve

	keep g_ind_offer_1 sess_sub1 ind_ind_offer_1 session first_offer group_offer ///
	group_nb part dec_in_part first second third fourth fifth g_memb_1
	foreach var in g_ind_offer ind_ind_offer g_memb {
		ren `var'_1 `var'
	}
	ren sess_sub1 sess_sub
	save "${data}/ind_offer.dta", replace 

restore 

forval num = 2/5 {
	preserve

		keep g_ind_offer_`num' sess_sub`num' ind_ind_offer_`num' session first_offer ///
		group_offer group_nb part dec_in_part first second third fourth fifth g_memb_`num'
		foreach var in g_ind_offer ind_ind_offer g_memb {
			ren `var'_`num' `var'
		}
		ren sess_sub`num' sess_sub
		append using "${data}/ind_offer.dta"
		save "${data}/ind_offer.dta", replace
	restore
}
clear

* Normalize individual offers by first offer
use "${data}/ind_offer.dta"
gen normal_g_ind_offer = g_ind_offer - first_offer
gen normal_ind_ind_offer = ind_ind_offer - first_offer

* Create variables indicating relative position in group
forval num = 1/5 {
	gen p`num' = 0
} 

* Case with no ties 
replace p1 = 1 if normal_g_ind_offer == first & normal_g_ind_offer != second & ///
	normal_g_ind_offer != third & normal_g_ind_offer != fourth & ///
	normal_g_ind_offer != fifth
replace p2 = 1 if normal_g_ind_offer != first & normal_g_ind_offer == second & ///
	normal_g_ind_offer != third & normal_g_ind_offer != fourth & ///
	normal_g_ind_offer != fifth
replace p3 = 1 if normal_g_ind_offer != first & normal_g_ind_offer != second & ///
	normal_g_ind_offer == third & normal_g_ind_offer != fourth & ///
	normal_g_ind_offer != fifth
replace p4 = 1 if normal_g_ind_offer != first & normal_g_ind_offer != second & ///
	normal_g_ind_offer != third & normal_g_ind_offer == fourth & ///
	normal_g_ind_offer != fifth
replace p5 = 1 if normal_g_ind_offer != first & normal_g_ind_offer != second & ///
	normal_g_ind_offer != third & normal_g_ind_offer != fourth & ///
	normal_g_ind_offer == fifth
	
* Case where first 2, second and third, third and fourth, or last 2 offers are tied	
forval num = 1/2{
	replace p`num' = 1/2 if normal_g_ind_offer == first & ///
	normal_g_ind_offer == second & normal_g_ind_offer != third & ///
	normal_g_ind_offer != fourth & normal_g_ind_offer != fifth
}
forval num = 2/3{
	replace p`num' = 1/2 if normal_g_ind_offer != first & ///
	normal_g_ind_offer == second & normal_g_ind_offer == third & ///
	normal_g_ind_offer != fourth & normal_g_ind_offer != fifth
}
forval num = 3/4{
	replace p`num' = 1/2 if normal_g_ind_offer != first & ///
	normal_g_ind_offer != second & normal_g_ind_offer == third & ///
	normal_g_ind_offer == fourth & normal_g_ind_offer != fifth
}
forval num = 4/5{
	replace p`num' = 1/2 if normal_g_ind_offer != first & ///
	normal_g_ind_offer != second & normal_g_ind_offer != third & ///
	normal_g_ind_offer == fourth & normal_g_ind_offer == fifth
}

* Case where first 3, middle 3, or last 3 offers are tied
forval num = 1/3{
	replace p`num' = 1/3 if normal_g_ind_offer == first & ///
	normal_g_ind_offer == second & normal_g_ind_offer == third & ///
	normal_g_ind_offer != fourth & normal_g_ind_offer != fifth
}
forval num = 2/4{
	replace p`num' = 1/3 if normal_g_ind_offer != first & ///
	normal_g_ind_offer == second & normal_g_ind_offer == third & ///
	normal_g_ind_offer == fourth & normal_g_ind_offer != fifth
}
forval num = 3/5{
	replace p`num' = 1/3 if normal_g_ind_offer != first & ///
	normal_g_ind_offer != second & normal_g_ind_offer == third & ///
	normal_g_ind_offer == fourth & normal_g_ind_offer == fifth
}
	
* Case where first 4 or last 4 offers are tied
forval num = 1/4{
	replace p`num' = 1/4 if normal_g_ind_offer == first & ///
	normal_g_ind_offer == second & normal_g_ind_offer == third & ///
	normal_g_ind_offer == fourth & normal_g_ind_offer != fifth
}
forval num = 2/5{
	replace p`num' = 1/4 if normal_g_ind_offer != first & ///
	normal_g_ind_offer == second & normal_g_ind_offer == third & ///
	normal_g_ind_offer == fourth & normal_g_ind_offer == fifth
}
* Case where all 5 offers are tied 
forval num = 1/5 {
	replace p`num' = 1/5 if normal_g_ind_offer == first & ///
	normal_g_ind_offer == second & normal_g_ind_offer == third & ///
	normal_g_ind_offer == fourth & normal_g_ind_offer == fifth
}

* Generate dependent variable of difference between individual and group offer
gen offer_diff = abs(group_offer - normal_g_ind_offer)	

encode sess_sub, gen(subject)

save "${data}/ind_offer.dta", replace

