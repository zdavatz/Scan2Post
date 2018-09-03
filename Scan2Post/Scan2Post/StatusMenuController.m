//
//  StatusMenuController.m
//  Scan2Post
//
//  Created by Alex Bettarini on 03 Sep 2018.
//  Copyright © 2018 Alex Bettarini. All rights reserved.
//

#import "StatusMenuController.h"

@implementation StatusMenuController

- (void)awakeFromNib {
    NSLog(@"%s", __FUNCTION__);
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    icon = [NSImage imageNamed:@"statusIcon"];
    //icon.template = TRUE; // best for dark mode
    statusItem.image = icon;
    statusItem.menu = self.statusMenu;
}

- (IBAction)quitClicked:(id)sender {
    [[NSApplication sharedApplication] terminate:self];
}
@end
