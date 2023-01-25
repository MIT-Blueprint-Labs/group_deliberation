/* 
This file compiles all tables presented in the paper and the online apppendix 
and exports each table into an excel sheet saved in the output folder
*/

********************************************************************
**************************  Table 1  *******************************
********************************************************************
* Initialize matrix
matrix A = J(6, 6, .)
local cols "N Avg StdDev N Avg StdDev"
local rows "individual group_median group only_last_session individual_for_individual individual_for_group"

* Summarize variables
local c = 1
foreach col in N mean sd {
	local r = 1 
	use "${data}/ind_offer.dta"
	sum normal_g_ind_offer
	mat A[`r', `c'] = round(r(`col'), 0.01)
	local ++r
	use "${data}/group_offer.dta"
	sum normal_median
	mat A[`r', `c'] = round(r(`col'), 0.01)
	local ++r
	sum group_offer
	mat A[`r', `c'] = round(r(`col'), 0.01)
	local ++r
	local ++r
	use "${data}/ind_offer.dta"
	sum normal_ind_ind_offer if session == 9
	mat A[`r', `c'] = round(r(`col'), 0.01)
	local ++r
	sum normal_g_ind_offer if session == 9
	mat A[`r', `c'] = round(r(`col'), 0.01)
	local ++r
	local ++c
}

foreach col in N mean sd {
	local r = 1 
	use "${data}/ind_lottery.dta"
	sum lott
	mat A[`r', `c'] = round(r(`col'), 0.01)
	local ++r
	use "${data}/group_lottery.dta"
	sum median
	mat A[`r', `c'] = round(r(`col'), 0.01)
	local ++r
	sum group_lott
	mat A[`r', `c'] = round(r(`col'), 0.01)
	local ++r
	local ++r
	use "${data}/ind_lottery.dta"
	sum ind_lott if session == 9
	mat A[`r', `c'] = round(r(`col'), 0.01)
	local ++r
	sum lott if session == 9
	mat A[`r', `c'] = round(r(`col'), 0.01)
	local ++r
	local ++c
}

svmat A 
mat rownames A = `rows'
mat colnames A = `cols'

putexcel set "${output}/table1.xlsx", modify sheet("summary statistics")
putexcel A1 = matrix(A), names

drop A*
clear 

********************************************************************
**************************  Table 2  *******************************
********************************************************************
* Initialize matrix
matrix A = J(14, 4, .)
local cols "group_offer group_offer(FE) group_lottery group_lottery(FE)"
local rows "constant _ individual_offer_1 _ individual_offer_2 _ "
local rows "`rows' individual_offer_3 _ individual_offer_4 _ individual_offer_5 _ "
local rows "`rows' N R-squared"

