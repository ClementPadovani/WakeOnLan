//
//  AppDelegate.m
//  TCPTest
//
//  Created by Clément Padovani on 9/8/15.
//  Copyright © 2015 Clément Padovani. All rights reserved.
//

#import "AppDelegate.h"

#import <CocoaAsyncSocket/CocoaAsyncSocket.h>

@interface AppDelegate () <GCDAsyncUdpSocketDelegate>

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

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	
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
	
	// Insert code here to initialize your application
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

- (void) socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
	NSLog(@"did connect to %@ %u", host, port);
}

- (void) socketDidCloseReadStream:(GCDAsyncSocket *)sock
{
	NSLog(@"did close read");
}


- (void) socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket
{
	NSLog(@"did accept new socket: %@", newSocket);
}

- (void) socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
	NSLog(@"did read %@ ith %ld", [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding], tag);
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
	// Insert code here to tear down your application
}

@end
