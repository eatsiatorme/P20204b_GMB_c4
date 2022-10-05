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

drop if key == "uuid:e9401da9-542f-465a-a451-8be46ec55406"


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
merge m:1 id using "`x'", update replace
*/


********************************************************************************
* 2. MAIN TABLE
********************************************************************************
use "$cleaning\/$form_title", clear

********************************************************************************
* ADDRESSING ID_KEY ISSUES
********************************************************************************

**************************************************
* 2.1 MERGING IN MEDIA
**************************************************

ctomergecom, fn(commentsx) mediapath("$exported\media")

tamerge text_audit, media("$exported")
foreach var of varlist ta_* {
	local varorig = subinstr("`var'", "ta_", "", 1)
	label variable `var' "Total duration on `varorig'"
	
}




**************************************************
* VARIABLE PREPARATION
**************************************************
clonevar ApplicantID = id_key
destring ApplicantID, replace
*drop id
order ApplicantID, first

** DESTRING VARIABLES
#d ;
destring
emp_inc_month_? 
emp_inkind_month_? 
sales_month_? 
profit_month_? 
duration 
total_month_inc 
ave_month_inc 
treatment
sum_b3 
sum_current_bus 
b20* 
emp_ilo
, replace
;
#d cr


su b2 
local jobs_roster_rows = `r(max)'

foreach u of num 1/`jobs_roster_rows' {
	replace b21_`u' = 0 if b21_`u'==-98
}


*clonevar treatment = treatment_group


ds, has(type numeric)
foreach var of varlist `r(varlist)' {
  mvdecode `var', mv(-97 = .a \ -98 = .b \ -99 = .c )
  
}

ds, has(type string)
foreach var of varlist `r(varlist)' {
	replace `var' = upper(`var')
}


destring id_key duration emp_inc_month_? emp_inkind_month_? sales_month_? profit_month_? duration total_month_inc ave_month_inc treatment sum_b3 sum_current_bus b20* emp_ilo, replace

clonevar completiondate = endtime
destring completiondate, replace 

/*
local mdy_time_strings "completiondate"
foreach var of varlist `mdy_time_strings' {
gen `var'_dt=clock(`var',"MDYhms",2025)
drop `var'
rename `var'_dt `var'
format `var' %tc
}
*/

/*
local ymdhs_time_strings "attempt_1_time attempt_2_time attempt_3_time attempt_4_time attempt_5_time attempt_6_time"
foreach var of varlist `ymdhs_time_strings' {
gen `var'_dt=clock(`var',"YMDhms",2025)
drop `var'
rename `var'_dt `var'
format `var' %tc
}
*/

drop if id_key==.

*gen duration_m = duration/60 // Phone call duration in 60 mins
gen duration_m = duration/60 // Phone call duration in 60 mins


**
/*
gen completed=(call_status==1)
bysort id: egen completed_any=max(completed)

duplicates tag id, gen(dup) // Tag multiple submissions
gsort id completed -completiondate 
by id: gen counter=_n
by id: gen attempt_tot=_N

preserve
keep if dup>0
drop if counter==attempt_tot
keep id completiondate call_status counter
reshape wide completiondate call_status, i(id)  j(counter) // Reshape previous visits
tempfile attempts_before
save `attempts_before'
restore

keep if counter==attempt_tot // Drop previous visits from the Long table
merge m:1 id using `attempts_before', nogen // Merge in wide table for previous visits

egen form_count=rownonmiss(completiondate?)
replace form_count=form_count+1

egen attempt_time=rowtotal(attempt_?_time)
format attempt_time %tc

**Generate variable to check daily interview completion
gen datedaily = dofc(submissiondate )
egen tag = tag (z1 datedaily) if completed ==1
egen days_worked = total(tag), by(z1)
bys z1: gen total_surveys_done = _N
gen daily_avg = round(total_surveys_done/days_worked, .01) 
tabdisp z1, c(days_worked total_surveys_done daily_avg) format(%9.2f) center
**
*/








**************************************************
* RESHAPING PREVIOUS ATTEMPTS - ENSURE UNIQUE ID
**************************************************
gen completed_interview=(a6!=.) // CHANGE THIS TO A PROPER COMPLETION VARIABLE
bysort ApplicantID: egen completed_any=max(completed_interview)

duplicates tag ApplicantID, gen(dup) // Tag multiple submissions
count if dup > 0

if `r(N)' > 0 {
gsort ApplicantID completed_interview -submissiondate 
by ApplicantID: gen counter=_n
by ApplicantID: gen attempt_tot=_N

preserve
keep if dup>0
drop if counter==attempt_tot
keep ApplicantID submissiondate counter
reshape wide submissiondate, i(ApplicantID)  j(counter) // Reshape previous visits
tempfile attempts_before
save `attempts_before'
restore

keep if counter==attempt_tot // Drop previous visits from the Long table
merge m:1 ApplicantID using `attempts_before', nogen // Merge in wide table for previous visits

egen form_count=rownonmiss(submissiondate?)
replace form_count=form_count+1
drop counter
}
else {
	gen form_count = 1

}



**************************************************
* PRELIMINARY ANALYSIS
**************************************************

** Employment Status
* Measure 1: Gambian Labour Force Survey Definition – In the past 7 days reported In Paid/In-kind employment or self-employed
*clonevar employed_ilo = b32 if completed_interview==1 // Used in Cycle 1
clonevar employed_ilo = emp_ilo if completed_interview==1
label var employed_ilo "In the past 7 days reported In Paid/In-kind employment or self-employed"

* Measure 2: Field (2019) Survey Definition 1 – Currently employed in a paid/in-kind employment or self-employed for longer than one month
gen employed_stable_current=(sum_b3>0) if completed_interview==1
label var employed_ilo "Currently employed in a paid/in-kind employment or self-employed for longer than one month"

* Measure 3: Field (2019) Survey Definition 2 – Ever (in reference period) employed in a paid/in-kind employment or self-employed for longer than one month
clonevar employed_stable_ever = b1 if completed_interview==1
label var employed_stable_ever "Ever employed in a paid/in-kind employment or self-employed for longer than one month"

** Business ownership
gen current_bus=(sum_current_bus>0) if completed_interview==1
label var current_bus "Currently owns a business"


** Income/Earnings
* Measure 1: Gambian Labour Force Survey Definition – Sum of all the compensation (cash, in-kind) received from economic activities over reference period


foreach u of num 1/`jobs_roster_rows' {


gen profit_kept_`u'=b27_`u' if b26_unit_`u'==1
replace profit_kept_`u'=(b27_`u' * 4.345) if b26_unit_`u'==2
replace profit_kept_`u'=(b23_`u'* b27_`u'* 4.345) if b26_unit_`u'==3
replace profit_kept_`u'=(b27_`u' / b26_unit_s_`u') if b26_unit_`u'==4
replace profit_kept_`u'=round(profit_kept_`u')
}

/*


*/
gen current_month_dts="1/" + current_month + "/2022" if completed_interview==1
gen current_month_dt=date(current_month_dts,"DMY",2025) if completed_interview==1
drop current_month_dts
format %td current_month_dt

gen ref_months="1/" + reference_month + "/" + reference_year if completed_interview==1
gen ref_month=date(ref_months,"DMY",2025) if completed_interview==1
format %td ref_month

foreach u of num 1/`jobs_roster_rows' {
	clonevar b5_`u'_analysis =  b5_`u'
	clonevar b4_`u'_analysis =  b4_`u'
}
	
foreach i of num 1/`jobs_roster_rows' {
	replace b5_`i'_analysis=current_month_dt if b4_`i'_analysis!=.
	replace b4_`i'_analysis=ref_month if b4_`i'_analysis<ref_month
	gen months_in_job_`i' = round((b5_`i'_analysis - b4_`i'_analysis)/(365/12))
	egen ave_ref_inc_`i'=rowtotal(emp_inc_month_`i' emp_inkind_month_`i' profit_month_`i')
	gen sum_inc_`i'=(months_in_job_`i' * ave_ref_inc_`i')
}
egen sum_inc_reference=rowtotal(sum_inc_?) if completed_interview==1
label var sum_inc_reference "Sum of all the compensation (cash, in-kind) received from economic activities over reference period"


* Measure 2: Field (2019) – Average Monthly earnings if currently employed

foreach i of num 1/`jobs_roster_rows' {
gen current_emp_inc_month_`i'=(emp_inc_month_`i' + emp_inkind_month_`i') if b3_`i'==1
gen current_profit_month_`i'=profit_month_`i' if b3_`i'==1
}

egen current_inc=rowtotal(current_emp_inc_month_? current_profit_month_?) if completed_interview==1
label var current_inc "Average Monthly earnings if currently employed"

** Psychological Resilience
* Measure 1: Brief Resilience Scale
/*
analysed using process from https://www.psytoolkit.org/survey-library/resilience-brs.html
*/
**
foreach var of varlist i1 i3 i5 { // Creating a cloned variable that will just be the BRS score
	clonevar `var'_brs = `var'
}

