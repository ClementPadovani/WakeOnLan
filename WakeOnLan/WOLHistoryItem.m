//
//  WOLHistoryItem.m
//  WakeOnLan
//
//  Created by Clément Padovani on 9/9/15.
//  Copyright © 2015 Clément Padovani. All rights reserved.
//

#import "WOLHistoryItem.h"

@interface WOLHistoryItem (PrivateMethods)

+ (instancetype) internal_historyItemForMACAddress: (NSString * __nonnull) itemMACAddress inManagedObjectContext: (NSManagedObjectContext * __nonnull) managedObjectContext;

@end


@implementation WOLHistoryItem

+ (instancetype) historyItemForMACAddress: (NSString * __nonnull) itemMACAddress inManagedObjectContext: (NSManagedObjectContext * __nonnull) managedObjectContext
{
	NSParameterAssert(itemMACAddress);
	
	NSParameterAssert(managedObjectContext);
	
	NSParameterAssert([itemMACAddress length] == kWOLMACAddressFormatterMACAddressLength);
	
	NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName: [self entityName]];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat: @"%K ==[c] %@", NSStringFromSelector(@selector(macAddress)), itemMACAddress];
	
	[fetchRequest setPredicate: predicate];
	
	NSError *fetchError = nil;
	
	NSArray *fetchResults = [managedObjectContext executeFetchRequest: fetchRequest
													error: &fetchError];
	
	if (fetchError)
	{
		CPLog(@"fetch error: %@", fetchError);
	}
	
	WOLHistoryItem *historyItem = [fetchResults firstObject];
	
	if (!historyItem)
	{
		historyItem = [self internal_historyItemForMACAddress: itemMACAddress
								 inManagedObjectContext: managedObjectContext];
	}
	
	return historyItem;
}

@end

@implementation WOLHistoryItem (PrivateMethods)

+ (instancetype) internal_historyItemForMACAddress: (NSString * __nonnull) itemMACAddress inManagedObjectContext: (NSManagedObjectContext * __nonnull) managedObjectContext
{
	WOLHistoryItem *historyItem = [self newEntityInManagedObjectContext: managedObjectContext];
	
	[historyItem setMacAddress: itemMACAddress];
	
	[historyItem setLastUsedDate: [NSDate date]];
	
	return historyItem;
}

@end
