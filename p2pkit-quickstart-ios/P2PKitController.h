//
//  P2PKitController.h
//  p2pkit-quickstart-ios
//
//  Copyright (c) 2016 Uepaa AG. All rights reserved.
//

@class NearbyPeersViewController;
@interface P2PKitController : NSObject

+(P2PKitController *)sharedInstance;

-(void)enableWithNearbyPeersViewController:(NearbyPeersViewController*)viewController;
-(BOOL)startOrUpdateDiscoveryWithDiscoveryInfo:(NSData*)data;
-(void)stopDiscovery;
-(void)disable;
-(BOOL)isEnabled;


@end
