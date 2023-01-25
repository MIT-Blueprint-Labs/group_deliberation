
***********************************************************;
* READ RAW DATA;
***********************************************************;

filename inf pipe "tr -d '\r' < data/data_101131_trust_choices.csv";

data trust;
        infile inf dlm="," dsd missover firstobs=2;
        input session sestype $:12. sess_code $ group_nb part dec_in_part ind_partner first_offer
                group_mem1-group_mem5 ses_sub1 $ ses_sub2 $ ses_sub3 $ ses_sub4 $ ses_sub5 $ male1-male5 age1-age5 econ1-econ5
		ind_offer1-ind_offer5 gind_offer1-gind_offer5 group_offer num1-num5 male_num1-male_num5
		female_num1-female_num5 econ_num1-econ_num5 age_num1-age_num5;

	drop ind_offer1-ind_offer5;
	*drop ses_sub1-ses_sub5;
	drop num1-num5 male_num1-male_num5 female_num1-female_num5 econ_num1-econ_num5 age_num1-age_num5;


	median=median(gind_offer1,gind_offer2,gind_offer3,gind_offer4,gind_offer5);
	mean = (gind_offer1+gind_offer2+gind_offer3+gind_offer4+gind_offer5) / 5;
	if session = 2 then sestype = "IMPERSONAL"; else sestype = "DELIBERATE";
	if session = 1 then delete;

	if sestype = "IMPERSONAL" then sestype_num=0; else sestype_num=1;	
	if sestype = "DELIBERATE" then delib=1;
	if sestype = "IMPERSONAL" then delib=0;

	if part=1 then part1=1; else part1=0;
	if part=2 then part2=1; else part2=0;
	if part=3 then part3=1; else part3=0;

	if session=3 then session3=1; else session3=0;
	if session=4 then session4=1; else session4=0;
	if session=5 then session5=1; else session5=0;
	if session=6 then session6=1; else session6=0;
	if session=7 then session7=1; else session7=0;
	if session=8 then session8=1; else session8=0;
	if session=9 then session9=1; else session9=0;


	first=ordinal(1,gind_offer1,gind_offer2,gind_offer3,gind_offer4,gind_offer5);
	second=ordinal(2,gind_offer1,gind_offer2,gind_offer3,gind_offer4,gind_offer5);
	third=ordinal(3,gind_offer1,gind_offer2,gind_offer3,gind_offer4,gind_offer5);
	fourth=ordinal(4,gind_offer1,gind_offer2,gind_offer3,gind_offer4,gind_offer5);
	fifth=ordinal(5,gind_offer1,gind_offer2,gind_offer3,gind_offer4,gind_offer5);

	count=0;
	if median = gind_offer1 then count=count+1;
	if median = gind_offer2 then count=count+1;
	if median = gind_offer3 then count=count+1;
	if median = gind_offer4 then count=count+1;
	if median = gind_offer5 then count=count+1;	
	if median = 0 then zero = 1; else zero = 0;	
	if median < mean then lower = 1; else lower=0;
	if median = mean then equal = 1; else equal = 0;
	if median > mean then higher = 1; else higher = 0;

	if delib=1;
	variance = (gind_offer1-mean)*(gind_offer1-mean) + (gind_offer2-mean)*(gind_offer2-mean) + (gind_offer3-mean)*(gind_offer3-mean) + (gind_offer4-mean)*(gind_offer4-mean) + (gind_offer5-mean)*(gind_offer5-mean);



/**
data trust;
	set trust;
	group_male=0; group_female=0;
	group_econ=0;
	if g1_gender = "M" then group_male=group_male+1;
	if g2_gender = "M" then group_male=group_male+1;
	if g3_gender = "M" then group_male=group_male+1;
	if g4_gender = "M" then group_male=group_male+1;
	if g5_gender = "M" then group_male=group_male+1;
	group_female = 5- group_male;
	if g1_economics = "Y" then group_econ=group_econ+1;
	if g2_economics = "Y" then group_econ=group_econ+1;
	if g3_economics = "Y" then group_econ=group_econ+1;
	if g4_economics = "Y" then group_econ=group_econ+1;	
	if g5_economics = "Y" then group_econ=group_econ+1;

	* since there are some missing group ages, this variable will sometimes be missing;
	group_age = (g1_age + g2_age + g3_age + g4_age + g5_age)/ 5;

	* rename variables to be referenced using SAS arrays;
	g_gender1 = g1_gender;
	g_gender2 = g2_gender;
	g_gender3 = g3_gender;
	g_gender4 = g4_gender;
	g_gender5 = g5_gender;
	drop g1_gender g2_gender g3_gender g4_gender g5_gender;

	g_econ1 = g1_economics;
	g_econ2 = g2_economics;
	g_econ3 = g3_economics;
	g_econ4 = g4_economics;
	g_econ5 = g5_economics;
	drop g1_economics g2_economics g3_economics g4_economics g5_economics;

	g_age1 = g1_age;
	g_age2 = g2_age;
	g_age3 = g3_age;
	g_age4 = g4_age;
	g_age5 = g5_age;
	drop g1_age g2_age g3_age g4_age g5_age;

* CODE TO EXPORT TO STATA;

*proc export data=trust outfile="stata/trust.csv" dbms=csv;

*proc print data=trust (obs=200);
**/


