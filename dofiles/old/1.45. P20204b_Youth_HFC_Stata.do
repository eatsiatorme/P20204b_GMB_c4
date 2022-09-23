

cd "H:\corrections"

	
******************************
**BASIC CHECKS**
******************************
* DUPLICATES
/*
global i=5
	use $main_table, clear
	duplicates tag id, gen(duplicate_id)
	gen error=${i} if duplicate_id>0
	addErr "Duplicate ID"
*/
	global i=1
	use $main_table, clear
	gen error=${i} if duration_m<10 & call_status==1
	gen duration_m_str = string(duration_m , "%2.1f") // find a better solution for this - decimals -> string in the addErr programe
	global keepvar "duration_m_str"
	addErr "Completed interview was less than 10 minutes - Send for back-check"

	global i=2
	use $main_table, clear
	gen time_diff = abs(clockdiff(time_start, timestamp_visit_cet, "minute"))
	gen error=${i} if time_diff>30 & call_status==1
	global keepvar "time_diff"
	addErr "Entered time is more than 30 minutes from the secret time - Send for back-check"
	
	/*
	global i=3
	use $main_table, clear
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
	use $main_table, clear
	keep submissiondate z2 z1 ApplicantID full_name respondent_name 
	replace full_name=upper(full_name)
	replace respondent_name=upper(respondent_name)
	matchit full_name respondent_name
	gen error=${i} if similscore<0.8 & respondent_name!=""
	global keepvar "full_name respondent_name"
	addErr "Pre-loaded name is not similar to the name entered in the survey"
	
	
	
	
	
	
*	 DUPLICATES
	

* SURVEY LOGIC CHECKS 
	global i=6
	use $main_table, clear
	gen error=${i} if b1==1 & b3_1==.
	addErr "Had Job in Reference Period but follow up section did not open"
	
	global i=7
	use $main_table, clear
	gen error=${i} if b2==2 & b3_2==.
	addErr "Said had two jobs but did not answer for second job"
	
/*	global i=4
	use $main_table, clear
	gen error=${i} if b2==3 & b3_3==.
	addErr "Said had three jobs but did not answer for third job"
	*/
	global i=8
	use $main_table, clear
	gen error=${i} if (d1==1 | d1==3) & d3a==.
	addErr "Searched for a job in reference period but did not answer questions about job search"
	
	global i=9
	use $main_table, clear
	egen d2_tot=rownonmiss(d2_*), strok
	gen error=${i} if (d1==0 | d1==2) & d2_tot==0
	addErr "Did not search for a job over the reference period but did not answer why"
	
	global i=10
	use $main_table, clear
	egen d12_tot=rownonmiss(d12_*), strok
	gen error=${i} if (d1==0 | d1==1) & d12_tot==0
	addErr "Did not try and start business over the reference period but did not answer why"
	
	global i=11
	use $main_table, clear
	gen error=${i} if (j1a==1 | j1b==1) & j3==.
	addErr "Had other vocational training but did not answer any follow up"
	
* OTHER QUALITY CHECKS

/*	global i=9
	use $main_table, clear
	capture destring phone_call_duration, replace
	gen error=${i} if phone_call_duration<900 & call_status_label=="Completed"
	addErr "Phone call for a completed interview lasted less than 20 minutes"
*/	
		

		
	global i=12
	use $main_table, clear
	gen error=${i} if phone_1=="7155019"
	addErr "TEST"
	
	global i=13
	use $main_table, clear
	gen error=${i} if phone_call_duration_m<15 & call_status==1
	addErr "Completed Interview that lasted less than 15 minutes"
	
	global i=14
	use $main_table, clear
	gen error=${i} if sum_b3>0 & b1b==0
	addErr "Say they currently have a stable job, but in the ILO check said they don't'"
	
	global i=15
	use $main_table, clear
	gen error=${i} if sum_b3==0 & b1b==1
	addErr "Say they don't current have a stable job, but in the ILO check said they do"

	global i=16
	use $main_table, clear
	gen error=${i} if ApplicantID== 300582
	addErr "Test2"	
	
	global i=17
	use $main_table, clear
	gen error=${i} if !(strpos(l10, "@")) & l7==1
	addErr "Email Address doesn't contain an @'"	
	
	global i=18
	use $main_table, clear
	gen recorded_name=id1a+" "+id1b
	replace recorded_name=upper(recorded_name)
	matchit recorded_name full_name
	gen error=${i} if similscore<0.5 & similscore>0
	addErr "Name is not similar to pre-populated name - please check"
	
	global i=19
	use $main_table, clear
	gen error=${i} if id2 > 35 & call_status==1
	addErr "Age is greater than 35 - check against BL data"	
	
	global i=20
	use $main_table, clear
	gen ig=(c2<0 | c1_normal<0 | c4<0) | call_status!=1 | c1==0
	gen error=${i} if (c2>c1_normal | c1_normal>c4 | c2>c4)  & ig==0
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
		
	/*
		global i=
	use $main_table, clear
	gen error=${i} if
	addErr ""
	*/
*****************************************************************************************************************	
*	Checks to add
*****************************************************************************************************************	
	

	
	
	
	
	
	
	
		*****************************************************************************************************************
		********************************************* END ERRORS ********************************************************
		*****************************************************************************************************************

		
	