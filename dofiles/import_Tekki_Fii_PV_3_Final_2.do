* import_Tekki_Fii_PV_3_Final_2.do
*
* 	Imports and aggregates "Tekki_Fii_PV_3_Final_2" (ID: Tekki_Fii_PV_3_Final_2) data.
*
*	Inputs:  "H:/exported/Tekki_Fii_PV_3_Final_2_WIDE.csv"
*	Outputs: "H:/exported/Tekki_Fii_PV_3_Final_2.dta"
*
*	Output by SurveyCTO August 25, 2022 12:59 PM.

* initialize Stata
clear all
set more off
set mem 100m

* initialize workflow-specific parameters
*	Set overwrite_old_data to 1 if you use the review and correction
*	workflow and allow un-approving of submissions. If you do this,
*	incoming data will overwrite old data, so you won't want to make
*	changes to data in your local .dta file (such changes can be
*	overwritten with each new import).
local overwrite_old_data 0

* initialize form-specific parameters
local csvfile "H:/exported/Tekki_Fii_PV_3_Final_2_WIDE.csv"
local dtafile "H:/exported/Tekki_Fii_PV_3_Final_2.dta"
local corrfile "H:/exported/Tekki_Fii_PV_3_Final_2_corrections.csv"
local note_fields1 ""
local text_fields1 "deviceid subscriberid simid devicephonenum commentsx username duration caseid instance_time text_audit phone_call_log phone_call_duration collect_phone_app device_info z1_text id contacts best_phone"
local text_fields2 "best_phoneno phone_1 phone_2 phone_3 phone_4 phone_5 phone_1_name phone_2_name phone_3_name phone_4_name phone_5_name phone_1_rel phone_2_rel phone_3_rel phone_4_rel phone_5_rel institute course"
local text_fields3 "phones_filter full_name returnee_unknown treatment_group callback_time pre_consent last_call_status num_calls call_num stop_at review_status needs_review now_closed now_complete users pub_to_users"
local text_fields4 "attempt_1_time attempt_2_time attempt_3_time attempt_4_time attempt_5_time attempt_6_time attempt_1_status attempt_2_status attempt_3_status attempt_4_status attempt_5_status attempt_6_status"
local text_fields5 "respondents_details phonecall_count phones_label_* phone_call_* phone_no_* owner_name_* owner_rel_* phone_number_label_* call_respondent_* phoneselected_now_* not_phone_* no_answer_* addrepeat_*"
local text_fields6 "last_continue phones_selected phones_exclude phones_no_answer phone_response phonenumber_called phone_called phone_rel phone_name resp_relationship_other resp_relationship_label name current_month"
local text_fields7 "reference_month reference_monthc reference_month_str reference_year_str reference_year reference_day reference_dayc reference_date timestamp_visit id1a id1b id5_other d2 d2_other d12 d12_other d7"
local text_fields8 "d7_other b1a emp_ilo b1c_other b2_ifmiss roster1_count earningsid_* job_name_* b4_time_* b5_time_* iswas_* havewere_* dodid_* b6oth_* b11_other_* b12_* total_wrk_hours_* b17_unit_val_* b17_month_*"
local text_fields9 "b17_weekly_* b17_daily_* b17_contract_* emp_inc_month_* b18_unit_s_* b18_unit_val_* b18_month_* b18_weekly_* b18_daily_* b18_contract_* b18_contract_2_* emp_inkind_month_* emp_month_est_* b20_*"
local text_fields10 "total_wrk_hours_se_* b24_unit_val_* b24_month_* b24_weekly_* b24_daily_* b24_contract_* sales_month_* b26_unit_val_* b26_month_* b26_weekly_* b26_daily_* b26_contract_* profit_month_* b30_*"
local text_fields11 "b30_other_* sum_b3 sum_current_bus total_month_inc ave_month_inc job1 job2 job3 b31c b33 b32_job_name c3 c5 c1_normal_month j4_other doesdid confirmed_attended tekkifii_dropout confirmed_applied"
local text_fields12 "tekkifii_absent_succ tekkifii_absent_unsucc k12 k12_other tekkifii_check_ind_why k14 k14_other parentdied l10 l9 l1_w l2a_w reschedule_full best_phone_confirm_label other_phone"
local text_fields13 "phone_relationship_label name_phone reschedule_notresp new_hour hour hours minutes reschedule_no_ans_2 reschedule_no_ans_3 sms_message phones_sms sending_sms_count index_* phone_sms_* launch_sms_*"
local text_fields14 "sms_message2 launch_sms2 call_status_label comments total_contacts phone2 phone3 phone4 phone5 update_contacts name_ph1 name_ph2 name_ph3 name_ph4 name_ph5 rel_ph1 rel_ph2 rel_ph3 rel_ph4 rel_ph5"
local text_fields15 "filter_phones primary_phone instanceid instancename"
local date_fields1 "today b4_* b5_*"
local datetime_fields1 "submissiondate starttime endtime time_start reschedule reschedule_not_resp reschedule_no_ans"

disp
disp "Starting import of: `csvfile'"
disp

* import data from primary .csv file
insheet using "`csvfile'", names clear

* drop extra table-list columns
cap drop reserved_name_for_field_*
cap drop generated_table_list_lab*

