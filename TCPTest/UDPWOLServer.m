//
//  UDPWOLServer.m
//  WakeOnLan
//
//  Created by Clément Padovani on 9/8/15.
//  Copyright (c) 2015 Clément Padovani. All rights reserved.
//

#import "UDPWOLServer.h"

#import <CocoaAsyncSocket/CocoaAsyncSocket.h>

#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>

@interface UDPWOLServer () <GCDAsyncUdpSocketDelegate>

@property (nonatomic, strong) GCDAsyncUdpSocket *socket;

@property (nonatomic, copy, readwrite) NSString *receivedDataString;

@property (nonatomic, copy, readwrite) NSString *MACAddress;

@property (nonatomic, assign, readwrite) BOOL hasReceived;

@end

@implementation NSData (NSData_Conversion)

- (NSString *) hexString
{
	NSUInteger bytesCount = self.length;
	if (bytesCount) {
		const char *hexChars = "0123456789ABCDEF";
		const unsigned char *dataBuffer = self.bytes;
		char *chars = malloc(sizeof(char) * (bytesCount * 2 + 1));
		char *s = chars;
		for (unsigned i = 0; i < bytesCount; ++i) {
			*s++ = hexChars[((*dataBuffer & 0xF0) >> 4)];
			*s++ = hexChars[(*dataBuffer & 0x0F)];
			dataBuffer++;
		}
		*s = '\0';
		NSString *hexString = [NSString stringWithUTF8String:chars];
		free(chars);
		return hexString;
	}
	return @"";
}

@end


@implementation UDPWOLServer

+ (UDPWOLServer *) sharedServer
{
	static UDPWOLServer *_sharedServer = nil;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_sharedServer = [[self alloc] init];
	});

	return _sharedServer;
}

- (NSString *)getMacAddress
{
	int                 mgmtInfoBase[6];
	char                *msgBuffer = NULL;
	size_t              length;
	unsigned char       macAddress[6];
	struct if_msghdr    *interfaceMsgStruct;
	struct sockaddr_dl  *socketStruct;
	NSString            *errorFlag = NULL;
	
	// Setup the management Information Base (mib)
	mgmtInfoBase[0] = CTL_NET;        // Request network subsystem
	mgmtInfoBase[1] = AF_ROUTE;       // Routing table info
	mgmtInfoBase[2] = 0;
	mgmtInfoBase[3] = AF_LINK;        // Request link layer information
	mgmtInfoBase[4] = NET_RT_IFLIST;  // Request all configured interfaces
	
	// With all configured interfaces requested, get handle index
	if ((mgmtInfoBase[5] = if_nametoindex("en0")) == 0)
		errorFlag = @"if_nametoindex failure";
	else
	{
		// Get the size of the data available (store in len)
		if (sysctl(mgmtInfoBase, 6, NULL, &length, NULL, 0) < 0)
			errorFlag = @"sysctl mgmtInfoBase failure";
		else
		{
			// Alloc memory based on above call
			if ((msgBuffer = malloc(length)) == NULL)
				errorFlag = @"buffer allocation failure";
			else
			{
				// Get system information, store in buffer
				if (sysctl(mgmtInfoBase, 6, msgBuffer, &length, NULL, 0) < 0)
					errorFlag = @"sysctl msgBuffer failure";
			}
		}
	}
	
	// Befor going any further...
	if (errorFlag != NULL)
	{
		NSLog(@"Error: %@", errorFlag);
		return errorFlag;
	}
	
	// Map msgbuffer to interface message structure
	interfaceMsgStruct = (struct if_msghdr *) msgBuffer;
	
	// Map to link-level socket structure
	socketStruct = (struct sockaddr_dl *) (interfaceMsgStruct + 1);
	
	// Copy link layer address data in socket structure to an array
	memcpy(&macAddress, socketStruct->sdl_data + socketStruct->sdl_nlen, 6);
	
	// Read from char array into a string object, into traditional Mac address format
	NSString *macAddressString = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
							macAddress[0], macAddress[1], macAddress[2],
							macAddress[3], macAddress[4], macAddress[5]];
	NSLog(@"Mac Address: %@", macAddressString);
	
	// Release the buffer memory
	free(msgBuffer);
	
	return macAddressString;
}

- (instancetype) init
{
	self = [super init];
	
	if (self)
	{
		
	}
	
	return self;
}

- (void) setup
{
	NSLog(@"setup");
	
	if ([self socket])
	{
		NSLog(@"has socket");
		
		return;
	}
	
	[self setHasReceived: NO];
	
	GCDAsyncUdpSocket *socket = [[GCDAsyncUdpSocket alloc] initWithDelegate: self delegateQueue: dispatch_get_main_queue()];
	
	NSError *error = nil;
	
	[socket setDelegate: self];
	
	if (![socket bindToPort: 1025 error: &error])
		NSLog(@"error: %@", error);
	else
	{
		NSLog(@"accepted");
	}
	
	if (![socket beginReceiving: &error])
		NSLog(@"error: %@", error);
	else
	{
		NSLog(@"started receiving");
	}
	
	[self setSocket: socket];
}

- (void) tearDown
{
	NSLog(@"tear down");
	
	[[self socket] close];
	
	[self setSocket: nil];
}

- (void) udpSocket:(GCDAsyncUdpSocket *)sock didNotConnect:(NSError *)error
{
	NSLog(@"did not connect: %@", error);
}

- (void) udpSocket:(GCDAsyncUdpSocket *)sock didConnectToAddress:(NSData *)address
{
	NSLog(@"connected to %@", [[NSString alloc] initWithData: address encoding: NSUTF8StringEncoding]);
}

- (void) udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext
{
	NSLog(@"received: %@", [data hexString]);
	
	[self setHasReceived: YES];
	
	[self setReceivedDataString: [data hexString]];
	
	[self setMACAddress: [self getMacAddress]];
}


@end
