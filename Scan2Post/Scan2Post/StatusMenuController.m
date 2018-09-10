//
//  StatusMenuController.m
//  Scan2Post
//
//  Created by Alex Bettarini on 03 Sep 2018.
//  Copyright © 2018 Alex Bettarini. All rights reserved.
//

#import "StatusMenuController.h"
#import <ServiceManagement/ServiceManagement.h>

//#define WITH_COMMS_AUTHENTICATION

@implementation StatusMenuController

- (void)awakeFromNib
{
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    icon = [NSImage imageNamed:@"statusIcon"];
    //icon.template = TRUE; // best for dark mode
    statusItem.image = icon;
    statusItem.menu = self.statusMenu;
    
    preferencesWindow = [PreferencesWindow new];
    preferencesWindow.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(newHealthCardData:)
                                                 name:@"smartCardDataAcquired"
                                               object:nil];
    
    healthCard = [[HealthCard alloc] init];
}

#pragma mark - Actions

- (IBAction)quitClicked:(NSMenuItem *)sender
{
    [[NSApplication sharedApplication] terminate:self];
}

- (IBAction)preferencesClicked:(NSMenuItem *)sender
{
#if false
    // Prefill the fields
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *s = [defaults stringForKey:@(KEY_DEFAULTS_USER)];
    [preferencesWindow.usernameTextField setStringValue:[defaults stringForKey:@(KEY_DEFAULTS_USER)]];
#endif
    
    [preferencesWindow showWindow:nil];
    [NSApp activateIgnoringOtherApps:TRUE]; // to foreground
}

#pragma mark - PreferencesWindowDelegate

- (void)preferencesDidUpdate
{
    BOOL state = [[NSUserDefaults standardUserDefaults] boolForKey:@"launchAtLogin"];  // updated via bindings
    NSLog(@"%s, launch at login: %d", __FUNCTION__, state);
    if (!SMLoginItemSetEnabled((__bridge CFStringRef)@"com.ywesee.Scan2Post-Helper", state))
    {
        NSLog(@"Login Item Was Not Successful");
    }
}

#pragma mark - Notifications

- (void) newHealthCardData:(NSNotification *)notification
{
    NSDictionary *cardDict = [notification object];
    NSLog(@"%s NSNotification:%@", __FUNCTION__, cardDict);

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    // Prepare JSON object
    NSDictionary *jsonDict = [NSDictionary dictionaryWithObjectsAndKeys:
                              [defaults stringForKey:@(KEY_DEFAULTS_USER)], @(KEY_JSON_USER),
                              [defaults stringForKey:@(KEY_DEFAULTS_PASSWORD)], @(KEY_JSON_PASSWORD),
                              cardDict, @(KEY_JSON_CARD),
                              nil];
#ifdef DEBUG
    NSLog(@"Line %d, NSDictionary:\n%@", __LINE__, jsonDict);
#endif

    NSError *error = nil;
    NSData *jsonObject = [NSJSONSerialization dataWithJSONObject:jsonDict
                                                         options:NSJSONWritingPrettyPrinted
                                                           error:&error];
    // BOOL success = [jsonObject writeToFile:path options:NSUTF8StringEncoding error:&error];
    //NSLog(@"Line %d, JSON data:%@", __LINE__, jsonObject);
    
    NSString *jsonStr = [[NSString alloc] initWithData:jsonObject encoding:NSUTF8StringEncoding];
    NSLog(@"Line %d, JSON string:\n%@", __LINE__, jsonStr);

    [self sendToServer:jsonStr];
}

#pragma mark -

- (void) sendToServer:(NSString *)data
{
    NSString *serverURL = [[NSUserDefaults standardUserDefaults] stringForKey:@(KEY_DEFAULTS_SERVER)];
    NSURL *url = [NSURL URLWithString:serverURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];

#ifdef WITH_COMMS_AUTHENTICATION
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *username = [defaults stringForKey:@(KEY_DEFAULTS_USER)];
    NSString *password = [defaults stringForKey:@(KEY_DEFAULTS_PASSWORD)];

    if (username.length > 0 &&
        password.length > 0 &&
        [url.scheme isEqualToString:@"http"])
    {
        // create a plaintext string in the format username:password
        NSString *loginString = [NSString stringWithFormat:@"%@:%@", username, password];

        // employ the Base64 encoding above to encode the authentication tokens
        NSData *plainData = [loginString dataUsingEncoding:NSUTF8StringEncoding];
        NSString *encodedLoginData = [plainData base64EncodedStringWithOptions:(NSDataBase64Encoding76CharacterLineLength)];

        NSString *authHeader = [NSString stringWithFormat:@"Basic %@", encodedLoginData];
        [request setValue:authHeader forHTTPHeaderField:@"Authorization"];

    }
    else if ([url.scheme isEqualToString:@"https"]) {
        // TODO: TLS authentication
        //[NSURLRequest setAllowsAnyHTTPSCertificate:YES forHost:[url host]];
    }
#endif

    request.HTTPMethod = @"POST";
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    request.HTTPBody = [data dataUsingEncoding:NSUTF8StringEncoding];
    request.timeoutInterval = 30.0;
    
#ifdef DEBUG
    NSLog(@"serverURL:<%@>\nscheme:%@", serverURL, url.scheme);
    NSLog(@"request header:%@", request.allHTTPHeaderFields);
#endif
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    
    NSURLSessionUploadTask *uploadTask =
    [session uploadTaskWithRequest:request
                          fromData:[data dataUsingEncoding:NSUTF8StringEncoding]
                 completionHandler:^(NSData *dataRx, NSURLResponse *response, NSError *error) {
        
                     if (error) {
                         // No response from the server
#ifdef DEBUG
                         NSLog(@"%@", error);
#else
                         NSLog(@"%@", error.localizedDescription);
#endif
                     }
                     else {
                         // There was some response from the server
                         NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                         if (httpResponse.statusCode != 200 ) {
#ifdef DEBUG
                             NSLog(@"%@", response);
#endif
                             NSLog(@"%@", [NSHTTPURLResponse localizedStringForStatusCode:httpResponse.statusCode]);
                         }
                         
                         if (dataRx.length > 0) {
                             NSString * dataStr =[[NSString alloc] initWithData:dataRx encoding:NSUTF8StringEncoding];
                             NSLog(@"dataRx:\n%@\n%@", dataRx, dataStr);
                         }
                     }
                 }];

    [uploadTask resume];
}
@end
