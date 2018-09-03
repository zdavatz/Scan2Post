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

//- (NSNibName *) windowNibName {
//    return (NSNibName *)@"PreferencesWindow";
//}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    [self.window center];
    [self.window makeKeyAndOrderFront:nil];
    [NSApp activateIgnoringOtherApps:TRUE];
}

@end
