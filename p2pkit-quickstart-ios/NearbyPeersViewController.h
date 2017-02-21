//
//  NearbyPeersViewController.h
//  p2pkit-quickstart-ios
//
//  Copyright (c) 2016 Uepaa AG. All rights reserved.
//

#import <P2PKit/P2PKit.h>
#import "DLForcedGraphView.h"
#import "DLEdge.h"
#import "ConsoleViewController.h"

@interface NearbyPeersViewController : UIViewController

#pragma mark - interaction api

-(void)addNodeForPeer:(PPKPeer*)peer;
-(void)updateColorForPeer:(PPKPeer*)peer;
-(void)updateProximityStrengthForPeer:(PPKPeer*)peer;
-(void)removeNodeForPeer:(PPKPeer*)peer;
-(void)removeNodesForAllPeers;
-(void)showErrorDialog:(NSString*)message retryBlock:(dispatch_block_t)retryBlock;

#pragma mark - subclasses api

-(void)setup;
-(UIColor*)getOwnColor;
-(CGRect)getOwnNodeRect;
-(NSData*)dataFromColor:(UIColor*)color;
-(void)setOwnColor:(UIColor*)color;

@end
