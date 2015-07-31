//
//  WOLViewController.m
//  WakeOnLan
//
//  Created by Clément Padovani on 7/31/15.
//  Copyright © 2015 Clément Padovani. All rights reserved.
//

#import "WOLViewController.h"
#import "WOLwol.h"

@interface WOLViewController ()

@property (weak) IBOutlet NSButton *sendWOLPacketButton;

@end

@implementation WOLViewController

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
