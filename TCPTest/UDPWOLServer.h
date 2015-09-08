//
//  UDPWOLServer.h
//  WakeOnLan
//
//  Created by Clément Padovani on 9/8/15.
//  Copyright (c) 2015 Clément Padovani. All rights reserved.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@class UDPWOLServer;

@protocol UDPWOLServerDelegate <NSObject>

- (void) wolServer: (UDPWOLServer *) server didReceiveDataString: (NSString *) dataString fromMACAddress: (NSString *) macAddress;

@end

@interface UDPWOLServer : NSObject

@property (nonatomic, weak, readonly, nullable) id <UDPWOLServerDelegate> delegate;

- (void) setupWithDelegate: (id <UDPWOLServerDelegate>) delegate;

- (void) tearDown;

@end

NS_ASSUME_NONNULL_END
