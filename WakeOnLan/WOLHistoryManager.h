//
//  WOLHistoryManager.h
//  WakeOnLan
//
//  Created by Clément Padovani on 9/9/15.
//  Copyright (c) 2015 Clément Padovani. All rights reserved.
//

@import Foundation;

@import CoreData;

NS_ASSUME_NONNULL_BEGIN

@interface WOLHistoryManager : NSObject

+ (instancetype) sharedManager;

@property (nonatomic, strong, readonly) NSManagedObjectContext *mainContext;

@property (nonatomic, strong, readonly) NSManagedObjectContext *importContext;

@end

NS_ASSUME_NONNULL_END