* continue only if there's at least one row of data to import
if _N>0 {
	* drop note fields (since they don't contain any real data)
	forvalues i = 1/100 {
		if "`note_fields`i''" ~= "" {
			drop `note_fields`i''
		}
	}
	
	* format date and date/time fields
	forvalues i = 1/100 {
		if "`datetime_fields`i''" ~= "" {
			foreach dtvarlist in `datetime_fields`i'' {
				cap unab dtvarlist : `dtvarlist'
				if _rc==0 {
					foreach dtvar in `dtvarlist' {
						tempvar tempdtvar
						rename `dtvar' `tempdtvar'
						gen double `dtvar'=.
						cap replace `dtvar'=clock(`tempdtvar',"DMYhms",2025)
						* automatically try without seconds, just in case
						cap replace `dtvar'=clock(`tempdtvar',"DMYhm",2025) if `dtvar'==. & `tempdtvar'~=""
						format %tc `dtvar'
						drop `tempdtvar'
					}
				}
			}
		}
		if "`date_fields`i''" ~= "" {
			foreach dtvarlist in `date_fields`i'' {
				cap unab dtvarlist : `dtvarlist'
				if _rc==0 {
					foreach dtvar in `dtvarlist' {
						tempvar tempdtvar
						rename `dtvar' `tempdtvar'
						gen double `dtvar'=.
						cap replace `dtvar'=date(`tempdtvar',"DMY",2025)
						format %td `dtvar'
						drop `tempdtvar'
					}
				}
			}
		}
	}

	* ensure that text fields are always imported as strings (with "" for missing values)
	* (note that we treat "calculate" fields as text; you can destring later if you wish)
	tempvar ismissingvar
	quietly: gen `ismissingvar'=.
	forvalues i = 1/100 {
		if "`text_fields`i''" ~= "" {
			foreach svarlist in `text_fields`i'' {
				cap unab svarlist : `svarlist'
				if _rc==0 {
					foreach stringvar in `svarlist' {
						quietly: replace `ismissingvar'=.
						quietly: cap replace `ismissingvar'=1 if `stringvar'==.
						cap tostring `stringvar', format(%100.0g) replace
						cap replace `stringvar'="" if `ismissingvar'==1
					}
				}
			}
		}
	}
	quietly: drop `ismissingvar'


	* consolidate unique ID into "key" variable
	replace key=instanceid if key==""
	drop instanceid


	* label variables
	label variable key "Unique submission ID"
	cap label variable submissiondate "Date/time submitted"
	cap label variable formdef_version "Form version used on device"
	cap label variable review_status "Review status"
	cap label variable review_comments "Comments made during review"
	cap label variable review_corrections "Corrections made during review"


	label variable z2 "Z2. Supervisor ID"
	note z2: "Z2. Supervisor ID"
	label define z2 1 "MOHAMMED JEBOU"
	label values z2 z2

	label variable z1 "Z1. Enumerator ID"
	note z1: "Z1. Enumerator ID"
	label define z1 1 "AISHA JEBOU" 2 "HADDY MBOOB" 3 "YUSUPHA JATTA" 4 "BINTOU NYASSI" 5 "ALIE CEESAY" 6 "MARIAMA DANSO"
	label values z1 z1

	label variable id "Select the respondent you would like to interview:"
	note id: "Select the respondent you would like to interview:"

	label variable resp_relationship "I'm calling to conduct a survey about employment, and we would love the particip"
	note resp_relationship: "I'm calling to conduct a survey about employment, and we would love the participation of \${full_name}. Do you know \${full_name}? What is the relationship between the owner of this phone and \${full_name}?"
	label define resp_relationship 0 "The respondent" 1 "Family member" 2 "Neighbor" 3 "Friend" 4 "Doesn't know the respondent" 888 "Other"
	label values resp_relationship resp_relationship

	label variable resp_relationship_other "Type other relationship"
	note resp_relationship_other: "Type other relationship"

	label variable name "Can I ask your name? This is just for our records to help us find \${full_name}."
	note name: "Can I ask your name? This is just for our records to help us find \${full_name}."

	label variable resp_available "Is \${full_name} nearby and available to speak now?"
	note resp_available: "Is \${full_name} nearby and available to speak now?"
	label define resp_available 1 "Yes" 0 "No"
	label values resp_available resp_available

	label variable resp_confirm "ENUMERATOR: DO NOT READ THIS ALOUD Ask to speak with the respondent and click 'Y"
	note resp_confirm: "ENUMERATOR: DO NOT READ THIS ALOUD Ask to speak with the respondent and click 'Yes' to confirm whether the respondent is on the phone, so you can move on to the actual form questions. Otherwise, go back and change your answer to 'No'."
	label define resp_confirm 1 "Yes" 0 "No"
	label values resp_confirm resp_confirm

	label variable best_phone_reconfirm "Is this still the best contact to reach out \${full_name}?"
	note best_phone_reconfirm: "Is this still the best contact to reach out \${full_name}?"
	label define best_phone_reconfirm 1 "Yes" 0 "No"
	label values best_phone_reconfirm best_phone_reconfirm

	label variable consent "ENUMERATOR: Starting now, you will read the questions out loud. Hello, my name i"
	note consent: "ENUMERATOR: Starting now, you will read the questions out loud. Hello, my name is \${Z1_text}. I work for CepRass, a research institute in Gambia. We are working with the Center for Evaluation and Development on a study about young people's lives and employment opportunities. We would like to ask you to complete a survey about your experiences in the labour market, including information about employment you have had or businesses that you own. The survey should last about 25 minutes in total. Your participation is voluntary and your answers will remain confidential and only seen by the Research Team, so please try and answer truthfully. We hope to use the information to improve training programmes and help young people find success in the labour market. You will receive mobile credit as a thank you for taking part in the survey. You are free to refuse to take part or answer any questions that you do not wish to answer. You can also pause the survey at any time amd complete at a later time. At the end of the survey we will provide you with \$1 worth of credit that will be transferred to your telephone number as a gift for taking part."
	label define consent 1 "Yes" 0 "No"
	label values consent consent

	label variable availability "Do you have about 25 minutes to complete the survey?"
	note availability: "Do you have about 25 minutes to complete the survey?"
	label define availability 1 "Yes" 0 "No"
	label values availability availability

	label variable time_start "Time of phone call"
	note time_start: "Time of phone call"

	label variable id1a "id1. What is your First Name?"
	note id1a: "id1. What is your First Name?"

	label variable id1b "id1. What is your surname?"
	note id1b: "id1. What is your surname?"

	label variable id2 "id2. What is your age?"
	note id2: "id2. What is your age?"

	label variable id2a "id2a. What is your gender?"
	note id2a: "id2a. What is your gender?"
	label define id2a 1 "Male" 2 "Female"
	label values id2a id2a

	label variable id2_check "WARNING:You have entered that the respondent is over 40. This is older than expe"
	note id2_check: "WARNING:You have entered that the respondent is over 40. This is older than expected Please confirm that this is correct, if it is confirm that this is indeed the correct respondent or go back and correct the age. Please select 'Yes' to confirm."
	label define id2_check 1 "yes"
	label values id2_check id2_check

	label variable id2_check_dk "WARNING:You have entered that the respondent does not know their own age. Please"
	note id2_check_dk: "WARNING:You have entered that the respondent does not know their own age. Please verify if they are at least 18 years old or above before you continue with the interview. If you are able to verify that they are 18 and above select yes and continue with the interview. Otherwise, go back to consent and select no. Please leave a comment on submission that the respondents age could not be verified to be above 18."
	label define id2_check_dk 1 "yes"
	label values id2_check_dk id2_check_dk

	label variable id3 "id3. What region were you born in?"
	note id3: "id3. What region were you born in?"
	label define id3 1 "Banjul City Council" 2 "Kanifing Municipal Council" 3 "West Coast Region" 4 "North Bank Region" 5 "Lower River Region" 6 "Central River Region" 7 "Upper River Region" 8 "Outside of Gambia" -98 "Don't know"
	label values id3 id3

	label variable id3a "id3a. What region are you currently resident in?"
	note id3a: "id3a. What region are you currently resident in?"
	label define id3a 1 "Banjul City Council" 2 "Kanifing Municipal Council" 3 "West Coast Region" 4 "North Bank Region" 5 "Lower River Region" 6 "Central River Region" 7 "Upper River Region" 8 "Outside of Gambia" -98 "Don't know"
	label values id3a id3a

	label variable id5 "id5. What is your religion"
	note id5: "id5. What is your religion"
	label define id5 1 "Muslim" 2 "Christian" -96 "Others"
	label values id5 id5

	label variable id5_other "Please specify other"
	note id5_other: "Please specify other"

	label variable a1a "a1a. I'd like you to think back to March 2020. What is the highest level of scho"
	note a1a: "a1a. I'd like you to think back to March 2020. What is the highest level of schooling you had completed then?"
	label define a1a 1 "None" 2 "Pre-school" 3 "Arabic (Informal)" 4 "Primary / Madrassa" 5 "Junior Secondary" 6 "Senior Secondary" 7 "Tertiary/Vocational Education" 8 "Higher Education/Degree"
	label values a1a a1a

	label variable a1b "a1b. And currently, what is the highest level of schooling you have completed?"
	note a1b: "a1b. And currently, what is the highest level of schooling you have completed?"
	label define a1b 1 "None" 2 "Pre-school" 3 "Arabic (Informal)" 4 "Primary / Madrassa" 5 "Junior Secondary" 6 "Senior Secondary" 7 "Tertiary/Vocational Education" 8 "Higher Education/Degree"
	label values a1b a1b

	label variable a2 "a2. What is your current marital status?"
	note a2: "a2. What is your current marital status?"
	label define a2 1 "Monogamous married" 2 "Polygamous married" 3 "Separated/Divorced" 5 "Widowed" 6 "Single / never married"
	label values a2 a2

	label variable d1 "d1. During the last 4 weeks, have you tried in any way to find a job working for"
	note d1: "d1. During the last 4 weeks, have you tried in any way to find a job working for someone else or start your own business?"
	label define d1 0 "No" 1 "Yes, for job" 2 "Yes, to start a business" 3 "Yes, both a job and start a business"
	label values d1 d1

	label variable d2 "d2. What are the reasons you did not look for a job working for someone else in "
	note d2: "d2. What are the reasons you did not look for a job working for someone else in the last 4 weeks?"

	label variable d2_other "Please specify other"
	note d2_other: "Please specify other"

	label variable d12 "d12. What is/are the reason/s you have not tried to start your own business in t"
	note d12: "d12. What is/are the reason/s you have not tried to start your own business in the last4 weeks?"

	label variable d12_other "Please specify other"
	note d12_other: "Please specify other"

	label variable dlabels "In the past 4 weeks did you…."
	note dlabels: "In the past 4 weeks did you…."
	label define dlabels 0 "No" 1 "Yes"
	label values dlabels dlabels

	label variable d3a "d3a. read classified ads in newspapers, journals or professional magazines."
	note d3a: "d3a. read classified ads in newspapers, journals or professional magazines."
	label define d3a 0 "No" 1 "Yes"
	label values d3a d3a

	label variable d3b "d3b. prepare/ revise your CV?"
	note d3b: "d3b. prepare/ revise your CV?"
	label define d3b 0 "No" 1 "Yes"
	label values d3b d3b

	label variable d3d "d3d. talk to friends or relatives about possible job leads?"
	note d3d: "d3d. talk to friends or relatives about possible job leads?"
	label define d3d 0 "No" 1 "Yes"
	label values d3d d3d

	label variable d3e "d3e. speak with previous employers or business acquaintances about possible job "
	note d3e: "d3e. speak with previous employers or business acquaintances about possible job leads?"
	label define d3e 0 "No" 1 "Yes"
	label values d3e d3e

	label variable d3f "d3f. use the internet/listened to the radio/searched on social media to locate j"
	note d3f: "d3f. use the internet/listened to the radio/searched on social media to locate job openings?"
	label define d3f 0 "No" 1 "Yes"
	label values d3f d3f

	label variable d4b "d4b. send your CV to potential employers?"
	note d4b: "d4b. send your CV to potential employers?"
	label define d4b 0 "No" 1 "Yes"
	label values d4b d4b

	label variable d4c "d4c. fill out a job application?"
	note d4c: "d4c. fill out a job application?"
	label define d4c 0 "No" 1 "Yes"
	label values d4c d4c

	label variable d4d "d4d. have an interview with a prospective employer?"
	note d4d: "d4d. have an interview with a prospective employer?"
	label define d4d 0 "No" 1 "Yes"
	label values d4d d4d

	label variable d4f "d4f. Telephone or email a prospective employer?"
	note d4f: "d4f. Telephone or email a prospective employer?"
	label define d4f 0 "No" 1 "Yes"
	label values d4f d4f

	label variable dlabels2 "."
	note dlabels2: "."
	label define dlabels2 0 "No" 1 "Yes"
	label values dlabels2 dlabels2

	label variable d5a "d5b. Within your district / municipality?"
	note d5a: "d5b. Within your district / municipality?"
	label define d5a 0 "No" 1 "Yes"
	label values d5a d5a

	label variable d5b "d5b. Outside of your district / municipality but within the Gambia?"
	note d5b: "d5b. Outside of your district / municipality but within the Gambia?"
	label define d5b 0 "No" 1 "Yes"
	label values d5b d5b

	label variable d5e "d5e. Abroad?"
	note d5e: "d5e. Abroad?"
	label define d5e 0 "No" 1 "Yes"
	label values d5e d5e

	label variable d7 "d7. What do you think are the challenges to finding and obtaining jobs that you "
	note d7: "d7. What do you think are the challenges to finding and obtaining jobs that you would be interested in in your local area?"

	label variable d7_other "Please specify other"
	note d7_other: "Please specify other"

	label variable d8 "d8. At any point since \${reference_month_str}\${reference_year_str} have you ha"
	note d8: "d8. At any point since \${reference_month_str}\${reference_year_str} have you had any job offers?"
	label define d8 0 "No" 1 "Yes"
	label values d8 d8

	label variable b1a "b1a. In the last 7 days, did you do any work, even for just one hour?"
	note b1a: "b1a. In the last 7 days, did you do any work, even for just one hour?"

	label variable b1b "b1b. Do you have a *paid* permanent/long term job (eventhough you did not work i"
	note b1b: "b1b. Do you have a *paid* permanent/long term job (eventhough you did not work in the last 7 days) from which you were temporarily absent?"
	label define b1b 0 "No" 1 "Yes"
	label values b1b b1b

	label variable b1c "b1c. What is the main reason that you did not work in the last 7 days although y"
	note b1c: "b1c. What is the main reason that you did not work in the last 7 days although you have a permanent job?"
	label define b1c 1 "Paid leave" 2 "Unpaid leave" 3 "Own illnes" 4 "Maternity leave" 5 "Care of household member" 6 "Holidays" 7 "Strike/Suspension" 8 "Temporary workload reduction" 9 "Closure" 10 "Bad weather" 11 "School/Education/Training" -96 "Other (Specify)"
	label values b1c b1c

	label variable b1c_other "b1c_other. Please specify other"
	note b1c_other: "b1c_other. Please specify other"

	label variable b1 "b1. At any point since \${reference_month_str}\${reference_year_str} have you wo"
	note b1: "b1. At any point since \${reference_month_str}\${reference_year_str} have you worked, or are currently working for, a job that you have had for at least one month or longer?"
	label define b1 0 "No" 1 "Yes"
	label values b1 b1

	label variable b2 "b2. How many jobs (including self-employed work) have you had, or still have sin"
	note b2: "b2. How many jobs (including self-employed work) have you had, or still have since \${reference_month_str}\${reference_year_str} for one month or longer?"

	label variable b31a "b31a. Since \${reference_month_str}\${reference_year_str} have you had any other"
	note b31a: "b31a. Since \${reference_month_str}\${reference_year_str} have you had any other jobs?"
	label define b31a 0 "No" 1 "Yes"
	label values b31a b31a

	label variable b31b "b31c. How many other jobs did you have since \${reference_month_str}\${reference"
	note b31b: "b31c. How many other jobs did you have since \${reference_month_str}\${reference_year_str}"

	label variable b31c "b31b. Was any of the other job/s since \${reference_month_str}\${reference_year_"
	note b31c: "b31b. Was any of the other job/s since \${reference_month_str}\${reference_year_str} related to the following trades?"

	label variable b32 "b32. In the last 7 days, did you do any work even for just one hour?"
	note b32: "b32. In the last 7 days, did you do any work even for just one hour?"
	label define b32 0 "No" 1 "Yes"
	label values b32 b32

	label variable b33 "b33.Was this work in the past 7 days in any of the jobs we've already discussed?"
	note b33: "b33.Was this work in the past 7 days in any of the jobs we've already discussed?"

	label variable b32_job_name "b32_job. What is the name of this job?"
	note b32_job_name: "b32_job. What is the name of this job?"

	label variable b34 "b6. What was your working status?"
	note b34: "b6. What was your working status?"
	label define b34 1 "Regular employee (of someone who is not a member of your household)" 2 "Regular family worker (of someone who is a member of your household)" 3 "Self-employed (works on his/her own account or employer)" 4 "Apprentice" 5 "Casual or By Day worker (works upon demand and according to needs of the employe" -96 "Other"
	label values b34 b34

	label variable isic_1_seven "isic_1. Please ask the respondent to describe the work they did and select the m"
	note isic_1_seven: "isic_1. Please ask the respondent to describe the work they did and select the most appropriate industry (ISIC Classification 1)"
	label define isic_1_seven 1 "Agriculture, forestry and fishing" 2 "Mining and quarrying" 3 "Manufacturing" 4 "Electricity, gas, steam and air conditioning supply" 5 "Water supply; sewerage, waste management and remediation activities" 6 "Construction" 7 "Wholesale and retail trade; repair of motor vehicles and motorcycles" 8 "Transportation and storage" 9 "Accommodation and food service activities" 10 "Information and communication" 11 "Financial and insurance activities" 12 "Real estate activities" 13 "Professional, scientific and technical activities" 14 "Administrative and support service activities" 15 "Public administration and defence; compulsory social security" 16 "Education" 17 "Human health and social work activities" 18 "Arts, entertainment and recreation" 19 "Other service activities" 20 "Activities of households as employers; undifferentiated goods- and services-prod" 21 "Activities of extraterritorial organizations and bodies"
	label values isic_1_seven isic_1_seven

	label variable isic_2_seven "isic_2. Please ask the respondent to describe the work they did and select the m"
	note isic_2_seven: "isic_2. Please ask the respondent to describe the work they did and select the most appropriate industry (ISIC Classification 2)"
	label define isic_2_seven 101 "Crop and animal production, hunting and related service activities" 102 "Forestry and logging" 103 "Fishing and aquaculture" 205 "Mining of coal and lignite" 206 "Extraction of crude petroleum and natural gas" 207 "Mining of metal ores" 208 "Other mining and quarrying" 209 "Mining support service activities" 310 "Manufacture of food products" 311 "Manufacture of beverages" 312 "Manufacture of tobacco products" 313 "Manufacture of textiles" 314 "Manufacture of wearing apparel" 315 "Manufacture of leather and related products" 316 "Manufacture of wood and of products of wood and cork, except furniture; manufact" 317 "Manufacture of paper and paper products" 318 "Printing and reproduction of recorded media" 319 "Manufacture of coke and refined petroleum products" 320 "Manufacture of chemicals and chemical products" 321 "Manufacture of basic pharmaceutical products and pharmaceutical preparations" 322 "Manufacture of rubber and plastics products" 323 "Manufacture of other non-metallic mineral products" 324 "Manufacture of basic metals" 325 "Manufacture of fabricated metal products, except machinery and equipment" 326 "Manufacture of computer, electronic and optical products" 327 "Manufacture of electrical equipment" 328 "Manufacture of machinery and equipment n.e.c." 329 "Manufacture of motor vehicles, trailers and semi-trailers" 330 "Manufacture of other transport equipment" 331 "Manufacture of furniture" 332 "Other manufacturing" 333 "Repair and installation of machinery and equipment" 435 "Electricity, gas, steam and air conditioning supply" 536 "Water collection, treatment and supply" 537 "Sewerage" 538 "Waste collection, treatment and disposal activities; materials recovery" 539 "Remediation activities and other waste management services" 641 "Construction of buildings" 642 "Civil engineering" 643 "Specialized construction activities" 745 "Wholesale and retail trade and repair of motor vehicles and motorcycles" 746 "Wholesale trade, except of motor vehicles and motorcycles" 747 "Retail trade, except of motor vehicles and motorcycles" 849 "Land transport and transport via pipelines" 850 "Water transport" 851 "Air transport" 852 "Warehousing and support activities for transportation" 853 "Postal and courier activities" 955 "Accommodation" 956 "Food and beverage service activities" 1058 "Publishing activities" 1059 "Motion picture, video and television programme production, sound recording and m" 1060 "Programming and broadcasting activities" 1061 "Telecommunications" 1062 "Computer programming, consultancy and related activities" 1063 "Information service activities" 1164 "Financial service activities, except insurance and pension funding" 1165 "Insurance, reinsurance and pension funding, except compulsory social security" 1166 "Activities auxiliary to financial service and insurance activities" 1268 "Real estate activities" 1369 "Legal and accounting activities" 1370 "Activities of head offices; management consultancy activities" 1371 "Architectural and engineering activities; technical testing and analysis" 1372 "Scientific research and development" 1373 "Advertising and market research" 1374 "Other professional, scientific and technical activities" 1375 "Veterinary activities" 1477 "Rental and leasing activities" 1478 "Employment activities" 1479 "Travel agency, tour operator, reservation service and related activities" 1480 "Security and investigation activities" 1481 "Services to buildings and landscape activities" 1482 "Office administrative, office support and other business support activities" 1584 "Public administration and defence; compulsory social security" 1685 "Education" 1786 "Human health activities" 1787 "Residential care activities" 1788 "Social work activities without accommodation" 1890 "Creative, arts and entertainment activities" 1891 "Libraries, archives, museums and other cultural activities" 1892 "Gambling and betting activities" 1893 "Sports activities and amusement and recreation activities" 1994 "Activities of membership organizations" 1995 "Repair of computers and personal and household goods" 1996 "Other personal service activities" 2097 "Activities of households as employers of domestic personnel" 2098 "Undifferentiated goods- and services-producing activities of private households " 2199 "Activities of extraterritorial organizations and bodies"
	label values isic_2_seven isic_2_seven

	label variable c1_normal "c1_normal. Taking all your acitivities into account how much do you make in a no"
	note c1_normal: "c1_normal. Taking all your acitivities into account how much do you make in a normal month?"

	label variable c1 "c1. Taking all your professional activities into account, does your income vary "
	note c1: "c1. Taking all your professional activities into account, does your income vary across the year?"
	label define c1 0 "No" 1 "Yes"
	label values c1 c1

	label variable c3 "c3. What months do you consider to be the bad?"
	note c3: "c3. What months do you consider to be the bad?"

	label variable c2 "c2. Taking all your professional activities into account (not including remittan"
	note c2: "c2. Taking all your professional activities into account (not including remittances or household transfers), how much do you make in the bad months?"

	label variable c5 "c5. What months do you consider to be good?"
	note c5: "c5. What months do you consider to be good?"

	label variable c4 "c4. Taking all your activities into account, how much do you make in the good mo"
	note c4: "c4. Taking all your activities into account, how much do you make in the good months?"

	label variable c1_normal_month "c3. Can you confirm that the remaining months are normal?"
	note c1_normal_month: "c3. Can you confirm that the remaining months are normal?"

	label variable e0 "e0. I regard my training(s) and education as a top priority"
	note e0: "e0. I regard my training(s) and education as a top priority"
	label define e0 1 "Strongly disagree" 2 "Disagree" 3 "Neither agree nor disagree" 4 "Agree" 5 "Strongly agree"
	label values e0 e0

	label variable e1 "e1. My training/educational background is a significant asset to me in job seeki"
	note e1: "e1. My training/educational background is a significant asset to me in job seeking"
	label define e1 1 "Strongly disagree" 2 "Disagree" 3 "Neither agree nor disagree" 4 "Agree" 5 "Strongly agree"
	label values e1 e1

	label variable e2 "e2. Employers specifically target individuals with my educational/training backg"
	note e2: "e2. Employers specifically target individuals with my educational/training background in order to recruit individuals from my economic sector(s)"
	label define e2 1 "Strongly disagree" 2 "Disagree" 3 "Neither agree nor disagree" 4 "Agree" 5 "Strongly agree"
	label values e2 e2

	label variable e3 "e3. There is a lot of competition for places on training courses I want to atten"
	note e3: "e3. There is a lot of competition for places on training courses I want to attend and many people are not able to enrol"
	label define e3 1 "Strongly disagree" 2 "Disagree" 3 "Neither agree nor disagree" 4 "Agree" 5 "Strongly agree"
	label values e3 e3

	label variable e4 "e4. People in the career I am aiming for are in high demand in the labour market"
	note e4: "e4. People in the career I am aiming for are in high demand in the labour market"
	label define e4 1 "Strongly disagree" 2 "Disagree" 3 "Neither agree nor disagree" 4 "Agree" 5 "Strongly agree"
	label values e4 e4

	label variable e5 "e5. My educational/training background is seen as leading to a specific career t"
	note e5: "e5. My educational/training background is seen as leading to a specific career that others would perceived as highly desirable"
	label define e5 1 "Strongly disagree" 2 "Disagree" 3 "Neither agree nor disagree" 4 "Agree" 5 "Strongly agree"
	label values e5 e5

	label variable e6 "e6. There are plenty of job vacancies in my target geographic area."
	note e6: "e6. There are plenty of job vacancies in my target geographic area."
	label define e6 1 "Strongly disagree" 2 "Disagree" 3 "Neither agree nor disagree" 4 "Agree" 5 "Strongly agree"
	label values e6 e6

	label variable e7 "e7. I can easily find out about opportunities in my chosen field"
	note e7: "e7. I can easily find out about opportunities in my chosen field"
	label define e7 1 "Strongly disagree" 2 "Disagree" 3 "Neither agree nor disagree" 4 "Agree" 5 "Strongly agree"
	label values e7 e7

	label variable e8 "e8. The skills and abilities that I possess are what employers are looking for"
	note e8: "e8. The skills and abilities that I possess are what employers are looking for"
	label define e8 1 "Strongly disagree" 2 "Disagree" 3 "Neither agree nor disagree" 4 "Agree" 5 "Strongly agree"
	label values e8 e8

	label variable e9 "e9. I am generally confident of success in job Interviews and selection events"
	note e9: "e9. I am generally confident of success in job Interviews and selection events"
	label define e9 1 "Strongly disagree" 2 "Disagree" 3 "Neither agree nor disagree" 4 "Agree" 5 "Strongly agree"
	label values e9 e9

	label variable e10 "e10. I feel I could get any job as long as my skills and experience are reasonab"
	note e10: "e10. I feel I could get any job as long as my skills and experience are reasonably relevant"
	label define e10 1 "Strongly disagree" 2 "Disagree" 3 "Neither agree nor disagree" 4 "Agree" 5 "Strongly agree"
	label values e10 e10

	label variable g6 "g6. When you were younger or in the past few years, were you involved in organis"
	note g6: "g6. When you were younger or in the past few years, were you involved in organising social projects. Examples include community or voluntary organisations or sports teams."
	label define g6 0 "No" 1 "Yes"
	label values g6 g6

	label variable g7 "g7. When you were in school, did you ever candidate for class prefect/other repr"
	note g7: "g7. When you were in school, did you ever candidate for class prefect/other representative?"
	label define g7 0 "No" 1 "Yes"
	label values g7 g7

	label variable g8 "g8. When you were younger, did you regularly organize events with the family or "
	note g8: "g8. When you were younger, did you regularly organize events with the family or friends?"
	label define g8 0 "No" 1 "Yes"
	label values g8 g8

	label variable g10 "g10. When you were younger, did you ever try to open a business?"
	note g10: "g10. When you were younger, did you ever try to open a business?"
	label define g10 0 "No" 1 "Yes"
	label values g10 g10

	label variable h2 "h2. Do you keep written financial records?"
	note h2: "h2. Do you keep written financial records?"
	label define h2 0 "No" 1 "Simple notes" 2 "Detailed notes"
	label values h2 h2

	label variable h4 "h4. Do you have a clear and concrete professional goal for next year (sales, pro"
	note h4: "h4. Do you have a clear and concrete professional goal for next year (sales, profits, starting a new business or finding a job, obtain a payrise)?"
	label define h4 0 "No" 1 "Yes"
	label values h4 h4

	label variable h5 "h5. Do you anticipate investments to be done in the coming year?"
	note h5: "h5. Do you anticipate investments to be done in the coming year?"
	label define h5 0 "No" 1 "Yes"
	label values h5 h5

	label variable h6 "h6. How often do you check to see whether you have achieved your targets or not?"
	note h6: "h6. How often do you check to see whether you have achieved your targets or not?"
	label define h6 0 "Never" 1 "once a year or less" 2 "Several times a year" 3 "monthly or more often"
	label values h6 h6

	label variable h1 "h1. Do you seperate professional and personal cash?"
	note h1: "h1. Do you seperate professional and personal cash?"
	label define h1 0 "No" 1 "Yes"
	label values h1 h1

	label variable h7 "h7. In the last 6 months, have you visited a competitor's business to compare pr"
	note h7: "h7. In the last 6 months, have you visited a competitor's business to compare prices and products sold?"
	label define h7 0 "No" 1 "Yes"
	label values h7 h7

	label variable h8 "h8. In the last 6 months, have you adapted your business offers according to you"
	note h8: "h8. In the last 6 months, have you adapted your business offers according to your competitors?"
	label define h8 0 "No" 1 "Yes"
	label values h8 h8

	label variable h9 "h9. In the last 6 months, have you discussed with a client to understand how you"
	note h9: "h9. In the last 6 months, have you discussed with a client to understand how you could answer his needs?"
	label define h9 0 "No" 1 "Yes"
	label values h9 h9

	label variable h10 "h10. In the last 6 months, have you asked a supplier about which products are se"
	note h10: "h10. In the last 6 months, have you asked a supplier about which products are selling well?"
	label define h10 0 "No" 1 "Yes"
	label values h10 h10

	label variable h11 "h11. In the last 6 months, have you advertised in any form?"
	note h11: "h11. In the last 6 months, have you advertised in any form?"
	label define h11 0 "No" 1 "Yes"
	label values h11 h11

	label variable h12 "h12. Do you know which goods/services you make the most profit per item selling?"
	note h12: "h12. Do you know which goods/services you make the most profit per item selling?"
	label define h12 0 "No" 1 "Yes"
	label values h12 h12

	label variable h13 "h13. Do you use records to analyse sales and profits of a particular product or "
	note h13: "h13. Do you use records to analyse sales and profits of a particular product or of the activity?"
	label define h13 0 "Never" 1 "once a year or less" 2 "Several times a year" 3 "monthly or more often"
	label values h13 h13

	label variable i1 "i1. I tend to bounce back quickly after hard times"
	note i1: "i1. I tend to bounce back quickly after hard times"
	label define i1 1 "Strongly disagree" 2 "Disagree" 3 "Neither agree nor disagree" 4 "Agree" 5 "Strongly agree"
	label values i1 i1

	label variable i2 "i2. I have a hard time making it through stressful events."
	note i2: "i2. I have a hard time making it through stressful events."
	label define i2 1 "Strongly disagree" 2 "Disagree" 3 "Neither agree nor disagree" 4 "Agree" 5 "Strongly agree"
	label values i2 i2

	label variable i3 "i3. It does not take me long to recover from a stressful event."
	note i3: "i3. It does not take me long to recover from a stressful event."
	label define i3 1 "Strongly disagree" 2 "Disagree" 3 "Neither agree nor disagree" 4 "Agree" 5 "Strongly agree"
	label values i3 i3

	label variable i4 "i4. It is hard for me to react positively when something bad happens"
	note i4: "i4. It is hard for me to react positively when something bad happens"
	label define i4 1 "Strongly disagree" 2 "Disagree" 3 "Neither agree nor disagree" 4 "Agree" 5 "Strongly agree"
	label values i4 i4

	label variable i5 "i5. I usually come through difficult times with little trouble."
	note i5: "i5. I usually come through difficult times with little trouble."
	label define i5 1 "Strongly disagree" 2 "Disagree" 3 "Neither agree nor disagree" 4 "Agree" 5 "Strongly agree"
	label values i5 i5

	label variable i6 "i6. I tend to take a long time to get over set-backs in my life."
	note i6: "i6. I tend to take a long time to get over set-backs in my life."
	label define i6 1 "Strongly disagree" 2 "Disagree" 3 "Neither agree nor disagree" 4 "Agree" 5 "Strongly agree"
	label values i6 i6

	label variable j1a "j1a. Have you attended a vocational or technical training course since January 2"
	note j1a: "j1a. Have you attended a vocational or technical training course since January 2020?"
	label define j1a 0 "No" 1 "Yes"
	label values j1a j1a

	label variable j1b "j1b. Have you attended another vocational or technical training course since \${"
	note j1b: "j1b. Have you attended another vocational or technical training course since \${reference_month_str}\${reference_year_str} (other than the Tekki Fii programme)?"
	label define j1b 0 "No" 1 "Yes"
	label values j1b j1b

	label variable j3 "j3. Was the training you attended formal or non-formal training?"
	note j3: "j3. Was the training you attended formal or non-formal training?"
	label define j3 1 "Formal" 2 "Non-formal"
	label values j3 j3

	label variable j4 "j4. What type of training have you attended?"
	note j4: "j4. What type of training have you attended?"
	label define j4 1 "Accountancy" 2 "Mechanical Engineering" 3 "Nursing" 4 "Teaching" 5 "Carpentry" 6 "Electrical Installation" 7 "Welding" 8 "Entrepreneurship" 9 "Plumbing" 10 "Masonry" 11 "Motor Mechanics" 12 "Electrical Engineering" 13 "Electricians" 14 "Block-laying and concreting" 15 "Tiling and Plastering" 16 "Welding and farm tool repair" 17 "Small engine repair" 18 "Solar PV installation" 19 "Garment making" 20 "Hairdressing and beauty therapy" 21 "Animal husbandry" -96 "Other (Specify)"
	label values j4 j4

	label variable j4_other "Please specify other"
	note j4_other: "Please specify other"

	label variable j5 "j5. Did you complete the training, is it still on-going or did you drop out?"
	note j5: "j5. Did you complete the training, is it still on-going or did you drop out?"
	label define j5 1 "Completed" 2 "Ongoing" 3 "Dropped out"
	label values j5 j5

	label variable j6 "j6. How many months \${doesdid} the training take to complete?"
	note j6: "j6. How many months \${doesdid} the training take to complete?"

	label variable j6_check "WARNING:You have entered that the length of the training is \${j6} months. This "
	note j6_check: "WARNING:You have entered that the length of the training is \${j6} months. This seem very high Please confirm Please select 'Yes' to confirm"
	label define j6_check 0 "No" 1 "Yes"
	label values j6_check j6_check

	label variable j7 "k19. Since completion of your training, have you done any internship?"
	note j7: "k19. Since completion of your training, have you done any internship?"
	label define j7 0 "No" 1 "Yes"
	label values j7 j7

	label variable j8 "k20. Were you paid in this internship?"
	note j8: "k20. Were you paid in this internship?"
	label define j8 0 "No" 1 "Yes"
	label values j8 j8

	label variable tekki_institute "Can you confirm you attended the Tekki Fii Programme at this institute \${instit"
	note tekki_institute: "Can you confirm you attended the Tekki Fii Programme at this institute \${institute}"
	label define tekki_institute 0 "No" 1 "Yes"
	label values tekki_institute tekki_institute

	label variable tekki_course "Can you confirm you attended the Tekki Fii Programme in this course \${course}"
	note tekki_course: "Can you confirm you attended the Tekki Fii Programme in this course \${course}"
	label define tekki_course 0 "No" 1 "Yes"
	label values tekki_course tekki_course

	label variable tekkifii_complete "Did you complete the training under the training in/at \${confirmed_attended}"
	note tekkifii_complete: "Did you complete the training under the training in/at \${confirmed_attended}"
	label define tekkifii_complete 0 "No" 1 "Yes"
	label values tekkifii_complete tekkifii_complete

	label variable tekkifii_dropout "Why did you not complete the training in/at \${confirmed_attended}?"
	note tekkifii_dropout: "Why did you not complete the training in/at \${confirmed_attended}?"

	label variable tekki_institute_applied "Did you ever apply to the Tekki Fii training Programme at this institute \${inst"
	note tekki_institute_applied: "Did you ever apply to the Tekki Fii training Programme at this institute \${institute} in this course \${course} ?"
	label define tekki_institute_applied 0 "No" 1 "Yes"
	label values tekki_institute_applied tekki_institute_applied

	label variable tekkifii_outcome "What was the outcome of your application to in/at \${confirmed_applied}?"
	note tekkifii_outcome: "What was the outcome of your application to in/at \${confirmed_applied}?"
	label define tekkifii_outcome 1 "Successful" 0 "Unsuccessful" -99 "Don't know"
	label values tekkifii_outcome tekkifii_outcome

	label variable tekkifii_absent_succ "What was the reason why you did not participate in the training in/at \${confirm"
	note tekkifii_absent_succ: "What was the reason why you did not participate in the training in/at \${confirmed_applied}?"

	label variable tekkifii_absent_unsucc "Why do you think your application was unsuccessful?"
	note tekkifii_absent_unsucc: "Why do you think your application was unsuccessful?"

	label variable k1 "k1. Teaching methods of teachers in the classroom"
	note k1: "k1. Teaching methods of teachers in the classroom"
	label define k1 1 "Very Bad" 2 "Bad" 3 "Average" 4 "Good" 5 "Excellent"
	label values k1 k1

	label variable k2 "k2. Teachers’ ability to handle training equipments and to instruct students whe"
	note k2: "k2. Teachers’ ability to handle training equipments and to instruct students when working with equipments"
	label define k2 1 "Very Bad" 2 "Bad" 3 "Average" 4 "Good" 5 "Excellent"
	label values k2 k2

	label variable k4 "k4. Teachers’ ability to engage students in the activities and motivate them"
	note k4: "k4. Teachers’ ability to engage students in the activities and motivate them"
	label define k4 1 "Very Bad" 2 "Bad" 3 "Average" 4 "Good" 5 "Excellent"
	label values k4 k4

	label variable k5 "k5. How would you assess the quality of the TVET facilities in the Training Cent"
	note k5: "k5. How would you assess the quality of the TVET facilities in the Training Centre?"
	label define k5 1 "Very Bad" 2 "Bad" 3 "Average" 4 "Good" 5 "Excellent"
	label values k5 k5

	label variable k6 "k6. Acquiring required skills needed at the work place"
	note k6: "k6. Acquiring required skills needed at the work place"
	label define k6 1 "Very Bad" 2 "Bad" 3 "Average" 4 "Good" 5 "Excellent"
	label values k6 k6

	label variable k8 "k8. Improving your team work skills"
	note k8: "k8. Improving your team work skills"
	label define k8 1 "Very Bad" 2 "Bad" 3 "Average" 4 "Good" 5 "Excellent"
	label values k8 k8

	label variable k9 "k9. Improving your ability to work independently"
	note k9: "k9. Improving your ability to work independently"
	label define k9 1 "Very Bad" 2 "Bad" 3 "Average" 4 "Good" 5 "Excellent"
	label values k9 k9

	label variable k10 "k10. Improving your ability to express yourself"
	note k10: "k10. Improving your ability to express yourself"
	label define k10 1 "Very Bad" 2 "Bad" 3 "Average" 4 "Good" 5 "Excellent"
	label values k10 k10

	label variable k11 "k11. Did you ever miss a teaching day of the Tekki Fii programme?"
	note k11: "k11. Did you ever miss a teaching day of the Tekki Fii programme?"
	label define k11 0 "No" 1 "Yes"
	label values k11 k11

	label variable k12 "k12. What were the reasons why you missed teaching day(s) for the Tekki Fii prog"
	note k12: "k12. What were the reasons why you missed teaching day(s) for the Tekki Fii programme? You can provide more than one."

	label variable k12_other "Please specify other"
	note k12_other: "Please specify other"

	label variable tekkifii_check_ind "Can you confirm you attended the Industrial Placement in the Tekki Fii Programme"
	note tekkifii_check_ind: "Can you confirm you attended the Industrial Placement in the Tekki Fii Programme"
	label define tekkifii_check_ind 0 "No" 1 "Yes"
	label values tekkifii_check_ind tekkifii_check_ind

	label variable tekkifii_check_ind_why "What was the reason you never took part in the Industrial Placement in the Tekki"
	note tekkifii_check_ind_why: "What was the reason you never took part in the Industrial Placement in the Tekki Fii programme?"

	label variable k13 "k13. Did you ever miss a working day of the industrial placement?"
	note k13: "k13. Did you ever miss a working day of the industrial placement?"
	label define k13 0 "No" 1 "Yes"
	label values k13 k13

	label variable k14 "k14. What were the reasons why you missed working day(s) for the industrial plac"
	note k14: "k14. What were the reasons why you missed working day(s) for the industrial placement? You can provide more than one."

	label variable k14_other "Please specify other"
	note k14_other: "Please specify other"

	label variable k15 "k15. Putting into practice the trade and skills you studied during the Tekki Fii"
	note k15: "k15. Putting into practice the trade and skills you studied during the Tekki Fii training"
	label define k15 1 "Very Bad" 2 "Bad" 3 "Average" 4 "Good" 5 "Excellent"
	label values k15 k15

	label variable k16 "k16. Providing useful work experience for your career development"
	note k16: "k16. Providing useful work experience for your career development"
	label define k16 1 "Very Bad" 2 "Bad" 3 "Average" 4 "Good" 5 "Excellent"
	label values k16 k16

	label variable k17 "k17. Were you ever offered a job at the company the provided an industrial place"
	note k17: "k17. Were you ever offered a job at the company the provided an industrial placement?"
	label define k17 0 "No" 1 "Yes - I accepted" 2 "Yes - I rejected"
	label values k17 k17

	label variable k18 "k18.Did you take part in the business development training component of Tekki Fi"
	note k18: "k18.Did you take part in the business development training component of Tekki Fii?"
	label define k18 0 "No" 1 "Yes"
	label values k18 k18

	label variable cc1 "What is your father's employment status?"
	note cc1: "What is your father's employment status?"
	label define cc1 -98 "Passed Away" 1 "Employed" 2 "Partially Employed" 3 "Unemployed (Looking for a job)" 4 "Inactive (Not looking for a job)" 5 "Self-employed" 6 "Retired" -99 "Don't know"
	label values cc1 cc1

	label variable cc2 "What is/was your father's education level?"
	note cc2: "What is/was your father's education level?"
	label define cc2 1 "Primary" 2 "Junior Secondary" 3 "Senior Secondary" 4 "Madrasse (Arabic School)" 5 "Tertiary Level" 6 "No formal education" -99 "Don't know"
	label values cc2 cc2

	label variable cc3 "What is your mother's employment status?"
	note cc3: "What is your mother's employment status?"
	label define cc3 -98 "Passed Away" 1 "Employed" 2 "Partially Employed" 3 "Unemployed (Looking for a job)" 4 "Inactive (Not looking for a job)" 5 "Self-employed" 6 "Retired" -99 "Don't know"
	label values cc3 cc3

	label variable cc4 "What is/was your mother's education level?"
	note cc4: "What is/was your mother's education level?"
	label define cc4 1 "Primary" 2 "Junior Secondary" 3 "Senior Secondary" 4 "Madrasse (Arabic School)" 5 "Tertiary Level" 6 "No formal education" -99 "Don't know"
	label values cc4 cc4

	label variable cc5 "What is an estimate of your parent' average monthly earnings in the last year?"
	note cc5: "What is an estimate of your parent' average monthly earnings in the last year?"

	label variable cc6 "I'd like you to think back to January 2020 at that point what was your employmen"
	note cc6: "I'd like you to think back to January 2020 at that point what was your employment status?"
	label define cc6 1 "Looking for Education / training opportunities" 2 "Unemployed and looking for a job" 3 "Working" 4 "In Education/Training (excluding Secondary School)" 5 "Inactive"
	label values cc6 cc6

	label variable cc7 "Did you ever move to another country or Are you a returnee to The Gambia? I.e. r"
	note cc7: "Did you ever move to another country or Are you a returnee to The Gambia? I.e. returned to The Gambia after travelling abroad for economic opportunities?"
	label define cc7 0 "No" 1 "Yes"
	label values cc7 cc7

	label variable cc8 "When did you return to The Gambia?"
	note cc8: "When did you return to The Gambia?"

	label variable l7 "l7. Do you have an email address you can provide us with?"
	note l7: "l7. Do you have an email address you can provide us with?"
	label define l7 0 "No" 1 "Yes"
	label values l7 l7

	label variable l10 "l8. What is your email address?"
	note l10: "l8. What is your email address?"

	label variable l9 "l9. What is the name of the community you currently live in"
	note l9: "l9. What is the name of the community you currently live in"

	label variable l8 "l8. What region is the community located in?"
	note l8: "l8. What region is the community located in?"
	label define l8 1 "Banjul City Council" 2 "Kanifing Municipal Council" 3 "West Coast Region" 4 "North Bank Region" 5 "Lower River Region" 6 "Central River Region" 7 "Upper River Region" 8 "Outside of Gambia" -98 "Don't know"
	label values l8 l8

	label variable l1 "l1. Is this the best phone number to contact you on?"
	note l1: "l1. Is this the best phone number to contact you on?"
	label define l1 0 "No" 1 "Yes"
	label values l1 l1

	label variable l1_w "l1_w. Do you use whatsapp, telegram or signal chat applications on this phone?"
	note l1_w: "l1_w. Do you use whatsapp, telegram or signal chat applications on this phone?"

	label variable l2a "l2a. What is the best phone number to contact you on?"
	note l2a: "l2a. What is the best phone number to contact you on?"

	label variable l2a_w "l2a_w. Do you use whatsapp, telegram or signal chat applications on \${l2a}?"
	note l2a_w: "l2a_w. Do you use whatsapp, telegram or signal chat applications on \${l2a}?"

	label variable l3 "l3. Does someone in your household or any person close to you own a telephone wh"
	note l3: "l3. Does someone in your household or any person close to you own a telephone which you can use if need be?"
	label define l3 0 "No" 1 "Yes"
	label values l3 l3

	label variable l4 "l4. Whose phone is that?"
	note l4: "l4. Whose phone is that?"
	label define l4 1 "Parents" 2 "Siblings" 3 "Other relative" 4 "Friend" 5 "Other"
	label values l4 l4

	label variable l5 "l5. What is the phone number?"
	note l5: "l5. What is the phone number?"

	label variable a6 "a6. Please assess the respondent's english skills. Were they able to communicate"
	note a6: "a6. Please assess the respondent's english skills. Were they able to communicate in English?"
	label define a6 1 "Yes, fluently" 2 "Yes, quite well" 3 "Yes, a bit" 4 "No"
	label values a6 a6

	label variable incentives "We would like to provide you with some mobile credit as a gift for taking the ti"
	note incentives: "We would like to provide you with some mobile credit as a gift for taking the time out to complete the survey. Would you like it to be sent to this phone number?"
	label define incentives 0 "No" 1 "Yes"
	label values incentives incentives

	label variable incentives_num "What is the phone number you would like the gift sent to?"
	note incentives_num: "What is the phone number you would like the gift sent to?"

	label variable addthreshold "Would you still be interested in rescheduling this survey to another day and tim"
	note addthreshold: "Would you still be interested in rescheduling this survey to another day and time?"
	label define addthreshold 1 "Yes" 0 "No"
	label values addthreshold addthreshold

	label variable reschedule "ENUMERATOR, read this out loud: When would you like to reschedule the survey? EN"
	note reschedule: "ENUMERATOR, read this out loud: When would you like to reschedule the survey? ENUMERATOR INSTRUCTIONS: When scheduling the callback, check the calendar to make sure you are available for that time. It may take up to five minutes before the event is published to the calendar."

	label variable confirm_phone "Is this the best phone number to call you in the future?"
	note confirm_phone: "Is this the best phone number to call you in the future?"
	label define confirm_phone 1 "Yes" 0 "No"
	label values confirm_phone confirm_phone

	label variable best_phone_confirm "Could you share the best phone number to contact \${full_name}?"
	note best_phone_confirm: "Could you share the best phone number to contact \${full_name}?"
	label define best_phone_confirm 1 "1. \${phone_1_name}, \${phone_1_rel}: \${phone_1}" 2 "2. \${phone_2_name}, \${phone_2_rel}: \${phone_2}" 3 "3. \${phone_3_name}, \${phone_3_rel}: \${phone_3}" 4 "4. \${phone_4_name}, \${phone_4_rel}: \${phone_4}" 5 "5. \${phone_5_name}, \${phone_5_rel}: \${phone_5}" 111 "Doesn't have any phone number to share" 555 "Will send an SMS with the phone number" 888 "Other"
	label values best_phone_confirm best_phone_confirm

	label variable other_phone "Enter the other phone number shared with you"
	note other_phone: "Enter the other phone number shared with you"

	label variable phone_relationship "What is the relationship between the respondent (\${full_name}) and the owner of"
	note phone_relationship: "What is the relationship between the respondent (\${full_name}) and the owner of the phone number just shared?"
	label define phone_relationship 0 "The respondent" 1 "Family member" 2 "Neighbor" 3 "Friend" 4 "Doesn't know the respondent" 888 "Other"
	label values phone_relationship phone_relationship

	label variable name_phone "What's their name?"
	note name_phone: "What's their name?"

	label variable reschedule_not_resp "ENUMERATOR, read this out loud: Could you let us know at which date and time \${"
	note reschedule_not_resp: "ENUMERATOR, read this out loud: Could you let us know at which date and time \${full_name} will be available? ENUMERATOR INSTRUCTIONS: When scheduling the callback, check the calendar to make sure you are available for that time. It may take up to five minutes before the event is published to the calendar."

	label variable reschedule_type "How would you like to reschedule the call?"
	note reschedule_type: "How would you like to reschedule the call?"
	label define reschedule_type 1 "Choose a date and time" 2 "Reschedule for X hours from now"
	label values reschedule_type reschedule_type

	label variable reschedule_no_ans "Check the calendar to see at which time you're available. When would you like to"
	note reschedule_no_ans: "Check the calendar to see at which time you're available. When would you like to reschedule the survey?"

	label variable extra_hours "How many hours from now do you want to call back this respondent?"
	note extra_hours: "How many hours from now do you want to call back this respondent?"

	label variable sms "Would you like to send an SMS to any of the phone numbers that had no answer?"
	note sms: "Would you like to send an SMS to any of the phone numbers that had no answer?"
	label define sms 1 "Yes" 0 "No"
	label values sms sms

	label variable phones_sms "To which phone number(s) would you like to send an SMS?"
	note phones_sms: "To which phone number(s) would you like to send an SMS?"

	label variable sms2 "Would you like to send an SMS to the best contact you just registered?"
	note sms2: "Would you like to send an SMS to the best contact you just registered?"
	label define sms2 1 "Yes" 0 "No"
	label values sms2 sms2

	label variable launch_sms2 "Click the button to send a text message"
	note launch_sms2: "Click the button to send a text message"

	label variable call_status "ENUMERATOR: DO NOT READ THIS ALOUD Report the status of this call."
	note call_status: "ENUMERATOR: DO NOT READ THIS ALOUD Report the status of this call."
	label define call_status 1 "Completed" 2 "Answered, but not completed" 3 "Answered, but not by the respondent" 4 "No answer" 5 "Refusal"
	label values call_status call_status

	label variable comments "Do you have any comments you would like to record?"
	note comments: "Do you have any comments you would like to record?"



	capture {
		foreach rgvar of varlist phones_* {
			label variable `rgvar' "If you're not sure which phone number you should call, follow this rule: Pick th"
			note `rgvar': "If you're not sure which phone number you should call, follow this rule: Pick the phone number you think you’re most likely to be able to make contact with (e.g. their own number first, their close family member’s second) Otherwise, call the first phone number in the list with an 'Unknown' owner, so you can confirm the contact number. Which phone do you want to call?"
			label define `rgvar' 1 "1. \${phone_1_name}, \${phone_1_rel}: \${phone_1}" 2 "2. \${phone_2_name}, \${phone_2_rel}: \${phone_2}" 3 "3. \${phone_3_name}, \${phone_3_rel}: \${phone_3}" 4 "4. \${phone_4_name}, \${phone_4_rel}: \${phone_4}" 5 "5. \${phone_5_name}, \${phone_5_rel}: \${phone_5}" 111 "Doesn't have any phone number to share" 555 "Will send an SMS with the phone number" 888 "Other"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist call_respondent_* {
			label variable `rgvar' "ENUMERATOR: DO NOT READ THIS ALOUD Call number: \${call_num} Last call status: \"
			note `rgvar': "ENUMERATOR: DO NOT READ THIS ALOUD Call number: \${call_num} Last call status: \${last_call_status} Tap the button below to call \${full_name} at \${phone_call}. If the respondent answers, read the following aloud, then go to the next field: Hi, this is \${Z1_text} calling for \${full_name}. Is this \${full_name}"
		}
	}

	capture {
		foreach rgvar of varlist response_* {
			label variable `rgvar' "ENUMERATOR: DO NOT READ THIS ALOUD What was the response?"
			note `rgvar': "ENUMERATOR: DO NOT READ THIS ALOUD What was the response?"
			label define `rgvar' 1 "Answered the phone, correct respondent" 2 "Answered, but not by the respondent" 3 "No answer" 4 "Number does not work (does not ring/connect to a phone)"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist continue_* {
			label variable `rgvar' "Would you like to try calling any of the phone numbers above?"
			note `rgvar': "Would you like to try calling any of the phone numbers above?"
			label define `rgvar' 1 "Yes" 0 "No"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist job_name_* {
			label variable `rgvar' "Jobs/Self Employment: \${EarningsID}. Please provide the name of the job/self em"
			note `rgvar': "Jobs/Self Employment: \${EarningsID}. Please provide the name of the job/self employment for reference"
		}
	}

	capture {
		foreach rgvar of varlist b3_* {
			label variable `rgvar' "b3. Are you currently working in this job '\${job_name}'?"
			note `rgvar': "b3. Are you currently working in this job '\${job_name}'?"
			label define `rgvar' 0 "No" 1 "Yes"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist b4_* {
			label variable `rgvar' "b4. When did you start working in this job '\${job_name}'?"
			note `rgvar': "b4. When did you start working in this job '\${job_name}'?"
		}
	}

	capture {
		foreach rgvar of varlist b5_* {
			label variable `rgvar' "b5. When did you finish working in this job '\${job_name}'?"
			note `rgvar': "b5. When did you finish working in this job '\${job_name}'?"
		}
	}

	capture {
		foreach rgvar of varlist b6_* {
			label variable `rgvar' "b6. What \${iswas} your working status as \${job_name}?"
			note `rgvar': "b6. What \${iswas} your working status as \${job_name}?"
			label define `rgvar' 1 "Regular employee (of someone who is not a member of your household)" 2 "Regular family worker (of someone who is a member of your household)" 3 "Self-employed (works on his/her own account or employer)" 4 "Apprentice" 5 "Casual or By Day worker (works upon demand and according to needs of the employe" -96 "Other"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist b6oth_* {
			label variable `rgvar' "b6oth. Please specify"
			note `rgvar': "b6oth. Please specify"
		}
	}

	capture {
		foreach rgvar of varlist job_category_* {
			label variable `rgvar' "job_category. Does the job fall under any of these trades?"
			note `rgvar': "job_category. Does the job fall under any of these trades?"
			label define `rgvar' 1 "Block-laying and concreting" 2 "Tiling and Plastering" 3 "Welding and farm tool repair" 4 "Small engine repair" 5 "Solar PV installation" 6 "Garment making" 7 "Hairdressing/barbering and beauty therapy" 8 "Animal husbandry" 9 "Satellite installation" 10 "Electrical installation and repairs" 11 "Plumbing" 12 "None of the above categories"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist isic_1_* {
			label variable `rgvar' "isic_1. Please select the most appropriate industry (ISIC Classification 1) for "
			note `rgvar': "isic_1. Please select the most appropriate industry (ISIC Classification 1) for \${job_name}"
			label define `rgvar' 1 "Agriculture, forestry and fishing" 2 "Mining and quarrying" 3 "Manufacturing" 4 "Electricity, gas, steam and air conditioning supply" 5 "Water supply; sewerage, waste management and remediation activities" 6 "Construction" 7 "Wholesale and retail trade; repair of motor vehicles and motorcycles" 8 "Transportation and storage" 9 "Accommodation and food service activities" 10 "Information and communication" 11 "Financial and insurance activities" 12 "Real estate activities" 13 "Professional, scientific and technical activities" 14 "Administrative and support service activities" 15 "Public administration and defence; compulsory social security" 16 "Education" 17 "Human health and social work activities" 18 "Arts, entertainment and recreation" 19 "Other service activities" 20 "Activities of households as employers; undifferentiated goods- and services-prod" 21 "Activities of extraterritorial organizations and bodies"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist isic_2_* {
			label variable `rgvar' "isic_2. Please ask the respondent to describe the work they did in \${job_name} "
			note `rgvar': "isic_2. Please ask the respondent to describe the work they did in \${job_name} and select the most appropriate industry (ISIC Classification 2)"
			label define `rgvar' 101 "Crop and animal production, hunting and related service activities" 102 "Forestry and logging" 103 "Fishing and aquaculture" 205 "Mining of coal and lignite" 206 "Extraction of crude petroleum and natural gas" 207 "Mining of metal ores" 208 "Other mining and quarrying" 209 "Mining support service activities" 310 "Manufacture of food products" 311 "Manufacture of beverages" 312 "Manufacture of tobacco products" 313 "Manufacture of textiles" 314 "Manufacture of wearing apparel" 315 "Manufacture of leather and related products" 316 "Manufacture of wood and of products of wood and cork, except furniture; manufact" 317 "Manufacture of paper and paper products" 318 "Printing and reproduction of recorded media" 319 "Manufacture of coke and refined petroleum products" 320 "Manufacture of chemicals and chemical products" 321 "Manufacture of basic pharmaceutical products and pharmaceutical preparations" 322 "Manufacture of rubber and plastics products" 323 "Manufacture of other non-metallic mineral products" 324 "Manufacture of basic metals" 325 "Manufacture of fabricated metal products, except machinery and equipment" 326 "Manufacture of computer, electronic and optical products" 327 "Manufacture of electrical equipment" 328 "Manufacture of machinery and equipment n.e.c." 329 "Manufacture of motor vehicles, trailers and semi-trailers" 330 "Manufacture of other transport equipment" 331 "Manufacture of furniture" 332 "Other manufacturing" 333 "Repair and installation of machinery and equipment" 435 "Electricity, gas, steam and air conditioning supply" 536 "Water collection, treatment and supply" 537 "Sewerage" 538 "Waste collection, treatment and disposal activities; materials recovery" 539 "Remediation activities and other waste management services" 641 "Construction of buildings" 642 "Civil engineering" 643 "Specialized construction activities" 745 "Wholesale and retail trade and repair of motor vehicles and motorcycles" 746 "Wholesale trade, except of motor vehicles and motorcycles" 747 "Retail trade, except of motor vehicles and motorcycles" 849 "Land transport and transport via pipelines" 850 "Water transport" 851 "Air transport" 852 "Warehousing and support activities for transportation" 853 "Postal and courier activities" 955 "Accommodation" 956 "Food and beverage service activities" 1058 "Publishing activities" 1059 "Motion picture, video and television programme production, sound recording and m" 1060 "Programming and broadcasting activities" 1061 "Telecommunications" 1062 "Computer programming, consultancy and related activities" 1063 "Information service activities" 1164 "Financial service activities, except insurance and pension funding" 1165 "Insurance, reinsurance and pension funding, except compulsory social security" 1166 "Activities auxiliary to financial service and insurance activities" 1268 "Real estate activities" 1369 "Legal and accounting activities" 1370 "Activities of head offices; management consultancy activities" 1371 "Architectural and engineering activities; technical testing and analysis" 1372 "Scientific research and development" 1373 "Advertising and market research" 1374 "Other professional, scientific and technical activities" 1375 "Veterinary activities" 1477 "Rental and leasing activities" 1478 "Employment activities" 1479 "Travel agency, tour operator, reservation service and related activities" 1480 "Security and investigation activities" 1481 "Services to buildings and landscape activities" 1482 "Office administrative, office support and other business support activities" 1584 "Public administration and defence; compulsory social security" 1685 "Education" 1786 "Human health activities" 1787 "Residential care activities" 1788 "Social work activities without accommodation" 1890 "Creative, arts and entertainment activities" 1891 "Libraries, archives, museums and other cultural activities" 1892 "Gambling and betting activities" 1893 "Sports activities and amusement and recreation activities" 1994 "Activities of membership organizations" 1995 "Repair of computers and personal and household goods" 1996 "Other personal service activities" 2097 "Activities of households as employers of domestic personnel" 2098 "Undifferentiated goods- and services-producing activities of private households " 2199 "Activities of extraterritorial organizations and bodies"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist b9_* {
			label variable `rgvar' "b9. \${havewere} you ever been injured or suffered from a work-related illness d"
			note `rgvar': "b9. \${havewere} you ever been injured or suffered from a work-related illness during \${job_name}?"
			label define `rgvar' 0 "No" 1 "Yes, Injured" 2 "Yes, illness" 3 "Yes, both injured and illness"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist b11_* {
			label variable `rgvar' "b11. How did you find out about this job ' \${job_name} '?"
			note `rgvar': "b11. How did you find out about this job ' \${job_name} '?"
			label define `rgvar' 1 "Through industrial placement / internship" 2 "Through friends or family" 3 "Through a job advert on electronic media" 4 "Through a job advert on social media" 5 "Through application" -96 "Other (Specify)"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist b11_other_* {
			label variable `rgvar' "Please specify other"
			note `rgvar': "Please specify other"
		}
	}

	capture {
		foreach rgvar of varlist b12_* {
			label variable `rgvar' "b12. \${iswas}\${job_name} working at an officially registered business with the"
			note `rgvar': "b12. \${iswas}\${job_name} working at an officially registered business with the Ministry of Justice, Gambia Chamber of Commerce or The Registrar of Companies?"
		}
	}

	capture {
		foreach rgvar of varlist b13_* {
			label variable `rgvar' "b13. \${dodid} you have a work contract, either written or oral?"
			note `rgvar': "b13. \${dodid} you have a work contract, either written or oral?"
			label define `rgvar' 0 "No" 1 "Yes - Written" 2 "Yes - Oral"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist b14_* {
			label variable `rgvar' "b14. For how many more months longer will you work in this job '\${job_name}?'"
			note `rgvar': "b14. For how many more months longer will you work in this job '\${job_name}?'"
			label define `rgvar' 1 "Less than one month" 2 "1-6 months" 3 "7-12 months" 4 "More than 12 months" -99 "Don't know"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist b15_* {
			label variable `rgvar' "b15. How many hours \${dodid} you work in this job '\${job_name}' in a typical d"
			note `rgvar': "b15. How many hours \${dodid} you work in this job '\${job_name}' in a typical day?"
		}
	}

	capture {
		foreach rgvar of varlist b15_check_* {
			label variable `rgvar' "WARNING:You have entered that the respondent works more than 12 hours per day in"
			note `rgvar': "WARNING:You have entered that the respondent works more than 12 hours per day in \${job_name}. This seems very high Please confirm Please select 'Yes' to confirm"
			label define `rgvar' 1 "yes"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist b16_* {
			label variable `rgvar' "b16. How many days \${dodid} you work in this job '\${job_name}' in a typical we"
			note `rgvar': "b16. How many days \${dodid} you work in this job '\${job_name}' in a typical week?"
		}
	}

	capture {
		foreach rgvar of varlist b16_check_* {
			label variable `rgvar' "WARNING:Based on the calution of total hours worked in a week, respondent works "
			note `rgvar': "WARNING:Based on the calution of total hours worked in a week, respondent works for \${total_wrk_hours} hours in this job '\${job_name}'. This seems very high Please confirm Please select 'Yes' to confirm"
			label define `rgvar' 1 "yes"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist b17_* {
			label variable `rgvar' "b17. What \${iswas} the average payment in cash in a typical month of work in th"
			note `rgvar': "b17. What \${iswas} the average payment in cash in a typical month of work in this job '\${job_name}'? IN GMD"
		}
	}

	capture {
		foreach rgvar of varlist b17_unit_* {
			label variable `rgvar' "Timeframe"
			note `rgvar': "Timeframe"
			label define `rgvar' 1 "Monthly" 2 "Weekly" 3 "Daily" 4 "Seasonal/Length of contract"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist b17_unit_s_* {
			label variable `rgvar' "Please enter how many months in the season/contract"
			note `rgvar': "Please enter how many months in the season/contract"
		}
	}

	capture {
		foreach rgvar of varlist b17_unit_check_* {
			label variable `rgvar' "WARNING:You have entered that respondents contract/season lasts for more \${b24_"
			note `rgvar': "WARNING:You have entered that respondents contract/season lasts for more \${b24_unit_s}. This appears to be long. Kindly confirm with the respondent if this is accurate."
			label define `rgvar' 1 "yes"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist b17_check_* {
			label variable `rgvar' "b17_check. WARNING:You have entered that the respondent earns a very high amount"
			note `rgvar': "b17_check. WARNING:You have entered that the respondent earns a very high amount in cash for this job '\${job_name}'. You have entered that they earn \${b17} GMD as a \${b17_unit_val} wage Please confirm Please select 'Yes' to confirm"
			label define `rgvar' 1 "yes"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist b17low_check_* {
			label variable `rgvar' "b17low_check. WARNING:You have entered that the respondent earns a very low amou"
			note `rgvar': "b17low_check. WARNING:You have entered that the respondent earns a very low amount in cash for this job '\${job_name}'. You have entered that they earn \${b17} as a \${b17_unit_val} GMD wage. Please check you entered the right timeframe Please confirm Please select 'Yes' to confirm"
			label define `rgvar' 1 "yes"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist b18_a_* {
			label variable `rgvar' "b18_a. Do you receive any payment in-kind in a typical month of work in \${job_n"
			note `rgvar': "b18_a. Do you receive any payment in-kind in a typical month of work in \${job_name}?"
			label define `rgvar' 0 "No" 1 "Yes"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist b18_* {
			label variable `rgvar' "b18. What \${iswas} the average payment in kind in a typical month of work in th"
			note `rgvar': "b18. What \${iswas} the average payment in kind in a typical month of work in this job '\${job_name}'? IN GMD"
		}
	}

	capture {
		foreach rgvar of varlist b18_unit_* {
			label variable `rgvar' "Timeframe"
			note `rgvar': "Timeframe"
			label define `rgvar' 1 "Monthly" 2 "Weekly" 3 "Daily" 4 "Seasonal/Length of contract"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist b18_unit_s_* {
			label variable `rgvar' "Please enter how many months in a season/contract"
			note `rgvar': "Please enter how many months in a season/contract"
		}
	}

	capture {
		foreach rgvar of varlist b18_unit_check_* {
			label variable `rgvar' "WARNING:You have entered that respondents contract/season lasts for more \${b24_"
			note `rgvar': "WARNING:You have entered that respondents contract/season lasts for more \${b24_unit_s}. This appears to be long. Kindly confirm with the respondent if this is accurate."
			label define `rgvar' 1 "yes"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist b18_check_* {
			label variable `rgvar' "b18_check. WARNING:You have entered that the respondent earns a very high amount"
			note `rgvar': "b18_check. WARNING:You have entered that the respondent earns a very high amount in-kind for this job '\${job_name}'. You have entered that they earn \${b18} as a \${b18_unit_val} GMD wage. Please check you entered the right timeframe Please confirm Please select 'Yes' to confirm"
			label define `rgvar' 1 "yes"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist employee_pay_check_* {
			label variable `rgvar' "Given the information you gave, we approximate that your average monthly earning"
			note `rgvar': "Given the information you gave, we approximate that your average monthly earnings from this job '\${job_name}' is typically about \${emp_month_est} GMD. Does this sound about right or is it too high or too low?"
			label define `rgvar' 1 "yes"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist b20_* {
			label variable `rgvar' "b20. \${iswas} this job '\${job_name}' officially registered business with the M"
			note `rgvar': "b20. \${iswas} this job '\${job_name}' officially registered business with the Ministry of Justice, Gambia Chamber of Commerce or The Registrar of Companies?"
		}
	}

	capture {
		foreach rgvar of varlist b21_* {
			label variable `rgvar' "b21. Besides yourself, how many workers \${dodid} you employ for this job '\${jo"
			note `rgvar': "b21. Besides yourself, how many workers \${dodid} you employ for this job '\${job_name}'?"
		}
	}

	capture {
		foreach rgvar of varlist b22_* {
			label variable `rgvar' "b22. How many hours \${dodid} you work in this job '\${job_name}' in a typical d"
			note `rgvar': "b22. How many hours \${dodid} you work in this job '\${job_name}' in a typical day?"
		}
	}

	capture {
		foreach rgvar of varlist b23_* {
			label variable `rgvar' "b23. How many days \${dodid} you work in this job '\${job_name}' in a typical we"
			note `rgvar': "b23. How many days \${dodid} you work in this job '\${job_name}' in a typical week?"
		}
	}

	capture {
		foreach rgvar of varlist b22_check_* {
			label variable `rgvar' "WARNING:Based on the calution of total hours worked in a week, respondent works "
			note `rgvar': "WARNING:Based on the calution of total hours worked in a week, respondent works for \${total_wrk_hours} hours in this job '\${job_name}'. This seems very high Please confirm Please select 'Yes' to confirm"
			label define `rgvar' 0 "No" 1 "Yes"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist b24_* {
			label variable `rgvar' "b24. During a typical month of working in this job '\${job_name}', what \${iswas"
			note `rgvar': "b24. During a typical month of working in this job '\${job_name}', what \${iswas} the value of total sales of products, goods or services? IN GMD"
		}
	}

	capture {
		foreach rgvar of varlist b24_unit_* {
			label variable `rgvar' "Timeframe"
			note `rgvar': "Timeframe"
			label define `rgvar' 1 "Monthly" 2 "Weekly" 3 "Daily" 4 "Seasonal/Length of contract"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist b24_unit_s_* {
			label variable `rgvar' "Please enter how many months in a season/contract"
			note `rgvar': "Please enter how many months in a season/contract"
		}
	}

	capture {
		foreach rgvar of varlist b24_unit_check_* {
			label variable `rgvar' "WARNING:You have entered that respondents contract/season lasts for more \${b24_"
			note `rgvar': "WARNING:You have entered that respondents contract/season lasts for more \${b24_unit_s}. This appears to be long. Kindly confirm with the respondent if this is accurate."
			label define `rgvar' 1 "yes"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist b24_check_* {
			label variable `rgvar' "b24_check. WARNING:You have entered that the respondent's business has a very hi"
			note `rgvar': "b24_check. WARNING:You have entered that the respondent's business has a very high level of revenue for this job '\${job_name}'. You have entered that they sell around \${b24} as a \${b24_unit_val} GMD. Please check you entered the right timeframe Please confirm Please select 'Yes' to confirm"
			label define `rgvar' 1 "yes"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist b24low_check_* {
			label variable `rgvar' "b24low_check. WARNING:You have entered that the respondent's business has a very"
			note `rgvar': "b24low_check. WARNING:You have entered that the respondent's business has a very low level of revenue for this job '\${job_name}'. You have entered that they sell around \${b24} as a \${b24_unit_val} GMD. Please check you entered the right timeframe Please confirm Please select 'Yes' to confirm"
			label define `rgvar' 1 "yes"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist b26_* {
			label variable `rgvar' "b26. How much profits \${dodid} you generate in a typical month for this job '\$"
			note `rgvar': "b26. How much profits \${dodid} you generate in a typical month for this job '\${job_name}'. By profits I mean what is left after you paid your workers, different charges such as electricity or water, raw materials and taxes. IN GMD"
		}
	}

	capture {
		foreach rgvar of varlist b26_unit_* {
			label variable `rgvar' "Timeframe"
			note `rgvar': "Timeframe"
			label define `rgvar' 1 "Monthly" 2 "Weekly" 3 "Daily" 4 "Seasonal/Length of contract"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist b26_unit_s_* {
			label variable `rgvar' "Please enter how many months in a season/contract"
			note `rgvar': "Please enter how many months in a season/contract"
		}
	}

	capture {
		foreach rgvar of varlist b26_unit_check_* {
			label variable `rgvar' "WARNING:You have entered that respondents contract/season lasts for more \${b26_"
			note `rgvar': "WARNING:You have entered that respondents contract/season lasts for more \${b26_unit_s}. This appears to be long. Kindly confirm with the respondent if this is accurate."
			label define `rgvar' 1 "yes"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist b26first_check_* {
			label variable `rgvar' "b26first_check. WARNING:You have entered that the respondent's business has a ve"
			note `rgvar': "b26first_check. WARNING:You have entered that the respondent's business has a very high level of profit for this job '\${job_name}'. You have entered that they have a profit around \${b26} as a \${b26_unit_val} GMD. Please check you entered the right timeframe Please confirm Please select 'Yes' to confirm"
			label define `rgvar' 1 "yes"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist profit_month_check_* {
			label variable `rgvar' "Given the information you gave, we approximate that your average monthly profits"
			note `rgvar': "Given the information you gave, we approximate that your average monthly profits from this job '\${job_name}' is typically about \${profit_month} GMD. Does this sound about right or is it too high or too low?"
			label define `rgvar' 1 "yes"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist b27_* {
			label variable `rgvar' "b27. How much of the profits from the this job \${job_name} belongs to you?"
			note `rgvar': "b27. How much of the profits from the this job \${job_name} belongs to you?"
		}
	}

	capture {
		foreach rgvar of varlist b29_b_* {
			label variable `rgvar' "b29_b. Since \${reference_month_str}\${reference_year_str}, did you apply or ask"
			note `rgvar': "b29_b. Since \${reference_month_str}\${reference_year_str}, did you apply or ask for any loan or credit for this '\${job_name}' from any source?"
			label define `rgvar' 0 "No" 1 "Yes"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist b30_* {
			label variable `rgvar' "b30. What was the source(s) of the loan/credit obtained since \${reference_month"
			note `rgvar': "b30. What was the source(s) of the loan/credit obtained since \${reference_month_str}?"
		}
	}

	capture {
		foreach rgvar of varlist b30_other_* {
			label variable `rgvar' "Please specify other"
			note `rgvar': "Please specify other"
		}
	}

	capture {
		foreach rgvar of varlist launch_sms_* {
			label variable `rgvar' "Click the button to send a text message."
			note `rgvar': "Click the button to send a text message."
		}
	}




	* append old, previously-imported data (if any)
	cap confirm file "`dtafile'"
	if _rc == 0 {
		* mark all new data before merging with old data
		gen new_data_row=1
		
		* pull in old data
		append using "`dtafile'"
		
		* drop duplicates in favor of old, previously-imported data if overwrite_old_data is 0
		* (alternatively drop in favor of new data if overwrite_old_data is 1)
		sort key
		by key: gen num_for_key = _N
		drop if num_for_key > 1 & ((`overwrite_old_data' == 0 & new_data_row == 1) | (`overwrite_old_data' == 1 & new_data_row ~= 1))
		drop num_for_key

		* drop new-data flag
		drop new_data_row
	}
	
	* save data to Stata format
	save "`dtafile'", replace

	* show codebook and notes
	codebook
	notes list
}

disp
disp "Finished import of: `csvfile'"
disp

* OPTIONAL: LOCALLY-APPLIED STATA CORRECTIONS
*
* Rather than using SurveyCTO's review and correction workflow, the code below can apply a list of corrections
* listed in a local .csv file. Feel free to use, ignore, or delete this code.
*
*   Corrections file path and filename:  H:/exported/Tekki_Fii_PV_3_Final_2_corrections.csv
*
*   Corrections file columns (in order): key, fieldname, value, notes

capture confirm file "`corrfile'"
if _rc==0 {
	disp
	disp "Starting application of corrections in: `corrfile'"
	disp

	* save primary data in memory
	preserve

	* load corrections
	insheet using "`corrfile'", names clear
	
	if _N>0 {
		* number all rows (with +1 offset so that it matches row numbers in Excel)
		gen rownum=_n+1
		
		* drop notes field (for information only)
		drop notes
		
		* make sure that all values are in string format to start
		gen origvalue=value
		tostring value, format(%100.0g) replace
		cap replace value="" if origvalue==.
		drop origvalue
		replace value=trim(value)
		
		* correct field names to match Stata field names (lowercase, drop -'s and .'s)
		replace fieldname=lower(subinstr(subinstr(fieldname,"-","",.),".","",.))
		
		* format date and date/time fields (taking account of possible wildcards for repeat groups)
		forvalues i = 1/100 {
			if "`datetime_fields`i''" ~= "" {
				foreach dtvar in `datetime_fields`i'' {
					* skip fields that aren't yet in the data
					cap unab dtvarignore : `dtvar'
					if _rc==0 {
						gen origvalue=value
						replace value=string(clock(value,"DMYhms",2025),"%25.0g") if strmatch(fieldname,"`dtvar'")
						* allow for cases where seconds haven't been specified
						replace value=string(clock(origvalue,"DMYhm",2025),"%25.0g") if strmatch(fieldname,"`dtvar'") & value=="." & origvalue~="."
						drop origvalue
					}
				}
			}
			if "`date_fields`i''" ~= "" {
				foreach dtvar in `date_fields`i'' {
					* skip fields that aren't yet in the data
					cap unab dtvarignore : `dtvar'
					if _rc==0 {
						replace value=string(clock(value,"DMY",2025),"%25.0g") if strmatch(fieldname,"`dtvar'")
					}
				}
			}
		}

		* write out a temp file with the commands necessary to apply each correction
		tempfile tempdo
		file open dofile using "`tempdo'", write replace
		local N = _N
		forvalues i = 1/`N' {
			local fieldnameval=fieldname[`i']
			local valueval=value[`i']
			local keyval=key[`i']
			local rownumval=rownum[`i']
			file write dofile `"cap replace `fieldnameval'="`valueval'" if key=="`keyval'""' _n
			file write dofile `"if _rc ~= 0 {"' _n
			if "`valueval'" == "" {
				file write dofile _tab `"cap replace `fieldnameval'=. if key=="`keyval'""' _n
			}
			else {
				file write dofile _tab `"cap replace `fieldnameval'=`valueval' if key=="`keyval'""' _n
			}
			file write dofile _tab `"if _rc ~= 0 {"' _n
			file write dofile _tab _tab `"disp"' _n
			file write dofile _tab _tab `"disp "CAN'T APPLY CORRECTION IN ROW #`rownumval'""' _n
			file write dofile _tab _tab `"disp"' _n
			file write dofile _tab `"}"' _n
			file write dofile `"}"' _n
		}
		file close dofile
	
		* restore primary data
		restore
		
		* execute the .do file to actually apply all corrections
		do "`tempdo'"

		* re-save data
		save "`dtafile'", replace
	}
	else {
		* restore primary data		
		restore
	}

	disp
	disp "Finished applying corrections in: `corrfile'"
	disp
}
