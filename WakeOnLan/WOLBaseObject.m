//
//  WOLBaseObject.m
//  WakeOnLan
//
//  Created by Clément Padovani on 9/9/15.
//  Copyright © 2015 Clément Padovani. All rights reserved.
//

#import "WOLBaseObject.h"

@implementation WOLBaseObject

+ (NSString *) entityName
{
	return NSStringFromClass(self);
}

+ (instancetype) newEntityInManagedObjectContext: (NSManagedObjectContext *) context
{
	return [NSEntityDescription insertNewObjectForEntityForName: [self entityName] inManagedObjectContext: context];
}

@end
