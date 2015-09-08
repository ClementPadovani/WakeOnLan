//
//  UDPWOLServer.h
//  WakeOnLan
//
//  Created by Clément Padovani on 9/8/15.
//  Copyright (c) 2015 Clément Padovani. All rights reserved.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@interface UDPWOLServer : NSObject

+ (UDPWOLServer *) sharedServer;

@property (nonatomic, copy, readonly) NSString *receivedDataString;

@property (nonatomic, copy, readonly) NSString *MACAddress;

@property (nonatomic, assign, readonly) BOOL hasReceived;

- (void) setup;

- (void) tearDown;

@end

NS_ASSUME_NONNULL_END
