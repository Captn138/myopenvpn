$OLD_DIR=Get-Location
cd 'C:\Program Files\OpenVPN\easy-rsa\'
 
$CLIENT_NAME=Read-Host "Nom du nouveau client: "
 
$PKI_PATH="C:\\Program Files\\OpenVPN\\easy-rsa\\pki"
$CRT_PATH="C:\\Program Files\\OpenVPN\\easy-rsa\\pki\\issued"
$KEY_PATH="C:\\Program Files\\OpenVPN\\easy-rsa\\pki\\private"
$BASE_CONFIG="C:\\Program Files\\OpenVPN\\clients\\base.txt"
$OUTPUT_DIR="C:\\Program Files\\OpenVPN\\clients"
 
Write-Output "easyrsa build-client-full $CLIENT_NAME" | .\EasyRSA-Start.bat
 
Get-Content $BASE_CONFIG > $OUTPUT_DIR\\$CLIENT_NAME.ovpn
Write-Output "<ca>" >> $OUTPUT_DIR\\$CLIENT_NAME.ovpn
Get-Content $PKI_PATH\\ca.crt >> $OUTPUT_DIR\\$CLIENT_NAME.ovpn
Write-Output "</ca>" >> $OUTPUT_DIR\\$CLIENT_NAME.ovpn
Write-Output "<cert>" >> $OUTPUT_DIR\\$CLIENT_NAME.ovpn
Get-Content $CRT_PATH\\$CLIENT_NAME.crt >> $OUTPUT_DIR\\$CLIENT_NAME.ovpn
Write-Output "</cert>" >> $OUTPUT_DIR\\$CLIENT_NAME.ovpn
Write-Output "<key>" >> $OUTPUT_DIR\\$CLIENT_NAME.ovpn
Get-Content $KEY_PATH\\$CLIENT_NAME.key >> $OUTPUT_DIR\\$CLIENT_NAME.ovpn
Write-Output "</key>" >> $OUTPUT_DIR\\$CLIENT_NAME.ovpn
 
cd $OLD_DIR
