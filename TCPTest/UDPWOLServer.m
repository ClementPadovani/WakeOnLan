//
//  UDPWOLServer.m
//  WakeOnLan
//
//  Created by Clément Padovani on 9/8/15.
//  Copyright (c) 2015 Clément Padovani. All rights reserved.
//

#import "UDPWOLServer.h"

#import <CocoaAsyncSocket/CocoaAsyncSocket.h>

@interface UDPWOLServer () <GCDAsyncUdpSocketDelegate>

@property (nonatomic, strong) GCDAsyncUdpSocket *socket;

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
	GCDAsyncUdpSocket *socket = [[GCDAsyncUdpSocket alloc] initWithDelegate: self delegateQueue: dispatch_get_main_queue()];
	
	NSError *error = nil;
	
	[socket setDelegate: self];
	
	if (![socket bindToPort: 9 error: &error])
		NSLog(@"error: %@", error);
	else
	{
		NSLog(@"accepted");
	}
	
	if (![socket beginReceiving: &error])
		NSLog(@"error: %@", error);
	
	[self setSocket: socket];
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
	
	NSString *host = nil;
	
	uint16_t port;
	
	if ([GCDAsyncUdpSocket getHost: &host port: &port fromAddress: address])
	{
		NSLog(@"host: %@", host);
		
		NSLog(@"port: %u", port);
	}
	
	NSLog(@"received: %@", [data hexString]);
}


@end