foreach var of varlist i2 i4 i6 { // Creating a cloned variable for the "reverse" variables (i.e. those where agree is a negative) that will just be the BRS score
	clonevar `var'_brs = `var'
	recode `var'_brs (1=5) (2=4) (4=2) (5=1)
}

**
egen brs_score=rowmean(i1_brs i2_brs i3_brs i4_brs i5_brs i6_brs)
label var brs_score "Brief Resilience Scale Score"

** Perception of Employability
* Measure 1: Adapted Self-Perceived Employability Scale from Rothwell (2008)
//*creating a clone variable that will be Self Perceived Employability Score ****//
foreach var of varlist e1 e2 e3 e4 e5 e6 e7 e8 e9 e10 { 
clonevar `var'_spe = `var'	
}

***generating Self Perceived Score from individual item score***
egen spe_score=rowmean (e1_spe e2_spe e3_spe e4_spe e5_spe e6_spe e7_spe e8_spe e9_spe e10_spe)
label var spe_score "Self Perceived Employability Scale Score"

** Size of Business
* Measure: Number of employees
egen num_empl = rowtotal (b21_?) if completed_interview==1
label var num_empl "Number of Employees"

** Job Formality	
* Measure: Written Formal contract for Main Job (current or most recent)
gen wrk_cntr = (b13_1==1 | b13_1==2) if completed_interview==1 // For the moment just taking the first job - need to decide how we consider this - main (most income)/(current)/(most recent) etc.
label var wrk_cntr "Written Formal contract for Main Job (current or most recent)"

/*
** Business Formality
* Measure: Business owned is registered
*b20 - 1 - MoJ 2 - GCC 3 - Registrar -95 None
capture gen b20__99_3=. // This isn't an exisiting variable - annoying but can remove
foreach i of num 1/3 {
capture gen notreg_`i'=(b20__95_`i'==1 | b20__99_`i'==1) if b6_`i'==3
gen bus_reg_`i'=(notreg_`i'==0) if b6_`i'==3
}
egen bus_reg_rate=rowmean(bus_reg_?)
label var bus_reg_rate "Rate that Business owned is registered (Across all owned business)"
*/
** Occupational safety
* Measure: Reported an injury or work related illness during job
foreach i of num 1/`jobs_roster_rows' {
gen work_inj_`i'=(inlist(b9_`i', 1, 3)) if b1==1
gen work_ill_`i'=(inlist(b9_`i', 1, 2)) if b1==1
gen work_hurt_`i'=(work_inj_`i'==1 | work_ill_`i'==1) if b1==1
}
egen work_hurt_total=rowtotal(work_hurt_?) if b1==1
gen work_hurt_any=(work_hurt_total>0) if b1==1
label var work_hurt_any "Reported an injury or work related illness during any job"



** Objective Employability
* Measure 4: Have they been offered any job in the reference period 
clonevar job_offer = d8 if completed_interview==1 // We only have this variable for people that were looking for jobs - maybe should ask to all next time
label var job_offer "Offered any job in the reference period - only those looking for job"


** Job-Search
* Measure 3: Adapted Job Search Behaviour Scales (Blau 1994) used in (Chen & Lim 2012) – Singapore. Used in Nigeria (Onyishi et al 2015). // Uses Y/N rather than Likert Scale
egen prep_score=rowmean(d3?)
label var prep_score "Prepatory Job Search Score"
egen active_score=rowmean(d4?)
label var active_score "Active Job Search Score"

** Has multiple economic activities
* Measure 2: The total number of economic activities undertaken over reference period
clonevar num_econ_ref = b2
replace num_econ_ref=0 if num_econ_ref==. & completed_interview==1
label var num_econ_ref "Number of economic activities over reference period"


**** Life Satisfaction (Cantril Ladder)
**** This is a preliminary analysis. Further categorization into ;'Thriving (7+)' , 'Struggling (6-5)' and 'Suffering (4-)'
egen life_satisfaction_total = rowmean(p1 p2 p3)
label var life_satisfaction_total  "Overall Life Satisfaction Score"

gen life_satisfaction_past = p1
label var life_satisfaction_past "Past Life Satisfaction"

gen life_satisfaction_present = p2
label var life_satisfaction_present "Present Life Satisfaction"

gen life_satisfaction_future = p3
label var life_satisfaction_future "Future Life Satisfaction"

****General Self Efficacy (GSE) Score
*** Source: Schwarzer, R., & Jerusalem, M. (1995). Generalized Self-Efficacy scale. In J. Weinman, S. Wright, & M. Johnston, Measures in health psychology: A user's portfolio. Causal and control beliefs (pp. 35-37). Windsor, UK: NFER-NELSON.

egen gse_score = rowmean(n1 n2 n3 n4 n5 n6)
label var gse_score "Generalized Self Efficacy Score"


**** Financial Literacy Scale
****
gen r1_correct = 1 if r1 ==200
gen r2_correct = 1 if r2 ==4
gen r3_correct = 1 if r3 ==0
gen r4_correct = 1 if r4 ==102
gen r5_correct = 1 if r5 ==1|r5 ==2
egen fl_scale_score = rowtotal (r1_correct r2_correct r3_correct r4_correct r5_correct)
label var fl_scale_score "Total Financial Literacy Score"

****Household Characteristics
***
clonevar hh_size = a3
label var hh_size "Houshold Size (Including respondent)"

clonevar hh_size_chil = a12
label var hh_size_chil "Number of Children below 15 years of Age in Household"

clonevar finance_access = t1
label var finance_access "Taken a loan in the past 1 year"

****Household decision making
/*Source: https://www.data4impactproject.org/prh/gender/women-and-girls-status-and-empowerment/participation-of-women-in-household-decision-making-index/
This applies more to women. Needs to be filtered through in the analysis for females only
*/
clonevar hh_decision_health = a9
replace hh_decision_health = 1 if a9 == 1 | a9 ==2
label var hh_decision_health "Involved in houshold decision on regarding their own health"

clonevar hh_decision_purchase = a10
replace hh_decision_purchase = 1 if a10 ==1 | a10 ==2
label var hh_decision_purchase "Involved in household decision on large purchases"

clonevar hh_decision_visit = a11
replace hh_decision_visit = 1 if a11 ==1 | a11 == 2
label var hh_decision_visit "Involved in household decisions on who to visit"






*** Shocks
clonevar shock_nat = shocks_1
clonevar shock_agr = shocks_2
clonevar shock_soc = shocks_3
clonevar shock_fam = shocks_4
clonevar shock_dem = shocks_5
clonevar shock_sup = shocks_6

***Total number of shocks experienced within the reference period
cap drop shocks_no
egen shocks_no=rowtotal(f1_?)
label variable shocks_no "Number of Shocks"

****Mean exposure to shocks within the reference period
cap drop shock_exposure
egen shock_exposure=rowmean(f2_?)
label variable shock_exposure "Mean schock exposure"

****Ability to recover from shocks
cap drop ATR					
egen ATR= rowmean(f3_?)
label variable ATR "Ability to Recover"






********************************************************************************
* LABELLING VARIABLES AND VALUES
********************************************************************************

label var ApplicantID "Unique ApplicantID"

label var full_name "Name of Respondent (Pre-populated)"

label var treatment "Treatment group of Respondent (Pre-populated)"
label def L_Treat 2 "Treatment (TVET + BD)" 1 "Treatment (TVET)" 0 "Control"
label val treatment L_Treat

/*
label var treatment_group "Treatment group of Respondent (Pre-populated)"
label def Treat_lbl  1 "Treatment" 0 "Control"
label val treatment_group Treat_lbl
*/
label var consent "Respondent Consent"

label var id1a "id1a. First Name"
label var id1b "id1b. Last Name"

egen respondent_name = concat(id1a id1b), punct(" ")
replace respondent_name = upper(respondent_name)
label var respondent_name "Name of Respondent Provided"

label var id2 "id2. Age"

*clonevar gender = id2a


gen id2_c4ed = "This was outside if the age range of Tekki Fii, but was confirmed by enumerator" if ApplicantID==100135
label var id2_c4ed "C4ED Comment on id2"
label var id3 "id3. Region of birth"


