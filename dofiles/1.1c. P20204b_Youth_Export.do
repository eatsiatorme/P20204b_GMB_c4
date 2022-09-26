quietly {
n: di "${proj}_Export.do Started"

/*
// This do-file: 
// - Deletes any previously exported and saved data sets on the cloud
// - Runs the SurveyCTO do-file(s) - importing the data and then labelling variables
// - Copies the output of the SurveyCTO do-file to the 'exported' folder


*/

********************************************************************************
** 1. ERASE FILES IN EXPORT (LOCAL)
********************************************************************************
local deletepathexp = "$exported\/"
local files : dir "`deletepathexp'" file "*.dta", respectcase	
foreach file in `files'{	
	local fileandpathtodelete = "`deletepathexp'"+"`file'"
	capture erase "`fileandpathtodelete'"
}
********************************************************************************
** 2. ERASE FILES IN CLEANING (LOCAL)
********************************************************************************
local deletepathclean = "$cleaning\/"
local files : dir "`deletepathclean'" file "*.dta", respectcase	
foreach file in `files'{	
	local fileandpathtodelete = "`deletepathclean'"+"`file'"
	capture erase "`fileandpathtodelete'"
}
********************************************************************************
** 3. ERASE FILES IN CORRECTIONS (LOCAL)
********************************************************************************
local deletepathcorr = "$corrections\/"
local files : dir "`deletepathcorr'" file "*.dta", respectcase	
foreach file in `files'{	
	local fileandpathtodelete = "`deletepathcorr'"+"`file'"
	di "`fileandpathtodelete'"
	capture erase "`fileandpathtodelete'"

}

********************************************************************************
** 4. RUN SURVEYCTO DO-FILE ON EXPORTED DATA
********************************************************************************

clear
cd "$exported"


do "import_${form_id}.do"

clear
cd "$exported"
do "import_Tekki_Fii_PV_5.do"
/*
********************************************************************************
** 5. COPY FILES TO EXPORTED (LOCAL)
********************************************************************************
clear
cd "$exported"

local files: dir "$l_exported" file "*.dta", respectcase
foreach file of local files{
	di `"`file'"'
	copy `""$l_exported\/`file'"' `"$exported\/`file'"', replace
	}
	
*/
n: di "${proj}_Export ran successfully"
}

