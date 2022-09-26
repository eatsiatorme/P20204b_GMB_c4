import excel using "$qx", clear first sheet("choices")  

count if list_name=="enumerator"
local num_enums = `r(N)'

keep if list_name=="enumerator"
sort value
levelsof label, l(l_enum)

putexcel set "$progress\Data Progress.xlsx", modify sheet("enumerator summary")
local row = 3
foreach l of local l_enum {
		di "`l'"
		putexcel A`row'= "`l'" 
		local row = `row'+1
}



********************************************************************************
* 1. Creating Data Entry Progress Sheet
********************************************************************************

import delimited using "$sample_list\sample.csv", varnames(1) clear 

keep id_key treatment
rename id_key ApplicantID

merge 1:1 ApplicantID using "$corrections\/${form_title}.dta"

gen submission=(_merge==3)
label def L_submission 0 "No Submission" 1 "Submitted"
label val submission L_submission
replace complete = 0 if complete == .
tempfile masterfield
save `masterfield'
keep ApplicantID submission ${supervisor_id} ${enumerator_id} submissiondate status _merge

drop _merge 

order ApplicantID submission status submissiondate ${supervisor_id} ${enumerator_id}

export excel using "$progress\Data Progress.xlsx", sheet("caselist", modify) cell(A2) keepcellfmt
export excel using "$lp_folder\Data Progress.xlsx", sheet("caselist", modify) cell(A2) keepcellfmt


********************************************************************************
* 2. Creating Data Progress Dashboard
********************************************************************************
use `masterfield', clear

putexcel set "$progress\Data Progress.xlsx", modify sheet("overview")

count
putexcel B3=`r(N)', nformat(number)

count if treatment==1
putexcel B4=`r(N)', nformat(number)
count if treatment==2
putexcel B5=`r(N)', nformat(number)
count if treatment==0
putexcel B6=`r(N)', nformat(number)


su submission
putexcel B8=`r(mean)', nformat(number_d2)
su complete // UPDATE
putexcel B9=`r(mean)', nformat(number_d2)
su duration_m if complete==1 // UPDATE WITH DURATION MINUTES
putexcel B10=`r(mean)', nformat(number)


putexcel set "$progress\Data Progress.xlsx", modify sheet("status summary")

*
gen interview_status= 1 if (status==1) // Completed
replace interview_status= 2 if (status==2) // Respondent Reached but not complete
replace interview_status = 3 if (inlist(status,3,4)) // Not reached
replace interview_status = 4 if (status==5) // Refused
label def l_interview_status 1 "Completed" 2 "Respondent Reached but not complete" 3 "Not reached" 4 "Refused", replace
label val interview_status l_interview_status
*

tabcount interview_status, v(1/4) matrix(x) zero
local row = 3
putexcel B`row'=matrix(x)

putexcel set "$progress\Data Progress.xlsx", modify sheet("enumerator summary")

local row = 3
tabcount ${enumerator_id} interview_status, v1(1/`num_enums') v2(1/4) matrix(y)
putexcel B`row'=matrix(y)

fre ${enumerator_id} duration_m
local row = 2
forvalues i = 1/10 {
	local rowx = `row'+`i'
	count if ${enumerator_id}==`i' & complete==1
	if `r(N)' > 0 {
	su duration_m if ${enumerator_id}==`i' & complete==1
	putexcel H`rowx'=`r(mean)', nformat(number)
	su complete if ${enumerator_id}==`i'
	putexcel G`rowx'=`r(mean)', nformat(number_d2)
	}
	
}

**************************************************************
**Local Partner Progress Sheet
**************************************************************
use `masterfield', clear

putexcel set "$lp_folder\Data Progress.xlsx", modify sheet("overview")

count
putexcel B3=`r(N)', nformat(number)

count if treatment==1
putexcel B4=`r(N)', nformat(number)
count if treatment==2
putexcel B5=`r(N)', nformat(number)
count if treatment==0
putexcel B6=`r(N)', nformat(number)


su submission
putexcel B8=`r(mean)', nformat(number_d2)
su complete // UPDATE
putexcel B9=`r(mean)', nformat(number_d2)
su duration_m if complete==1 // UPDATE WITH DURATION MINUTES
putexcel B10=`r(mean)', nformat(number)


putexcel set "$lp_folder\Data Progress.xlsx", modify sheet("status summary")

*
gen interview_status= 1 if (status==1) // Completed
replace interview_status= 2 if (status==2) // Respondent Reached but not complete
replace interview_status = 3 if (inlist(status,3,4)) // Not reached
replace interview_status = 4 if (status==5) // Refused
label def l_interview_status 1 "Completed" 2 "Respondent Reached but not complete" 3 "Not reached" 4 "Refused", replace
label val interview_status l_interview_status
*

tabcount interview_status, v(1/4) matrix(x) zero
local row = 3
putexcel B`row'=matrix(x)

putexcel set "$lp_folder\Data Progress.xlsx", modify sheet("enumerator summary")

local row = 3
tabcount ${enumerator_id} interview_status, v1(1/`num_enums') v2(1/4) matrix(y)
putexcel B`row'=matrix(y)

fre ${enumerator_id} duration_m
local row = 2
forvalues i = 1/10 {
	local rowx = `row'+`i'
	count if ${enumerator_id}==`i' & complete==1
	if `r(N)' > 0 {
	su duration_m if ${enumerator_id}==`i' & complete==1
	putexcel H`rowx'=`r(mean)', nformat(number)
	su complete if ${enumerator_id}==`i'
	putexcel G`rowx'=`r(mean)', nformat(number_d2)
	}
	
}


