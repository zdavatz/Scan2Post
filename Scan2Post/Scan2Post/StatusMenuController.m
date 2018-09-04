//
//  StatusMenuController.m
//  Scan2Post
//
//  Created by Alex Bettarini on 03 Sep 2018.
//  Copyright © 2018 Alex Bettarini. All rights reserved.
//

#import "StatusMenuController.h"

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
    NSLog(@"%s", __FUNCTION__);
}

#pragma  mark - NSURLConnectionDelegate

// the server has responded
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    NSLog(@"%s status code:%ld", __FUNCTION__, (long)[httpResponse statusCode]);

    // A response has been received, this is where we initialize the instance var you created
    // so that we can append data to it in the didReceiveData method
    // Furthermore, this method is called each time there is a redirect so reinitializing it
    // also serves to clear it
    responseData = [[NSMutableData alloc] init];
}

// This can be called weveral times
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSLog(@"%s", __FUNCTION__);
    [responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"%s", __FUNCTION__);
    // The request is complete and data has been received
    // You can parse the stuff in your instance variable now
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    // The request has failed for some reason!
    // Check the error var
    NSLog(@"%s %@ %@ %@", __FUNCTION__,
          error,
          error.localizedDescription,
          error.localizedFailureReason);
}

- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    NSLog(@"%s", __FUNCTION__);
    if ([challenge previousFailureCount] == 0) {
        NSLog(@"received authentication challenge");
        NSURLCredential *newCredential = [NSURLCredential credentialWithUser:@"USER"
                                                                    password:@"PASSWORD"
                                                                 persistence:NSURLCredentialPersistenceForSession];
        NSLog(@"credential created");
        [[challenge sender] useCredential:newCredential forAuthenticationChallenge:challenge];
        NSLog(@"responded to authentication challenge");
    }
    else {
        NSLog(@"previous authentication failure");
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
    NSLog(@"serverURL:<%@>\nscheme:%@", serverURL, url.scheme);
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];

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

    request.HTTPMethod = @"POST";
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"]; // header field
    request.HTTPBody = [data dataUsingEncoding:NSUTF8StringEncoding];
    request.timeoutInterval = 30.0;
    NSLog(@"request header:%@", request.allHTTPHeaderFields);
    
#if 0
    // Asynch
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request
                                                            delegate:self];
    [conn start];
#else
    // Synch
    NSHTTPURLResponse *response;
    NSError *error = nil;
    NSData *dataRx = [NSURLConnection sendSynchronousRequest:request
                                           returningResponse:&response
                                                       error:&error];
    if (error == nil) {
#ifdef DEBUG
        // 405 unsupported method POST
        //if (response.statusCode != 200 )
        {
            NSLog(@"%s line %d, response:%@\n%@", __FUNCTION__,
                  __LINE__,
                  response,
                  [NSHTTPURLResponse localizedStringForStatusCode:response.statusCode]);
        }
        NSString * dataStr =[[NSString alloc] initWithData:dataRx encoding:NSUTF8StringEncoding];
        NSLog(@"dataRx:\n%@\n<%@>", dataRx, dataStr);
#endif
        // Parse data here
    }
#endif
}
@end
