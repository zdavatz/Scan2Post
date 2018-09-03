# Scan2Post
Scan a Swiss Health Insurance card and create a HTTP(S)-Post request.

1. Scan2Post has to be able to register in Start-Up Objects in the Settings. 
2. Scan2Post has to startup when the computer is started. Scan2Post has no Gui only a preferences field.
3. If the User inserts a Swiss Insurance Card a HTTP-Post request is send to the URL according to the settings.
4. In the settings field you have to able to set 
 * HTTP(S) URL
 * Username
 * Password (optional)
5. All the Data from the card in a JSON File. See sample below.
6. Software has to be installed for the User.
7. Software starts when the User logs in.
8. The User has to be able to quit the application.
8. When you run the application the first time then the User is asked: "Do you want to add Scan2Post to startup automatically at login?"
10. If you click the Icon on the top bar, then you can close the Scan2Post application or access the settings, see 4.
11. Deployment Target is 10.8.

# JSON HTTP(S) Post-Request File
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
The User's Browser with the Web-Application is open. The User inserts a card into the card reader. Scan2Post sends all the information from the card as a HTTP-Post request to the defined URL in a JSON File. The data is then processed by the API/Server and the Web-App can refresh with the Data that was sent via the HTTP-Post-Request.

# License
GPLv3.0 See [License](https://github.com/zdavatz/Scan2Post/blob/master/LICENSE).
