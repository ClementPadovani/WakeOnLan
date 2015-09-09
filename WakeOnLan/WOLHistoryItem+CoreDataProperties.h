//
//  WOLHistoryItem+CoreDataProperties.h
//  WakeOnLan
//
//  Created by Clément Padovani on 9/9/15.
//  Copyright © 2015 Clément Padovani. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "WOLHistoryItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface WOLHistoryItem (CoreDataProperties)

@property (nullable, nonatomic, retain) NSDate *lastUsedDate;
@property (nullable, nonatomic, retain) NSString *macAddress;

@end

NS_ASSUME_NONNULL_END
