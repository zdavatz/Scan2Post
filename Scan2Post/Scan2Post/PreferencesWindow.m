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

#pragma mark - Actions

- (IBAction)saveClicked:(NSButton *)sender
{
    NSLog(@"%s", __FUNCTION__);

#if 0
    // This way works for macOS 10.14 but not for macOS 10.13
    // Now done via bindings, but it's not very reliable.
    // Force a synchronize to make sure it's updated.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults synchronize];
#else
    // This way works both for macOS 10.14 and for macOS 10.13
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:self.serverUrlTextField.stringValue forKey:@(KEY_DEFAULTS_SERVER)];
    [defaults setValue:self.usernameTextField.stringValue forKey:@(KEY_DEFAULTS_USER)];
    [defaults setValue:self.passwordTextField.stringValue forKey:@(KEY_DEFAULTS_PASSWORD)];
#endif
    
    [self.delegate preferencesDidUpdate];
    [self.window orderOut:self];
}

//#pragma mark - NSWindowDelegate
//
//- (void)windowWillClose:(NSNotification *)notification
//{
//    NSLog(@"%s", __FUNCTION__);
//}
@end
