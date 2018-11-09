//
//  PreferencesWindow.h
//  Scan2Post
//
//  Created by Alex Bettarini on 03 Sep 2018.
//  Copyright © 2018 Alex Bettarini. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define INITIAL_SERVER_URL          "https://elstage.pharmedsolutions.ch/api/1.0/insurance-card"

#define KEY_DEFAULTS_SERVER         "serverUrl"
#define KEY_DEFAULTS_USER           "username"
#define KEY_DEFAULTS_PASSWORD       "password"

@protocol PreferencesWindowDelegate <NSObject>
- (void)preferencesDidUpdate;
@end

@interface PreferencesWindow : NSWindowController <NSWindowDelegate>

@property (nonatomic, weak) id<PreferencesWindowDelegate> delegate;

@property (weak) IBOutlet NSTextField *serverUrlTextField;
@property (weak) IBOutlet NSTextField *usernameTextField;
@property (weak) IBOutlet NSTextField *passwordTextField;

- (IBAction)saveClicked:(NSButton *)sender;

@end
