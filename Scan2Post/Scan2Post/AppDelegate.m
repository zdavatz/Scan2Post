//
//  AppDelegate.m
//  Scan2Post
//
//  Created by Alex Bettarini on 03 Sep 2018.
//  Copyright © 2018 Alex Bettarini. All rights reserved.
//

#import "AppDelegate.h"
#import "PreferencesWindow.h"

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
    
    NSDictionary *initialValues = [NSDictionary dictionaryWithObjectsAndKeys:
                                 @(INITIAL_SERVER_URL), @(KEY_DEFAULTS_SERVER),
                                 nil];
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:initialValues];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
}
@end
