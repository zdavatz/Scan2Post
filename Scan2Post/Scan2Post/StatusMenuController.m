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

#pragma mark - Notifications

- (void) newHealthCardData:(NSNotification *)notification
{
    NSDictionary *cardDict = [notification object];
    NSLog(@"%s NSNotification:%@", __FUNCTION__, cardDict);

    NSDictionary *idDict = [cardDict valueForKeyPath:@"id"];
    NSDictionary *adminDict = [cardDict valueForKeyPath:@"admin"];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    // Prepare JSON object
    NSDictionary *jsonDict = [NSDictionary dictionaryWithObjectsAndKeys:
                              [defaults stringForKey:@(KEY_DEFAULTS_USER)], @(KEY_JSON_USER),
                              [defaults stringForKey:@(KEY_DEFAULTS_PASSWORD)], @(KEY_JSON_PASSWORD),
#if true
                              cardDict, @(KEY_JSON_CARD),
#else
                              idDict, @(KEY_JSON_CARD_ID),
                              adminDict, @(KEY_JSON_CARD_ADMIN),
#endif
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

    // TODO: send to server
    NSString *serverURL = [defaults stringForKey:@"serverUrl"];
}

@end
