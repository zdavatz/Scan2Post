# Scan2Post
Scan a Swiss Health Insurance card and create a HTTP(S)-Post request.

1. Scan2Post has to be able to register in Start-Up Objects in the Settings. 
2. Scan2Post has to startup when the computer is started.
3. If the User inserts a Swiss Insurance Card a HTTP-Post request is send to the URL according to the settings.
4. In the settings field you have to able to set 
 * HTTP(S) URL
 * Username
 * Passwort (optional)
 * All the Data from the card in a JSON File.
5. Software has to be installed for the User.
6. Software starts when the User logs in.

# JSON HTTP(S) Request-File
```
{
"username":"jdoe@gmail.com",
"password":"Password_that_is_optional",
"insuranceCard":{
"identificationData":{"firstName":"Peter","lastName":"Franken","birthDate":749178000000,"sex":1,"ssn":"7569999999410"},
"administrationData":{"insurance":{"id":"01234","name":"TEST"},"cardNumber":"80756012340000000582","expiryDate":1404079200000}
}}
```
# Use Case
The Users Browser with the Web-Application is open. The User scans a card. Scan2Post sends all the information from the card as a HTTP-Post request to the defined URL. The data is then processed by the API/Server and shown in the Browser.

# License
GPLv3.0 See [License](https://github.com/zdavatz/Scan2Post/blob/master/LICENSE).
