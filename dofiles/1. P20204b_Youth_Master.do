quietly {
** P20204b_EUTF_GMB 

// This do-file is the Master do-file for the data management. It first runs the 
// do-files that take the data from export to clean.

clear all

// Project Globals
global proj "P20204b" // Project Code
global proj_name "P20204b_GMB" // Shorthand Project name
global round "Endline" // Round of Data Collection
global cycle "C2"
global tool "Youth"


********************************************************************************
* SETTINGS
********************************************************************************
global review = 0
global hfc = 0
global data_progress = 0
global bc = 0
global trends = 0
********************************************************************************
** FIXED GLOBALS (DO NOT EDIT)
********************************************************************************
global ONEDRIVE "C:\Users\/`c(username)'\C4ED\"
global version = 1
global date = string(date("`c(current_date)'","DMY"),"%tdNNDD")
global time = string(clock("`c(current_time)'","hms"),"%tcHHMMSS")
global datetime = "$date"+"$time"



********************************************************************************
** GLOBALS TO ENTER BASED ON PROJECT
********************************************************************************
* Local Paths - Enter based on people working on the project
if "`c(username)'"=="NathanSivewright" { 
	global timezone = 1
global scto_workspace "C:\Users\/`c(username)'\SurveyCTO Desktop Local Storage\"
global local_path "$scto_workspace\/${proj_name}_Local\/${round}\/${cycle}\/${tool}\"
global dofiles "C:\Users\/`c(username)'\Documents\GitHub\P20204b_GMB_c4\dofiles"
}

if "`c(username)'"=="ElikplimAtsiatorme" {
	global timezone = 1
global scto_workspace "C:\Users\/`c(username)'\OneDrive - C4ED\Dokumente\Desktop\"
global local_path "$scto_workspace\/${proj_name}_Local\/${round}\/${cycle}\/${tool}\"
global dofiles "C:\Users\ElikplimAtsiatorme\Documents\GitHub\P20204_GMB\P20204b_GMB_c4\dofiles"
}

global unique_id ApplicantID // Unique ID of interviews
global supervisor_id z2 // ID variable for Supervisor Team
global enumerator_id z1 // ID variable for Enumerators

global cvar "comment" // Name of Column in the Comments media files - seems to always be Comment
global fname "commentsx" // Name of the 'comments' variable in the qx

global project_path "$ONEDRIVE\P20204b_EUTF_GMB - Documents\"

global qx "$ONEDRIVE\P20204b_EUTF_GMB - Documents\03_Questionnaires\03_Endline\Programming\Tekki_Fii_PV_Endline_2.xlsx" // Enter the latest version of the form
global form_id "Tekki_Fii_PV_5" // Enter the form_id from the SurveyCTO survey form
global form_title "Tekki_Fii_PV_5" // Enter the form_title from the SurveyCTO survey form

global local_partner "CepRass" // Enter shorthand name of Local partner

********************************************************************************
** PATH GLOBALS TO ENTER (ONLY EDIT IF NECESSARY)
********************************************************************************
* Local Encryption Drive
global l_encrypted_drive "H"
global l_encrypted_path "$l_encrypted_drive:"

global exported "$l_encrypted_path\exported"
global corrections "$l_encrypted_path\corrections"
global cleaning "$l_encrypted_path\cleaning"
global pii_link "$l_encrypted_path\pii_link"
global sample_list "$l_encrypted_path\sample"

* Cloud Data Path
global raw_path "$local_path"
capture mkdir "$project_path\02_Analysis\06_Field_Work_Reports\"
capture mkdir "$hfc_path\02_Analysis\06_Field_Work_Reports\${round}\/${cycle}\"
global scto_server "mannheimc4ed"

global lp_folder "$project_path\04_Field Work\Share with $local_partner\/${round}\/${cycle}\"
capture mkdir "$lp_folder"

global progress "$project_path\02_Analysis\06_Field_Work_Reports\/${round}\/${cycle}\Data Progress"
global data_quality "$project_path\02_Analysis\06_Field_Work_Reports\/${round}\/${cycle}\HFC"
global data_anon "$project_path\02_Analysis\02_Data\/${round}\/${cycle}\/${tool}\"


********************************************************************************
** PII VARIABLES
********************************************************************************
// Enter here variables that constitute PII
#d ;
global personal_info
*phone_call_log
*phone*
*phone_*_name
*phone_*_rel
full_name
*respondents_details
*phones_label_*
*phonenumber_called
id1a
id1b
*other_phone
*name_phone
*name_ph?
*rel_ph?
*primary_phone
*respondent_name
*best_phone
z2 
z1_text
;
#d cr

********************************************************************************
** KEY COMPONENT VARIABLES
********************************************************************************
// These are variables that are used to calculate key outcome variables

** BINARY VARIABLES
#d ;
global component_vars_bin
b1
b31a
b1b
;
#d cr

** CONTINUOUS VARIABLES
#d ;
global component_vars_cont
b2
b21_?
emp_inc_month_? 
sales_month_?
profit_month_?
;
#d cr

** CATEGORICAL VARIABLES
#d ;
global component_vars_cat
b6_?
job_category_?
;
#d cr

********************************************************************************
** KEY OUTCOME VARIABLES
********************************************************************************
// These are variables that are key outcome variables

** BINARY VARIABLES
#d ;
global outcome_vars_bin
employed_ilo

employed_stable_ever
current_bus
wrk_cntr
job_offer
work_hurt_any
;
#d cr

** CONTINUOUS VARIABLES
#d ;
global outcome_vars_cont
sum_inc_reference
current_inc
num_empl
brs_score
spe_score
prep_score
active_score
num_econ_ref
;
#d cr

********************************************************************************
** ENUMERATOR TREND VARIABLES
********************************************************************************
#d ;
global trigger
d1 
b1 
b2 
c1
;
#d cr

global outcome "$outcome_vars_bin $outcome_vars_cont"



n: di "Hi `c(username)'!"

cd "$dofiles"


}

