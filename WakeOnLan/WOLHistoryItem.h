//
//  WOLHistoryItem.h
//  WakeOnLan
//
//  Created by Clément Padovani on 9/9/15.
//  Copyright © 2015 Clément Padovani. All rights reserved.
//

#import "WOLBaseObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface WOLHistoryItem : WOLBaseObject

+ (instancetype) historyItemForMACAddress: (NSString * __nonnull) itemMACAddress inManagedObjectContext: (NSManagedObjectContext * __nonnull) managedObjectContext;


@end

NS_ASSUME_NONNULL_END

#import "WOLHistoryItem+CoreDataProperties.h"