foreach i of num 1/`jobs_roster_rows' {
label var job_name_`i' "Name of Job `i'"
label var b3_`i' "b3. Employment status in Job `i'"
label var b4_`i' "b4. When did you start in Job `i'" 
label var b4_time_`i' "b4. Time since the beginning of Job `i'"
label var b5_`i' "b5. Time of end of employment Job `i'"
label var b5_time_`i' "b5. Time of end of employment Job `i'"
label var b6_`i' "b6. Working status in Job `i'"
label var b6oth_`i' "b6. Other working status in Job `i'"
label var isic_1_`i' "ISIC1. Employment by industry categorisation 1 of Job `i'"
label var isic_2_`i' "IISIC2. Emplyoyment by industry categorisation 2 of Job `i'"
label var b9_`i' "b9. Suffered job related injury in Job `i'"
label var b11_`i' "b11. How job was found Job `i'"
label var b11_other_`i' "b11. Other mweans job was found Job `i'"

label var b12_1_`i' "b12. Business officially registered Job `i' [Ministry of Justice]"
label var b12_2_`i' "b12. Business officially registered Job `i' [Gambia Chamber of Commerce]"
label var b12_3_`i' "b12. Business officially registered Job `i' [The Registrar of Companies]"
label var b12__99_`i' "b12. Business officially registered Job `i' [Don't know]"
*label var b12__95_`i' "b12. Business officially registered Job `i' [None of the above]"
label var b12__96_`i' "b12. Business officially registered Job `i' [Other specify]"

label var b13_`i' "b13. official work contract written or oral Job `i'"
label var b14_`i' "b14. How many months longer in Job `i'"
label var b15_`i' "b15. Number of hours worked in typical day Job `i'"
label var b16_`i' "b16. Number of days worked in a typical week Job `i'"
label var b17_`i' "b17. Average earnings in cash (GMD) in a typical month Job `i'"
label var b17_unit_`i' "b17. Time frame of average earnings in a typical month Job `i'"
label var b17_unit_s_`i' "b17. Number of months in a season or contract [if seasonal or contract] Job `i'"
label var b17_unit_val_`i' "b17. Time frame of season and contract" 
label var emp_inc_month_`i' "Total monthly average income (GMD) Job `i'"
label var b18_a_`i' "b18. Did you receive any payment in-kind Job `i'"
label var b18_`i' "b18. Total average payment in-kind Job `i'"
label var b18_unit_`i' "b18. Time frame of average payments in kind Job `i'"
label var b18_unit_s_`i' "b18. Number of months in a [if]season or contract for payment in-kind Job `i'"
label var b18_unit_val_`i' "b18. Time frame of season and contract" 
label var emp_inkind_month_`i' "Total monthly average payment in-kind Job `i'"

label var b20_1_`i' "b20. Business officially registered Job `i' [Ministry of Justice]" 
label var b20_2_`i' "b20. Business officially registered Job `i' [Gambian Chamber of Commerce]"
label var b20_3_`i' "b20. Business officially registered Job `i' [The Registrar of Companies]"
label var b20__99_`i' "b20. Business officially registered Job `i' [Don't know]"
*label var b20__95_`i' "b20. Business officially registered Job `i' [None of the above]"

label var b21_`i' "b21. Besides yourself how many workers do you employ Job `i'? "
label var b22_`i' "b22. Number of hours worked in business in a typical day Job `i'"
label var b23_`i' "b23. Number of days worked in business in a typical month Job `i'"
label var b24_`i' "b24. Sales (GMD) in a typical month of operation of business Job `i' "
label var b24_unit_`i' "b24. Timeframe of total sales in a typical month of operation of business Job `i'"
label var b24_unit_s_`i' "b24. Number of months in a [if]season or contract for total sales Job `i'"
label var b24_unit_val_`i' "b24. Time frame of season and contract" 
label var sales_month_`i' "Total monthly sales (GMD) in operation of business Job `i' "
label var b26_`i' "b26. Profits generated in a typical month of operation of business Job `i' "
labe var b26_unit_`i' "b26. Time frame of profits generated in a typical month of operation Job `i'"
label var b26_unit_s_`i' "b26. Number of months in a [if]season or contract for profits Job `i'"
label var b26_unit_val_`i' "b26. Time frame of season and contract"
label var profit_month_`i' "Total monthly profits in operation of business Job `i' "
*label var b29_`i' "b29. Received a loan  in the past 6 months"
*label var b30_1_`i' "b30. Source(s) of loans received in the past 6 months "
*label var b30_other_`i' "b30. Other sources of loans received in the past 6 months"
*label var b30_9_`i' "b30. Source(s) of received in the past 6 months [Bank/Financial Institution]"
*label var b30__96_`i' "b30. Source(s) of loans recienced in the past 6 months [Other specify]"

*label var b30_`i' "b230. Source(s) of loans received in the past 6 months "
*label var b30_other_`i' "b30. Other sources of loans received in the past 6 months"

label var work_inj_`i' "Injured self while working in Job `i'"
label var work_ill_`i' "Ill while working in Job `i'"
label var current_emp_inc_month_`i' "Monthly income if employee from Job `i'"
label var current_profit_month_`i' "Monthly profit if self employed from Job `i'"

