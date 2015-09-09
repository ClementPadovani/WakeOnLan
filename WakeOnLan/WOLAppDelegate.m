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

#import <SNRFetchedResultsController/SNRFetchedResultsController.h>
#import "WOLHistoryItem.h"


@interface WOLAppDelegate () <SNRFetchedResultsControllerDelegate>

@property (weak) IBOutlet NSMenuItem *historyMenuItem;

@property (strong) SNRFetchedResultsController *fetchedResultsController;

@end


@implementation WOLAppDelegate

- (void) applicationDidFinishLaunching:(nonnull NSNotification *)notification
{
	#ifdef RELEASE
		[[NSUserDefaults standardUserDefaults] registerDefaults:@{ @"NSApplicationCrashOnExceptions": @YES }];
	
		[Fabric with:@[[Crashlytics class]]];
	#endif
	
	NSManagedObjectContext *context = [[WOLHistoryManager sharedManager] mainContext];
	
	NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName: [WOLHistoryItem entityName]];
	
	NSSortDescriptor *lastUsedDateSortDescriptor = [NSSortDescriptor sortDescriptorWithKey: NSStringFromSelector(@selector(lastUsedDate))
														ascending: YES];
	
	[fetchRequest setSortDescriptors: @[lastUsedDateSortDescriptor]];
	
	SNRFetchedResultsController *fetchedResultsController = [[SNRFetchedResultsController alloc] initWithManagedObjectContext: context
																						    fetchRequest: fetchRequest];
	
	[fetchedResultsController setDelegate: self];
	
	NSError *fetchError = nil;
	
	if (![fetchedResultsController performFetch: &fetchError])
	{
		CPLog(@"fetch error: %@", fetchError);
		
		[NSApp presentError: fetchError];
	}
}

- (void) controllerDidChangeContent: (SNRFetchedResultsController *) controller
{
	NSMenu *historyMenu = [[self historyMenuItem] menu];
	
	[historyMenu removeAllItems];
	
	for (WOLHistoryItem *aHistoryItem in [controller fetchedObjects])
	{
		NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle: [aHistoryItem macAddress]
												action: NULL
										   keyEquivalent: @""];
		
		[historyMenu addItem: menuItem];
	}
	
	if (![historyMenu itemArray] ||
	    ![[historyMenu itemArray] count])
	{
		NSMenuItem *noItemsMenuItem = [[NSMenuItem alloc] initWithTitle: @"No History"
													  action: NULL
												keyEquivalent: @""];
		
		[noItemsMenuItem setEnabled: NO];
		
		[historyMenu addItem: noItemsMenuItem];
	}
}

- (BOOL) applicationShouldTerminateAfterLastWindowClosed: (nonnull NSApplication *) sender
{
	return YES;
}

@end
