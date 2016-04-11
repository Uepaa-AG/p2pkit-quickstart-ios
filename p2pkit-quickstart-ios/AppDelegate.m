//
//  AppDelegate.m
//  p2pkit-quickstart-ios
//
//  Copyright (c) 2015 Uepaa AG. All rights reserved.
//

#import <P2PKit/P2PKit.h>
#import "AppDelegate.h"
#import "NearbyPeersViewController.h"


@interface AppDelegate () <PPKControllerDelegate> {
    NearbyPeersViewController *nearbyPeersViewController;
}
@end


@implementation AppDelegate

-(BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions {
    
    [PPKController enableWithConfiguration:@"<YOUR APPLICATION KEY>" observer:self];

    nearbyPeersViewController = (NearbyPeersViewController*)self.window.rootViewController;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(colorUpdateNotification:) name:@"userSelectedNewColorNotification" object:nil];
    
    return YES;
}

#pragma mark - PPKControllerDelegate

-(void)PPKControllerInitialized {
    
    [nearbyPeersViewController setup];
}

-(void)PPKControllerFailedWithError:(NSError*)error {
    
    NSString *description;
    
    switch ((PPKErrorCode) error.code) {
        case PPKErrorAppKeyInvalid:
            description = @"Invalid app key";
            break;
        case PPKErrorAppKeyExpired:
            description = @"Expired app key";
            break;
        case PPKErrorOnlineProtocolVersionNotSupported:
            description = @"Server protocol mismatch";
            break;
        case PPKErrorOnlineAppKeyInvalid:
            description = @"Invalid app key";
            break;
        case PPKErrorOnlineAppKeyExpired:
            description = @"Expired app key";
            break;
    }
    
    [[[UIAlertView alloc] initWithTitle:@"p2pkit Error" message:description delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

-(void)p2pPeerDiscovered:(PPKPeer*)peer {
    
    [nearbyPeersViewController addNodeForPeer:peer];
}

-(void)p2pPeerLost:(PPKPeer*)peer {
    
    [nearbyPeersViewController removeNodeForPeer:peer];
}

-(void)discoveryInfoUpdatedForPeer:(PPKPeer*)peer {
    
    [nearbyPeersViewController updateColorForPeer:peer];
}

-(void)proximityStrengthChangedForPeer:(PPKPeer*)peer {
    
    [nearbyPeersViewController updateProximityStrengthForPeer:peer];
}

-(void)p2pDiscoveryStateChanged:(PPKPeer2PeerDiscoveryState)state {
    
    if (state == PPKPeer2PeerDiscoveryStopped) {
        [nearbyPeersViewController removeNodesForAllPeers];
    }
}

#pragma mark - Notifications

-(void)colorUpdateNotification:(NSNotification*)notification {
    
    switch ([PPKController p2pDiscoveryState]) {
            
        case PPKPeer2PeerDiscoverySuspended:
        case PPKPeer2PeerDiscoveryRunning:
            
            [PPKController pushNewP2PDiscoveryInfo:notification.object];

            break;
            
        case PPKPeer2PeerDiscoveryStopped:
            
            [PPKController enableProximityRanging];
            [PPKController startP2PDiscoveryWithDiscoveryInfo:notification.object stateRestoration:NO];
            
            break;
    }
}

@end
