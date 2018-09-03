//
//  PreferencesWindow.m
//  Scan2Post
//
//  Created by Alex Bettarini on 03 Sep 2018.
//  Copyright © 2018 Alex Bettarini. All rights reserved.
//

#import "PreferencesWindow.h"

@interface PreferencesWindow ()

@end

@implementation PreferencesWindow

- (instancetype)init {
    return [self initWithWindowNibName:@"PreferencesWindow"];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    [self.window center];
    [self.window makeKeyAndOrderFront:nil];
    [NSApp activateIgnoringOtherApps:TRUE];
}

#pragma mark - NSWindowDelegate

- (void)windowWillClose:(NSNotification *)notification
{
    NSLog(@"%s", __FUNCTION__);
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:self.serverUrlTextField.stringValue forKey:@"serverUrl"];
    [defaults setValue:self.usernameTextField.stringValue forKey:@"username"];
    [defaults setValue:self.passwordTextField.stringValue forKey:@"password"];
    
    [self.delegate preferencesDidUpdate];
}
@end
