//
//  NearbyPeersViewController.h
//  p2pkit-quickstart-ios
//
//  Copyright (c) 2016 Uepaa AG. All rights reserved.
//

#import <P2PKit/P2PKit.h>

@interface NearbyPeersViewController : UIViewController

-(void)setup;

-(void)addNodeForPeer:(PPKPeer*)peer;
-(void)updateColorForPeer:(PPKPeer*)peer;
-(void)updateProximityStrengthForPeer:(PPKPeer*)peer;
-(void)removeNodeForPeer:(PPKPeer*)peer;
-(void)removeNodesForAllPeers;

@end
