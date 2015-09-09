//
//  WOLBaseObject.h
//  WakeOnLan
//
//  Created by Clément Padovani on 9/9/15.
//  Copyright © 2015 Clément Padovani. All rights reserved.
//

@import CoreData;

@interface WOLBaseObject : NSManagedObject

+ (NSString *) entityName;

+ (instancetype) newEntityInManagedObjectContext: (NSManagedObjectContext *) context;

@end