******************************************************;
* SUMMARY STATISTICS *;
******************************************************;


/**
proc sort data=trust;
	by session;

proc univariate data=trust noprint;
	var first_offer;
	by session;
	output out = first
	       mean = first
	       std = first_std;

proc univariate data=trust noprint;
	var group_offer;
	by session;
	output out = group
	       mean = group
	       std = group_std;

proc univariate data=trust noprint;
	var median;
	by session;
	output out = median
	       mean = median
               std = median_std;

proc univariate noprint data=trust;
	var mean;
	by session;
	output out = mean
	       mean = mean
	       std = mean_std;

proc print data=first;
proc print data=group;
proc print data=mean;
proc print data=median;


proc sort data=trust;
	by part;
**/



*******************************************************;
* MAIN RESULTS *;
*******************************************************;
/**
data trust;
	set trust;
	*if first_offer = third;
	first2=first*first;
	second2=second*second;
	third2=third*third;
	fourth2=fourth*fourth;
	fifth2=fifth*fifth;
	first3=first2*first;
	second3=second2*second;
	third3=third2*third;
	fourth3=fourth2*fourth;
	fifth3=fifth2*fifth;
	

proc print data=trust;
	var session delib group_offer first_offer median first second third fourth fifth;

proc reg;
	model group_offer = first second third fourth fifth;
	by same;	
	test first=second=third=fourth=fifth;
	test first=second=third=fourth=fifth=0.2;


proc glm;
	model group_offer = first second third fourth fifth;
	*by same;
	contrast 'mean hypothesis: first=second=third=fourth=fifth'
		first 1 second -1,
		second 1 third -1,
		third 1 fourth -1,
		fourth 1 fifth -1;
	contrast 'strong form mean hypothesis'
		first 1 second -1,
		second 1 third -1,
		third 1 fourth -1,
		fourth 1 fifth -1, 
		fifth 1 0.2; 

	contrast 'median hypothesis: first=second=fourth=fifth=0' first 1, second 1, fourth 1, fifth 1;
	contrast 'group shift: intercept=0' intercept 1;
	


proc glm;
	class session part;	
	model group_offer = first second third fourth fifth session*part / solution; 
	*by same;
	contrast 'mean hypothesis: first=second=third=fourth=fifth' 
		first 1 second -1, 
		second 1 third -1,
		third 1 fourth -1,
		fourth 1 fifth -1;
	contrast 'median hypothesis: first=second=fourth=fifth=0' first 1, second 1, fourth 1, fifth 1;

proc glm;
	model group_offer = mean / solution;
	by delib;
	contrast 'group shift relative to mean: intercept=0' intercept 1;

proc glm;
	class session part;
	model group_offer = mean session*part / solution;
	by delib;

proc glm;
	model group_offer = median / solution;
	by delib;
	contrast 'group shift relative to median: intercept=0' intercept 1;

proc glm;
	class session part;
	model group_offer = median session*part / solution;
	by delib;
**/



*********************************************************************;
* ROBUSTNESS *;
*********************************************************************;

** SESSION-BY-SESSION BREAKDOWN;

data later;
	set trust;
	*if session = 3 or session = 4 or session = 5;
	*if dec_in_part=1;

/*
proc reg data=later;
	model group_offer = first second third fourth fifth;
	test first=second=third=fourth=fifth;
	test first=second=fourth=fifth=0;
	*by session;
*/

proc reg data=later;
	model group_offer = mean;
	model group_offer = median;
	by session;



*******************************************************************;
** BY TIME PERIOD BREAK DOWN;
*******************************************************************;

