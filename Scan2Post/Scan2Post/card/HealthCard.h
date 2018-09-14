//
//  HealthCard.h
//  Scan2Post
//
//  Created by Alex Bettarini on 22 May 2018
//  Copyright © 2018 Ywesee GmbH. All rights reserved.
//

#import "SmartCard.h"

////////////////////////////////////////////////////////////////////////////////
#define KEY_CARD_NAME           "firstName"    // KEY_AMK_PAT_NAME in AmiKo
#define KEY_CARD_SURNAME        "lastName"     // KEY_AMK_PAT_SURNAME
#define KEY_CARD_BIRTHDATE      "birthDate"    // KEY_AMK_PAT_BIRTHDATE
#define KEY_CARD_GENDER         "sex"          // KEY_AMK_PAT_GENDER
#define KEY_CARD_AVS            "ssn"          // not in AmiKo

#define KEY_CARD_EXPIRY         "expiryDate"    // not in AmiKo
#define KEY_CARD_NUMBER         "cardNumber"    // not in AmiKo

////////////////////////////////////////////////////////////////////////////////
#define KEY_JSON_USER           "username"
#define KEY_JSON_PASSWORD       "password"
#define KEY_JSON_CARD           "insuranceCard"
#define KEY_JSON_CARD_ID        "identificationData"
#define KEY_JSON_CARD_ADMIN     "administrationData"
#define KEY_JSON_CARD_ADMIN_INS         "insurance"
#define KEY_JSON_CARD_ADMIN_INS_ID      "id"
#define KEY_JSON_CARD_ADMIN_INS_NAME    "name"

////////////////////////////////////////////////////////////////////////////////
//#define WITH_GENDER_AS_STRING
//#define WITH_EXPIRY_DATE_AS_STRING
//#define WITH_BIRTH_DATE_AS_STRING

@interface HealthCard : SmartCard
{
    NSString *familyName;
    NSString *givenName;

#ifdef WITH_BIRTH_DATE_AS_STRING
    NSString *birthDate;
#else
    int birthDate;
#endif

#ifdef WITH_GENDER_AS_STRING
    NSString *gender;
#else
    uint8_t sexEnum;
#endif

    NSString *cardHolderID; // AVS or SSN

#ifdef WITH_EXPIRY_DATE_AS_STRING
    NSString *expiryDate;
#else
    int expiryDate;
#endif

    NSString *insuredPersonNumber;
    NSString *institutionID;
    NSString *institutionName;
}

- (uint8_t) parseTLV:(NSData *)data;
- (void) parseCardData:(NSData *)data;

@end
