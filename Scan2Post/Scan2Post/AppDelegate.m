//
//  AppDelegate.m
//  Scan2Post
//
//  Created by Alex Bettarini on 03 Sep 2018.
//  Copyright © 2018 Alex Bettarini. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
#ifdef DEBUG
    NSDictionary *d = [[NSBundle mainBundle] infoDictionary];
    NSString *bundleIdentifier = [d objectForKey:@"CFBundleIdentifier"];
    NSLog(@"Defaults file:\n\t%@/Preferences/%@.plist",
          NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).firstObject,
          bundleIdentifier);
#endif
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
}
@end
