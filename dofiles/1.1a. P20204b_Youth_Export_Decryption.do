quietly {
n: di "${proj}_Export_Decryption.do Started"

/*
// This do-file: 
// - Automatically dismounts any mounted vaults on the VeraCrpyt paths you will be using. 
// - Mounts both the vaults on your local drive and your cloud that holds PII information. 
// - Ensures that the correct directories are created on the mounted drives.

*/

********************************************************************************
** 1. MOUNT ON VERACRYPT (LOCAL)
********************************************************************************
capture veracrypt, dismount drive("${l_encrypted_drive}")
cd "$local_path"
veracrypt "vault", mount drive($l_encrypted_drive)

*global l_exported "$l_encrypted_path\exported"
capture mkdir "$exported"
capture mkdir "$corrections"
capture mkdir "$cleaning"
capture mkdir "$pii_link"

/*
********************************************************************************
** 2. MOUNT ON VERACRYPT (CLOUD)
********************************************************************************
capture veracrypt, dismount drive(B)
cd "$raw_path"
veracrypt "Raw_Data_Cloud", mount drive($c_encrypted_drive)

*global exported "$c_encrypted_path\exported"
*global corrections "$c_encrypted_path\corrections"
*global cleaning "$c_encrypted_path\cleaning"

capture mkdir "$exported"
capture mkdir "$corrections"
capture mkdir "$cleaning"
capture mkdir "$pii_link"

*/

n: di "${proj}_Decryption.do Completed"
}

