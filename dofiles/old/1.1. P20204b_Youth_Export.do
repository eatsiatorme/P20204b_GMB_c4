*quietly {

*** Youth_Export
** Cycle 1 Batch 1
** Youth Survey
* Nathan Sivewright Feb 2021

// This do-file: 
// 1. Deletes any previously exported and saved data sets - both local and on onedrive. 
// 2. Amends the exported SurveyCTO do-file(s) to include the sctoapi command to download the data from the SurveyCTO server
// 3. Amends the exported SurveyCTO do-file(s) to account for missing variables in the exported csv
// 4. Runs the SurveyCTO do-file(s) - importing the data and then labelling variables
// 4. Copies the output of the SurveyCTO do-file to the 'exported' folder


n: di "This could take a minute or two... Go and get a coffee"

***************************
**  erase files in export **
***************************
local deletepathexp = "$exported\/"
local files : dir "`deletepathexp'" file "*.dta", respectcase	
foreach file in `files'{	
	local fileandpathtodelete = "`deletepathexp'"+"`file'"
	capture erase "`fileandpathtodelete'"
}

***************************
**  erase files in cleaning **
***************************
local deletepathclean = "$cleaning\/"
local files : dir "`deletepathclean'" file "*.dta", respectcase	
foreach file in `files'{	
	local fileandpathtodelete = "`deletepathclean'"+"`file'"
	capture erase "`fileandpathtodelete'"
}

***************************
**  erase files in corrections **
***************************
local deletepathcorr = "$corrections\/"
local files : dir "`deletepathcorr'" file "*.dta", respectcase	
foreach file in `files'{	
	local fileandpathtodelete = "`deletepathcorr'"+"`file'"
	di "`fileandpathtodelete'"
	capture erase "`fileandpathtodelete'"

}

***************************
**  Import Data **
***************************

clear
cd "$local_path"


do "import_${table_name}.do"

******************************
**Copy Files to Exported**
******************************
clear
cd "$local_path"

local files: dir "$local_path" file "*.dta", respectcase
foreach file of local files{
	di `"`file'"'
	copy `""$local_path\/`file'"' `"$exported\/`file'"', replace
	}
	
n: di "${proj}_Export ran successfully"
*}

