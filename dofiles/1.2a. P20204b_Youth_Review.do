*quietly {
n: di "${proj}_Review.do Started"
/*
// This do-file: 
// - Opens the exported data and keeps cases that are awaiting review
// - Runs the mata code to allow for proper formatting of review sheets
// - Splits the cases by Supervisor and saves a separate sheet for each Supervisor
// - Re-opens the exported data and keeps cases that have been approved and pushes them onto cleaning stage

*/

********************************************************************************
** 1. SEPARATING CASES FOR REVIEW AND OUTPUTTING SUPERVISOR REVIEW SHEETS
********************************************************************************
use "$exported\/$form_title", clear

**** DELETE

****


keep if review_status == "AWAITING_REVIEW"


			    gen scto_link=""
		local bad_chars `"":" "%" " " "?" "&" "=" "{" "}" "[" "]""'
		local new_chars `""%3A" "%25" "%20" "%3F" "%26" "%3D" "%7B" "%7D" "%5B" "%5D""'
		local url "https://$scto_server.surveycto.com/view/submission.html?uuid="
		local url_redirect "https://$scto_server.surveycto.com/officelink.html?url="

		foreach bad_char in `bad_chars' {
			gettoken new_char new_chars : new_chars
			replace scto_link = subinstr(key, "`bad_char'", "`new_char'", .)
		}
		replace scto_link = `"HYPERLINK("`url_redirect'`url'"' + scto_link + `"", "View Submission")"'

mata: 
mata clear


void add_scto_link(string scalar filename, string scalar sheetname, string scalar variable, real scalar col, real scalar rowbeg, real scalar rowend)
{
	class xl scalar b
	string matrix links
	real scalar N

	b = xl()
	links = st_sdata(., variable)
	N = length(links) + 2
	

	b.load_book(filename)
	b.set_sheet(sheetname)
	b.set_mode("open")
	b.put_formula(rowbeg, col, links)
	b.set_font((rowbeg, rowend), col, "Calibri", 11, "5 99 193")
	b.set_font_underline((rowbeg, rowend), col, "on")
	b.set_column_width(col, col, 17)
	b.set_column_width(1, col-1, 25)
	b.set_fill_pattern(1,(1, col), "solid", ("4 123 119"))
	b.set_font(1,(1, col), "calibri", 11 , "white") 
	b.set_font_bold(1,(1, col), "on")
	b.set_border((1, rowend), (1,col), "medium") 
	b.close_book()
	}
end

keep $unique_id $supervisor_id $enumerator_id scto_link 
local keeplist "$unique_id $supervisor_id $enumerator_id scto_link"

export excel "$progress\Cases_For_Review_MASTER.xlsx", replace firstrow(var)

unab allvars : _all
local pos : list posof "scto_link" in allvars
count
local rowend = `r(N)' + 1

di "`rowend'"
mata: add_scto_link("$progress\Cases_For_Review_MASTER.xlsx", "Sheet1", "scto_link", `pos', 2, `rowend')

levelsof $supervisor_id, l(l_sups)
local vlname: value label $supervisor_id
foreach l of local l_sups {
preserve
	keep if ${supervisor_id}==`l'

local vl: label `vlname' `l'


export excel "$lp_folder\Cases_For_Review_`vl'.xlsx", replace firstrow(var)
unab allvars : _all
local pos : list posof "scto_link" in allvars
su $supervisor_id
local rowend = `r(N)' + 1

mata: add_scto_link("$lp_folder\Cases_For_Review_`vl'.xlsx", "Sheet1", "scto_link", `pos', 2, `rowend')
restore
}

********************************************************************************
** 2. COPY EXPORTED FILES TO CLEANING
********************************************************************************

cd "$cleaning"

local files: dir `"$exported\/`file'"' file "*.dta", respectcase
foreach file of local files{
	di `"`file'"'
	copy `"$exported\/`file'"' `"$cleaning\/`file'"', replace
}

********************************************************************************
** 3. PUSH ONLY APPROVED CASES ONTO THE DATA CLEANING
********************************************************************************

use "$cleaning\/$form_title", clear

keep if review_status=="APPROVED" 

save "$cleaning\/$form_title", replace

n: di "${proj}_Review ran successfully"
*}