label val b17_unit_`i' b17_unit_1
}













label var b1 "b1. Work or employment in the past 6 months"
label var b2 "b2. Number of stable jobs in the past 6 months"

label var b34 "b34. What was your working status in small job done in the past 7 days"
label var isic_1_seven "ISIC1. empolyomeyment by industry categorisation 1 of small job in past 7 days"
label var isic_2_seven "ISIC2. employment by industry categorisation 2 of small job in past 7 days"

label var sum_b3 "b3. Total number of jobs in the past 6 months"
label var sum_current_bus "Total number of businesses"
label var ave_month_inc "Average monthly income including all jobs in the past 6 months"

//Section 'j'
label var j1a "j1a. Attended a training course since January 2020"
label var j1b "j1b. Attended other Voc/Tech training other than Tekki Fii in past 6 months"
label var j3 "j3. If other training was attended was it formal or non-formal" 
label var j4 "j4. Type of training attended"
label var j4_other "j4 Other type of training attended"
label var j5 "j5. Completion status of other training attended"
label var j6 "j6. Time frame of other training attended" 

label var k1 "k1. Teaching methods of teachers used in Tekki Fii traninig "
label var k2 "k2.Teachers ability to handle training equipment for instruction"
label var k4 "k4. Teachers ability to engage students in the activirities "
label var k5 "k5. Quality assessment of TVET facilities in Training Centres by trainees"
label var k6 "k6. Assessment of Tekki Fii by trainees [work place relevant skills]"
label var k8 "k8. Assessement of Tekki Fii by trainees [improving team work skills]"
label var k9 "k9. Assessment of Tekki Fii by trainees [improve ability to work independetly]"
label var k10 "k10. Assessment of Tekki Fii by trainees [improve self expression]"
label var k11 "k11. Absenteeism at Tekki Fii trainings"
label var k12_1 "k12. Reasons for Tekki Fii absenteeism [Illness]"
*label var k12_2 "k12_2. Reasons for Tekki Fii absenteeism [Household obligations]"
*label var k12_3 "k12_3. Reasons for Tekki Fii absenteeism [Economic obligations]"

label var k12_5 "k12_5. Reasons for Tekki Fii absenteeism [Lack of money to travel]"
label var k12_other "k12_other. Reasons for Tekki Fii absenteeism [Specify other]"
label var k12__96 "k12. Reasons for Tekki Fii absenteeism [if other]"
label var tekkifii_check_ind "Tekki Fii industrial placement participation confirmation"
label var tekkifii_check_ind_why "Reason for not taking part in Tekki Fii industrial placementy"
label var k13 "k13. Absenteeism industrial placement"
label var k14_1 "k12. Reasons for indsutrial placement absenteeism [Illness]"
label var k14_2 "k12_2. Reasons for indsutrial placement absenteeism [Household obligations]"
/*label var k14_3 "k12_3. Reasons for indsutrial placement absenteeism [Economic obligations]"
*label var k14_5 "k12_5. Reasons for indsutrial placement absenteeism [Lack of money to travel]"
label var k14_other "k12_other. Reasons for indsutrial placement absenteeism [Specify other]"
label var k14__96 "k12. Reasons for indsutrial placement absenteeism [if other]"
*/

label var k15 "k15. Assessment of Tekki Fii by trainees [putting into practice learned trade and skills]"
label var k16 "k16. Assessment of Tekki Fii by trainees [useful work experience for career dev't']"
label var k17 "Offered a job at company of industrial placement"
label var k18 "k18. Participation in business development component of Tekki Fii"
*label var tekkifii_check "Tekki fii Programme participation confirmation"
*label var tekkifii_check_apply "Tekki Fii Programme application confirmation"
*label var tekkifii_outcome "Outcome of Tekki Fii programme application"
*label var employed_stable_current "Still employed in a paid employment that has lasted more than a month"



label var a1a "a1a. March 2020 highest level of education"
label var a1b "a1b. Current highest level of education"

label var a2 "a2. Current Marital Status"

label var d1 "d1. Looked for job or started business in last 4 weeks" 

drop d2
label var d2_1 "d2. reasons not look for a job in the last 4 weeks [Already have job]"
label var d2_2 "d2. reasons not look for a job in the last 4 weeks [Studying]"
label var d2_3 "d2. reasons not look for a job in the last 4 weeks [Domestic work]"
capture label var d2_4 "d2. reasons not look for a job in the last 4 weeks [Disabled]"
capture label var d2_5 "d2. reasons not look for a job in the last 4 weeks [Found Job to start]"
capture label var d2_6 "d2. reasons not look for a job in the last 4 weeks [Awaiting Recall]"
capture label var d2_7 "d2. reasons not look for a job in the last 4 weeks [Waiting Busy Period]"
capture label var d2_8 "d2. reasons not look for a job in the last 4 weeks [Don't want to work]"
capture label var d2_9 "d2. reasons not look for a job in the last 4 weeks [No chance]"

rename d2__96 d2_96 
label var d2_96 "d2. reasons not look for a job in the last 4 weeks [Other]"


// Clean up other specify
drop d12
label var d12_1 "d12. reasons not tried to start business in last 4 weeks? [Already have]"
label var d12_2 "d12. reasons not tried to start business in last 4 weeks? [Prefer job]"
label var d12_3 "d12. reasons not tried to start business in last 4 weeks? [Lack Finance]"
label var d12_4 "d12. reasons not tried to start business in last 4 weeks? [No Interest]"
label var d12_5 "d12. reasons not tried to start business in last 4 weeks? [No knowledge]"
label var d12_6 "d12. reasons not tried to start business in last 4 weeks? [Bureaucracy]"

label var d3a "d3a. In the past 4 weeks did you… [Read Ads]"
label var d3b "d3b. In the past 4 weeks did you… [Prepare CV]"
label var d3d "d3d. In the past 4 weeks did you… [Talk to friends]"
label var d3e "d3e. In the past 4 weeks did you… [Previous Employers]"
label var d3f "d3f. In the past 4 weeks did you… [Use Internet/Radio]"

label var d4b "d4b. In the past 4 weeks did you… [Send CV]"
label var d4c "d4c. In the past 4 weeks did you… [Fill out Application]"
label var d4d "d4d. In the past 4 weeks did you… [Have interview]"
label var d4f "d4f. In the past 4 weeks did you… [Telephone Employer]"

label var d5a "d5a. Searching for work based [District/Municipality]"
label var d5b "d5b. Searching for work based [Outside District]"
label var d5e "d5e. Searching for work based [Outside Gambia]"

label var d7_1 "d7. Challenges to obtaining local jobs [Competition]"
label var d7_2 "d7. Challenges to obtaining local jobs [Lack Experience/Skills]"
label var d7_3 "d7. Challenges to obtaining local jobs [Lack Jobs Matching Skills]"
label var d7_4 "d7. Challenges to obtaining local jobs [Corruption]"
label var d7_5 "d7. Challenges to obtaining local jobs [No information]"
label var d7_6 "d7. Challenges to obtaining local jobs [No jobs at all]"
label var d7_0 "d7. Challenges to obtaining local jobs [None]"
rename d7__96 d7_96
label var d7_96 "d7. Challenges to obtaining local jobs [Other]"

label var d8 "d8. Any job offers since [REF PERIOD]"

label var c1 "c1. Does professional income vary across the year?" 
label var c3_1 "c3. What months do you consider to be the worst? [January]"
label var c3_2 "c3. What months do you consider to be the worst? [February]"
label var c3_3 "c3. What months do you consider to be the worst? [March]"
label var c3_4 "c3. What months do you consider to be the worst? [April]"
label var c3_5 "c3. What months do you consider to be the worst? [May]"
label var c3_6 "c3. What months do you consider to be the worst? [June]"
label var c3_7 "c3. What months do you consider to be the worst? [July]"
label var c3_8 "c3. What months do you consider to be the worst? [August]"
label var c3_9 "c3. What months do you consider to be the worst? [September]"
label var c3_10 "c3. What months do you consider to be the worst? [October]"
label var c3_11 "c3. What months do you consider to be the worst? [November]"
label var c3_12 "c3. What months do you consider to be the worst? [December]"

label var c2 "c2. Professional income in the worst months"

label var c5_1 "c3. What months do you consider to be the best? [January]"
label var c5_2 "c3. What months do you consider to be the best? [February]"
label var c5_3 "c3. What months do you consider to be the best? [March]"
label var c5_4 "c3. What months do you consider to be the best? [April]"
label var c5_5 "c3. What months do you consider to be the best? [May]"
label var c5_6 "c3. What months do you consider to be the best? [June]"
label var c5_7 "c3. What months do you consider to be the best? [July]"
label var c5_8 "c3. What months do you consider to be the best? [August]"
label var c5_9 "c3. What months do you consider to be the best? [September]"
label var c5_10 "c3. What months do you consider to be the best? [October]"
label var c5_11 "c3. What months do you consider to be the best? [November]"
label var c5_12 "c3. What months do you consider to be the best? [December]"

label var c5 "c5. Professional income in the best months"

label var e1 "e1. My training/educational is an asset to me in job seeking"
label var e2 "e2. Employers target individuals with my educational background"
label var e3 "e3. There is a lot of competition for places on training courses"
label var e4 "e4. People in my career are in high demand in the labour market"
label var e5 "e5. My educational background leads to highly desirable jobs"
label var e6 "e6. There are plenty of job vacancies in my geographical area"
label var e7 "e7. I can easily find out about opportunities in my chosen field"
label var e8 "e8. My skills are what employers are looking for"
label var e9 "e9. Im confident of success in job Interviews and selection" 
label var e10 "e10. I feel I could get any job as long as I have relevant skills" 

label var g6 "g6. When younger involved in organising social projects"
label var g7 "g7. When younger candidate for class prefect/other representative"
label var g8 "g8. When younger regularly organize events with the family or friends"
label var g10 "g10. When younger, ever try to open a business"

label var h2 "h2. Keep written financial records"
label var h4 "h4. Clear and concrete professional goal for next year"
label var h5 "h5. Anticipate investments to be done in the coming year"
label var h6 "h6. How often check to see if achieved targets or not"
label var h1 "h1. Seperate professional and personal cash"
label var h7 "h7. In the last 6 months visited a competitor's business"
label var h8 "h8. In the last 6 months adapted business offers according to competitors"
label var h9 "h9. In the last 6 months discussed with a client how to answer needs"
label var h10 "h10. In the last 6 months asked a supplier about products selling well"
label var h11 "h11. In the last 6 months advertised in any form"
label var h12 "h12. Know which goods/services make the most profit per item selling"
label var h13 "h13. Use records to analyse sales and profits of a particular product"



*****
**Labelling for Cycle 2 Variables**
label var b1a "b1a. In the last 7 days did you do any work, for even one hour?"
label var b1a_1 "b1a_1. In the last 7 days did you do any work, for even one hour? [Paid employee of non-member of household]"
label var b1a_2 "b1a_2. In the last 7 days did you do any work, for even one hour? [Paid worker on HH farm of non-farm bus. ent.]"
label var b1a_3 "b1a_3. In the last 7 days did you do any work, for even one hour? [An employer]"
label var b1a_4 "b1a_4. In the last 7 days did you do any work, for even one hour? [A worker non-agric. own account worker without empl.]"
label var b1a_5 "b1a_5. In the last 7 days did you do any work, for even one hour? [Unpaid workers (eg. homemaker, working in non-farm family business]"
label var b1a_6 "b1ab_6. In the last 7 days did you do any work, for even one hour? [Unpaid farmers]"
label var b1a_7 "b1ab_7. In the last 7 days did you do any work, for even one hour? [None of the above]"
label var b1b "b1b. Has a paid permanent/long term job (eventhough did not work in the past 7 days) due to absenteeism" 
label var b1c "b1c. Main reasons for not working in the past 7 days despite having a permanent job"
*label var b29_b "29_b. Applied for loan or credit within the reference period"
label var b30_1 "Source of loans or credits obtained in the reference period [Relative or friends]"

/*
label var b1c_1 "b1c_1. Main reasons for not working in the past 7 days despite having a permanent job [Paid leave]"
label var b1c_2 "b1c_2. Main reasons for not working in the past 7 days despite having a permanent job [Unpaid leave]"
label var b1c_3 "b1c_3. Main reasons for not working in the past 7 days despite having a permanent job [Own illness]"
label var b1c_4 "b1c_4. Main reasons for not working in the past 7 days despite having a permanent job [Maternity leave]"
label var b1c_5 "b1c_5. Main reasons for not working in the past 7 days despite having a permanent job [Care of household member]"
label var b1c_6 "b1c_6. Main reasons for not working in the past 7 days despite having a permanent job [Holidays]"
label var b1c_7 "b1c_7. Main reasons for not working in the past 7 days despite having a permanent job [Strike/Suspension]"
label var b1c_8 "b1c_8. Main reasons for not working in the past 7 days despite having a permanent job [Temporary workload reduction]"
label var b1c_9 "b1c_9. Main reasons for not working in the past 7 days despite having a permanent job [Closure]"
label var b1c_10 "b1c_10. Main reasons for not working in the past 7 days despite having a permanent job [Bad weather]"
label var b1c_11 "b1c_11. Main reasons for not working in the past 7 days despite having a permanent job [School/Education/Training]"
label var b1c_other "b1c_other. Main reasons for not working in the past 7 days despite having a permanent job [Other specify]"
*/

label var b31a "b31a. Had other jobs in the reference period other than those already discussed"
label var b31b "Number of other jobs since reference period" 
label var b31c "b31c. Other jobs match with trades"
label var b31c_1 "b31c_1. Other jobs match with trades [Block laying]"
label var b31c_2 "b31c_2. Other jobs match with trades [Tiling and plastering]"
label var b31c_2 "b31c_3. Other jobs match with trades [Welding and farm tool repair]"
label var b31c_4 "b31c_4. Other jobs match with trades [Small engine repair]"
label var b31c_5 "b31c_5. Other jobs match with trades [Soalr PV installation]"
label var b31c_6 "b31c_6. Other jobs match with trades [Gament making]"
capture label var b31c_7 "b31c_7. Other jobs match with trades [Hairdressing/barbering and beauty therapy]"
capture label var b31c_8 "b31c_8. Other jobs match with trades [Animal husbandry]"
capture label var b31c_9 "b31c_9. Other jobs match with trades [Satelitte installation]"
capture label var b31c_10 "b31c_10. Other jobs match with trades [Electrical installation and repairs]"
capture label var b31c_11 "b31c_11. Other jobs match with trades [Plumbing]"
capture label var b31c_12 "b31c_12. Other jobs match with trades [None of the above categories]"

label var c1_normal_month_1 "c1_normal. What months do you consider to be the best? [January]"
label var c1_normal_month_2 "c1_normal. What months do you consider to be the best? [February]"
label var c1_normal_month_3 "c1_normal. What months do you consider to be the best? [March]"
label var c1_normal_month_4 "c1_normal. What months do you consider to be the best? [April]"
label var c1_normal_month_5 "c1_normal. What months do you consider to be the best? [May]"
label var c1_normal_month_6 "c1_normal. What months do you consider to be the best? [June]"
label var c1_normal_month_7 "c1_normal. What months do you consider to be the best? [July]"
label var c1_normal_month_8 "c1_normal. What months do you consider to be the best? [August]"
label var c1_normal_month_9 "c1_normal. What months do you consider to be the best? [September]"
label var c1_normal_month_10 "c1_normal. What months do you consider to be the best? [October]"
label var c1_normal_month_11 "c1_normal. What months do you consider to be the best? [November]"
label var c1_normal_month_12 "c1_normal. What months do you consider to be the best? [December]"

********************************************************************************
* LABELLING MULTI RESPONSE OPTIONS - TRY AND FORMALISE AS A TEMPLATE / ADO
********************************************************************************

preserve
import excel using "$qx", clear first sheet("survey")   
keep if strpos(type, "multiple")
gen list_name = subinstr(type, "select_multiple ", "", 1)
rename label question_label

replace question_label = subinstr(question_label, char(34), "", .)

tempfile x 
save `x'

