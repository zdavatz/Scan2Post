# Scan2Post
* Scan a Swiss Health Insurance card and create a HTTP(S)-Post request.
* Supported Scanner is [PX-8935-919](http://www.xystec.info/USB-Chipkartenleser-HBCI-faehig-Smart-Car-PX-8935-919.shtml) from Xystec.

## Features
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
11. Deployment Target is 10.12.
12. A Reference we used: [WeatherBar](http://footle.org/WeatherBar/)
13. Copy and Pasting via Mouse.

## JSON HTTP(S) Post-Request File
```
{
"username":"jdoe@gmail.com",
"password":"Password_that_is_optional",
"insuranceCard":{
"identificationData":{"firstName":"65.80.50","lastName":"65.80.50","birthDate":65.82.8,"sex":65.84.1,"ssn":"65.83.13"},
"administrationData":{"insurance":{"id":"65.92.5","name":"65.91.50"},"cardNumber":"65.93.20","expiryDate":65.94.8}
}}
```
1. All dates set to UNIX timestamp and mmdd set to 0 (zero) and milliseconds also set to 0 (zero).
2. [Swiss Insurance Card Reference](https://github.com/zdavatz/amiko-osx/files/2018228/Implementierungsanleitung.fur.die.Versichertenkarte.nach.eCH-0064.der.SASIS.AG.pdf).
3. [HTTP Server useful for testing](https://gist.github.com/dtchepak/13b53eef9dc6b65ae1ad)
4. Password can be used for Server-Side Authentication.

## Use Case
The User's Browser with the Web-Application is open. The User inserts a card into the card reader. Scan2Post sends all the information from the card as a HTTP-Post request to the defined URL in a JSON File. The data is then processed by the API/Server and the Web-App can refresh with the Data that was sent via the HTTP-Post-Request.

# License
GPLv3.0 See [License](https://github.com/zdavatz/Scan2Post/blob/master/LICENSE).

# Contact
```
Zeno Davatz
ywesee GmbH
zdavatz at ywesee dot com
+41 43 540 05 50
```
# Copyright
©ywesee GmbH, all rights reserved.
