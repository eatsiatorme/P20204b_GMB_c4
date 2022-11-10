
	
	
********************************************************************************
* APPENDING 
********************************************************************************
global add_logic_sheet = 0
import excel "${outfile}", sheet("6. logic") clear first case(preserve)
count if ${unique_id} != .

if `r(N)' > 0 {
	global add_logic_sheet = 1
gen logic = 1
}
tempfile logic
save `logic'

global add_constraints_sheet = 0
import excel "${outfile}", sheet("8. constraints") clear first case(preserve)
count if ${unique_id} != .
if `r(N)' > 0 {
	global add_constraints_sheet = 1
replace variable = variable + " = " + value
rename variable variable_1
rename label label_1
drop value
}
tempfile constraints
save `constraints'



if $add_check_sheet == 1 {
import excel "$checking_log\/`checksheet'.xlsx", clear first case(preserve)
tempfile other
save `other'
}

global add_outlier_sheet = 0
import excel "${outfile}", sheet("11. outliers") clear first case(preserve)

count if ${unique_id} != .
if `r(N)' > 0 {
		global add_outlier_sheet = 1
gen variable_1 = variable + " = " + value
rename label label_1
drop variable value
}
tempfile outliers
save `outliers'


import excel "${outfile}", sheet("10. comments") clear first case(preserve)
count if ${unique_id} != .
if `r(N)' > 0 {
	global add_comments_sheet = 1
	rename value variable_1 // value instead of variable + value as already done the concat
	rename comment label_1
	drop variable label
gen comments = 1
}
tempfile comments
save `comments'

clear

if $add_logic_sheet == 1 {
use `logic', clear
}

if $add_constraints_sheet == 1 {
append using `constraints', gen(constraint)
}
if $add_check_sheet == 1 {
append using `other', gen(other) 
}
if $add_outlier_sheet == 1 {
append using `outliers', gen(outliers)
}
if $add_comments_sheet == 1 {
append using `comments', gen(comments)
}

gen check_type=.

if $add_logic_sheet == 1 {
replace check_type = 1 if logic == 1
drop logic
}

if $add_constraints_sheet == 1 {
replace check_type = 2 if constraint == 1
drop constraint
}
if $add_check_sheet == 1 {
replace check_type = 3 if other == 1 
drop other error
}
if $add_outlier_sheet == 1 {
replace check_type = 4 if outliers == 1 
drop outliers
}

if $add_comments_sheet == 1 {
replace check_type = 5 if comments == 1 
drop comments
}

label def l_checktype 1 "Logic Check" 2 "Constraint Error" 3 "Other Quality Check" 4 "Outlier" 5 "Enumerator Comments"
label val check_type l_checktype


*merge m:1 ApplicantID using `scto_link_var', nogen keep(3)
*drop scto_link
*rename scto_link2 scto_link

*order submissiondate ApplicantID z2 z1 check_type message scto_link



*******************************************************************************
* Check to see whether the sample has been run before
*******************************************************************************

capture confirm file "$data_quality\11_error_logs\error_log\error_log.xlsx" // Confirms that there is already an error log

di _rc

if _rc {
	di "Error Log does not exist"
	global previous_run = 0
}

if !_rc {
	di "Error log does exist!"
	global previous_run = 1
}


*******************************************************************************
* Create 'New list' - i.e. new errors that are flagged
*******************************************************************************

generate submissiondate_str = string(submissiondate, "%tc")
egen error_id = concat(${unique_id} ${enumerator_id} check_type variable_* submissiondate_str) // message)



drop ${enumerator_id} ${supervisor_id}
merge m:1 ${unique_id} using "$corrections\/${form_title}", nogen keep(3) keepusing(${enumerator_id} ${supervisor_id}) // getting labels for supervisor and enumerator
*label val z1 z1
*decode ${enumerator_id}, gen(enumerator_name)
*label val z2 z2
*decode ${supervisor_id}, gen(supervisor)
*drop ${enumerator_id} ${supervisor_id}

tempfile new_list
save `new_list' // List of newly added errors