import excel using "$qx", clear first sheet("choices")
keep list_name value label


joinby list_name using `x' //, keep(3) nogen


keep list_name value label name question_label

replace value = subinstr(value, "-", "_", 1)
gen variable_name = name + "_" + value
levelsof variable_name, l(l_mulvals)

di `"`l_mulvals'"'

tokenize `"`l_mulvals'"'
while "`*'" != "" {
tempfile begin
save `begin'
	di "`1'"
	keep if variable_name == "`1'"
	local `1'_val = question_label + ". [" + upper(label) + "]" //if nathan == `1'
	local label_length = strlen("``1'_val'")
	di "`label_length'"
	di "``1'_val'"
	if `label_length' > 80 {
	local length_diff = `label_length' - 80
	di "LENGTH DIFFERENCE: `length_diff'"
	local `1'_val_orig = question_label 
	local `1'_val_orig_length = strlen("``1'_val_orig'")
	di "ORIGINAL Q LENGTH: ``1'_val_orig_length'"
	local length_keep = ``1'_val_orig_length' - `length_diff' - 4 
	di "NEW Q LENGTH: `length_keep'"
	if `length_keep' > 9 {
	local `1'_val_orig  = substr(question_label, 1, `length_keep')
	}
	if `length_keep' < 10 {
	local `1'_val_orig  = substr(question_label, 1, 10)
	}
	di "``1'_val_orig'"
	local `1'_val = "``1'_val_orig'" + "... [" + upper(label) + "]" //if nathan == `1'
	di "NEW VARIABLE LABEL: ``1'_val'"
	}

di "``1'_val'"
macro shift
use `begin', clear
}

restore 
 
di `"`l_mulvals'"'


tokenize `"`l_mulvals'"'


while "`*'" != "" {
	local n = 999
	di "Going through: `1'"	
	capture confirm variable `1'
	if !_rc {
	di "`1' EXISTS"	
	unab vars : `1'*
	local n `: word count `vars''
	di "`n'"
	
	if `n' == 1 {
		label var `1' "``1'_val'"	
	}
	if `n' > 1 {
	local bort = ""
	capture unab bort : `1'_*
	di "XXXX: `bort'"
	local k `: word count `bort''
	di "`k'"	
	if `k' > 0 {	
			foreach var of varlist `1'_* {
			di "`var'"
			*di "``1'_val'" 
			label var `var' "``1'_val'" 
			}
	}
	}
	}
	else {
	local bill = ""
	capture unab bill : `1'_*
	di "XXXX: `bill'"
	local h `: word count `bill''
	di "`h'"	
	if `h' > 0 {	
			foreach var of varlist `1'_* {
			di "`var'"
			*di "``1'_val'" 
			label var `var' "``1'_val'" 
			}
	}		
		
		
		
	}

	macro shift
}




*label def call_status 1 "Completed" 2 "Answered, but not by respondent" 3 "No Answer" 4 "Number does not work" , replace

gen status = 1 if completed=="YES"
replace status = 2 if partially_completed_1=="YES"
replace status = 3 if partially_completed_2=="YES"
replace status = 4 if refused_status=="YES"
replace status = 5 if untracked=="YES"

label def L_status_final 1 "Completed" 2 "Partially Completed - Started" 3 "Partially Completed - Not Started" 4 "Refused" 5 "Untracked"
label val status L_status_final


gen complete = (status==1)

*gen duration_m = duration / 60

gen timestamp_visit_cet=clock(timestamp_visit,"YMDhms",2025)
format timestamp_visit_cet %tc 

replace timestamp_visit_cet = timestamp_visit_cet + ${timezone}*(60*60*1000)


drop timestamp_visit

gen interview_date = dofc(endtime)
format interview_date %td

drop simid

foreach var of varlist b4_? b5_? {
	gen `var'_dk = .
}

********************************************************************************
*Removing unnecessary variables
********************************************************************************

********************************************************************************
*Removing unnecessary variables
********************************************************************************
capture drop b15_check_1 b16_check_1 b17_unit_check_1 b17_check_1 b17low_check_1 b18_unit_check_1 b18_check_1 employee_pay_check_1 b22_check_1 b24_unit_check_1 b24_check_1 b24low_check_1 b26_unit_check_1 b26first_check_1 profit_month_check_1 b15_check_2 b16_check_2 b17_check_2 b17low_check_2 b18_unit_check_2 b18_check_2 employee_pay_check_2 b22_check_2 b24_check_2 b24low_check_2 b26first_check_2 b15_check_3 b16_check_3 b17_check_3 b17low_check_3 b18_unit_check_3 b18_check_3 employee_pay_check_3 b22_check_3 b24_check_3 b24low_check_3 b26first_check_3 j6_check

