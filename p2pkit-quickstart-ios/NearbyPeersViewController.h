//
//  NearbyPeersViewController.h
//  p2pkit-quickstart-ios
//
//  Copyright (c) 2015 Uepaa AG. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NearbyPeersViewController : UIViewController

-(void)setup;

-(void)addNodeForPeer:(PPKPeer*)peer;
-(void)updateColorForPeer:(PPKPeer*)peer;
-(void)updateProximityStrengthForPeer:(PPKPeer*)peer;
-(void)removeNodeForPeer:(PPKPeer*)peer;
-(void)removeNodesForAllPeers;

@end
