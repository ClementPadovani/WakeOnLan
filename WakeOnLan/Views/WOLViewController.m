//
//  WOLViewController.m
//  WakeOnLan
//
//  Created by Clément Padovani on 7/31/15.
//  Copyright © 2015 Clément Padovani. All rights reserved.
//

@import QuartzCore;

#import "WOLViewController.h"
#import "WOLwol.h"
#import "WOLMACAddressFormatter.h"
#import "WOLHistoryManager.h"
#import "WOLHistoryItem.h"

@interface WOLViewController () <NSTextFieldDelegate>

@property (weak) IBOutlet NSButton *sendWOLPacketButton;
@property (strong) IBOutlet NSTextField *macAddressTextField;

@property (strong) WOLMACAddressFormatter *macAddressFormatter;

@property (weak) IBOutlet NSTextField *sentLabel;

@end

@implementation WOLViewController

- (void) viewDidLoad
{
	[super viewDidLoad];
	
	[[self macAddressTextField] setAllowsEditingTextAttributes: NO];
		
	WOLMACAddressFormatter *macAddressFormatter = [[WOLMACAddressFormatter alloc] init];

	[self setMacAddressFormatter: macAddressFormatter];
	
	[[self macAddressTextField] setFormatter: [self macAddressFormatter]];
}

- (BOOL) isMACAddressValid
{
	static const NSUInteger kAddressLength = 17;
	
	if ([[[self macAddressTextField] stringValue] length] != kAddressLength)
		return NO;
	
	NSArray *components = [[[self macAddressTextField] stringValue] componentsSeparatedByString: @":"];
	
	__block BOOL hasInvalidCharacter = NO;
	
	NSCharacterSet *disallowedCharacters = [[NSCharacterSet characterSetWithCharactersInString: @"0123456789:abcdefABCDEF"] invertedSet];
	
	[components enumerateObjectsUsingBlock: ^(NSString  *_Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
		
		if ([obj rangeOfCharacterFromSet: disallowedCharacters].location != NSNotFound)
		{
			hasInvalidCharacter = YES;

			*stop = YES;
		}
		
	}];
	
	return !hasInvalidCharacter;
}

- (IBAction) userDidPressReturn: (id) sender
{
	if ([self isMACAddressValid])
		[self performSendWOLPacket: nil];
}

- (void) doWakeUpClientWithMACAddress: (NSString * __nonnull) clientMacAddress
{
	[[self macAddressTextField] setStringValue: clientMacAddress];
	
	[self performSendWOLPacket: nil];
}

- (void) doAddMACAddress: (NSString * __nonnull) macAddress
{
	NSManagedObjectContext *importContext = [[WOLHistoryManager sharedManager] importContext];
	
	[importContext performBlock: ^{
		
		WOLHistoryItem *historyItem = [WOLHistoryItem historyItemForMACAddress: macAddress
											   inManagedObjectContext: importContext];
		
		[historyItem setLastUsedDate: [NSDate date]];
		
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
			CPLog(@"import save");
			
			NSManagedObjectContext *parentContext = [importContext parentContext];
			
			[parentContext performBlock: ^{
				
				NSError *parentSaveError = nil;
				
				if (![parentContext save: &parentSaveError])
				{
					CPLog(@"parent save error: %@", parentSaveError);
					
					dispatch_async(dispatch_get_main_queue(), ^{
						
						[NSApp presentError: parentSaveError];
						
					});
				}
				else
				{
					CPLog(@"did save");
				}
				
			}];
		}
		
	}];
}

- (IBAction) performSendWOLPacket: (NSButton *) sender
{
	if (![self isMACAddressValid])
		return;
	
//	NSString *lacieMACAddress = @"00:D0:4B:8D:A3:38";
	
//	NSString *lacieMACAddress = @"64:76:ba:8e:83:d2";
	
	NSString *deviceMACAddress = [[self macAddressTextField] stringValue];
	
	deviceMACAddress = [deviceMACAddress uppercaseString];
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		
		[self doAddMACAddress: deviceMACAddress];
		
	});
	
	//	NSString *port = @"4343";
	
	unsigned char *networkBroadcastAddress = (unsigned char *) strdup([@"255.255.255.255" UTF8String]);
	
	unsigned char *macAddress = (unsigned char *) strdup([deviceMACAddress UTF8String]);
	
	if (send_wol_packet(networkBroadcastAddress, macAddress, false))
	{
		CPLog(@"error sending WOL packet");
	}
	else
	{
		[[self sentLabel] setAlphaValue: 0];
		
		[[self sentLabel] setHidden: NO];
		
		[NSAnimationContext beginGrouping];
		
		NSAnimationContext *animationContext = [NSAnimationContext currentContext];
		
		[animationContext setAllowsImplicitAnimation: YES];
		
		[animationContext setDuration: .2];
		
		[[NSAnimationContext currentContext] setTimingFunction: [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseOut]];
		
		[[[self sentLabel] animator] setAlphaValue: 1];
		
		[animationContext setCompletionHandler: ^{
			
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
				
			[NSAnimationContext beginGrouping];
			
			[[NSAnimationContext currentContext] setDuration: .2];
				
				[[NSAnimationContext currentContext] setTimingFunction: [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseIn]];
				
				[[NSAnimationContext currentContext] setAllowsImplicitAnimation: YES];
			
			[[[self sentLabel] animator] setAlphaValue: 0];
			
			[NSAnimationContext endGrouping];
				
			});
		}];
		
		[NSAnimationContext endGrouping];

	}
}

@end