********************************************************************************
** 1.1 EXPORTING DATA FROM SURVEYCTO DESKTOP
********************************************************************************
do "1.1a. ${proj}_${tool}_Export_Decryption.do"
cd "$dofiles"
window stopbox rusure "You should now export the data using SurveyCTO. Select YES when you have exported the latest data to continue with the data processing or select NO to stop`=char(13)'Yes=continue; No=stop here."
n: di "Please ensure that you have downloaded the latest SurveyCTO do-file to your SurveyCTO data export path"
do "1.1b. ${proj}_${tool}_Edit_SurveyCTO_Do.do"
cd "$dofiles"
do "1.1c. ${proj}_${tool}_Export.do"
cd "$dofiles"

********************************************************************************
** 1.2 DATA PREPARATION
********************************************************************************
if $review == 1 {
cd "$dofiles"
do "1.2a. ${proj}_${tool}_Review.do"
cd "$dofiles"
}
do "1.2b. ${proj}_${tool}_Clean.do"
cd "$dofiles"

********************************************************************************
** 1.3 DATA CORRECTIONS (STATA)
********************************************************************************
cd "$dofiles"
do "1.3. ${proj}_${tool}_Corrections.do"
cd "$dofiles"

if $hfc == 1 {
********************************************************************************
** 2. IPA DATA QUALITY CHECKS
********************************************************************************
cd "$dofiles"
do "2. ${proj}_${tool}_HFCs_IPA.do"
cd "$dofiles"
********************************************************************************
** 3. STATA DATA QUALITY CHECKS
********************************************************************************
cd "$dofiles"
do "3. ${proj}_${tool}_HFCs_Stata.do"
cd "$dofiles"
}

if $trends == 1 {
******************************************************************************** 
** 4. ENUMERATOR TRENDS
********************************************************************************
cd "$dofiles"
do "4. ${proj}_${tool}_Enumerator_Trends.do"
cd "$dofiles"
}

if $data_progress == 1 {
********************************************************************************
* 5. FIELDWORK PROGRESS
********************************************************************************
cd "$dofiles"
do "5. ${proj}_${tool}_Progress.do"
cd "$dofiles"
}

********************************************************************************
** 6. REMOVING PII AND SAVING NON-PII VERSION ON ONEDRIVE
********************************************************************************
do "6. ${proj}_${tool}_Data_Protection.do"
cd "$dofiles"

********************************************************************************
** 7. ENCRYPTION AND CLOSING VERACRYPT
********************************************************************************
do "7. ${proj}_${tool}_Encryption.do"
cd "$dofiles"

di "Ran Successfully! :D"

&&&7777777777777777777777777777777777777777777ddddddldllllllllllll