* Run regressions
local c = 1
local r = 1
use "${data}/group_offer.dta"
reg group_offer first second third fourth fifth, cluster(session)
foreach var in _cons first second third fourth fifth {
	mat A[`r',`c'] = round(_b[`var'], .001)
	local ++r
	mat A[`r',`c'] = round(_se[`var'], .001)
	local ++r
}
mat A[`r',`c'] = round(e(N), .001)
local ++r
mat A[`r',`c'] = round(e(r2), .001)

local ++c
local r = 1
reg group_offer first second third fourth fifth i.session_phase, cluster(session)
foreach var in _cons first second third fourth fifth {
	mat A[`r',`c'] = round(_b[`var'], .001)
	local ++r
	mat A[`r',`c'] = round(_se[`var'], .001)
	local ++r
}
mat A[`r',`c'] = round(e(N), .001)
local ++r
mat A[`r',`c'] = round(e(r2), .001)

local ++c
local r = 1
use "${data}/group_lottery.dta"
reg group_lott first second third fourth fifth, cluster(session)
foreach var in _cons first second third fourth fifth {
	mat A[`r',`c'] = round(_b[`var'], .001)
	local ++r
	mat A[`r',`c'] = round(_se[`var'], .001)
	local ++r
}
mat A[`r',`c'] = round(e(N), .001)
local ++r
mat A[`r',`c'] = round(e(r2), .001)

local ++c
local r = 1
reg group_lott first second third fourth fifth i.session_phase, cluster(session)
foreach var in _cons first second third fourth fifth {
	mat A[`r',`c'] = round(_b[`var'], .001)
	local ++r
	mat A[`r',`c'] = round(_se[`var'], .001)
	local ++r
}
mat A[`r',`c'] = round(e(N), .001)
local ++r
mat A[`r',`c'] = round(e(r2), .001)

svmat A

mat rownames A = `rows'
mat colnames A = `cols'

* Output table
putexcel set "${output}/table2.xlsx", modify sheet("Table 2")
putexcel A1 = matrix(A), names

drop A*
clear

********************************************************************
**************************  Table 3  *******************************
********************************************************************
* Initialize matrix
matrix A = J(7, 4, .)
local cols "(1) (2) (3) (4)"
local rows "hypothesis weak_mean strong_mean weak_median strong_median"
local rows "`rows' extreme_irrelevance convex_combination"

* Run hypothesis tests
use "${data}/group_offer.dta"
local fe 
local c = 1
foreach model in 1 2 {
	if `model' == 2 {
		local fe "i.session_phase"
	}
	local r = 2
	reg group_offer first second third fourth fifth `fe', cluster(session)
	* Weak mean
	test first = second = third = fourth = fifth
	mat A[`r',`c'] = round(r(p), .001)
	local ++r
	* Strong mean
	test first = second = third = fourth = fifth = 1/5
	mat A[`r',`c'] = round(r(p), .001)
	local ++r
	* Weak median
	test first = second = fourth = fifth = 0
	mat A[`r',`c'] = round(r(p), .001)
	local ++r
	* Strong median
	test (first = second = fourth = fifth = 0) (third = 1)
	mat A[`r',`c'] = round(r(p), .001)
	local ++r
	* Extreme irrelevance
	test first = fifth = 0
	mat A[`r',`c'] = round(r(p), .001)
	local ++r
	* Convex combination
	test first + second + third + fourth + fifth = 1
	mat A[`r',`c'] = round(r(p), .001)
	local ++c
}

use "${data}/group_lottery.dta"
local fe 
foreach model in 1 2 {
	if `model' == 2 {
		local fe "i.session_phase"
	}
	local r = 2
	reg group_lott first second third fourth fifth `fe', cluster(session)
	* Weak mean
	test first = second = third = fourth = fifth
	mat A[`r',`c'] = round(r(p), .001)
	local ++r
	* Strong mean
	test first = second = third = fourth = fifth = 1/5
	mat A[`r',`c'] = round(r(p), .001)
	local ++r
	* Weak median
	test first = second = fourth = fifth = 0
	mat A[`r',`c'] = round(r(p), .001)
	local ++r
	* Strong median
	test (first = second = fourth = fifth = 0) (third = 1)
	mat A[`r',`c'] = round(r(p), .001)
	local ++r
	* Extreme irrelevance
	test first = fifth = 0
	mat A[`r',`c'] = round(r(p), .001)
	local ++r
	* Convex combination
	test first + second + third + fourth + fifth = 1
	mat A[`r',`c'] = round(r(p), .001)
	local ++c
}

svmat A

mat rownames A = `rows'
mat colnames A = `cols'

* Output table
putexcel set "${output}/table3.xlsx", modify sheet("Table 3")
putexcel A1 = matrix(A), names

drop A*
clear

********************************************************************
**************************  Table 4  *******************************
********************************************************************
* Initialize matrix
matrix A = J(12, 6, .)
local cols "(1) (2) (3) (4) (5) (6)"
local rows "constant _ p1 _ p2 _ p4 _ p5 _ N R^2"

local c = 1
local r = 1 
use "${data}/ind_offer.dta"
reg offer_diff p1 p2 p4 p5, cluster(session)
foreach var in _cons p1 p2 p4 p5 {
	mat A[`r',`c'] = round(_b[`var'], .001)
	local ++r
	mat A[`r',`c'] = round(_se[`var'], .001)
	local ++r
}
mat A[`r',`c'] = round(e(N), .001)
local ++r
mat A[`r',`c'] = round(e(r2_a), .001)

local ++c 
local r = 1
areg offer_diff, absorb(subject) cluster(session)
mat A[`r',`c'] = round(_b[_cons], .001)
local ++r
mat A[`r',`c'] = round(_se[_cons], .001)
local ++r

foreach var in p1 p2 p4 p5 {
	local ++r
	local ++r
}

mat A[`r',`c'] = round(e(N), .001)
local ++r
mat A[`r',`c'] = round(e(r2_a), .001)

local ++c
local r = 1
areg offer_diff p1 p2 p4 p5, absorb(subject) cluster(session)
foreach var in _cons p1 p2 p4 p5 {
	mat A[`r',`c'] = round(_b[`var'], .001)
	local ++r
	mat A[`r',`c'] = round(_se[`var'], .001)
	local ++r
}
mat A[`r',`c'] = round(e(N), .001)
local ++r
mat A[`r',`c'] = round(e(r2_a), .001)

local ++c
local r = 1 
use "${data}/ind_lottery.dta"
reg lott_diff p1 p2 p4 p5, cluster(subject)
foreach var in _cons p1 p2 p4 p5 {
	mat A[`r',`c'] = round(_b[`var'], .001)
	local ++r
	mat A[`r',`c'] = round(_se[`var'], .001)
	local ++r
}
mat A[`r',`c'] = round(e(N), .001)
local ++r
mat A[`r',`c'] = round(e(r2_a), .001)

local ++c 
local r = 1
areg lott_diff, absorb(subject) cluster(session)
mat A[`r',`c'] = round(_b[_cons], .001)
local ++r
mat A[`r',`c'] = round(_se[_cons], .001)
local ++r

foreach var in p1 p2 p4 p5 {
	local ++r
	local ++r
}

mat A[`r',`c'] = round(e(N), .001)
local ++r
mat A[`r',`c'] = round(e(r2_a), .001)

local ++c
local r = 1
areg lott_diff p1 p2 p4 p5, absorb(subject) cluster(session)
foreach var in _cons p1 p2 p4 p5 {
	mat A[`r',`c'] = round(_b[`var'], .001)
	local ++r
	mat A[`r',`c'] = round(_se[`var'], .001)
	local ++r
}
mat A[`r',`c'] = round(e(N), .001)
local ++r
mat A[`r',`c'] = round(e(r2_a), .001)

svmat A

mat rownames A = `rows'
mat colnames A = `cols'

* Output table
putexcel set "${output}/table4.xlsx", modify sheet("Table 4")
putexcel A1 = matrix(A), names

drop A*
clear

********************************************************************
**************************  Table 5  *******************************
********************************************************************
* Initialize matrix
matrix A = J(8, 3, .)
local cols "1st_decision 2nd_decision lottery"
local rows "constant _ t-1_own_decision _ t-1_diff_to_group _ N R^2"

local c = 1
local r = 1 
insheet using "${raw_data}/gift_exchange.txt"
reg ind_g_norm pr_ind_g_norm pr_diff_group_ind if dec_in_phase==1, cluster(session)
foreach var in _cons pr_ind_g_norm pr_diff_group_ind {
	mat A[`r',`c'] = round(_b[`var'], .001)
	local ++r
	mat A[`r',`c'] = round(_se[`var'], .001)
	local ++r
}
mat A[`r',`c'] = round(e(N), .001)
local ++r
mat A[`r',`c'] = round(e(r2), .001)

local r = 1
local ++c
reg ind_g_norm pr_ind_g_norm pr_diff_group_ind if dec_in_phase==2, cluster(session)
foreach var in _cons pr_ind_g_norm pr_diff_group_ind {
	mat A[`r',`c'] = round(_b[`var'], .001)
	local ++r
	mat A[`r',`c'] = round(_se[`var'], .001)
	local ++r
}
mat A[`r',`c'] = round(e(N), .001)
local ++r
mat A[`r',`c'] = round(e(r2), .001)

local r = 1
local ++c
clear
use "${data}/ind_lottery.dta"
reg lott previous_lott previous_diff, cluster(session)
foreach var in _cons previous_lott previous_diff {
	mat A[`r',`c'] = round(_b[`var'], .001)
	local ++r
	mat A[`r',`c'] = round(_se[`var'], .001)
	local ++r
}
mat A[`r',`c'] = round(e(N), .001)
local ++r
mat A[`r',`c'] = round(e(r2), .001)

svmat A

mat rownames A = `rows'
mat colnames A = `cols'

* Output table
putexcel set "${output}/table5.xlsx", modify sheet("Table 5")
putexcel A1 = matrix(A), names

drop A*
clear

********************************************************************
**************************  Table 6  *******************************
********************************************************************
* Initialize matrix
matrix A = J(16, 2, .)
local cols "2nd_decision lottery"
local rows "constant _ own_decision_t-1 _ was(1)xdiff_to_group_t-1 _ "
local rows "`rows' was(2)xdiff_to_group_t-1 _ was(3)xdiff_to_group_t-1 _ "
local rows "`rows' was(4)xdiff_to_group_t-1 _ was(5)xdiff_to_group_t-1 _ N R^2"


local c = 1
local r = 1 
insheet using "${raw_data}/gift_exchange.txt"
reg ind_g_norm pr_ind_g_norm pr_i_was_1st_x_pr_diff_group_ind pr_i_was_2nd_x_pr_diff_group_ind pr_i_was_3rd_x_pr_diff_group_ind pr_i_was_4th_x_pr_diff_group_ind pr_i_was_5th_x_pr_diff_group_ind if dec_in_phase==2, cluster(session)
foreach var in _cons pr_ind_g_norm pr_i_was_1st_x_pr_diff_group_ind pr_i_was_2nd_x_pr_diff_group_ind pr_i_was_3rd_x_pr_diff_group_ind pr_i_was_4th_x_pr_diff_group_ind pr_i_was_5th_x_pr_diff_group_ind {
	mat A[`r',`c'] = round(_b[`var'], .001)
	local ++r
	mat A[`r',`c'] = round(_se[`var'], .001)
	local ++r
}
mat A[`r',`c'] = round(e(N), .001)
local ++r
mat A[`r',`c'] = round(e(r2), .001)

local ++c 
local r = 1
clear 
use "${data}/ind_lottery.dta"
reg lott previous_lott previous_int*, cluster(session)
foreach var in _cons previous_lott previous_int_d1_diff previous_int_d2_diff previous_int_d3_diff previous_int_d4_diff previous_int_d5_diff {
	mat A[`r',`c'] = round(_b[`var'], .001)
	local ++r
	mat A[`r',`c'] = round(_se[`var'], .001)
	local ++r
}
mat A[`r',`c'] = round(e(N), .001)
local ++r
mat A[`r',`c'] = round(e(r2), .001)


svmat A

mat rownames A = `rows'
mat colnames A = `cols'

* Output table
putexcel set "${output}/table6.xlsx", modify sheet("Table 6")
putexcel A1 = matrix(A), names

drop A*
clear


********************************************************************
***********************  Appendix Table 7  *************************
********************************************************************
* Initialize matrix
matrix A = J(14, 4, .)
local cols "group_offer group_offer(FE) group_lottery group_lottery(FE)"
local rows "constant _ individual_offer_1 _ individual_offer_2 _ "
local rows "`rows' individual_offer_3 _ individual_offer_4 _ individual_offer_5 _ "
local rows "`rows' N R-squared"

* Run regressions
local c = 1
local r = 1
use "${data}/group_offer.dta"
tobit group_offer first second third fourth fifth, ll(-10) ul(10) vce(cluster session)
foreach var in _cons first second third fourth fifth {
	mat A[`r',`c'] = round(_b[`var'], .001)
	local ++r
	mat A[`r',`c'] = round(_se[`var'], .001)
	local ++r
}
mat A[`r',`c'] = round(e(N), .001)
local ++r
mat A[`r',`c'] = round(e(r2_p), .001)

local ++c
local r = 1
tobit group_offer first second third fourth fifth i.session_phase,ll(-10) ul(10) vce(cluster session)
foreach var in _cons first second third fourth fifth {
	mat A[`r',`c'] = round(_b[`var'], .001)
	local ++r
	mat A[`r',`c'] = round(_se[`var'], .001)
	local ++r
}
mat A[`r',`c'] = round(e(N), .001)
local ++r
mat A[`r',`c'] = round(e(r2_p), .001)

local ++c
local r = 1
use "${data}/group_lottery.dta"
tobit group_lott first second third fourth fifth, ll(0) ul(10) vce(cluster session)
foreach var in _cons first second third fourth fifth {
	mat A[`r',`c'] = round(_b[`var'], .001)
	local ++r
	mat A[`r',`c'] = round(_se[`var'], .001)
	local ++r
}
mat A[`r',`c'] = round(e(N), .001)
local ++r
mat A[`r',`c'] = round(e(r2_p), .001)

local ++c
local r = 1
tobit group_lott first second third fourth fifth i.session_phase, ll(0) ul(10) vce(cluster session)
foreach var in _cons first second third fourth fifth {
	mat A[`r',`c'] = round(_b[`var'], .001)
	local ++r
	mat A[`r',`c'] = round(_se[`var'], .001)
	local ++r
}
mat A[`r',`c'] = round(e(N), .001)
local ++r
mat A[`r',`c'] = round(e(r2_p), .001)

svmat A

mat rownames A = `rows'
mat colnames A = `cols'

* Output table
putexcel set "${output}/table7.xlsx", modify sheet("Table 7")
putexcel A1 = matrix(A), names

drop A*
clear

********************************************************************
***********************  Appendix Table 8  *************************
********************************************************************
* Initialize matrix
matrix A = J(7, 4, .)
local cols "(1) (2) (3) (4)"
local rows "hypothesis weak_mean strong_mean weak_median strong_median"
local rows "`rows' extreme_irrelevance convex_combination"

* Run hypothesis tests
use "${data}/group_offer.dta"
local fe 
local c = 1
foreach model in 1 2 {
	if `model' == 2 {
		local fe "i.session_phase"
	}
	local r = 2
	tobit group_offer first second third fourth fifth `fe', ll(-10) ul(10) vce(cluster session)
	* Weak mean
	test first = second = third = fourth = fifth
	mat A[`r',`c'] = round(r(p), .001)
	local ++r
	* Strong mean
	test first = second = third = fourth = fifth = 1/5
	mat A[`r',`c'] = round(r(p), .001)
	local ++r
	* Weak median
	test first = second = fourth = fifth = 0
	mat A[`r',`c'] = round(r(p), .001)
	local ++r
	* Strong median
	test (first = second = fourth = fifth = 0) (third = 1)
	mat A[`r',`c'] = round(r(p), .001)
	local ++r
	* Extreme irrelevance
	test first = fifth = 0
	mat A[`r',`c'] = round(r(p), .001)
	local ++r
	* Convex combination
	test first + second + third + fourth + fifth = 1
	mat A[`r',`c'] = round(r(p), .001)
	local ++c
}

use "${data}/group_lottery.dta"
local fe 
foreach model in 1 2 {
	if `model' == 2 {
		local fe "i.session_phase"
	}
	local r = 2
	tobit group_lott first second third fourth fifth `fe', ll(0) ul(10) vce(cluster session)
	test first = second = third = fourth = fifth
	mat A[`r',`c'] = round(r(p), .001)
	local ++r
	* Strong mean
	test first = second = third = fourth = fifth = 1/5
	mat A[`r',`c'] = round(r(p), .001)
	local ++r
	* Weak median
	test first = second = fourth = fifth = 0
	mat A[`r',`c'] = round(r(p), .001)
	local ++r
	* Strong median
	test (first = second = fourth = fifth = 0) (third = 1)
	mat A[`r',`c'] = round(r(p), .001)
	local ++r
	* Extreme irrelevance
	test first = fifth = 0
	mat A[`r',`c'] = round(r(p), .001)
	local ++r
	* Convex combination
	test first + second + third + fourth + fifth = 1
	mat A[`r',`c'] = round(r(p), .001)
	local ++c
}

svmat A

mat rownames A = `rows'
mat colnames A = `cols'

* Output table
putexcel set "${output}/table8.xlsx", modify sheet("Table 8")
putexcel A1 = matrix(A), names

drop A*
clear

********************************************************************
***********************  Appendix Table 9  *************************
********************************************************************
* Initialize matrix
matrix A = J(16, 4, .)
local cols "OLS OLS(FE) Tobit Tobit(FE)"
local rows "constant _ individual_offer_1 _ individual_offer_2 _ "
local rows "`rows' individual_offer_3 _ individual_offer_4 _ individual_offer_5 _ "
local rows "`rows' first_mover_gift _ N R-squared"

* Run regressions
local c = 1
local r = 1
use "${data}/group_offer.dta"
reg group_offer_abs first_abs second_abs third_abs fourth_abs fifth_abs first_offer, cluster(session)
foreach var in _cons first_abs second_abs third_abs fourth_abs fifth_abs first_offer {
	mat A[`r',`c'] = round(_b[`var'], .001)
	local ++r
	mat A[`r',`c'] = round(_se[`var'], .001)
	local ++r
}
mat A[`r',`c'] = round(e(N), .001)
local ++r
mat A[`r',`c'] = round(e(r2), .001)

local ++c
local r = 1
reg group_offer_abs first_abs second_abs third_abs fourth_abs fifth_abs first_offer session_phase_*, cluster(session)
foreach var in _cons first_abs second_abs third_abs fourth_abs fifth_abs first_offer {
	mat A[`r',`c'] = round(_b[`var'], .001)
	local ++r
	mat A[`r',`c'] = round(_se[`var'], .001)
	local ++r
}
mat A[`r',`c'] = round(e(N), .001)
local ++r
mat A[`r',`c'] = round(e(r2), .001)

local ++c
local r = 1
drop session_phase_18
tobit group_offer_abs first_abs second_abs third_abs fourth_abs fifth_abs first_offer, ll(0) ul(10) vce(cluster session)
foreach var in _cons first_abs second_abs third_abs fourth_abs fifth_abs first_offer {
	mat A[`r',`c'] = round(_b[`var'], .001)
	local ++r
	mat A[`r',`c'] = round(_se[`var'], .001)
	local ++r
}
mat A[`r',`c'] = round(e(N), .001)
local ++r
mat A[`r',`c'] = round(e(r2_p), .001)

local ++c
local r = 1
tobit group_offer_abs first_abs second_abs third_abs fourth_abs fifth_abs first_offer session_phase_*, ll(0) ul(10) vce(cluster session)
foreach var in _cons first_abs second_abs third_abs fourth_abs fifth_abs first_offer {
	mat A[`r',`c'] = round(_b[`var'], .001)
	local ++r
	mat A[`r',`c'] = round(_se[`var'], .001)
	local ++r
}
mat A[`r',`c'] = round(e(N), .001)
local ++r
mat A[`r',`c'] = round(e(r2_p), .001)

svmat A

mat rownames A = `rows'
mat colnames A = `cols'

* Output table
putexcel set "${output}/table9.xlsx", modify sheet("Table 9")
putexcel A1 = matrix(A), names

drop A*
clear

********************************************************************
***********************  Appendix Table 10  ************************
********************************************************************
* Initialize matrix
matrix A = J(8, 3, .)
local cols "1st_decision 2nd_decision lottery"
local rows "constant _ t-1_own_decision _ t-1_diff_to_group _ N R^2"

local c = 1
local r = 1 
insheet using "${raw_data}/gift_exchange.txt"
tobit ind_g_norm pr_ind_g_norm pr_diff_group_ind if dec_in_phase==1, ll(-10) ul(10) vce(cluster session)
foreach var in _cons pr_ind_g_norm pr_diff_group_ind {
	mat A[`r',`c'] = round(_b[`var'], .001)
	local ++r
	mat A[`r',`c'] = round(_se[`var'], .001)
	local ++r
}
mat A[`r',`c'] = round(e(N), .001)
local ++r
mat A[`r',`c'] = round(e(r2_p), .001)

local r = 1
local ++c
tobit ind_g_norm pr_ind_g_norm pr_diff_group_ind if dec_in_phase==2, ll(-10) ul(10) vce(cluster session)
foreach var in _cons pr_ind_g_norm pr_diff_group_ind {
	mat A[`r',`c'] = round(_b[`var'], .001)
	local ++r
	mat A[`r',`c'] = round(_se[`var'], .001)
	local ++r
}
mat A[`r',`c'] = round(e(N), .001)
local ++r
mat A[`r',`c'] = round(e(r2_p), .001)

local r = 1
local ++c
clear
use "${data}/ind_lottery.dta"
tobit lott previous_lott previous_diff, ll(0) ul(10) vce(cluster session)
foreach var in _cons previous_lott previous_diff {
	mat A[`r',`c'] = round(_b[`var'], .001)
	local ++r
	mat A[`r',`c'] = round(_se[`var'], .001)
	local ++r
}
mat A[`r',`c'] = round(e(N), .001)
local ++r
mat A[`r',`c'] = round(e(r2_p), .001)

svmat A

mat rownames A = `rows'
mat colnames A = `cols'

* Output table
putexcel set "${output}/table10.xlsx", modify sheet("Table 10")
putexcel A1 = matrix(A), names

drop A*
clear
