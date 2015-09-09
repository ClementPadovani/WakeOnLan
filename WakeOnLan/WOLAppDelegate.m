//
//  WOLAppDelegate.m
//  WakeOnLan
//
//  Created by Clément Padovani on 7/31/15.
//  Copyright © 2015 Clément Padovani. All rights reserved.
//

#ifdef RELEASE
@import Fabric;
@import Crashlytics;
#endif

#import "WOLAppDelegate.h"
#import "WOLHistoryManager.h"


@interface WOLAppDelegate ()

@property (weak) IBOutlet NSMenuItem *historyMenuItem;

@end


@implementation WOLAppDelegate

- (void) applicationDidFinishLaunching:(nonnull NSNotification *)notification
{
	#ifdef RELEASE
		[[NSUserDefaults standardUserDefaults] registerDefaults:@{ @"NSApplicationCrashOnExceptions": @YES }];
	
		[Fabric with:@[[Crashlytics class]]];
	#endif
	
	
}

- (BOOL) applicationShouldTerminateAfterLastWindowClosed: (nonnull NSApplication *) sender
{
	return YES;
}

@end
