quietly {
n: di "${proj}_Edit_SurveyCTO_Do.do Started"
/*
Because you are using the review system, you need to change the macro for overwrite_old_data from 0 to 1.
You could do this manually each time there's a new SurveyCTO do-file, however this do-file will do it automatically.

// This do-file: 
// - Imports the SurveyCTO do-file into Stata using the intext command
// - Checks to see if the macro for overwrite_old_data has already been changed
// - If Yes - nothing further needed
// - If No - search for the macro, and replace it to equal 1 and save SurveyCTO do-file

*/

********************************************************************************
** 1. OVERWRITE DEFAULT MACRO FOR OVERWRITE OLD DATA
********************************************************************************
clear
intext using "$exported/import_${form_id}.do", gen(xx) length(1000)
if xx1=="**AMENDED DO-FILE" in 3 {
    di "Already amended - no change required"
}
else {
replace xx1="** AMENDED DO-FILE TO OVERWRITE DATA **" in 3
replace xx1=subinstr(xx1,"local overwrite_old_data 0","local overwrite_old_data 1", 1)

outfile xx1 using "$exported/import_${form_id}.do", runtogether replace
}

n: di "${proj}_Edit_SurveyCTO_Do.do Completed"
}

