/*
// This do-file: 
// Allows the data manager to programme specific checks in the data
// When adding a new check:
	// Make the global i = the next number if line (i.e. if last check is global i=10 then the new one should equal i=11)
		// You should respect the original numbering - even if you blank out an earlier check
	// in the 'global keepvar' line list the most relevant variables in the check
	
*/

cd "$dofiles"	
include "3a. ${proj}_${tool}_HFCs_Stata_Mata.do"	

cd "$corrections"
	
********************************************************************************
* USER WRITTEN CHECKS
********************************************************************************

/*
global i=5
	use "${form_title}", clear
	duplicates tag id, gen(duplicate_id)
	gen error=${i} if duplicate_id>0
	addErr "Duplicate ID"
*/
	global i=1
	use "${form_title}", clear
	gen error=${i} if duration_m<10 & call_status==1
	gen duration_m_str = string(duration_m , "%2.1f") // find a better solution for this - decimals -> string in the addErr programe
	global keepvar "duration_m_str"
	addErr "Completed interview was less than 10 minutes - Send for back-check"

	global i=2
	use "${form_title}", clear
	gen time_diff = abs(clockdiff(time_start, timestamp_visit_cet, "minute"))
	gen error=${i} if time_diff>30 & call_status==1
	global keepvar "time_diff"
	addErr "Entered time is more than 30 minutes from the secret time - Send for back-check"
	
	/*
	global i=3
	use "${form_title}", clear
	keep z1 ApplicantID loclatitude loclongitude localtitude locaccuracy submissiondate z2
	preserve
	rename (ApplicantID loclatitude loclongitude localtitude locaccuracy) (ApplicantID_2 loclatitude_2 loclongitude_2 localtitude_2 locaccuracy_2)
	tempfile gps_loc
	save `gps_loc'
	use `gps_loc', clear
	restore 
	joinby z1 using `gps_loc'
	drop if ApplicantID==ApplicantID_2
	drop if loclatitude==. | loclatitude_2==.
	count
	if `r(N)' > 0 {
	geodist loclatitude loclongitude loclatitude_2 loclongitude_2, gen(gps_distance)
	replace gps_distance = gps_distance * 1000
	gen error=${i} if gps_distance<100
	gen gps_distance_str = string(gps_distance , "%2.1f") // find a better solution for this - decimals -> string in the addErr programe
	global keepvar "gps_distance_str ApplicantID_2"
	addErr "Less than 100 metres away from another interview by enumerator - Send for back-check"
	}
	
	*/
	
	global i=4
	use "${form_title}", clear
	keep submissiondate z2 z1 ApplicantID full_name respondent_name 
	replace full_name=upper(full_name)
	replace respondent_name=upper(respondent_name)
	matchit full_name respondent_name
	gen error=${i} if similscore<0.8 & respondent_name!=""
	global keepvar "full_name respondent_name"
	addErr "Pre-loaded name is not similar to the name entered in the survey"
	
	global i=6
	use "${form_title}", clear
	gen error=${i} if b1==1 & b3_1==.
	global keepvar "b1 b3_1"
	addErr "Had Job in Reference Period but follow up section did not open"
	
	global i=7
	use "${form_title}", clear
	gen error=${i} if b2==2 & b3_2==.
	global keepvar "b2 b3_2"
	addErr "Said had two jobs but did not answer for second job"
	
/*	global i=4
	use $main_table, clear
	gen error=${i} if b2==3 & b3_3==.
	addErr "Said had three jobs but did not answer for third job"
	*/
	global i=8
	use "${form_title}", clear
	gen error=${i} if (d1==1 | d1==3) & d3a==.
	global keepvar "d1 d3a"
	addErr "Searched for a job in reference period but did not answer questions about job search"
	
	global i=9
	use "${form_title}", clear
	egen d2_tot=rownonmiss(d2_*), strok
	gen error=${i} if (d1==0 | d1==2) & d2_tot==0
	global keepvar "d1 d2_tot"
	addErr "Did not search for a job over the reference period but did not answer why"
	
	global i=10
	use "${form_title}", clear
	egen d12_tot=rownonmiss(d12_*), strok
	gen error=${i} if (d1==0 | d1==1) & d12_tot==0
	global keepvar "d1 d12_tot"
	addErr "Did not try and start business over the reference period but did not answer why"
	
	global i=11
	use "${form_title}", clear
	gen error=${i} if (j1a==1 | j1b==1) & j3==.
	global keepvar "j1a j1b j3"
	addErr "Had other vocational training but did not answer any follow up"
	

