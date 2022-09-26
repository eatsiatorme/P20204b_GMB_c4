/*
// This do-file: 
// - Creates a dataset that holds the PII data only and a link variable (pii_obs) and saves it in the encrpyted folder. 
// - Creates a dataset called NoPII that doesn't include any PII and saves it in the data folder on OneDrive - unencrypted. This allows for easy access with the research team for analysis.
// - If you ever have to share data with a client you should share both these datasets separately and they can link them together
// - Similarly, although PII is rarely used for analysis, then they should link these together if PII variables are needed for the analysis

*/



use "$corrections\/${form_title}.dta", clear
preserve
keep $unique_id full_name id1a id1b z2 z1_text
save "$pii_link\piilink_obs.dta", replace
restore
drop full_name id1a id1b z2 z1_text
save "$data_anon\/${form_title}_NoPII.dta", replace 





/*
preserve
keep $personal_info
bysort $personal_info: keep if _n==1
egen pii_obs = rank(runiform()), unique
label var pii_obs "Unique observation ID"  
save "$pii_link\piilink_obs.dta", replace
restore
merge m:1 $personal_info using "$pii_link\piilink_obs.dta", nogen assert(3)
drop $personal_info
order pii_obs
save "$data_anon\/${form_title}_NoPII.dta", replace 
*/

n: di "${proj}_Data_Protection ran successfully"































