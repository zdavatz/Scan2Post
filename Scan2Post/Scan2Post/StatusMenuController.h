//
//  StatusMenuController.h
//  Scan2Post
//
//  Created by Alex Bettarini on 03 Sep 2018.
//  Copyright © 2018 Alex Bettarini. All rights reserved.
//

#import <Cocoa/Cocoa.h>
//#import <Foundation/Foundation.h>

@interface StatusMenuController : NSObject
{
    NSStatusItem *statusItem;
    NSImage *icon;
}

@property (weak) IBOutlet NSMenu *statusMenu;

- (IBAction)quitClicked:(id)sender;

@end
