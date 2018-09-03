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
}

- (IBAction)quitClicked:(NSMenuItem *)sender
{
    [[NSApplication sharedApplication] terminate:self];
}

- (IBAction)preferencesClicked:(NSMenuItem *)sender
{
    [preferencesWindow showWindow:nil];
}

#pragma mark - PreferencesWindowDelegate

- (void)preferencesDidUpdate
{
    NSLog(@"%s", __FUNCTION__);
}
@end