di "$previous_run"
if $previous_run == 0 { // If this is the first time - then create the error log
sort error_id
gen error_counter = _n
keep error_counter error_id
tempfile error_log_data_first
save `error_log_data_first'
export excel "$data_quality\11_error_logs\error_log\error_log.xlsx", firstrow(var) 

copy "$data_quality\Output Templates\Checking_List.xlsx" "$data_quality\05_output\Checking_List.xlsx"
}

if $previous_run == 1 { // If this is not the first time make a copy of previous log and filter out any old cases
copy "$data_quality\11_error_logs\error_log\error_log.xlsx" "$data_quality\11_error_logs\error_log\archive\error_log_$datetime.xlsx", replace
import excel "$data_quality\11_error_logs\error_log\error_log.xlsx", clear firstrow 
tempfile error_log
save `error_log'
merge 1:1 error_id using `new_list'
su error_counter
local error_counter_upto = `r(max)' // Take total number of errors in log
di "`error_counter_upto'"
keep if _merge == 2 // Keep only new error cases

count 
if `r(N)' > 0 { // If there are indeed new error cases - create new version of the error log
*
sort error_counter error_id
replace error_counter = _n + `error_counter_upto'
keep error_counter error_id
tempfile error_log_data_new
save `error_log_data_new'
append using `error_log'
export excel "$data_quality\11_error_logs\error_log\error_log.xlsx", firstrow(var) replace
}
else {
	global no_new_checks = 1
}
}

if $no_new_checks == 1 { // If there are no new error cases
	di "No new checks to show"
}
else { // If there are indeed new error cases 


use `new_list', clear // Use new error cases
count 
if `r(N)' > 0 { 
	if $previous_run == 0 { // If new error cases AND this is the first time running then merge with the cases in the log
merge 1:1 error_id using `error_log_data_first', keep(3) keepusing(error_counter)
	}

	if $previous_run == 1 { // If new error cases AND there are previous errors then merge with error log but only keep new ones
merge 1:1 error_id using `error_log_data_new', keep(3) keepusing(error_counter)

	}
sort error_counter
drop error_id _merge submissiondate_str
}


merge m:1 ${unique_id} using `scto_link_var', nogen keep(3)
capture confirm variable scto_link
if !_rc {
drop scto_link
}
rename scto_link2 scto_link

sort error_counter
order error_counter submissiondate ${unique_id} ${supervisor_id} ${enumerator_id} check_type message scto_link
des, short
local n_vars `r(k)' // count number of variables

if $previous_run == 0 {
local error_counter_upto = 0
}



local startfrom = `error_counter_upto' + 3
export excel "$data_quality\05_output\Checking_List.xlsx", sheet("Sheet1", modify) keepcellfmt cell(C`startfrom')


*******************************************************************************
* Mata Formatting Checking List
*******************************************************************************

		unab allvars : _all
		local pos : list posof "scto_link" in allvars
		local pos = `pos' + 2 // Because of status column
		di "`pos'"
		su error_counter
		local rowbeg = `r(min)' + 2
		local rowend = `r(max)' + 2
		mata: add_scto_link("$data_quality\05_output\Checking_List.xlsx", "Sheet1", "scto_link", `pos', `rowbeg', `rowend')

		mata: check_list_format("$data_quality\05_output\Checking_List.xlsx", "Sheet1", "${unique_id}", 1, `rowbeg', `rowend', `n_vars')	

	copy "$data_quality\05_output\Checking_List.xlsx" "$data_quality\11_error_logs\error_log\archive\Checking_List_$datetime.xlsx", replace		
		}




*******************************************************************************
* Creating Status column
*******************************************************************************

import excel "$data_quality\11_error_logs\error_log\error_log.xlsx", clear firstrow // Open errors
merge 1:1 error_id using `new_list', keep(3) keepusing(error_id) nogen // Keep only 'new errors'
tempfile bleh
save `bleh' 

import excel "$data_quality\05_output\Checking_List.xlsx", clear firstrow cellrange(B2) // Open up errors
drop if error_counter==. // ADDED AS IT CAN IMPORT BLANK FILES
merge 1:1 error_counter using `bleh', gen(still_error)

gen status = 0

capture confirm string variable Action
			if _rc == 0 {
			}
			else {
			tostring Action, replace

			}

replace status = 1 if still_error==3 & Action!="No further action"
replace status = 2 if still_error==1
replace status = 3 if Action=="No further action" & status != 2
replace status = 4 if Action=="Back-check"


drop still_error

label def l_status 1 "Error still remains" 2 "Error No Longer Remains" 3 "No further action" 4 "Sent for Back-check"
label val status l_status

keep status
export excel "$data_quality\05_output\Checking_List.xlsx", sheet("Sheet1", modify) keepcellfmt cell(A3)





********************************************************************************
* CREATING LOCAL PARTNER CHECKING SHEET
********************************************************************************
if $previous_run == 0 {
	copy "$data_quality\Output Templates\Checking_List_LP.xlsx" "$lp_folder\Checking_List_LP.xlsx"	
}



import excel "$lp_folder\Checking_List_LP.xlsx", clear firstrow cellrange(B2)

*keep field_counter error_counter
drop scto_link
su field_counter
local field_check = `r(N)'
di `field_check'

if `field_check'>0 {
	local field_check_count = `r(max)'
	foreach var of varlist variable_* label_* {
		capture confirm numeric variable `var'
		if _rc == 0 {
		tostring `var', gen(`var'_str)
		order `var'_str, after(`var')
		drop `var'
		rename `var'_str `var'
	}
	tempfile already_in_field
	save `already_in_field'
}
}


import excel "$data_quality\05_output\Checking_List.xlsx", clear firstrow cellrange(A2)


capture confirm string variable Action
			if _rc == 0 {
			}
			else {
			tostring Action, replace

			}

keep if Action=="Field Clarification"
drop Action status

if `field_check'==0 {
gen field_counter = _n
merge m:1 ${unique_id} using `scto_link_var', nogen keep(3)
drop scto_link
rename scto_link2 scto_link
order scto_link, after(message)	
}

if `field_check'>0 {
		foreach var of varlist variable_* label_* {
		capture confirm numeric variable `var'
		if _rc == 0 {
		tostring `var', gen(`var'_str)
		order `var'_str, after(`var')
		drop `var'
		rename `var'_str `var'
		}
	}
