//
//  WOLViewController.h
//  WakeOnLan
//
//  Created by Clément Padovani on 7/31/15.
//  Copyright © 2015 Clément Padovani. All rights reserved.
//

@import Cocoa;

@interface WOLViewController : NSViewController

- (void) doWakeUpClientWithMACAddress: (NSString * __nonnull) clientMacAddress;

@end
