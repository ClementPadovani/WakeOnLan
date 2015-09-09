//
//  WOLHistoryManager.m
//  WakeOnLan
//
//  Created by Clément Padovani on 9/9/15.
//  Copyright (c) 2015 Clément Padovani. All rights reserved.
//

#import "WOLHistoryManager.h"

@import CoreData;

@import AppKit;

@interface WOLHistoryManager ()

@property (nonatomic, strong) NSManagedObjectModel *model;

@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, strong, readwrite) NSManagedObjectContext *mainContext;

@property (nonatomic, strong, readwrite) NSManagedObjectContext *importContext;

@end

@implementation WOLHistoryManager

+ (instancetype) sharedManager
{
	static WOLHistoryManager *_sharedManager = nil;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_sharedManager = [[self alloc] init];
	});

	return _sharedManager;
}

- (NSManagedObjectModel *) model
{
	if (!_model)
	{
		NSURL *modelURL = [[NSBundle mainBundle] URLForResource: @"WOLHistory" withExtension: @"momd"];
		
		NSManagedObjectModel *model = [[NSManagedObjectModel alloc] initWithContentsOfURL: modelURL];
		
		_model = model;
	}
	
	return _model;
}

- (NSDictionary *) storeOptions
{
	return @{NSPersistentStoreUbiquitousContentNameKey : @"History"};
}

- (NSPersistentStoreCoordinator *) persistentStoreCoordinator
{
	if (!_persistentStoreCoordinator)
	{
		NSPersistentStoreCoordinator *persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self model]];
		
		NSError *storeError = nil;
		
		NSURL *storeURL = [self applicationDocumentsDirectory];
		
		storeURL = [storeURL URLByAppendingPathComponent: @"history"];
		
		storeURL = [storeURL URLByAppendingPathExtension: @"sqlite"];
		
		NSPersistentStore *persistentStore = [persistentStoreCoordinator addPersistentStoreWithType: NSSQLiteStoreType
																	   configuration: nil
																			   URL: storeURL
																		    options: [self storeOptions]
																			 error: &storeError];
		
		if (!persistentStore ||
		    storeError)
		{
			CPLog(@"store error: %@", storeError);
			
			if (![NSApp presentError: storeError])
				CPLog(@"couldn't present error");
		}
		
		if ([persistentStoreCoordinator respondsToSelector: @selector(setName:)])
		{
			[persistentStoreCoordinator setName: @"Persistent Store Coordinator"];
		}
		
		_persistentStoreCoordinator = persistentStoreCoordinator;
	}
	
	return _persistentStoreCoordinator;
}

- (NSManagedObjectContext *) mainContext
{
	if (!_mainContext)
	{
		NSManagedObjectContext *mainContext = [[NSManagedObjectContext alloc] initWithConcurrencyType: NSMainQueueConcurrencyType];
		
		if ([mainContext respondsToSelector: @selector(setName:)])
		{
			[mainContext setName: @"Main Context"];
		}
		
		[mainContext setPersistentStoreCoordinator: [self persistentStoreCoordinator]];
		
		_mainContext = mainContext;
	}
	
	return _mainContext;
}

- (NSManagedObjectContext *) importContext
{
	if (!_importContext)
	{
		NSManagedObjectContext *importContext = [[NSManagedObjectContext alloc] initWithConcurrencyType: NSPrivateQueueConcurrencyType];
		
		if ([importContext respondsToSelector: @selector(setName:)])
		{
			[importContext setName: @"Import Context"];
		}
		
		[importContext setParentContext: [self mainContext]];
		
		_importContext = importContext;
	}
	
	return _importContext;
}

- (NSURL *) applicationDocumentsDirectory
{
	return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
