//
//  WOLHistoryManager.m
//  WakeOnLan
//
//  Created by Clément Padovani on 9/9/15.
//  Copyright (c) 2015 Clément Padovani. All rights reserved.
//

#import "WOLHistoryManager.h"

@interface WOLHistoryManager ()



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

- (instancetype) init
{
	self = [super init];
	
	if (self)
	{
		
	}
	
	return self;
}

@end