/*
** ONLY FIRST DECISION IN SESSION;

data first;
        set trust;
        if part=1;
        if delib=1;

proc glm data=first;
	model group_offer = first second third fourth fifth / solution;
	contrast 'mean hypothesis: first=second=third=fourth=fifth'
		first 1 second -1,
		second 1 third -1,
		third 1 fourth -1,
		fourth 1 fifth -1;
	contrast 'median hypothesis: first=second=fourth=fifth=0' first 1, second 1, fourth 1, fifth 1;
	contrast 'group shift: intercept=0' intercept 1;

proc glm data=first;
       	class session dec_in_part; 
	model group_offer = first second third fourth fifth session*dec_in_part / solution;
	contrast 'mean hypothesis: first=second=third=fourth=fifth'
		first 1 second -1,
		second 1 third -1,
		third 1 fourth -1,
		fourth 1 fifth -1;
	contrast 'median hypothesis: first=second=fourth=fifth=0' first 1, second 1, fourth 1, fifth 1;
	contrast 'group shift: intercept=0' intercept 1;

proc glm data=first;
	model group_offer = mean / solution;

proc glm data=first;
	class session dec_in_part;
	model group_offer = mean session*dec_in_part / solution;

proc glm data=first;
	model group_offer = median / solution;

proc glm data=first;
	class session dec_in_part;
	model group_offer = median session*dec_in_part / solution;

** COMPARE TO DECISIONS IN second parts of SESSION;

data later;
	set trust;
	if part=2;
	if delib = 1;

proc glm data=later;
	model group_offer = first second third fourth fifth / solution;
	contrast 'mean hypothesis: first=second=third=fourth=fifth'
		first 1 second -1,
		second 1 third -1,
		third 1 fourth -1,
		fourth 1 fifth -1;
	contrast 'median hypothesis: first=second=fourth=fifth=0' first 1, second 1, fourth 1, fifth 1;
	contrast 'group shift: intercept=0' intercept 1;


proc glm data=later;
       	class session dec_in_part; 
	model group_offer = first second third fourth fifth session*dec_in_part / solution;
	contrast 'mean hypothesis: first=second=third=fourth=fifth'
		first 1 second -1,
		second 1 third -1,
		third 1 fourth -1,
		fourth 1 fifth -1;
	contrast 'median hypothesis: first=second=fourth=fifth=0' first 1, second 1, fourth 1, fifth 1;
	contrast 'group shift: intercept=0' intercept 1;

proc glm data=later;
	model group_offer = mean / solution;

proc glm data=later;
	class session dec_in_part;
	model group_offer = mean session*dec_in_part / solution;

proc glm data=later;
	model group_offer = median / solution;

proc glm data=later;
	class session dec_in_part;
	model group_offer = median session*dec_in_part / solution;

** COMPARE TO DECISIONS IN THIRD PARTS OF SESSION;

data later;
	set trust;
	if part=3;
	if delib = 1;

proc glm data=later;
	model group_offer = first second third fourth fifth / solution;
	contrast 'mean hypothesis: first=second=third=fourth=fifth'
		first 1 second -1,
		second 1 third -1,
		third 1 fourth -1,
		fourth 1 fifth -1;
	contrast 'median hypothesis: first=second=fourth=fifth=0' first 1, second 1, fourth 1, fifth 1;
	contrast 'group shift: intercept=0' intercept 1;


proc glm data=later;
       	class session dec_in_part; 
	model group_offer = first second third fourth fifth session*dec_in_part / solution;
	contrast 'mean hypothesis: first=second=third=fourth=fifth'
		first 1 second -1,
		second 1 third -1,
		third 1 fourth -1,
		fourth 1 fifth -1;
	contrast 'median hypothesis: first=second=fourth=fifth=0' first 1, second 1, fourth 1, fifth 1;
	contrast 'group shift: intercept=0' intercept 1;

proc glm data=later;
	model group_offer = mean / solution;

proc glm data=later;
	class session dec_in_part;
	model group_offer = mean session*dec_in_part / solution;

proc glm data=later;
	model group_offer = median / solution;

proc glm data=later;
	class session dec_in_part;
	model group_offer = median session*dec_in_part / solution;


** ALLOW FOR TIME VARYING COEFFICIENTS;
proc glm;
        class session part;
        model group_offer = first*part second*part third*part fourth*part fifth*part / solution;
        by delib;
        contrast 'test for time variation in first'
                        first*part 1 -1 0,
                        first*part 0 1 -1;
        contrast 'test for time variation in second'
                        second*part 1 -1 0,
                        second*part 0 1 -1;
        contrast 'test for time variation in third'
                        third*part 1 -1 0,
                        third*part 0 1 -1;
        contrast 'test for time variation in fourth'
                        fourth*part 1 -1 0,
                        fourth*part 0 1 -1;
        contrast 'test for time variation in fifth'
                        fifth*part 1 -1 0,
                        fifth*part 0 1 -1;

proc glm;
        class session part dec_in_part;
        model group_offer = first*part second*part third*part fourth*part fifth*part session*part*dec_in_part / solution;
        by delib;
        contrast 'test for time variation in first'
                        first*part 1 -1 0,
                        first*part 0 1 -1;
        contrast 'test for time variation in second'
                        second*part 1 -1 0,
                        second*part 0 1 -1;
        contrast 'test for time variation in third'
                        third*part 1 -1 0,
                        third*part 0 1 -1;
        contrast 'test for time variation in fourth'
                        fourth*part 1 -1 0,
                        fourth*part 0 1 -1;
        contrast 'test for time variation in fifth'
                        fifth*part 1 -1 0,
                        fifth*part 0 1 -1;

*/

