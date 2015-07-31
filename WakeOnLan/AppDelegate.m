//
//  AppDelegate.m
//  WakeOnLan
//
//  Created by Clément Padovani on 7/30/15.
//  Copyright © 2015 Clément Padovani. All rights reserved.
//

#import "AppDelegate.h"
//#import "wol.h"

#import <arpa/inet.h>

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/time.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application
	
	NSString *lacieMACAddress = @"00:D0:4B:8D:A3:38";
	
//	NSString *port = @"4343";
	
	BOOL hasSent = [AppDelegate wakeOnLanByMacAddress: [lacieMACAddress UTF8String] usingSubnet: [@"255.255.255.255" UTF8String]];
	
	NSLog(@"sent: %@", hasSent ? @"YES" : @"NO");
}

void host2addr(char *name, struct in_addr *addrp, short *familyp) {
	struct hostent *hp;
	if ((hp=gethostbyname(name))) {
		bcopy(hp->h_addr,(char *)addrp,hp->h_length);
		if (familyp) *familyp = hp->h_addrtype;
	} else if ((addrp->s_addr=inet_addr(name)) != -1) {
		if (familyp) *familyp = AF_INET;
	} else {
		fprintf(stderr,"Unknown host : %s\n",name);
		exit(1);
	}
}

int hex(char c) {
	if ('0' <= c && c <= '9') return c - '0';
	if ('a' <= c && c <= 'f') return c - 'a' + 10;
	if ('A' <= c && c <= 'F') return c - 'A' + 10;
	return -1;
}

int hex2(char *p) {
	int i;
	unsigned char c;
	i = hex(*p++);
	if (i < 0) return i;
	c = (i << 4);
	i = hex(*p);
	if (i < 0) return i;
	return c | i;
}

/** Sends a Wake On Lan (WOL) messagge to the specified target.
 
 MAC address must be in the 12:34:56:78:9A:BC format.
 
 @param mac The MAC address to wake up.
 @param addr The subnet mask to use.
 @return Returns true on success, false otherwise.
 @see wakeOnLanByMacAddress:
 
 */
+ (BOOL)wakeOnLanByMacAddress:(char *)mac usingSubnet:(char *)addr {
	
	int BUFMAX = 1024;
	int MACLEN = 6;
	
	int sd;
	int optval;
	char unsigned buf[BUFMAX];
	int len;
	struct sockaddr_in sin;
	unsigned char macAddr[MACLEN];
	unsigned char *p;
	int i, j;
	
	bzero((char *)&sin,sizeof(sin)); // Clear sin struct.
	sin.sin_family = AF_INET;
	host2addr(addr,&sin.sin_addr,(short*)&sin.sin_family);    // Host.
	sin.sin_port = htons(9);                                // Port.
	if ((sd=socket(AF_INET,SOCK_DGRAM,IPPROTO_UDP)) < 0) {
		NSLog(@"Can't get socket");
		return NO;
	}
	optval = 1;
	if (setsockopt(sd,SOL_SOCKET,SO_BROADCAST,&optval,sizeof(optval)) < 0) {
		NSLog(@"Can't set sockopt (%d)", errno);
		return NO;
	}
	p = (unsigned char*)mac;
	j = hex2((char*)p);
	if (j < 0) {
	MACerror:
		NSLog(@"Illegal MAC address: %s",mac);
		return NO;
	}
	macAddr[0] = j;
	p += 2;
	for (i=1; i < MACLEN; i++) {
		if (*p++ != ':') goto MACerror;
		j = hex2((char*)p);
		if (j < 0) goto MACerror;
		macAddr[i] = j;
		p += 2;
	}
	p = buf;
	for (i=0; i < 6; i++) {    // 6 bytes of FFhex.
		*p++ = 0xFF;
	}
	for (i=0; i < 16; i++) { // MAC addresses repeated 16 times.
		for (j=0; j < MACLEN; j++) {
			*p++ = macAddr[j];
		}
	}
	len = p - buf;
	
	if (sendto(sd,buf,len,0,(struct sockaddr*)&sin,sizeof(sin)) != len) {
		NSLog(@"Sendto failed (%d)", errno);
		return NO;
	}
	
	
	return YES;
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
	// Insert code here to tear down your application
}

@end
