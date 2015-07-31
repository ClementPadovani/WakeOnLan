//
//  WOLViewController.m
//  WakeOnLan
//
//  Created by Clément Padovani on 7/31/15.
//  Copyright © 2015 Clément Padovani. All rights reserved.
//

#import "WOLViewController.h"
#import "WOLwol.h"
#import "WOLMACAddressFormatter.h"
#import "WOLTextField.h"

@interface WOLViewController () <NSTextFieldDelegate>

@property (weak) IBOutlet NSButton *sendWOLPacketButton;
@property (strong) IBOutlet NSTextField *macAddressTextField;

@property (strong) WOLMACAddressFormatter *macAddressFormatter;

@end

@implementation WOLViewController

- (void) viewDidLoad
{
	[super viewDidLoad];
	
	[[self macAddressTextField] setAllowsEditingTextAttributes: NO];
	
	NSFont *font = [NSFont fontWithName: @"Monaco" size: [NSFont systemFontSize]];
	
	[[self macAddressTextField] setFont: font];
	
	WOLMACAddressFormatter *macAddressFormatter = [[WOLMACAddressFormatter alloc] init];

	[self setMacAddressFormatter: macAddressFormatter];
	
	[[self macAddressTextField] setFormatter: [self macAddressFormatter]];
	
//	[[NSNotificationCenter defaultCenter] addObserver: self
//									 selector: @selector(textFieldDidChange:)
//										name: NSControlTextDidChangeNotification
//									   object: [self macAddressTextField]];
	
//	[[NSNotificationCenter defaultCenter] addObserverForName: nil
//											object: [self macAddressTextField]
//											 queue: [NSOperationQueue mainQueue]
//										 usingBlock: ^(NSNotification * _Nonnull note) {
//											
//											 NSLog(@"notification: %@", note);
//											 
//										 }];
}

- (void) textFieldDidChange: (NSNotification *) notification
{
	NSLog(@"did change");
	
//	[[self macAddressTextField] invalidateIntrinsicContentSize];
}

- (IBAction) performSendWOLPacket: (NSButton *) sender
{
	NSString *lacieMACAddress = @"00:D0:4B:8D:A3:38";
	
	//	NSString *port = @"4343";
	
	unsigned char *networkBroadcastAddress = (unsigned char *) strdup([@"255.255.255.255" UTF8String]);
	
	unsigned char *macAddress = (unsigned char *) strdup([lacieMACAddress UTF8String]);
	
	if (send_wol_packet(networkBroadcastAddress, macAddress))
	{
		NSLog(@"error sending WOL packet");
	}
}

@end
