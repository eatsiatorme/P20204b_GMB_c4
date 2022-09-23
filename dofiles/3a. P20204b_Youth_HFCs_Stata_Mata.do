
********************************************************************************
*
********************************************************************************
* MACROS

local checksheet "${proj_name}_CHECKS"
global checking_log "$data_quality\11_error_logs" // Not sure why this has to be on again
global error_log "$data_quality\11_error_logs" // Not sure why this has to be on again
local datadir "corrections"

global no_new_checks = 0

********************************************************************************
* Take SurveyCTO Server Links
********************************************************************************

use "$corrections\/${form_title}.dta", clear

			    gen scto_link2=""
		local bad_chars `"":" "%" " " "?" "&" "=" "{" "}" "[" "]""'
		local new_chars `""%3A" "%25" "%20" "%3F" "%26" "%3D" "%7B" "%7D" "%5B" "%5D""'
		local url "https://$scto_server.surveycto.com/view/submission.html?uuid="
		local url_redirect "https://$scto_server.surveycto.com/officelink.html?url="

		foreach bad_char in `bad_chars' {
			gettoken new_char new_chars : new_chars
			replace scto_link2 = subinstr(key, "`bad_char'", "`new_char'", .)
		}
		replace scto_link2 = `"HYPERLINK("`url_redirect'`url'"' + scto_link2 + `"", "View Submission")"'

keep ${unique_id} scto_link2
tempfile scto_link_var
save `scto_link_var'


******************************
**SETTING UP HYPERLING CODE IN EXCEL**
******************************

mata: 
mata clear
void basic_formatting(string scalar filename, string scalar sheet, string matrix vars, string matrix colors, real scalar nrow) 
{

class xl scalar b
real scalar i, ncol
real vector column_widths, varname_widths, bottomrows
real matrix bottom

b = xl()
ncol = length(vars)

b.load_book(filename)
b.set_sheet(sheet)
b.set_mode("open")

b.set_bottom_border(1, (1, ncol), "thin")
b.set_font_bold(1, (1, ncol), "on")
b.set_horizontal_align(1, (1, ncol), "center")

if (length(colors) > 1 & nrow > 2) {	
for (j=1; j<=length(colors); j++) {
	b.set_font((3, nrow+1), strtoreal(colors[j]), "Calibri", 11, "lightgray")
	}
}


// Add separating bottom lines : figure out which columns to gray out	
bottom = st_data(., st_local("bottom"))
bottomrows = selectindex(bottom :== 1)
column_widths = colmax(strlen(st_sdata(., vars)))	
varname_widths = strlen(vars)

for (i=1; i<=cols(column_widths); i++) {
	if	(column_widths[i] < varname_widths[i]) {
		column_widths[i] = varname_widths[i]
	}

	b.set_column_width(i, i, column_widths[i] + 2)
}

if (rows(bottomrows) > 1) {
for (i=1; i<=rows(bottomrows); i++) {
	b.set_bottom_border(bottomrows[i]+1, (1, ncol), "thin")
	if (length(colors) > 1) {
		for (k=1; k<=length(colors); k++) {
			b.set_font(bottomrows[i]+2, strtoreal(colors[k]), "Calibri", 11, "black")
		}
	}
}
}
else b.set_bottom_border(2, (1, ncol), "thin")

b.close_book()

}

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
	b.close_book()
	}
	
void check_list_format(string scalar filename, string scalar sheetname, string scalar variable, real scalar col, real scalar rowbeg, real scalar rowend, real scalar nvar)
{
	class xl scalar b
	string matrix links
	real scalar Nrow

	b = xl()
	links = st_sdata(., variable)
	Nrow = length(links) + 2
	
	
	b.load_book(filename)
	b.set_sheet(sheetname)
	b.set_mode("open")
	b.set_border((rowbeg,rowend), (col,nvar), "thin")
	b.close_book()
	}

end



******************************
**SETTING UP THE PROGRAM FOR THE ERROR LOOPS**
******************************


	global i=0

	capture prog drop addErr
	cd "$data_quality\11_error_logs\"
	cap mkdir checking_log
	cap mkdir error_log
	cd "$data_quality\11_error_logs\error_log"
	cap mkdir archive
	
	program addErr
	qui{
		gen message="`1'"
		di "`errorfile'"
		keep if error!=.
		keep submissiondate $unique_id error message $keepvar $supervisor_id $enumerator_id
		global keepvar_counter = 1
		foreach var of varlist $keepvar {
			capture confirm string variable `var'
			if _rc == 0 {
			gen variable_$keepvar_counter = "`var'" + " = " + `var'
			local lbl : variable label `var' 
			gen label_$keepvar_counter = "`lbl'"
			global keepvar_counter = ${keepvar_counter}+1
			drop `var'
			}
			else {
			tostring `var', gen(`var'_str)
			gen variable_$keepvar_counter = "`var'" + " = " + `var'_str
			drop `var'_str
			local lbl : variable label `var' 
			gen label_$keepvar_counter = "`lbl'"
			global keepvar_counter = ${keepvar_counter}+1
			drop `var'
			}
		}
		
		
		count if error != .
		n dis "Found `r(N)' instances of error ${i}: `1'"

		capture duplicates drop
		save `c(tmpdir)'error_${proj_name}_${i}.dta, replace

	}
	end
/*
******************************************
**Check if files are present in cleaning**
******************************************

	local cleaningfiles: dir "$corrections" file "*.dta", respectcase
	if `"`cleaningfiles'"' != ""{
		local dirs cleaning corrections
		local flgNocleaning 0 
	}
	else{
		local dirs cleaning
		local flgNocleaning 1
	}
	
	foreach datadir in `dirs'{
*/

	n di as result "Running Standard Checks  on `datadir' data"
		clear	
		di "`checksheet'"
		tempfile `checksheet'
		gen float error=.
		gen float ${supervisor_id}=.
		gen float ${enumerator_id}=.
		gen str244 message=""
		format message %-244s
		save "$checking_log\\`checksheet'_`datadir'", replace 

	 	n di "Running user specified checks on `datadir' data:"

		

/*


		
	*/
	


	