capture drop deviceid subscriberid devicephonenum mean_light_level min_light_level max_light_level sd_light_level mean_movement sd_movement min_movement max_movement mean_sound_level min_sound_level max_sound_level sd_sound_level mean_sound_pitch min_sound_pitch max_sound_pitch sd_sound_pitch pct_quiet pct_still pct_moving pct_conversation light_level movement sound_level sound_pitch conversation commentsx duration caseid instance_time text_audit id2_check_consistency id2_check id2_check_dk ta_id2_check_consistency ta_id2_bad id2_c4ed ta_note135 ta_Z2 ta_Z1 ta_nameid ta_respondent_found ta_consent ta_availability ta_time_start ta_note245 ta_id1a ta_id1b ta_id1_check ta_id2 ta_id5 ta_a3 ta_a4 ta_a5 ta_a5_other ta_a12 ta_a7 ta_a8 ta_note_decision ta_a9 ta_a10 ta_a11 ta_setuplf ta_d1 ta_d2 ta_d12 ta_d7 ta_d8 ta_sectionBsetup ta_b1a ta_stablejobsetup ta_b1 ta_b2 ta_note7876 ta_job_name ta_b3 ta_b4 ta_b6 ta_generated_note_name_209 ta_job_category ta_b9 ta_b9a ta_b11 ta_b12 ta_b13 ta_b14 ta_note50 ta_b14a ta_b14b ta_b14c ta_b14d ta_b14e ta_b14f ta_b15 ta_b16 ta_income_setup1 ta_b17 ta_b17_unit ta_b18_a ta_employee_pay_check ta_note31 ta_b31a ta_sectionCsetup ta_c1_normal ta_c1 ta_c3 ta_c2 ta_c5 ta_c4 ta_setup_satisfaction ta_p1 ta_p2 ta_p3 ta_setup_finance ta_t1 ta_t6 ta_t7 ta_sectionEsetup ta_e0 ta_e1 ta_e2 ta_e3 ta_e4 ta_e5 ta_e6 ta_e7 ta_e8 ta_e9 ta_e10 ta_note32 ta_n1 ta_n2 ta_n3 ta_n4 ta_n5 ta_n6 ta_note48959 ta_h2 ta_h4 ta_h5 ta_h6 ta_note4895664 ta_r1 ta_r2 ta_r3 ta_r4 ta_r5 ta_note12 ta_i1 ta_i2 ta_i3 ta_i4 ta_i5 ta_i6 ta_note30 ta_shocks ta_j1a ta_f1 ta_f2 ta_f3 ta_k18 ta_a6 ta_completed_questions ta_job_name_1 ta_b3_1 ta_b4_1 ta_b6_1 ta_generated_note_name_209_1 ta_job_category_1 ta_b9_1 ta_b9a_1 ta_b20 ta_b21 ta_note55 ta_b21a ta_b21b ta_b21c ta_b21d ta_b21e ta_b21f ta_b22 ta_b23 ta_income_setup2 ta_b24 ta_b24_unit ta_b26 ta_b26_unit ta_b11_1 ta_b12_1 ta_b13_1 ta_b14_1 ta_note50_1 ta_b14a_1 ta_b14b_1 ta_b14c_1 ta_b14d_1 ta_b14e_1 ta_b14f_1 ta_b15_1 ta_b16_1 ta_income_setup1_1 ta_b17_1 ta_b17_unit_1 ta_b18_a_1 ta_employee_pay_check_1 ta_b31b ta_b31c ta_job_name_2 ta_b3_2 ta_b4_2 ta_b6_2 ta_generated_note_name_209_2 ta_job_category_2 ta_b9_2 ta_b9a_2 ta_b11_2 ta_b12_2 ta_b13_2 ta_b14_2 ta_note50_2 ta_b14a_2 ta_b14b_2 ta_b14c_2 ta_b14d_2 ta_b14e_2 ta_b14f_2 ta_b15_2 ta_b16_2 ta_income_setup1_2 ta_b17_2 ta_b17_unit_2 ta_b18_a_2 ta_employee_pay_check_2 ta_f1_1 ta_f2_1 ta_f3_1 ta_f1_2 ta_f2_2 ta_f3_2 ta_f1_3 ta_f2_3 ta_f3_3 ta_profit_month_check ta_b27 ta_c1_normal_month ta_h1 ta_h7 ta_h8 ta_h9 ta_h10 ta_h11 ta_h12 ta_h13 ta_note34566 ta_dlabels ta_d3a ta_d3b ta_d3d ta_d3e ta_d3f ta_d4b ta_d4c ta_d4d ta_d4f ta_note34 ta_dlabels2 ta_d5a ta_d5b ta_d5e ta_b12_other ta_f1_4 ta_f2_4 ta_f3_4 ta_f1_5 ta_f2_5 ta_f3_5 ta_f1_6 ta_f2_6 ta_f3_6 ta_tekki_institute ta_tekkifii_complete ta_note14 ta_k1 ta_k2 ta_k4 ta_k5 ta_note15 ta_k6 ta_k8 ta_k9 ta_k10 ta_k11 ta_tekkifii_check_ind ta_b1b ta_isic_1 ta_b5 ta_b16_check ta_note13 ta_j3 ta_j4 ta_j5 ta_j6 ta_j7 ta_j4_other ta_j8 ta_b18 ta_b18_unit ta_b35 ta_b36 ta_d2_other ta_b11_other ta_t2 ta_t3 ta_id2_check_consistency ta_d7_other ta_b1c ta_b1c_other ta_b5_error ta_c2_check ta_b24_unit_s ta_b26_unit_s ta_b20_other ta_tekki_course ta_tekki_institute_applied ta_tekki_course_applied ta_isic_1_1 ta_isic_1_2 ta_k12 ta_tekkifii_check_ind_why ta_b20_1 ta_b20_other_1 ta_b21_1 ta_note55_1 ta_b21a_1 ta_b21b_1 ta_b21c_1 ta_b21d_1 ta_b21e_1 ta_b21f_1 ta_b22_1 ta_b23_1 ta_income_setup2_1 ta_b24_1 ta_b24_unit_1 ta_b26_1 ta_b26_unit_1 ta_profit_month_check_1 ta_b27_1 ta_b20_2 ta_b20_other_2 ta_b21_2 ta_note55_2 ta_b21a_2 ta_b21b_2 ta_b21c_2 ta_b21d_2 ta_b21e_2 ta_b21f_2 ta_b22_2 ta_b23_2 ta_income_setup2_2 ta_b24_2 ta_b24_unit_2 ta_b26_2 ta_b26_unit_2 ta_profit_month_check_2 ta_b27_2 ta_job_name_3 ta_b3_3 ta_b4_3 ta_b6_3 ta_generated_note_name_209_3 ta_job_category_3 ta_b9_3 ta_b9a_3 ta_b20_3 ta_b20_other_3 ta_b21_3 ta_note55_3 ta_b21a_3 ta_b21b_3 ta_b21c_3 ta_b21d_3 ta_b21e_3 ta_b21f_3 ta_b22_3 ta_b23_3 ta_income_setup2_3 ta_b24_3 ta_b24_unit_3 ta_b24_check ta_b26_3 ta_b26_unit_3 ta_b26first_check ta_profit_month_check_3 ta_b26_check_3 ta_b27_3 ta_t4 ta_b26_check_2 ta_c4_check_normal ta_b24low_check ta_b26_check ta_t5 ta_t5_other ta_b9a_other ta_t2_other ta_b15_check ta_tekkifii_dropout ta_cc7 ta_b17_unit_s ta_b17_check ta_b35_1 ta_b35_2 ta_k13 ta_k14 ta_note16 respondent_found consent availability ta_b11_3 ta_b12_3 ta_b13_3 ta_b14_3 ta_note50_3 ta_b14a_3 ta_b14b_3 ta_b14c_3 ta_b14d_3 ta_b14e_3 ta_b14f_3 ta_b16_3 ta_income_setup1_3 ta_b17_3 ta_b17_unit_3 ta_b18_a_3 ta_employee_pay_check_3 ta_tekkifii_absent_unsucc ta_t6_other ta_b5_1 ta_b5_2 ta_b17low_check ta_b5_3 ta_j6_check ta_b12_other_1 ta_b12_other_2 ta_refused ta_b18_unit_1 ta_b18_2 ta_b18_unit_2 ta_isic_1_3 ta_k12_other ta_b6oth ta_note_takehome id1_check

cap drop b15_check_2 b17_check_2 b17low_check_2 b18_check_2 b24_check_2 b24low_check_2 b26first_check_2 b15_check_3 b17_check_3 b17low_check_3 b18_check_3 b24_check_3 b24low_check_3 note135 phones_label_2 phone_call_2 phone_no_2 phone_number_label_2 phones_label_3 phones_4 phones_label_4 phone_call_4 phone_no_4 owner_name_4 owner_rel_4 one_number_label_4 response_4 phoneselected_now_4 not_phone_4 no_answer_4 addrepeat_4 note245 sectionbsetup generated_note_name_327 generated_note_name_460 generated_note_name_463 generated_note_name_465 id2_check_dk

