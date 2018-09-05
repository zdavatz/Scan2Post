//
//  HealthCard.m
//  Scan2Post
//
//  Created by Alex Bettarini on 22 May 2018
//  Copyright © 2018 Ywesee GmbH. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "HealthCard.h"

@interface HealthCard ()
- (NSDate *) stringToDate:(NSString *)dateString;
@end

@implementation HealthCard

- (NSDate *) stringToDate:(NSString *)dateString
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setTimeZone:[NSTimeZone systemTimeZone]];
    [dateFormat setDateFormat:@"yyyyMMdd"];

    return [dateFormat dateFromString:dateString];
}

- (uint8_t) parseTLV:(NSData *)data
{
    //NSLog(@"%s %lu %@", __FUNCTION__, (unsigned long)data.length, data);
    NSString *s;
    uint8_t *bytes = (uint8_t *)[data bytes];
    uint8_t tag = bytes[0];
    uint8_t length = bytes[1];
    NSData* value = [data subdataWithRange:NSMakeRange(2, length)];
    //NSLog(@"T:0x%02x, L:%d, V: %@", tag, length, value);
    switch (tag) {
        case 0x80:  // UTF8InternationalString
        {
            s = [[NSString alloc] initWithData:value encoding:NSUTF8StringEncoding];
            NSArray *a = [s componentsSeparatedByString:@", "];
            familyName = [a objectAtIndex:0];
            givenName = @"";
            if (a.count > 1)
                givenName = [a objectAtIndex:1];
            //NSLog(@"Name <%@>", a);
        }
            break;
            
        case 0x82:  // NUMERIC STRING
        {
            s = [[NSString alloc] initWithData:value encoding:NSUTF8StringEncoding];
            //NSLog(@"DOB yyyyMMdd <%@>", s);
            NSDate *dob = [self stringToDate:s];
            
#ifdef WITH_BIRTH_DATE_AS_STRING
            [dateFormat setDateFormat:@"dd.MM.yyyy"];   // to this
            birthDate = [dateFormat stringFromDate:dob];
            //NSLog(@"DOB dd.mm.yyyy <%@>", birthDate);
#else
            // UNIX time-stamp
            birthDate = (int)[dob timeIntervalSince1970];
            //NSLog(@"DOB time stamp:%i", birthDate);
#endif
        }
            break;
            
        case 0x83:  // UTF8InternationalString
            cardHolderID = [[NSString alloc] initWithData:value encoding:NSUTF8StringEncoding];
            NSLog(@"Card holder ID <%@>", cardHolderID);
            break;
            
        case 0x84:  // ENUMERATED
#ifdef WITH_GENDER_AS_STRING
        {
            uint8_t sexEnum = *(uint8_t *)[value bytes];
            NSLog(@"Sex %d (1=male, 2=female, 0=not known, 9=not appl.)", sexEnum);
            if (sexEnum == 1)
                gender = @"man";
            else if (sexEnum == 2)
                gender = @"woman";
            else
                gender = @"";
        }
#else
            sexEnum = *(uint8_t *)[value bytes];
#endif
            break;
            
        case 0x90: // UTF8InternationalString
            s = [[NSString alloc] initWithData:value encoding:NSUTF8StringEncoding];
            NSLog(@"Issuing State ID Number <%@>", s);
            break;
            
        case 0x91: // UTF8InternationalString
            institutionName = [[NSString alloc] initWithData:value encoding:NSUTF8StringEncoding];
            NSLog(@"name Of The Institution <%@>", institutionName);
            break;
            
        case 0x92:  // NUMERIC STRING
            institutionID = [[NSString alloc] initWithData:value encoding:NSUTF8StringEncoding];
            NSLog(@"identificationNumber Of The Institution <%@>", institutionID);
            break;
            
        case 0x93: // UTF8InternationalString
            insuredPersonNumber = [[NSString alloc] initWithData:value encoding:NSUTF8StringEncoding];
            NSLog(@"Insured Person Number <%@>", insuredPersonNumber);
            break;
            
        case 0x94:  // NUMERIC STRING
#ifdef WITH_EXPIRY_DATE_AS_STRING
            expiryDate = [[NSString alloc] initWithData:value encoding:NSUTF8StringEncoding];
            NSLog(@"ExpiryDate yyyyMMdd <%@>", expiryDate);
#else
            {
                // UNIX time-stamp
                s = [[NSString alloc] initWithData:value encoding:NSUTF8StringEncoding];
                NSDate *ed = [self stringToDate:s];
                expiryDate = (int)[ed timeIntervalSince1970];
                //NSLog(@"ExpiryDate time stamp:%i", expiryDate);
            }
#endif
            break;
            
        default:
            NSLog(@"T:0x%02x, L:%d, V: <%@>", tag, length, value);
            break;
    }
    return length+2;
}

- (void) parseCardData:(NSData *)data
{
    NSRange dataRange;
    uint8_t offset = 0;
    
    //NSLog(@"%s %lu %@", __FUNCTION__, (unsigned long)data.length, data);
    uint8_t *bytes = (uint8_t *)[data bytes];
    uint8_t packetType = bytes[0];
    uint8_t packetSize = bytes[1];
    NSData* payload = [data subdataWithRange:NSMakeRange(2, packetSize)];
    //NSLog(@"=== payload:%@", payload);
    switch (packetType) {
        case 0x65:
            while (offset < packetSize) {
                dataRange = NSMakeRange(offset, packetSize-offset);
                offset += [self parseTLV:[payload subdataWithRange:dataRange]];
                //NSLog(@"line %d, offset:0x%02x=%d", __LINE__, offset, offset);
            }
            break;
            
        default:
            break;
    }
}

