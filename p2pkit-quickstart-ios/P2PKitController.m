//
//  P2PKitController.m
//  p2pkit-quickstart-ios
//
//  Copyright (c) 2016 Uepaa AG. All rights reserved.
//

#import <P2PKit/P2PKit.h>
#import "P2PKitController.h"
#import "NearbyPeersViewController.h"

@interface P2PKitController () <PPKControllerDelegate> {
    NearbyPeersViewController *nearbyPeersViewController;
}

@end

static dispatch_once_t token;
static P2PKitController *sharedInstance = nil;
@implementation P2PKitController

+(P2PKitController *)sharedInstance {

    dispatch_once(&token, ^{
        sharedInstance = [P2PKitController new];
    });
    return sharedInstance;
}

-(void)enableWithNearbyPeersViewController:(NearbyPeersViewController*)viewController {
    
    nearbyPeersViewController = viewController;
    [self enable];
}

-(void)enable {
    [PPKController enableWithConfiguration:@"<YOUR APPLICATION KEY>" observer:self];
}

-(void)disable {
    [PPKController disable];
}

-(BOOL)isEnabled {
    return [PPKController isEnabled];
}

#pragma mark - PPKControllerDelegate

-(void)PPKControllerInitialized {
    [nearbyPeersViewController setup];
}

-(void)PPKControllerFailedWithError:(PPKErrorCode)error {
    
    NSString *description;
    
    switch (error) {
        case PPKErrorInvalidAppKey:
            description = @"Invalid app key";
            break;
        case PPKErrorInvalidBundleId:
            description = @"Invalid bundle ID";
            break;
        case PPKErrorIncompatibleClientVersion:
            description = @"Incompatible p2pkit (SDK) version, please update";
            break;
        case PPKErrorServerConnectionUnavailable:
            description = @"Server connection not available.";
            break;
        default:
            description = @"Unknown error";
            break;
    }
    
     __weak P2PKitController *weakSelf = self;
    [self showErrorDialog:description withRetryBlock:^{
        [weakSelf enable];
    }];
}

-(BOOL)startOrUpdateDiscoveryWithDiscoveryInfo:(NSData*)data {
    
    if(![PPKController isEnabled]){
         [self showErrorDialog:@"Failed to update color, p2pkit is not running" withRetryBlock:nil];
        return NO;
    }
    
    BOOL success = NO;
    
    switch ([PPKController discoveryState]) {
            
        // case p2pkit discovery not yet started
        case PPKDiscoveryStateStopped:

            [PPKController enableProximityRanging];
            [PPKController startDiscoveryWithDiscoveryInfo:data stateRestoration:NO];
            success = YES;
            
            break;
            
        // case p2pkit discovery is already runnning/suspended
        case PPKDiscoveryStateServerConnectionUnavailable:
        case PPKDiscoveryStateSuspended:
        case PPKDiscoveryStateRunning:
            
            @try {
                [PPKController pushNewDiscoveryInfo:data];
                success = YES;
            } @catch (NSException *exception) {
                [self showErrorDialog:@"Failed! Discovery info update is limited to once per 60 seconds" withRetryBlock:nil];
                success = NO;
            }
            
            break;
            
        default:
            break;
    }
    
    return success;
}

-(void)stopDiscovery {
    [PPKController stopDiscovery];
}

-(void)peerDiscovered:(PPKPeer*)peer {
    [nearbyPeersViewController addNodeForPeer:peer];
}

-(void)peerLost:(PPKPeer*)peer {
    [nearbyPeersViewController removeNodeForPeer:peer];
}

-(void)discoveryInfoUpdatedForPeer:(PPKPeer*)peer {
    [nearbyPeersViewController updateColorForPeer:peer];
}

-(void)proximityStrengthChangedForPeer:(PPKPeer*)peer {
    [nearbyPeersViewController updateProximityStrengthForPeer:peer];
}

-(void)discoveryStateChanged:(PPKDiscoveryState)state {
    
    if (state == PPKDiscoveryStateStopped) {
        [nearbyPeersViewController removeNodesForAllPeers];
    }
    else if (state == PPKDiscoveryStateUnauthorized) {
        [self showErrorDialog:@"p2pkit cannot run because it is missing a user permission" withRetryBlock:nil];
    }
    else if (state == PPKDiscoveryStateUnsupported) {
        [self showErrorDialog:@"p2pkit is not supported on this device" withRetryBlock:nil];
    }
}

#pragma mark - Helpers

-(void)showErrorDialog:(NSString*)message withRetryBlock:(dispatch_block_t)retryBlock {
    [nearbyPeersViewController showErrorDialog:message retryBlock:retryBlock];
}

@end
