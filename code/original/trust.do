
/// Program to run analysis for group experiments
/// Created by: Parag Pathak
/// Last modified: March 20, 2009

global    user 			  `c(username)'
global    data 	          "A:/groups_deliberation/${user}/raw_data"


insheet using "${data}/trust.csv", clear
*log using trust.log, replace

/// Summary statistics

summ first_offer group_offer median mean

/// Main results
// No Deliberation
regress group_offer first second third fourth fifth if delib==0
test first=second=third=fourth=fifth
test first=second=third=fourth=fifth=0.2
test first=second=fourth=fifth
test (first=second=fourth=fifth) (third=1)
test _cons=0

xi: reg group_offer first second third fourth fifth i.session*i.part if delib==0 
test first=second=third=fourth=fifth
test first=second=third=fourth=fifth=0.2
test first=second=fourth=fifth
test (first=second=fourth=fifth) (third=1)

regress group_offer mean if delib==0
test _cons=0
xi: reg group_offer mean i.session*i.part if delib==0

regress group_offer median if delib==0
test _cons=0
xi: reg group_offer median i.session*i.part if delib==0

// Deliberation
regress group_offer first second third fourth fifth if delib==1
test first=second=third=fourth=fifth
test first=second=third=fourth=fifth=0.2
test first=second=fourth=fifth
test (first=second=fourth=fifth) (third=1)
test _cons=0

xi: reg group_offer first second third fourth fifth i.session*i.part if delib==1 
test first=second=third=fourth=fifth
test first=second=third=fourth=fifth=0.2
test first=second=fourth=fifth
test (first=second=fourth=fifth) (third=1)

regress group_offer mean if delib==1
test _cons=0
xi: reg group_offer mean i.session*i.part if delib==1

regress group_offer median if delib==1
test _cons=0
xi: reg group_offer median i.session*i.part if delib==1


/// ROBUSTNESS
// SESSION EFFECTS

xi: reg group_offer first second third fourth fifth if delib==1 & session==3 
test first=second=third=fourth=fifth
test first=second=third=fourth=fifth=0.2
test first=second=fourth=fifth
test (first=second=fourth=fifth) (third=1)

regress group_offer mean if delib==1 & session==3
test _cons=0

regress group_offer median if delib==1 & session==3
test _cons=0


xi: reg group_offer first second third fourth fifth if delib==1 & session==4
test first=second=third=fourth=fifth
test first=second=third=fourth=fifth=0.2
test first=second=fourth=fifth
test (first=second=fourth=fifth) (third=1)

regress group_offer mean if delib==1 & session==4
test _cons=0

regress group_offer median if delib==1 & session==4
test _cons=0


xi: reg group_offer first second third fourth fifth if delib==1 & session==5 
test first=second=third=fourth=fifth
test first=second=third=fourth=fifth=0.2
test first=second=fourth=fifth
test (first=second=fourth=fifth) (third=1)

regress group_offer mean if delib==1 & session==5
test _cons=0

regress group_offer median if delib==1 & session==5
test _cons=0



// TIME EFFECTS
// Only first decision in session
regress group_offer first second third fourth fifth if delib==1 & part==1
test first=second=third=fourth=fifth
test first=second=third=fourth=fifth=0.2
test first=second=fourth=fifth
test (first=second=fourth=fifth) (third=1)
test _cons=0

xi: reg group_offer first second third fourth fifth i.session*i.dec_in_part if delib==1 & part==1 
test first=second=third=fourth=fifth
test first=second=third=fourth=fifth=0.2
test first=second=fourth=fifth
test (first=second=fourth=fifth) (third=1)

regress group_offer mean if delib==1 & part==1
test _cons=0
xi: reg group_offer mean i.session*i.dec_in_part if delib==1 & part==1

regress group_offer median if delib==1 & part==1
test _cons=0
xi: reg group_offer median i.session*i.dec_in_part if delib==1 & part==1

// Only the second decision in the session
regress group_offer first second third fourth fifth if delib==1 & part==2
test first=second=third=fourth=fifth
test first=second=third=fourth=fifth=0.2
test first=second=fourth=fifth
test (first=second=fourth=fifth) (third=1)
test _cons=0

xi: reg group_offer first second third fourth fifth i.session*i.dec_in_part if delib==1 & part==2 
test first=second=third=fourth=fifth
test first=second=third=fourth=fifth=0.2
test first=second=fourth=fifth
test (first=second=fourth=fifth) (third=1)

regress group_offer mean if delib==1 & part==2
test _cons=0
xi: reg group_offer mean i.session*i.dec_in_part if delib==1 & part==2

regress group_offer median if delib==1 & part==2
test _cons=0
xi: reg group_offer median i.session*i.dec_in_part if delib==1 & part==2

// Only the third decision in the session
regress group_offer first second third fourth fifth if delib==1 & part==3
test first=second=third=fourth=fifth
test first=second=third=fourth=fifth=0.2
test first=second=fourth=fifth
test (first=second=fourth=fifth) (third=1)
test _cons=0

xi: reg group_offer first second third fourth fifth i.session*i.dec_in_part if delib==1 & part==3 
test first=second=third=fourth=fifth
test first=second=third=fourth=fifth=0.2
test first=second=fourth=fifth
test (first=second=fourth=fifth) (third=1)

regress group_offer mean if delib==1 & part==3
test _cons=0
xi: reg group_offer mean i.session*i.dec_in_part if delib==1 & part==3

regress group_offer median if delib==1 & part==3
test _cons=0
xi: reg group_offer median i.session*i.dec_in_part if delib==1 & part==3


/// DEMOGRAPHICS
// Do demographics matter at the group level?
generate byte young1 = first*(g_age1<24)
generate byte young2 = second*(g_age2<24)
generate byte young3 = third*(g_age3<24)
generate byte young4 = fourth*(g_age4<24)
generate byte young5 = fifth*(g_age5<24)
generate byte female1 = first*(g_gender1=="F")
generate byte female2 = second*(g_gender2=="F")
generate byte female3 = third*(g_gender3=="F")
generate byte female4 = fourth*(g_gender4=="F")
generate byte female5 = fifth*(g_gender5=="F")
generate byte econ1 = first*(g_econ1=="Y")
generate byte econ2 = second*(g_econ2=="Y")
generate byte econ3 = third*(g_econ3=="Y")
generate byte econ4 = fourth*(g_econ4=="Y")
generate byte econ5 = fifth*(g_econ5=="Y") 


xi: reg group_offer first second third fourth fifth i.group_male i.session*i.part if delib==1
testparm _Ig*
xi: reg group_offer first female1 second female2 third female3 fourth female4 fifth female5 i.group_male i.session*i.part if delib==1


xi: reg group_offer first second third fourth fifth i.group_econ i.session*i.part if delib==1
testparm _Ig*
xi: reg group_offer first econ1 second econ2 third econ3 fourth econ4 fifth econ5 i.group_econ i.session*i.part if delib==1

// Do demographics matter at the individual level?
// add robust because of correlation with individuals
insheet using "trust_indiv.csv", clear
xi: reg indiv male i.first_offer i.session*i.part if delib==1 
xi: reg indiv econ i.first_offer i.session*i.part if delib==1
xi: reg indiv age i.first_offer i.session*i.part if delib==1
xi: reg indiv male econ age i.first_offer i.session*i.part if delib==1


log close