***********************************************************;
* DEMOGRAPHICS;
***********************************************************;

* do demographics matter at an individual level?;
data test;
	set trust;
	array ind[5] ind_offer1-ind_offer5;
	array gen[5] g_gender1-g_gender5;
	array eco[5] g_econ1-g_econ5;
	array ag[5] g_age1-g_age5;	
	array na[5] g1-g5;
	if delib=1;	
	do i = 1 to 5;
		if gen[i] = "M" then male = 1; else male = 0;	
		indiv =ind[i];
		if eco[i] = "Y" then econ = 1; else econ = 0;
		age = ag[i];
		name = catt(session,"-",na[i]);	
		output;
	end;	

/*
data sum;
	set test;
	keep session group i part male econ age first_offer name;

proc sort data=sum nodupkey;
	by session name;

proc print data=sum;

proc means data=sum;
	var male econ age;

proc univariate data=sum;
	var age;

*proc export data=test outfile="stata/trust_indiv.csv" dbms="csv" replace; 

*proc print data=test;

proc univariate data=sum;	
	var age;

proc glm data=test;
	class session part first_offer;
	model indiv = male session*part first_offer / solution;
	
proc glm data=test;
	class session part first_offer;
	model indiv = econ session*part first_offer / solution;

proc glm data=test;
	class session part first_offer;
	model indiv = age session*part first_offer / solution;

proc glm data=test;
	class session part first_offer;
	model indiv = male econ age session*part first_offer / solution; 
*/

* do demographics matter at the group level?;

data test;
	set trust;
	if delib = 1;

proc sort data=test nodupkey;
	by session group part group_male group_econ group_age;

proc freq data=test;
	tables g_gender1;
	tables g_gender2;
	tables g_gender3;
	tables g_gender4;
	tables g_gender5; 

proc means data=test;
	var group_male group_econ group_age;

proc freq data=test;
	tables group_male;
	tables group_econ;

data trust;
	set trust;
	if delib = 1;
	if g_age1 < 28 then young1=1; else young1=0;
	if g_age2 < 28 then young2=1; else young2=0;
	if g_age3 < 28 then young3=1; else young3=0;
	if g_age4 < 28 then young4=1; else young4=0;
	if g_age5 < 28 then young5=1; else young5=0;
	if group_age < 22 then group_young = 1; else group_young=0;
	female1 = 0; female2 = 0; female3 = 0; female4 = 0; female5 = 0;
	if g_gender1 = "F" then female1 = 1;
	if g_gender2 = "F" then female2 = 1;
	if g_gender3 = "F" then female3 = 1;
	if g_gender4 = "F" then female4 = 1;
	if g_gender5 = "F" then female5 = 1;
	econ1=0; econ2=0; econ3=0; econ4=0; econ5=0;
	if g_econ1 = "Y" then econ1=1;
	if g_econ2 = "Y" then econ2=1;
	if g_econ3 = "Y" then econ3=1;
	if g_econ4 = "Y" then econ4=1;
	if g_econ5 = "Y" then econ5=1;


proc glm;
	class session part group_male;
	model group_offer = first second third fourth fifth group_male session*part / solution;
	contrast 'test for group_male effects'
		group_male 1 -1 0 0,
		group_male 0 1 -1 0,
		group_male 0 0 1 -1;

proc glm data=trust;
	class session part group_male; 
	model group_offer = first first*female1 second second*female2 third third*female3 fourth fourth*female4 fifth fifth*female5
		group_male session*part / solution;


/*
** test for age effects;
proc glm;
	class session part group_young;
	model group_offer = first second third fourth fifth group_young session*part / solution;
	contrast 'test for group age effects'
		group_young 1 -1;

proc glm data=test;
	class session part young1 young2 young3 young4 young5;
	model group_offer = first*young1 second*young2 third*young3 fourth*young4 fifth*young5 session*part / solution;
	contrast 'test for first'
		first*young1 1 -1;
	contrast 'test for second'
		second*young2 1 -1;
	contrast 'test for third'
		third*young3 1 -1;
	contrast 'test for fourth'
		fourth*young4 1 -1;
	contrast 'test for fifth'
		fifth*young5 1 -1;

** test for econ effects;
proc glm;
	class session part group_econ;
	model group_offer = first second third fourth fifth group_econ session*part / solution;
	contrast 'test for group econ effects'
		group_econ 1 -1 0 0,
		group_econ 0 1 -1 0,
		group_econ 0 0 1 -1;


proc glm data=trust;
	class session part group_econ; 
	model group_offer = first first*econ1 second second*econ2 third third*econ3 fourth fourth*econ4 fifth fifth*econ5 group_econ session*part / solution;
*/



