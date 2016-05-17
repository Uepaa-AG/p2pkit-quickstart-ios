//
//  P2PKitController.h
//  p2pkit-quickstart-ios
//
//  Copyright (c) 2016 Uepaa AG. All rights reserved.
//

#import "NearbyPeersViewController.h"

@interface P2PKitController : NSObject

-(instancetype)initWithNearbyPeersViewController:(NearbyPeersViewController*)viewController;
-(void)disable;

@end
