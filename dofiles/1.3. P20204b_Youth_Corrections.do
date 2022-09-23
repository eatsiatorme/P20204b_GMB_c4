*quietly {


/*
// This do-file: 
// Copies the cleaning data sets to the 'corrections' folder

// By Table, Cleans data 
	// Makes Corrections in the data
		// When changing 'real' data you should
		// Make a comment including:
			// Who is making the change
			// Why is the change being made
			// Date of change

*/


******************************
** 1. COPY CLEANING FILES TO CORRECTIONS
******************************
cd "$corrections"
local files: dir `"$cleaning\/`file'"' file "*.dta", respectcase
foreach file of local files{
	di `"`file'"'
	copy `"$cleaning\/`file'"' `"$corrections\/`file'"', replace
}


********************************************************************************
* 2. MAIN TABLE
********************************************************************************
use "$corrections\/$form_title", clear

di "HELLO"

replace c2 = 1500 if ApplicantID == 300015
****MALANG CAMARA


/* 
replace b1a = "1" if full_name == "MALANG CAMARA"
replace b1a_1 = 1 if full_name == "MALANG CAMARA"
replace b1a_2 =0 if full_name == "MALANG CAMARA"
replace b1a_3=0 if full_name == "MALANG CAMARA"
replace b1a_4=0 if full_name == "MALANG CAMARA"
replace b1a_5=0 if full_name == "MALANG CAMARA"
replace b1a_6=6 if full_name == "MALANG CAMARA"
replace b1a_7=0 if full_name == "MALANG CAMARA"
replace emp_ilo=1 if full_name == "MALANG CAMARA"
replace b1b=1 if full_name == "MALANG CAMARA"
*replace b1c
*replace b1c_other
replace b1=1 if full_name == "MALANG CAMARA"
replace b2=2 if full_name == "MALANG CAMARA"
replace b2_ifmiss="2" if full_name == "MALANG CAMARA"
replace roster1_count="1" if full_name == "MALANG CAMARA"
replace earningsid_1 ="1" if full_name == "MALANG CAMARA"
replace job_name_1="Taylor" if full_name == "MALANG CAMARA"
replace b3_1=1 if full_name == "MALANG CAMARA"	
*replace b4_1= 03jan2022 if full_name == "MALANG CAMARA"
*b4_time_1
*replace b4_2 = 10jan2020 if full_name == "MALANG CAMARA"		
replace iswas_1= "is" if full_name == "MALANG CAMARA"
replace havewere_1	="have" if full_name == "MALANG CAMARA"
replace dodid_1= "do" if full_name == "MALANG CAMARA"	
replace b6_1= 1	if full_name == "MALANG CAMARA"
*b6oth_1	
replace job_category_1=1  if full_name == "MALANG CAMARA"	
*isic_1_1	
*isic_2_1	
replace b9_1=0 if full_name == "MALANG CAMARA"	
replace b11_1=2	if full_name == "MALANG CAMARA"
*b11_other_1	
replace b12_1= "2" if full_name == "MALANG CAMARA"	
replace b12_1_1	="0" if full_name == "MALANG CAMARA"
replace b12_2_1	="1" if full_name == "MALANG CAMARA"
replace b12_3_1	="0" if full_name == "MALANG CAMARA"
replace b12__95_1= "0" if full_name == "MALANG CAMARA"
replace b12__96_1= "0" if full_name == "MALANG CAMARA"
replace b12__97_1="0" if full_name == "MALANG CAMARA"
replace b12__99_1 ="0" if full_name == "MALANG CAMARA"	
replace b13_1= 1 if full_name == "MALANG CAMARA"
replace b14_1=2	if full_name == "MALANG CAMARA"
replace b15_1 =5 if full_name == "MALANG CAMARA"	
*b15_check_1	
replace b16_1=5	if full_name == "MALANG CAMARA"
replace total_wrk_hours_1="25" if full_name == "MALANG CAMARA"	
*b16_check_1	
replace b17_1=200 if full_name == "MALANG CAMARA"	
replace b17_unit_1=	1 if full_name == "MALANG CAMARA"
*b17_unit_s_1	
*b17_unit_check_1	
replace b17_unit_val_1 = "Monthly" if full_name == "MALANG CAMARA"	
*b17_check_1	
*replace b17low_check_1	
replace b17_month_1 = 200 if full_name == "MALANG CAMARA"
*b17_weekly_1	
*b17_daily_1	
*b17_contract_1	
replace emp_inc_month_1 ="200" if full_name == "MALANG CAMARA"
replace b18_a_1	= 1 if full_name == "MALANG CAMARA"
replace b18_1= 50 if full_name == "MALANG CAMARA"
replace b18_unit_1 = 1 if full_name == "MALANG CAMARA"	
*b18_unit_s_1	
*b18_unit_check_1	
replace b18_unit_val_1 "Monthly" if full_name == "MALANG CAMARA"	
*b18_check_1	
replace b18_month_1	= "50" if full_name == "MALANG CAMARA"
*b18_weekly_1	
*b18_daily_1	
*b18_contract_1	
*b18_contract_2_1	
replace emp_inkind_month_1 = "50" if full_name == "MALANG CAMARA"	
replace emp_month_est_1	= "250" if full_name == "MALANG CAMARA"
*employee_pay_check_1 =1	
/*
b20_1	
b20_1_1	
b20_2_1	
b20_3_1	
b20_4_1	
b20_5_1	
b20__96_1	
b20__97_1	
b20__99_1	
b21_1	
b22_1	
b23_1	
total_wrk_hours_se_1	
b22_check_1	
b24_1	
b24_unit_1	
b24_unit_s_1	
b24_unit_check_1	
b24_unit_val_1	
b24_month_1	
b24_weekly_1	
b24_daily_1	
b24_contract_1	
sales_month_1	
b24_check_1	
b24low_check_1	
b26_1	
b26_unit_1	
b26_unit_s_1	
b26_unit_check_1	
b26_unit_val_1	
b26first_check_1	
b26_month_1	
b26_weekly_1	
b26_daily_1	
b26_contract_1	
profit_month_1	
profit_month_check_1	
b27_1	
b29_b_1	
b30_1	
b30_1_1	
b30_2_1	
b30_3_1	
b30_4_1	
b30_5_1
b30_6_1	
b30_7_1	
b30_8_1	
b30_9_1	
b30_10_1	
b30_11_1	
b30_12_1	
b30__96_1	
b30_other_1	
EarningsID_2
*/
replace earningsid_2 ="2" if full_name == "MALANG CAMARA"
replace job_name_2	= "Trader" if full_name == "MALANG CAMARA"
replace b3_2=1	if full_name == "MALANG CAMARA"
replace b4_2 =10jan2020	 if full_name == "MALANG CAMARA"
*b4_time_2	
*b5_2	
*b5_time_2	
replace iswas_2	= "is" if full_name == "MALANG CAMARA"
replace havewere_2= "have" if full_name == "MALANG CAMARA"
replace dodid_2	= "do" if full_name == "MALANG CAMARA"
replace b6_2 = 	"3" if full_name == "MALANG CAMARA"
*b6oth_2	
replace job_category_2 = 11	if full_name == "MALANG CAMARA"
*isic_1_2	
*isic_2_2	
replace b9_2 = 1 if full_name == "MALANG CAMARA"
replace b20_2="2" if full_name == "MALANG CAMARA"
replace b20_1_2	="0" if full_name == "MALANG CAMARA"
replace b20_2_2	= "1" if full_name == "MALANG CAMARA"
replace b20_3_2	="0" if full_name == "MALANG CAMARA"
replace b20_4_2	="0" if full_name == "MALANG CAMARA"
replace b20_5_2	="0" if full_name == "MALANG CAMARA"
replace b20__96_2="0" if full_name == "MALANG CAMARA"
replace b20__97_2= "0" if full_name == "MALANG CAMARA"
replace b20__99_2= "0" if full_name == "MALANG CAMARA"	
replace b21_2= 0 if full_name == "MALANG CAMARA"
replace b22_2= 3 if full_name == "MALANG CAMARA"
b23_2= 6 if full_name == "MALANG CAMARA"
replace total_wrk_hours_se_2 = "18" if full_name == "MALANG CAMARA"	
*b22_check_2	
replace b24_2= 200 if full_name == "MALANG CAMARA"	
replace b24_unit_2 = 2 if full_name == "MALANG CAMARA"	
*b24_unit_s_2	
*b24_unit_check_2	
replace b24_unit_val_2 = "Weekly" if full_name == "MALANG CAMARA"	
*b24_month_2	
replace b24_weekly_2= "869" if full_name == "MALANG CAMARA"
*b24_daily_2	
*b24_contract_2	
replace sales_month_2 = "869" if full_name == "MALANG CAMARA"
*b24_check_2	
*b24low_check_2	
replace b26_2 = 150 if full_name == "MALANG CAMARA"	
replace b26_unit_2	=2 if full_name == "MALANG CAMARA"
*b26_unit_s_2	
*b26_unit_check_2	
replace b26_unit_val_2= "Weekly" if full_name == "MALANG CAMARA"
replace b26first_check_2	
*b26_month_2	
replace b26_weekly_2 "651.75" if full_name == "MALANG CAMARA"	
*b26_daily_2	
*b26_contract_2	
replace profit_month_2= "652" if full_name == "MALANG CAMARA"
replace profit_month_check_2 = "1" if full_name == "MALANG CAMARA"
replace b27_2= 600 if full_name == "MALANG CAMARA"
replace b29_b_2= 0 if full_name == "MALANG CAMARA"
replace sum_b3= "2" if full_name == "MALANG CAMARA"
replace sum_current_bus ="1" if full_name == "MALANG CAMARA"	
replace total_month_inc	= "902" if full_name == "MALANG CAMARA"
replace ave_month_inc = "902" if full_name == "MALANG CAMARA"	
replace job1 = "Taylor" if full_name == "MALANG CAMARA"
replace job2 = "Trader"	if full_name == "MALANG CAMARA"
*job3	
replace b31a=0 if full_name == "MALANG CAMARA"
*/

/*
replace
replace id = 300036 if id == 400001	
400002	300075
400003	300111
400004	300114
400005	300122
400006	300135
400007	300155
400008	300183
400009	300188
400010	300255
400011	300266
400012	300320
400013	300389
400014	300405
400015	300409
400016	300412
400017	300523
400018	300527
400019	300546
400020	300558
400021	390121
400021	366666
*/
*quietly {

/*
// This do-file: 
// Copies the corrected data sets to the 'cleaning' folder
// By Table, Cleans data 
	// Merging in Media (Comments/Time Audits)
	// Transforming variable format
	// Reshaping previous attempts so only 1 row per case
	// Labelling multiple response questions
	// Variable labelling
	// Value labelling
	// Adding variables from calculations of others
	// Renaming variables
	// Dealing with Special Responses
	// Categorising other specify
	// Rename table with more useful one
	
// This do-file includes all cleaning of the data to be ready for analysis. It should not be used for 'correcting' data from the field - this should be done in Corrections_Data

*/

///// NATHAN - REMOVE PROBLEMATIC COMMENT FILES 
cd "$exported\media"

// NEED TO FIX CTOMERGE TO ALLOW COMMENTS ON THE SAME QUESTION ON MULTIPLE ROSTERS
local deletepathexp = "$exported\media"
local files : dir "`deletepathexp'" file "Comments-84f1006c-08af-4803-9152-796cc522d692.csv", respectcase	
foreach file in `files'{	
	local fileandpathtodelete = "`deletepathexp'"+"\"+"`file'"
	di "`fileandpathtodelete'"
	capture erase "`fileandpathtodelete'"
}

// IN FUTURE FOR HFC MERGE NEED TO
	// MAKE A BREAK IF ERROR DUPLICATES THAT PROVIDES INFO
	// INCLUDE DIFFERENTIATOR OF COMMENT VALUE FOR COMMENTS ON THE SAME VARIABLE - OR CONCAT IN THE CLEANING?
local files : dir "`deletepathexp'" file "Comments-d8dd4fb1-1d26-47ce-a218-d425af8b1e00.csv", respectcase	
foreach file in `files'{	
	local fileandpathtodelete = "`deletepathexp'"+"\"+"`file'"
	di "`fileandpathtodelete'"
	capture erase "`fileandpathtodelete'"
}



******************************
** 1. COPY EXPORTED FILES TO CLEANING
******************************

cd "$cleaning"

local files: dir `"$exported\/`file'"' file "*.dta", respectcase
foreach file of local files{
	di `"`file'"'
	copy `"$exported\/`file'"' `"$cleaning\/`file'"', replace
}


/*

import delimited "H:\sample\respondents_tkpv3_final_2.csv", clear
save "respondents.dta", replace
use "respondents.dta"
keep id_key old_id
clonevar id = id_key
drop if old_id == 366666
tempfile x
save `x'

use "Tekki_Fii_PV_3_Final_2.dta"
keep if call_status==1
destring id, replace
*clonevar id_num = id
merge 1:1 id using `x'
drop id 
rename old_id id
drop _merge

save "Tekki_Fii_PV_3_Final_2.dta", replace


cd "$cleaning"
use "Tekki_Fii_PV_3_Final_2.dta", clear
keep if call_status==1
tempfile x
save `x'

use "$cleaning\/$form_title"
destring id, replace
merge 1:1 full_name using "`x'", update replace
*/


save "$corrections\/$form_title", replace

********************************************************************************
* EXIT CODE
********************************************************************************

n: di "${proj}_Corrections ran successfully"
*}
