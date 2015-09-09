//
//  WOLManagedObject.m
//  WakeOnLan
//
//  Created by Clément Padovani on 9/9/15.
//  Copyright © 2015 Clément Padovani. All rights reserved.
//

#import "WOLManagedObject.h"

@implementation WOLManagedObject

+ (NSString *) entityName
{
	return NSStringFromClass(self);
}

+ (instancetype) newEntityInManagedObjectContext: (NSManagedObjectContext *) context
{
	return [NSEntityDescription insertNewObjectForEntityForName: [self entityName] inManagedObjectContext: context];
}

@end