/*	global i=9
	use "${form_title}", clear
	capture destring phone_call_duration, replace
	gen error=${i} if phone_call_duration<900 & call_status_label=="Completed"
	addErr "Phone call for a completed interview lasted less than 20 minutes"
*/	

		
	*global i=12
	*use "${form_title}", clear
	*gen error=${i} if phone_1=="7155019"
	*addErr "TEST"
	
	global i=13
	use "${form_title}", clear
	gen error=${i} if phone_call_duration_m<15 & call_status==1
	gen phone_call_duration_m_str = string(phone_call_duration_m, "%2.1f")
	global keepvar "phone_call_duration_m_str"
	addErr "Completed Interview that lasted less than 15 minutes"
	
	global i=14
	use "${form_title}", clear
	gen error=${i} if sum_b3>0 & b1b==0
	global keepvar "sum_b3"
	addErr "Say they currently have a stable job, but in the ILO check said they don't'"
	
	global i=15
	use "${form_title}", clear
	gen error=${i} if sum_b3==0 & b1b==1
	global keepvar "sum_b3 b1b"
	addErr "Say they don't current have a stable job, but in the ILO check said they do"

	*global i=16
	*use "${form_title}", clear
	*gen error=${i} if ApplicantID== 300582
	*addErr "Test2"	
	
	global i=17
	use "${form_title}", clear
	gen error=${i} if !(strpos(l10, "@")) & l7==1
	global keepvar "l10"
	addErr "Email Address doesn't contain an @'"	
	
	global i=18
	use "${form_title}", clear
	gen recorded_name=id1a+" "+id1b
	replace recorded_name=upper(recorded_name)
	matchit recorded_name full_name
	gen error=${i} if similscore<0.5 & similscore>0
	global keepvar "recorded_name full_name"
	addErr "Name is not similar to pre-populated name - please check"
	
	global i=19
	use "${form_title}", clear
	gen error=${i} if id2 > 35 & call_status==1
	global keepvar "id2"
	addErr "Age is greater than 35 - check against BL data"	
	
	global i=20
	use "${form_title}", clear
	gen ig=(c2<0 | c1_normal<0 | c4<0) | call_status!=1 | c1==0
	gen error=${i} if (c2>c1_normal | c1_normal>c4 | c2>c4)  & ig==0
	global keepvar "ig"
	addErr "Inconsistency in bad - normal - good months"
	
	/*
	global i=21
	use $main_table, clear
	gen error=${i} if daily_avg > 15
	addErr "Completing more than an average of 15 interviews in a day"
*/
/*
	global i=5
	use $main_table, clear
	gen error=${i} if pct_conversation<0.2 & call_status==1
	gen pct_conversation_str = string(pct_conversation, "%2.1f")
	global keepvar "pct_conversation_str"
	addErr "Low pitch recording for conversation - Send for back-check"
*/
		

*****************************************************************************************************************	
*	CHECKS TO ADD
*****************************************************************************************************************	
	/*
		global i=
	use $main_table, clear
	gen error=${i} if
	addErr ""
	*/


		
	/*
		global i=
	use $main_table, clear
	gen error=${i} if
	addErr ""
	*/
	

********************************************************************************
* CREATING SHEETS
********************************************************************************

	di "Creating checking sheets"
		cd "$field_work_reports"
		local I=$i
		di "`datadir'"
		use "$checking_log\/`checksheet'_`datadir'", clear
			forvalues f=1/`I'{
			capture confirm file `c(tmpdir)'error_${proj_name}_`f'.dta
			*dis _rc
			if _rc==0{	
				append using `c(tmpdir)'error_${proj_name}_`f'.dta, nol
				sort $unique_id
				erase `c(tmpdir)'error_${proj_name}_`f'.dta
			}
		}	
		save, replace



********************************************************************************
* CREATING CHECK SHEET
********************************************************************************


use "$checking_log\\`checksheet'_corrections", clear



foreach var of varlist _all {
capture assert mi(`var')
if !_rc {
drop `var'
}
}

count
if `r(N)' > 0 {
	global add_check_sheet = 1
export excel using  "$checking_log\/`checksheet'.xlsx", firstrow(var) replace
}

di "$add_check_sheet"

else {
		global add_check_sheet = 0
}


	
cd "$dofiles"	
include "3b. ${proj}_${tool}_Enum_Com.do"

cd "$dofiles"	
include "3c. ${proj}_${tool}_HFCs_Merge.do"	
	
	

	
	
	
	
	
	
	
	
	
	
	
	