cap drop phones_no_answer response_1 phoneselected_now_1 not_phone_1 no_answer_1 addrepeat_1 last_continue phones_selected phones_exclude phones_no_answer emp_inc_month emp_inkind_month sales_month profit_month  current_month reference_month reference_monthc reference_year availability callback_time total_contacts update phones_2 best_phone stop_at call_num num_calls roster1_count extra_hours continue note16 note17 sectionlsetup note13 note12 note48959 note11 sectionesetup sectioncsetup income_setup1_1 income_setup1_2 note4_1 note4_2 note4_3 callback_disp1 callback_note note1_2 note3_3 employee_pay_check call_status1 completiondate1 call_status2 completiondate2 call_status3 completiondate3 call_status4 completiondate4 call_status5 attempt_time

cap drop ta_note135 ta_Z2 ta_Z1 ta_id ta_intro_phones ta_phones_1 ta_call_respondent_1 ta_otherphone_note ta_note2 ta_continue ta_phones_2 ta_call_respondent_2 ta_response_2 ta_call_status ta_final_note ta_comments ta_phones ta_call_respondent ta_response ta_resp_relationship ta_consent ta_availability ta_time_start ta_note245 ta_id1a ta_id1b ta_id2 ta_id2a ta_id3 ta_id3a ta_a1a ta_a1b ta_a2 ta_d1 ta_note34566 ta_dlabels ta_d3a ta_d3b ta_d3d ta_d3e ta_d3f ta_d4b ta_d4c ta_d4d ta_d4f ta_note34 ta_dlabels2 ta_d5a ta_d5b ta_d5e ta_d7 ta_d8 ta_sectionBsetup ta_b1a ta_stablejobsetup ta_b2 ta_note7876 ta_job_name ta_b3 ta_b4 ta_b6 ta_generated_note_name_228 ta_job_category ta_b9 ta_b11 ta_b12 ta_b13 ta_b15 ta_b16 ta_income_setup1 ta_b17 ta_b17_unit ta_b18_a ta_generated_note_name_330 ta_b31a ta_b31b ta_sectionCsetup ta_c1_normal ta_c1 ta_c3 ta_c2 ta_c5 ta_c4 ta_c1_normal_month ta_sectionEsetup ta_e0 ta_e1 ta_e2 ta_e3 ta_e4 ta_e5 ta_e6 ta_e7 ta_e8 ta_e9 ta_e9 ta_e10 ta_note11 ta_g6 ta_g7 ta_g8 ta_g10 ta_note48959 ta_h2 ta_h4 ta_h5 ta_h6 ta_i1 ta_i2 ta_i3 ta_i4 ta_i5 ta_i6 ta_j1b ta_tekki_institute ta_tekkifii_complete ta_note14 ta_k1 ta_k2 ta_k5 ta_k4 ta_note15 ta_k6 ta_k6 ta_k8 ta_k9 ta_k10 ta_k11 ta_k13 ta_note16 ta_note17 ta_k15 ta_k16 ta_k17 ta_k18 ta_sectionLsetup ta_l7 ta_l10 ta_l9 ta_l8 ta_l1 ta_l1 ta_l2a ta_l2a_w ta_l3 ta_completed_questions ta_incentives ta_a6 ta_incentives ta_d2 ta_d12 ta_b1b ta_b1c ta_l1_w ta_l5 ta_l5 ta_d2_other ta_b1c_other ta_b20 ta_b21 ta_b22 ta_b23 ta_income_setup2 ta_b24 ta_income_setup2 ta_b24 ta_b26 ta_b24_unit ta_b26_unit ta_b27 ta_b29_b ta_h1 ta_h7 ta_h8 ta_h9 ta_h10 ta_h11 ta_h12 ta_h13 ta_j1a ta_note13 ta_j3 ta_b31c ta_j4 ta_j5 ta_j6 ta_j7 ta_name ta_resp_available ta_resp_confirm ta_best_phone_confirm ta_reschedule_not_resp ta_k14 ta_k12 ta_review_error ta_b24_unit_s ta_b26_unit_s ta_b30 ta_job_name_1 ta_b3_1 ta_b4_1 ta_b4_1 ta_b6_1 ta_b6oth ta_generated_note_name_228_1 ta_job_category_1 ta_isic_1 ta_b11_1 ta_job_name_2 ta_b3_2 ta_b4_2 ta_b5 ta_b6_2 ta_generated_note_name_228_2 ta_job_category_2 ta_b9_2 ta_b9_2 ta_b11_2 ta_tekki_course ta_tekki_institute_applied ta_tekkifii_outcome ta_tekkifii_absent_succ ta_j4_other ta_k12_other ta_note3 ta_note4 ta_tekkifii_absent_unsucc ta_j8 ta_id2_bad ta_b12_1 ta_b13_1 ta_b15_1 ta_b14_1 ta_b16_1 ta_income_setup1_1 ta_b17_1 ta_b17_unit_1 ta_b12_2 ta_b13_2 ta_b14_2 ta_b15_2 ta_b16_2 ta_income_setup1_2 ta_b17_2 ta_b17_unit_2 ta_b18_a_2 ta_b20_1 ta_b21_1 ta_b22_1 ta_b23_1 ta_income_setup2_1 ta_b24_1 ta_b24_unit_1 ta_b26_1 ta_b26_unit_1 ta_b27_1 ta_b29_b_1 ta_b20_2 ta_b21_2 ta_b22_2 ta_b23_2 ta_income_setup2_2 ta_b24_2 ta_b24_unit_2 ta_b26_2 ta_b29_b_2 ta_incentives_num ta_resp_relationship_other ta_b17_unit_s ta_callback_disp2 ta_bye_note ta_other_phone ta_reschedule_type ta_reschedule_no_ans ta_callback_disp3 ta_phone_relationship ta_name_phone ta_extra_hours ta_sms2 ta_b15_check ta_job_name_3 ta_generated_note_name_228_3 ta_b4_3 ta_b3_3 ta_tekkifii_dropout ta_b18 ta_b18_unit ta_b5_error ta_isic_1_2 ta_job_category_3 ta_isic_1_3 ta_b9_3 ta_b20_3 ta_b21_3 ta_b22_3 ta_b23_3 ta_income_setup2_3 ta_b24_3 ta_b24_unit_3 ta_b26_3 ta_b26_unit_3 ta_b27_3 ta_b27_3 ta_b29_b_3 ta_k14_other ta_b30_1 ta_b30_2 ta_isic_1_1 ta_bestphone_note ta_note1 ta_sms ta_warning_status_completed ta_refused ta_best_phone_reconfirm ta_bestphone_sms ta_otherphone_note_1 ta_note1_1 ta_note1_2 ta_continue_2 ta_phones_3 ta_call_respondent_3 ta_response_3 ta_phones_sms ta_launch_sms_2 ta_launch_sms_3 ta_launch_sms ta_warning_status_refusal ta_note4_1 ta_note4_2 ta_otherphone_note_3 ta_note1_3 ta_continue_3 ta_note1_3 ta_phones_4 ta_call_respondent_4 ta_response_4 ta_warning_status_noanswer ta_warning_status_answer2 ta_note3_1 ta_note3_2 ta_note2_1 ta_note2_2 ta_answer_wrong_num ta_b5_1 ta_b5_2 ta_d7_other ta_note3_3 ta_a1b_error ta_note4_3 ta_reschedule ta_confirm_phone ta_callback_note ta_otherphone_note_4 ta_continue_4 ta_phones_5 ta_call_respondent_5 ta_response_5 ta_b18_1 ta_b18_unit_1 ta_b12_3 ta_b13_3 ta_b14_3 ta_b15_3 ta_b16_3 ta_income_setup1_3 ta_b17_3 ta_b17_unit_3 ta_b18_a_3 ta_b18_3 ta_b18_3 ta_b18_unit_3 ta_employee_pay_check_3 ta_employee_pay_check_3 ta_b11_other ta_note4_4

cap drop b15_check_1 b16_check_1 b17_unit_check_1 b17_check_1 b17low_check_1 b18_unit_check_1 b18_check_1 employee_pay_check_1 b22_check_1 b24_unit_check_1 b24_check_1 b24low_check_1 b26_unit_check_1 b26first_check_1 profit_month_check_1 b15_check_2 b16_check_2 b17_check_2 b17low_check_2 b18_unit_check_2 b18_check_2 employee_pay_check_2 b22_check_2 b24_check_2 b24low_check_2 b26first_check_2 b15_check_3 b16_check_3 b17_check_3 b17low_check_3 b18_unit_check_3 b18_check_3 employee_pay_check_3 b22_check_3 b24_check_3 b24low_check_3 b26first_check_3 j6_check

