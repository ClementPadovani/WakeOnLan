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

- (void) persistentStoreDidImportUbiquitousDataWithNotification: (NSNotification *) notification
{
	CPLog(@"did import iCloud data");
	
	[[self mainContext] performBlock: ^{
		
		[[self mainContext] mergeChangesFromContextDidSaveNotification: notification];
		
	}];
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
		
		[[NSNotificationCenter defaultCenter] addObserver: self
										 selector: @selector(persistentStoreDidImportUbiquitousDataWithNotification:)
											name: NSPersistentStoreDidImportUbiquitousContentChangesNotification
										   object: [self persistentStoreCoordinator]];
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

- (void) doPerformSave
{
	NSManagedObjectContext *importContext = [self importContext];
	
	NSManagedObjectContext *mainContext = [self mainContext];
	
	[importContext performBlock: ^{
		
		NSError *importSaveError = nil;
		
		if (![importContext save: &importSaveError])
		{
			CPLog(@"import save error: %@", importSaveError);
			
			dispatch_async(dispatch_get_main_queue(), ^{
				
				[NSApp presentError: importSaveError];
				
			});
		}
		else
		{
			[mainContext performBlock: ^{
				
				NSError *mainSaveError = nil;
				
				if (![mainContext save: &mainSaveError])
				{
					CPLog(@"main save error: %@", mainSaveError);
					
					dispatch_async(dispatch_get_main_queue(), ^{
						
						[NSApp presentError: mainSaveError];
						
					});
				}
				
			}];
		}
		
	}];
}

//- (NSURL *) ubiquitousDocumentsDirectory
//{
//	if (![[NSFileManager defaultManager] ubiquityIdentityToken])
//		return [self applicationDocumentsDirectory];
//	
//	NSURL *ubiquitousDocumentsDirectory = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier: nil];
//	
//	NSParameterAssert(ubiquitousDocumentsDirectory);
//	
//	NSParameterAssert([[ubiquitousDocumentsDirectory path] length]);
//	
//	return ubiquitousDocumentsDirectory;
//}

- (NSURL *) applicationDocumentsDirectory
{
	return [[NSFileManager defaultManager] URLForDirectory: NSDocumentDirectory inDomain: NSUserDomainMask appropriateForURL: nil create: YES error: NULL];
}

@end
