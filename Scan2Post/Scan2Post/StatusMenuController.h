//
//  StatusMenuController.h
//  Scan2Post
//
//  Created by Alex Bettarini on 03 Sep 2018.
//  Copyright © 2018 Alex Bettarini. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PreferencesWindow.h"
#import "HealthCard.h"

@interface StatusMenuController : NSObject <PreferencesWindowDelegate, NSURLConnectionDelegate>
{
    NSStatusItem *statusItem;
    NSImage *icon;
    PreferencesWindow *preferencesWindow;
    HealthCard *healthCard;
    
    NSMutableData *responseData;
}

@property (weak) IBOutlet NSMenu *statusMenu;

- (IBAction)quitClicked:(NSMenuItem *)sender;
- (IBAction)preferencesClicked:(NSMenuItem *)sender;

- (void) newHealthCardData:(NSNotification *)notification;

- (void) sendToServer:(NSString *)data;

@end