merge 1:1 error_counter using `already_in_field', keep(1) nogen keepusing(field_counter)
sort error_counter
replace field_counter = _n + `field_check_count'
merge 1:1 error_counter using `already_in_field', keep(1 2) nogen //force // remove force later
merge m:1 ${unique_id} using `scto_link_var', nogen keep(3)
drop scto_link
rename scto_link2 scto_link
order scto_link, after(message)

}
sort field_counter
order field_counter, after(error_counter)

count 
if `r(N)' > 0 {
export excel "$lp_folder\Checking_List_LP.xlsx", sheet("Sheet1", modify) keepcellfmt cell(B3)


*******************************************************************************
* Mata Formatting Checking List
*******************************************************************************
des, short
local n_vars `r(k)' // count number of variables

		unab allvars : _all
		local pos : list posof "scto_link" in allvars
		local pos = `pos' + 1 // Because of status column
		di "`pos'"
		su field_counter
		local rowbeg = `r(min)' + 2
		local rowend = `r(max)' + 2
		mata: add_scto_link("$lp_folder\Checking_List_LP.xlsx", "Sheet1", "scto_link", `pos', `rowbeg', `rowend')

		mata: check_list_format("$lp_folder\Checking_List_LP.xlsx", "Sheet1", "${unique_id}", 1, `rowbeg', `rowend', `n_vars')	

}


ex

********************************************************************************
* CREATING BACK CHECK
*******************************************************************************

import excel "$data_quality\05_output\Checking_List_Backcheck.xlsx", clear firstrow cellrange(B2)
*keep bc_counter error_counter
*drop scto_link
su bc_counter
local bc_check = `r(N)'
if `bc_check'>0 {
	local bc_check_count = `r(max)'
	tempfile already_in_bc
	save `already_in_bc'
}


import excel "$$data_quality\05_output\Checking_List.xlsx", clear firstrow cellrange(A2)

capture confirm string variable Action
			if _rc == 0 {
			}
			else {
			tostring Action, replace

			}

keep if Action=="Back-check"
drop Action status

if `bc_check'==0 {
gen bc_counter = _n	
}

if `bc_check'>0 {
merge 1:1 error_counter using `already_in_bc', keep(1) nogen keepusing(bc_counter)
sort error_counter
replace bc_counter = _n + `bc_check_count'
merge 1:1 error_counter using `already_in_bc', keep(1 2) nogen force // remove force later

}
sort bc_counter
order bc_counter, after(error_counter)

*drop scto_link

count 
if `r(N)' > 0 {
export excel "$hfc_output\Checking_List_Backcheck.xlsx", sheet("Sheet1", modify) keepcellfmt cell(B3)

}

ex
*******************************************************************************
* Mata Formatting Checking List
*******************************************************************************
des, short
local n_vars `r(k)' // count number of variables

		unab allvars : _all
		local pos : list posof "scto_link" in allvars
		local pos = `pos' + 1 // Because of status column
		di "`pos'"
		su field_counter
		local rowbeg = `r(min)' + 2
		local rowend = `r(max)' + 2
		mata: add_scto_link("$ONEDRIVE\P20204b_EUTF_GMB - Documents\04_Field Work\Share with CepRass\Checking_List_CepRass.xlsx", "Sheet1", "scto_link", `pos', `rowbeg', `rowend')

		mata: check_list_format("$ONEDRIVE\P20204b_EUTF_GMB - Documents\04_Field Work\Share with CepRass\Checking_List_CepRass.xlsx", "Sheet1", "${unique_id}", 1, `rowbeg', `rowend', `n_vars')	

}
ex
*/