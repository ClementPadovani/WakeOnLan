//
//  UDPWOLServerSpec.m
//  WakeOnLan
//
//  Created by Clément Padovani on 9/8/15.
//  Copyright 2015 Clément Padovani. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "UDPWOLServer.h"


SPEC_BEGIN(UDPWOLServerSpec)

describe(@"UDPWOLServer", ^{

	context(@"Test WOL server", ^{
		
		let(server, ^{
			
			return [UDPWOLServer sharedServer];
			
		});
		
		beforeEach(^{
			
			[server setup];
			
		});
		
		afterEach(^{
			
			[server tearDown];
			
		});
		
		it(@"Should receive data", ^{
			
			[[[server MACAddress] shouldEventually] haveLengthOf: 12];
			
			[[[server receivedDataString] shouldEventually] startWithString: @"FFFFFFFFFFFF"];
			
			[[[server receivedDataString] shouldEventually] endWithString: [[server MACAddress] stringByPaddingToLength: 16 * 12 withString: [server MACAddress] startingAtIndex: 0]];
		});

		
	});
	
});

SPEC_END
