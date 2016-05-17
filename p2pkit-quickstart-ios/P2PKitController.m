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

@implementation P2PKitController

-(instancetype)initWithNearbyPeersViewController:(NearbyPeersViewController*)viewController {
    
    self = [super init];
    if (self) {
        nearbyPeersViewController = viewController;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(colorUpdateNotification:) name:@"userSelectedNewColorNotification" object:nil];
        
        [PPKController enableWithConfiguration:@"<YOUR APPLICATION KEY>" observer:self];
    }
    return self;
}

-(void)disable {
    [PPKController disable];
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
    
    [self showErrorDialog:description];
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
    else if (state == PPKPeer2PeerDiscoveryUnauthorized) {
        [self showErrorDialog:@"P2P Discovery cannot run because it is missing a user permission"];
    }
    else if (state == PPKPeer2PeerDiscoveryUnsupported) {
        [self showErrorDialog:@"P2P Discovery is not supported on this device"];
    }
}

#pragma mark - Notifications

-(void)colorUpdateNotification:(NSNotification*)notification {
    
    switch ([PPKController p2pDiscoveryState]) {
            
        case PPKPeer2PeerDiscoveryUnsupported:
        case PPKPeer2PeerDiscoveryUnauthorized:
            break;
            
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

#pragma mark - Helpers

-(void)showErrorDialog:(NSString*)message {
#if TARGET_OS_IOS
    [[[UIAlertView alloc] initWithTitle:@"p2pkit Error" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
#else
    NSAlert *alert = [NSAlert new];
    [alert setMessageText:@"p2pkit Error"];
    [alert setInformativeText:message];
    [alert addButtonWithTitle:@"OK"];
    [alert runModal];
#endif
}

@end