- (BOOL) validAtr: (TKSmartCardATR *) atr
{
    uint8_t mutuelBytes[] = {
        0x3b, 0x9f, 0x13, 0x81, 0xb1, 0x80, 0x37, 0x1f,
        0x03, 0x80, 0x31, 0xf8, 0x69, 0x4d, 0x54, 0x43,
        0x4f, 0x53, 0x70, 0x02, 0x01, 0x02, 0x81, 0x07, 0x86};

    NSData *mutuelData = [NSData dataWithBytes:mutuelBytes
                                  length:sizeof mutuelBytes];

    if (![atr.bytes isEqual:mutuelData])
    {
        //NSLog(@"card %@", atr.bytes);
        //NSLog(@"mutu %@", mutuelData);
        NSString *part1 = NSLocalizedString(@"This card can not be read", nil);
        NSString *part2 = [NSString stringWithFormat:NSLocalizedString(@"Please contact Zeno Davatz\nzdavatz@ywesee.com\n+41 43 540 05 50\nATR: %@", nil),
                           atr.bytes];
        
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:part1];
        [alert setInformativeText:part2];
        dispatch_sync(dispatch_get_main_queue(), ^{
            [alert runModal];
        });
        
        return false;
    }

    return true;
}

- (void) processValidCard: (TKSmartCard *) sc
{
    //NSLog(@"%s", __FUNCTION__);

    uint8_t ef_id[] = {0x2f, 0x06};
    NSData *filePath = [NSData dataWithBytes:ef_id length:sizeof ef_id];
    [self scSelectFile:sc byPath:filePath];
    
    [sc sendIns:INS_READ_BIN // READ BINARY
             p1:0
             p2:0
           data:nil
             le:[NSNumber numberWithInt:84] // what we expect *back*
          reply:^(NSData *replyData, UInt16 sw, NSError *error2) {
              if (error2)
                  NSLog(@"Line %d READ_BIN, %@", __LINE__, error2);
              
              assert(!error2);
//            NSLog(@"SW:      %02x/%02x", sw >> 8, sw & 0xFF);
//            NSLog(@"Serial:  %@", replyData);
              [self parseCardData:replyData];
          }
     ];

    [NSThread sleepForTimeInterval:0.5f];

    uint8_t ef_ad[] = {0x2f, 0x07};
    filePath = [NSData dataWithBytes:ef_ad length:sizeof ef_ad];
    [self scSelectFile:sc byPath:filePath];
    
    [sc sendIns:INS_READ_BIN // READ BINARY
             p1:0
             p2:0
           data:nil
             le:[NSNumber numberWithInt:95] // what we expect *back*
          reply:^(NSData *replyData, UInt16 sw, NSError *error2) {
              if (error2)
                  NSLog(@"Line %d READ_BIN, %@", __LINE__, error2);

              assert(!error2);
//            NSLog(@"SW:      %02x/%02x", sw >> 8, sw & 0xFF);
//            NSLog(@"Serial:  %@", replyData);
              [self parseCardData:replyData];
              
              NSDictionary *idData = [NSDictionary dictionaryWithObjectsAndKeys:
                                           self->givenName,    @(KEY_CARD_NAME),
                                           self->familyName,   @(KEY_CARD_SURNAME),

#ifdef WITH_BIRTH_DATE_AS_STRING
                                           self->birthDate,    @(KEY_CARD_BIRTHDATE),
#else
                                           [NSNumber numberWithInt:self->birthDate], @(KEY_CARD_BIRTHDATE),
#endif

#ifdef WITH_GENDER_AS_STRING
                                           self->gender,       @(KEY_CARD_GENDER),
#else
                                           [NSNumber numberWithInt:self->sexEnum], @(KEY_CARD_GENDER),
#endif
                                           self->cardHolderID, @(KEY_CARD_AVS),
                                        nil];

              NSDictionary *institution = [NSDictionary dictionaryWithObjectsAndKeys:
                                         self->institutionID, @(KEY_JSON_CARD_ADMIN_INS_ID),
                                         self->institutionName, @(KEY_JSON_CARD_ADMIN_INS_NAME),
                                         nil];

              NSDictionary *adminData = [NSDictionary dictionaryWithObjectsAndKeys:
#ifdef WITH_EXPIRY_DATE_AS_STRING
                                         self->expiryDate, @(KEY_CARD_EXPIRY),
#else
                                         [NSNumber numberWithInt:self->expiryDate], @(KEY_CARD_EXPIRY),
#endif
                                         self->insuredPersonNumber, @(KEY_CARD_NUMBER),
                                         institution, @(KEY_JSON_CARD_ADMIN_INS),
                                         nil];
              
              // We are required to split it into identification and administration data
              NSMutableDictionary *cardData = [NSMutableDictionary dictionary];
              cardData[@(KEY_JSON_CARD_ID)] = idData;
              cardData[@(KEY_JSON_CARD_ADMIN)] = adminData;
              
              [[NSNotificationCenter defaultCenter] postNotificationName:@"smartCardDataAcquired"
                                                                  object:cardData];
          }
     ];
}

@end
