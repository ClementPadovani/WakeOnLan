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
//											 CPLog(@"notification: %@", note);
//											 
//										 }];
}

- (IBAction) performSendWOLPacket: (NSButton *) sender
{
//	NSString *lacieMACAddress = @"00:D0:4B:8D:A3:38";
	
//	NSString *lacieMACAddress = @"64:76:ba:8e:83:d2";
	
	NSString *deviceMACAddress = [[self macAddressTextField] stringValue];
	
	deviceMACAddress = [deviceMACAddress uppercaseString];
	
	//	NSString *port = @"4343";
	
	unsigned char *networkBroadcastAddress = (unsigned char *) strdup([@"255.255.255.255" UTF8String]);
	
	unsigned char *macAddress = (unsigned char *) strdup([deviceMACAddress UTF8String]);
	
	if (send_wol_packet(networkBroadcastAddress, macAddress, false))
	{
		CPLog(@"error sending WOL packet");
	}
	else
	{
		CPLog(@"sent to %@", deviceMACAddress);
	}
}

@end
