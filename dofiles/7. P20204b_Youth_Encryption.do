quietly {
n: di "${proj}_Encryption.do Started"

/*
// This do-file: 
// - Dismounts any mounted vaults on the VeraCrpyt - an encrypts 

*/
capture veracrypt, dismount drive("${l_encrypted_drive}")



n: di "${proj}_Encryption.do Completed"
}