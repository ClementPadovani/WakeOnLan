//
//  UDPWOLServerSpec.m
//  WakeOnLan
//
//  Created by Clément Padovani on 9/8/15.
//  Copyright 2015 Clément Padovani. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "UDPWOLServer.h"

#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>

#import "WOLwol.h"


SPEC_BEGIN(UDPWOLServerSpec)

describe(@"UDPWOLServer", ^{

	context(@"Test WOL server", ^{
		
		UDPWOLServer *server = [UDPWOLServer sharedServer];
		
		beforeAll(^{
			
			[server setup];
			
		});
		
		afterAll(^{
			
			[server tearDown];
			
		});
		
		__block NSString *MACAddress;
		
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
				
				fail(errorFlag);
//				return errorFlag;
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
			
			MACAddress = [macAddressString copy];
		}
		
		it(@"Will send magic packet", ^{

//			MACAddress = [MACAddress stringByReplacingOccurrencesOfString: @":" withString: @""];
			
			MACAddress = [MACAddress uppercaseString];
			
			//	NSString *port = @"4343";
			
			unsigned char *networkBroadcastAddress = (unsigned char *) strdup([@"255.255.255.255" UTF8String]);
			
			unsigned char *macAddress = (unsigned char *) strdup([MACAddress UTF8String]);
			
			[[theValue(send_wol_packet(networkBroadcastAddress, macAddress, true)) should] equal: theValue(0)];
			
//			if (send_wol_packet(networkBroadcastAddress, macAddress))
//			{
//				NSLog(@"error sending WOL packet");
//			}
//			else
//			{
//				NSLog(@"sent to %@", MACAddress);
//			}

		
			
		});
		
		context(@"Should receive data", ^{
			it(@"Should receive data", ^{
				
				[[[server MACAddress] shouldEventually] haveLengthOf: 12];
				
				[[[server receivedDataString] shouldEventually] startWithString: @"FFFFFFFFFFFF"];
				
				[[[server receivedDataString] shouldEventually] endWithString: [[server MACAddress] stringByPaddingToLength: 16 * 12 withString: [server MACAddress] startingAtIndex: 0]];
				
				NSLog(@"address: %@", [server MACAddress]);
				
				NSLog(@"data: %@", [server receivedDataString]);
			});
		});

		
	});
	
});

SPEC_END