cap drop deviceid subscriberid devicephonenum caseid device_info contacts best_phoneno callback_time pre_consent last_call_status num_calls call_num stop_at review_status needs_review pub_to_users attempt_1_status attempt_2_status attempt_3_status attempt_4_status attempt_5_status attempt_6_status owner_name_1 owner_rel_1 call_respondent_1 response_1 continue_1 not_phone_1 no_answer_1 addrepeat_1 owner_name_2 owner_rel_2 call_respondent_2 response_2 continue_2 not_phone_2 no_answer_2 addrepeat_2 owner_name_3 owner_rel_3 call_respondent_3 call_respondent_3 response_3 continue_3 not_phone_3 no_answer_3 addrepeat_3 owner_name_4 owner_rel_4 call_respondent_4 response_4 continue_4 not_phone_4 no_answer_4 addrepeat_4 owner_name_5 owner_rel_5 call_respondent_5 response_5 continue_5 not_phone_5 no_answer_5 addrepeat_5 last_continue resp_relationship resp_relationship_other resp_relationship_label name resp_available resp_confirm best_phone_reconfirm consent availability incentives incentives_num addthreshold reschedule_full confirm_phone reschedule_notresp reschedule_type extra_hours new_hour hour hours minutes reschedule_no_ans_2 reschedule_no_ans_3 sms_message sms sending_sms_count index_1 launch_sms_1 index_2 launch_sms_2 index_3 launch_sms_3 index_4 launch_sms_4 index_5 launch_sms_5 sms2 sms_message2 launch_sms2 total_contacts update_contacts filter_phones instancename reschedule reschedule_not_resp reschedule_no_ans ta_response_1 ta_b1 ta_b14 ta_employee_pay_check ta_note12 ta_tekkifii_check_ind ta_l4 ta_profit_month_check ta_b9_1 ta_b17low_check ta_c2_check ta_b17_check ta_c4_check_normal ta_j6_check ta_b16_check ta_b18_a_1 ta_employee_pay_check_1 ta_employee_pay_check_2 ta_profit_month_check_1 ta_b24low_check ta_b26_unit_2 ta_b27_2 ta_b6_3 ta_b26_check ta_tekkifii_check_ind_why ta_profit_month_check_3 ta_launch_sms2 ta_warning_status_answer1 ta_continue_1 ta_otherphone_note_2 ta_id2_check ta_callback_disp1 ta_c4_check ta_b26first_check ta_b24_check ta_b11_3 attempt_1_time attempt_2_time attempt_3_time attempt_4_time attempt_5_time attempt_6_time submissiondate1 submissiondate2 submissiondate3 submissiondate4 submissiondate5 submissiondate6

cap drop l1_w l1_w_1 l1_w_2 l1_w_3 l1_w_0 l2a l2a_w l2a_w_1 l2a_w_2 l2a_w_3 l2a_w_0 l3 l4 l5 l5_comx phone_relationship phone_relationship_label  phones_sms phones_sms_1 phones_sms_2 phones_sms_3 phones_sms_4 phones_sms_5 phones_sms_111 phones_sms_888 phone_sms_1 phone_sms_2 phone_sms_3 phone_sms_4 phone_sms_5 phone2 phone3 phone4 phone5 

cap drop d2_comx d12_comx d7_comx b1a_comx b1_comx b3_comx b6_comx b12_comx b15_comx b16_check_comx b20_comx b21_comx b30_comx b31a_comx b31b_comx b31c_comx c1_normal_comx c1_comx c3_comx c5_comx c4_comx c1_normal_month_comx e10_comx j1a_comx j3_comx j6_comx j7_comx tekki_institute_comx tekkifii_complete_comx tekkifii_dropout_comx tekkifii_outcome_comx k12_comx k17_comx k18_comx l1_comx other_phone_comx call_status_comx b4_comx bye_note_comx



********************************************************************************
* ORDERING VARIABLES
********************************************************************************
{
#d ;
order 
ApplicantID
treatment
formdef_version
status
id2 
id3 
id5
id5_other
a1a 
a1b 
a2 
d1 
d2_1 
d2_2 
d2_4 
d2_5 
d2_6 
d2_7 
d2_8 
d2_9 
d2_96 
d2_other 
d12_1 
d12_2 
d12_3 
d12_4 
d12_5 
d12_6 
d12_other 
dlabels 
d3a 
d3b 
d3d 
d3f 
d4b 
d4d 
d4f 
dlabels2 
d5a 
d5b 
d5e 
d7 
d7_1 
d7_2 
d7_3 
d7_4 
d7_5 
d7_6 
d7_96 
d7_other 
d8
d2_3 
d3e 
d4c 
d7_0 
b1a 
b1a_1 
b1a_2 
b1a_3 
b1a_4 
b1a_5 
b1a_6 
b1a_7 
emp_ilo 
b1b 
b1c 
b1c_other 
b1 
b2 
b2_ifmiss 
earningsid_1 
b3_1 b6oth_1 
job_category_1 
isic_1_1 
isic_2_1 
b11_1 
b11_other_1 
b12_1 
b12_1_1 
b12_2_1 
b12_3_1 
 
 

b12__96_1 
b12__97_1 
b12__99_1 

b13_1 
b14_1 
 
b15_1 
b16_1
total_wrk_hours_1 
b17_1 
b17_unit_1 
b17_unit_s_1 
b17_unit_val_1 
b17_month_1 
b17_weekly_1 
b17_daily_1 
b17_contract_1 
emp_inc_month_1 
b18_a_1 
b18_1 
b18_unit_1 
b18_unit_s_1 
b18_unit_val_1 
b18_month_1 
b18_weekly_1 
b18_daily_1 
b18_contract_1 
emp_inkind_month_1 
emp_month_est_1 
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
b24_1 
b24_unit_1 
b24_unit_s_1 
b24_unit_val_1 
b24_month_1 
b24_weekly_1 
b24_contract_1 
b26_1 
b26_unit_1 
b26_unit_s_1 
b26_unit_val_1 
b26_month_1 
b26_weekly_1 
b26_daily_1 
b26_contract_1 
profit_month_1 
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
b30_other_1 

earningsid_2 
b3_2 iswas_2 
havewere_2 
dodid_2 
b6oth_2 
isic_1_2 
isic_2_2 
b9_2 
 
b11_2 
b11_other_2 
b12_2 
b12_1_2 
b12_2_2 
b12_3_2 

b12__96_2 
b12__97_2 
b12__99_2 
 
b13_2 
b14_2 

b15_2 
b16_2 
total_wrk_hours_2 
b17_2 
b17_unit_2 
b17_unit_val_2 
b17_month_2 
b17_weekly_2 
b17_daily_2 
b17_contract_2 
emp_inc_month_2 
b18_a_2 
b18_2 
b18_unit_2 
b18_unit_s_2 
b18_unit_val_2 
b18_month_2 
b18_weekly_2 
b18_daily_2 
b18_contract_2 
emp_inkind_month_2 
emp_month_est_2 
b20_1_2 
b20_2_2 
b20_3_2 
b20_4_2 
b20__96_2 
b20__97_2 
b20__99_2 

b21_2 

b22_2 
b23_2 
total_wrk_hours_se_2 
b24_2 
b24_unit_2 
b24_unit_s_2 

b24_unit_val_2 
b24_month_2 
b24_weekly_2 
b24_daily_2 
b24_contract_2 
sales_month_2 
b26_2 
b26_unit_2 
b26_unit_s_2 

b26_unit_val_2 
b26_weekly_2 
b26_daily_2 
b26_contract_2 
profit_month_2 

b27_2 
b29_b_2 
b30_2
;
#d cr
}


cap drop enum_ID
gen enum_ID = z1
lab var enum_ID "Enumerator ID"

**************************************************************
* To understand better who actualy belongs to treatment group, respondents who were expected to be part of the treatment group but indicated during the midline indicated that they did not participate in the training were questioned again about the participation by rephrasing the equation. 
**************************************************************

replace tekki_fii_section = "1" if confirmed_attended !=""
replace tekki_fii_section = "1" if tekkifii_complete == 1

label var status "Status of midline survey [Completed/Not Completed]"
label var confirmed_attended "Confirmed that attended Tekki Fii Training"
label var tekkifii_complete "Confirmed that completed Tekki Fii Training"




********************************************************************************
* ORDERING VARIABLES
********************************************************************************

save "$cleaning\/$form_title", replace

********************************************************************************
* EXIT CODE
********************************************************************************

n: di "${proj}_Clean ran successfully"
*}



